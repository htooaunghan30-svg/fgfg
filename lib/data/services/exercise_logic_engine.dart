
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import '../models/exercise_log.dart';
import '../models/exercise_model.dart';
import '../../domain/use_cases/validate_form.dart';
import '../../core/constants/exercise_config.dart';

const bool _enableExerciseLogicVerboseLogs = false;
const Object _exerciseStateUnset = Object();

void print(Object? object) {
  if (_enableExerciseLogicVerboseLogs) {
    debugPrint('$object');
  }
}

class ExerciseState {
  final String exerciseId;
  final String phase; // 'up', 'down', 'hold'
  final int repetitions;
  final double currentAccuracy;
  final List<FormWarning> activeWarnings;
  final DateTime? phaseStartTime;
  final Duration? holdDuration;
  final bool isExerciseComplete;

  ExerciseState({
    required this.exerciseId,
    required this.phase,
    required this.repetitions,
    required this.currentAccuracy,
    required this.activeWarnings,
    this.phaseStartTime,
    this.holdDuration,
    this.isExerciseComplete = false,
  });

  ExerciseState copyWith({
    String? phase,
    int? repetitions,
    double? currentAccuracy,
    List<FormWarning>? activeWarnings,
    Object? phaseStartTime = _exerciseStateUnset,
    Object? holdDuration = _exerciseStateUnset,
    bool? isExerciseComplete,
  }) {
    return ExerciseState(
      exerciseId: exerciseId,
      phase: phase ?? this.phase,
      repetitions: repetitions ?? this.repetitions,
      currentAccuracy: currentAccuracy ?? this.currentAccuracy,
      activeWarnings: activeWarnings ?? this.activeWarnings,
      phaseStartTime: identical(phaseStartTime, _exerciseStateUnset)
          ? this.phaseStartTime
          : phaseStartTime as DateTime?,
      holdDuration: identical(holdDuration, _exerciseStateUnset)
          ? this.holdDuration
          : holdDuration as Duration?,
      isExerciseComplete: isExerciseComplete ?? this.isExerciseComplete,
    );
  }
}

class ExerciseLogicEngine {
  final ValidateFormUseCase _validateForm;
  final String _exerciseId;
  final Map<String, dynamic> _exerciseConfig;

  String get exerciseId => _exerciseId;
  Map<String, dynamic> get exerciseConfig => _exerciseConfig;
  ExerciseState get state => _currentState;

  ExerciseState _currentState;
  StreamController<ExerciseState> _stateController;
  Timer? _holdTimer;

  // âœ… Now using RepDetail from exercise_log.dart
  List<RepDetail> _currentRepDetails = [];
  double _currentRepPeakAccuracy = 0.0;

  DateTime? _sessionStartTime;

  // State machine constants
  static const String _phaseUp = 'up';
  static const String _phaseDown = 'down';
  static const String _phaseHold = 'hold';
  static const Duration _noiseBuffer = Duration(milliseconds: 600);
  static const Duration _minRepDuration = Duration(milliseconds: 400);
  static const Duration _maxRepDuration = Duration(seconds: 5);
  static const Duration _repContinuationWindow = Duration(seconds: 28);

  DateTime? _lastRepTime;
  double _lastRecordedAngle = 0.0;
  List<double> _angleHistory = [];
  static const int _historySize = 10;
  double? _currentRepMinAngle;
  double? _currentRepMaxAngle;
  final List<double> _shoulderPressElbowHistory = [];

  // Track per-side elbow angles to choose active side (bicep curl, generic elbow)
  double? _lastLeftElbowAngle;
  double? _lastRightElbowAngle;
  String? _lastSelectedElbowSide;
  static const int _shoulderPressHistorySize = 12;

  // Prevent auto-counting on first frames
  bool _readyForCounting = false;
  int _readyFrameCount = 0;
  static const int _readyFramesRequired = 3;
  static const int _recordingReadyFramesRequired = 3;

  // Push-up false-count protection
  int _pushupDownConfirmFrames = 0;
  int _pushupUpConfirmFrames = 0;
  static const int _pushupConfirmFramesRequired = 3;
  static const int _recordingPushupConfirmFramesRequired = 3;

  // Bench press transition confirmation (kept low for snappier counting)
  int _benchDownConfirmFrames = 0;
  int _benchUpConfirmFrames = 0;
  static const int _benchConfirmFramesRequired = 2;
  static const int _recordingBenchConfirmFramesRequired = 1;
  static const double _pushupUprightRatioThreshold = 1.90;
  static const int _pushupMinRepDurationMs = 1000;
  static const int _pushupMaxRepDurationMs = 4000;
  static const double _pushupMinRange = 8;

  // Full-cycle counting (phase1 -> phase2 -> phase1)
  bool _cycleReachedPhase2 = false;
  DateTime? _cycleStartTime;
  double? _cyclePhase2Accuracy;
  bool _isRecordingMode = false;

  // âœ… Accuracy threshold for rep counting (informational only; not blocking)
  static const double _minAccuracyForRep = 0.5;

  ExerciseLogicEngine({
    required ValidateFormUseCase validateForm,
    required String exerciseId,
    required Map<String, dynamic> exerciseConfig,
  })  : _validateForm = validateForm,
        _exerciseId = exerciseId,
        _exerciseConfig = exerciseConfig,
        _currentState = ExerciseState(
          exerciseId: exerciseId,
          phase: _phaseUp,
          repetitions: 0,
          currentAccuracy: 0.0,
          activeWarnings: [],
          phaseStartTime: DateTime.now(),
        ),
        _stateController = StreamController<ExerciseState>.broadcast() {
    _sessionStartTime = DateTime.now();
  }

  Stream<ExerciseState> get stateStream => _stateController.stream;
  ExerciseState get currentState => _currentState;

  void processFrame({
    required Map<String, double> jointAngles,
    required List<FormWarning> formWarnings,
    required double overallAccuracy,
    bool isRecordingMode = false,
  }) {
    _isRecordingMode = isRecordingMode;
    final now = DateTime.now();
    final exerciseType = _exerciseConfig['type'] as String? ?? 'dynamic';
    if (overallAccuracy < _minAccuracyForRep) {
      print(
          'âš ï¸ Accuracy below threshold: ${(overallAccuracy * 100).toStringAsFixed(1)}%');
    }

    if (exerciseType == 'dynamic') {
      _enforceRepContinuationWindow(now);
      _processDynamicExercise(
        jointAngles: jointAngles,
        formWarnings: formWarnings,
        overallAccuracy: overallAccuracy,
      );
    } else {
      _processStaticExercise(
        jointAngles: jointAngles,
        formWarnings: formWarnings,
        overallAccuracy: overallAccuracy,
      );
    }

    _emitStateUpdate();
  }

  int get _effectiveReadyFramesRequired => _isRecordingMode
      ? _recordingReadyFramesRequired
      : _readyFramesRequired;

  int get _effectivePushupConfirmFramesRequired => _isRecordingMode
      ? _recordingPushupConfirmFramesRequired
      : _pushupConfirmFramesRequired;

  int get _effectiveBenchConfirmFramesRequired => _isRecordingMode
      ? _recordingBenchConfirmFramesRequired
      : _benchConfirmFramesRequired;

  void _enforceRepContinuationWindow(DateTime now) {
    final lastRepTime = _lastRepTime;
    if (lastRepTime == null || _currentState.repetitions <= 0) {
      return;
    }

    final gap = now.difference(lastRepTime);
    if (gap <= _repContinuationWindow) {
      return;
    }

    // If the user pauses too long between reps, discard the current chain and
    // restart counting from zero.
    _currentRepDetails.clear();
    _angleHistory.clear();
    _shoulderPressElbowHistory.clear();

    _currentRepPeakAccuracy = 0.0;
    _currentRepMinAngle = null;
    _currentRepMaxAngle = null;
    _lastRepTime = null;

    _readyForCounting = false;
    _readyFrameCount = 0;
    _pushupDownConfirmFrames = 0;
    _pushupUpConfirmFrames = 0;
    _benchDownConfirmFrames = 0;
    _benchUpConfirmFrames = 0;
    _situpArmed = false;
    _situpBaselineFrames = 0;
    _resetCycleTracking();

    _currentState = _currentState.copyWith(
      phase: _phaseUp,
      repetitions: 0,
      phaseStartTime: now,
      holdDuration: null,
      currentAccuracy: 0.0,
      activeWarnings: const [],
    );
  }

  int _uprightConfirmFrames =
      0; // class á€¡á€†á€„á€·á€ºá€™á€¾á€¬ á€‘á€Šá€·á€ºá€›á€”á€º (á€¡á€á€¼á€¬á€¸ variable á€á€½á€±á€”á€²á€·á€¡á€á€°)

  void _processDynamicExercise({
    required Map<String, double> jointAngles,
    required List<FormWarning> formWarnings,
    required double overallAccuracy,
  }) {
 

    final repLogic = _resolveRepLogic();
    if (repLogic == null) return;

    final primaryJoint = repLogic['primary_joint'] as String? ?? 'knee';
    final alternativeJoints = (repLogic['alternative_joints'] as List?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    final phase1 = repLogic['phase_1_eccentric'] as Map<String, dynamic>?;
    final phase2 = repLogic['phase_2_concentric'] as Map<String, dynamic>?;

    if (phase1 == null || phase2 == null) return;

    double? currentAngle = _selectJointAngle(
      primaryJoint: primaryJoint,
      alternativeJoints: alternativeJoints,
      jointAngles: jointAngles,
    );
    if (_exerciseId == 'shoulder_press') {
      final elbowAngle = _selectJointAngle(
        primaryJoint: 'elbow',
        alternativeJoints: const ['left_elbow', 'right_elbow'],
        jointAngles: jointAngles,
      );
      if (elbowAngle != null && elbowAngle > 0) {
        _shoulderPressElbowHistory.add(elbowAngle);
        if (_shoulderPressElbowHistory.length > _shoulderPressHistorySize) {
          _shoulderPressElbowHistory.removeAt(0);
        }
      }

      final elbowRaised = jointAngles['elbow_raised'];
      final double? fallbackAngle =
          elbowRaised == null ? null : (elbowRaised >= 0.5 ? 170.0 : 80.0);
      if (fallbackAngle != null) {
        bool elbowAngleFlat = false;
        if (_shoulderPressElbowHistory.length >= 6) {
          final minAngle = _shoulderPressElbowHistory.reduce(min);
          final maxAngle = _shoulderPressElbowHistory.reduce(max);
          elbowAngleFlat = (maxAngle - minAngle) < 12.0;
        }
        if (currentAngle == null || currentAngle <= 0 || elbowAngleFlat) {
          currentAngle = fallbackAngle;
        }
      }
    }
    if (currentAngle == null) {
      return;
    }
    final phase1Threshold = (phase1['threshold'] as num?)?.toDouble() ?? 170.0;
    final phase2Threshold = (phase2['threshold'] as num?)?.toDouble() ?? 80.0;

    final now = DateTime.now();

    // Apply noise filtering
    final filteredAngle = _applyNoiseFilter(currentAngle);
    final pushupTorsoUprightRatio = jointAngles['torso_upright_ratio'] ?? 0.0;
    final frameAccuracy = _exerciseId == 'bench_press'
        ? _computeBenchPressDirectionalAccuracy(
            filteredAngle: filteredAngle,
            phase1Threshold: phase1Threshold,
            phase2Threshold: phase2Threshold,
            jointAngles: jointAngles,
            fallbackAccuracy: overallAccuracy,
          )
        : overallAccuracy;

    if (_exerciseId == 'situp') {
      if (_isSitupStandingLike(jointAngles)) {
        _situpArmed = false;
        _situpBaselineFrames = 0;
        _abortCurrentDynamicRep(
          angle: filteredAngle,
          timestamp: now,
          warnings: formWarnings,
          accuracy: frameAccuracy,
        );
        return;
      }

      if (!_situpArmed) {
        if (_isSitupClearLyingBaseline(jointAngles, filteredAngle)) {
          _situpBaselineFrames++;
          if (_situpBaselineFrames >= _situpBaselineFramesRequired) {
            _situpArmed = true;
            _situpBaselineFrames = _situpBaselineFramesRequired;
            _currentState = _currentState.copyWith(
              phase: _phaseUp,
              phaseStartTime: now,
              currentAccuracy: frameAccuracy,
              activeWarnings: formWarnings,
            );
          }
        } else {
          _situpBaselineFrames = 0;
        }

        if (!_situpArmed) {
          _currentState = _currentState.copyWith(
            currentAccuracy: frameAccuracy,
            activeWarnings: formWarnings,
          );
          return;
        }
      }
    }

    // Leg extension: block counting unless user is seated (avoid standing up
    // accidentally counting a rep).
    if (_exerciseId == 'leg_extension') {
      const double seatedHipAngleMax = 125.0;
      const double standingKneeAngle = 160.0;
      const double standingHipAngle = 150.0;
      const double frontViewRatioThreshold = 0.35;
      const double frontViewStandingKnee = 150.0;
      const double frontViewStandingHip = 155.0;

      final double? hipAngle =
          jointAngles['hip'] ?? jointAngles['left_hip'] ?? jointAngles['right_hip'];
      final double frontViewRatio = jointAngles['front_view_ratio'] ?? 0.0;
      final bool isFrontView = frontViewRatio >= frontViewRatioThreshold;

      final bool hasHipAngle = hipAngle != null && hipAngle > 0.0;
      final bool isStanding = hasHipAngle &&
          ((hipAngle >= standingHipAngle && filteredAngle >= standingKneeAngle) ||
              (isFrontView &&
                  hipAngle >= frontViewStandingHip &&
                  filteredAngle >= frontViewStandingKnee));
      final bool isSeated = hasHipAngle && hipAngle <= seatedHipAngleMax;

      if (hasHipAngle && (!isSeated || isStanding)) {
        _readyForCounting = false;
        _readyFrameCount = 0;
        _abortCurrentDynamicRep(
          angle: filteredAngle,
          timestamp: now,
          warnings: formWarnings,
          accuracy: frameAccuracy,
        );
        return;
      }
    }

   
    if (_exerciseId == 'pushup' &&
        pushupTorsoUprightRatio > 0 &&
        pushupTorsoUprightRatio >= _pushupUprightRatioThreshold) {
      _abortCurrentDynamicRep(
        angle: filteredAngle,
        timestamp: now,
        warnings: formWarnings,
        accuracy: frameAccuracy,
      ); // á€á€»á€€á€ºá€á€»á€„á€ºá€¸ á€›á€•á€ºá€œá€­á€¯á€€á€º
      return;
    }

    // Require a stable "up" start position before counting any reps
    if ((_exerciseId == 'squat' ||
            _exerciseId == 'leg_extension' ||
            _exerciseId == 'pushup') &&
        !_readyForCounting) {
      if (_exerciseId == 'leg_extension') {
        final bool inUp = filteredAngle >= phase2Threshold;
        final bool inDown = filteredAngle <= phase1Threshold;

        if (inUp || inDown) {
          _readyFrameCount++;
        } else {
          _readyFrameCount = 0;
        }

        if (_readyFrameCount >= _effectiveReadyFramesRequired) {
          _readyForCounting = true;
          if (inDown) {
            // Seed the first rep while seated and flexed so the first
            // full cycle (down -> up -> down) counts correctly.
            _transitionToDown(
              angle: filteredAngle,
              timestamp: now,
              warnings: formWarnings,
              accuracy: frameAccuracy,
            );
          } else {
            _currentState = _currentState.copyWith(
              phase: _phaseUp,
              phaseStartTime: now,
            );
          }
        } else {
          _currentState = _currentState.copyWith(
            currentAccuracy: frameAccuracy,
            activeWarnings: formWarnings,
          );
          return;
        }
      } else {
        if (filteredAngle >= phase2Threshold) {
          _readyFrameCount++;
        } else {
          _readyFrameCount = 0;
        }
        if (_readyFrameCount >= _effectiveReadyFramesRequired) {
          _readyForCounting = true;
          _currentState = _currentState.copyWith(
            phase: _phaseUp,
            phaseStartTime: now,
          );
        } else {
          _currentState = _currentState.copyWith(
            currentAccuracy: frameAccuracy,
            activeWarnings: formWarnings,
          );
          return;
        }
      }
    }

    print('ðŸ¦µ $primaryJoint angle: ${filteredAngle.toStringAsFixed(1)}Â°');
    print('ðŸŽ¯ Accuracy: ${(frameAccuracy * 100).toStringAsFixed(1)}%');

    
    switch (_currentState.phase) {
      case _phaseUp:
        // SIT-UP: Sitting (Up) -> Lying (Down)
        // Angle á€€ á€€á€¼á€®á€¸á€œá€¬á€›á€™á€šá€º (á€¥á€•á€™á€¬ 90 -> 180)

        // âŒ á€™á€¾á€¬á€¸á€”á€±á€žá€±á€¬ Code á€¡á€Ÿá€±á€¬á€„á€ºá€¸ (Velocity Check á€€á€­á€¯ á€–á€šá€ºá€œá€­á€¯á€€á€ºá€•á€«)

        // âœ… á€¡á€žá€…á€ºá€•á€¼á€„á€ºá€†á€„á€ºá€‘á€¬á€¸á€žá€±á€¬ Code
        bool isTransitioningDown = false;

        if (_exerciseId == 'situp') {
          // Situp á€¡á€á€½á€€á€º: Angle á€€ Threshold (á€¥á€•á€™á€¬ 140) á€‘á€€á€º á€€á€»á€±á€¬á€ºá€žá€½á€¬á€¸á€›á€„á€º á€œá€¾á€²á€”á€±á€•á€¼á€®á€œá€­á€¯á€· á€šá€°á€†á€™á€šá€º
          if (filteredAngle > phase1Threshold) {
            isTransitioningDown = true;
          }
        } else {
          // á€¡á€á€¼á€¬á€¸ Exercise á€™á€»á€¬á€¸ (Squat/Pushup) á€¡á€á€½á€€á€º á€™á€°á€œ Logic
          if (_evaluatePhaseCondition(
            phase: phase1,
            angle: filteredAngle,
            defaultLessThan: true,
            fallbackThreshold: phase1Threshold,
          )) {
            isTransitioningDown = true;
          }
        }

        if (_exerciseId == 'pushup') {
          if (isTransitioningDown) {
            _pushupDownConfirmFrames++;
          } else {
            _pushupDownConfirmFrames = 0;
          }
          isTransitioningDown =
              _pushupDownConfirmFrames >= _effectivePushupConfirmFramesRequired;
        }
        if (_exerciseId == 'bench_press') {
          if (isTransitioningDown) {
            _benchDownConfirmFrames++;
          } else {
            _benchDownConfirmFrames = 0;
          }
          isTransitioningDown =
              _benchDownConfirmFrames >= _effectiveBenchConfirmFramesRequired;
        }

        if (isTransitioningDown) {
          if (_exerciseId == 'pushup') {
            _pushupDownConfirmFrames = 0;
            _pushupUpConfirmFrames = 0;
          }
          if (_exerciseId == 'bench_press') {
            _benchDownConfirmFrames = 0;
            _benchUpConfirmFrames = 0;
          }
          if (_requiresFullCycle && _cycleReachedPhase2) {
            if (_cycleStartTime != null) {
              _completeRepetition(
                angle: filteredAngle,
                timestamp: now,
                warnings: formWarnings,
                accuracy: _cyclePhase2Accuracy ?? frameAccuracy,
                cycleStartTime: _cycleStartTime,
              );
            }
            _resetCycleTracking();
          }
          _transitionToDown(
            angle: filteredAngle,
            timestamp: now,
            warnings: formWarnings,
            accuracy: frameAccuracy,
          );
        }
        break;

      case _phaseDown:
        // SIT-UP: Lying (Down) -> Sitting (Up)
        // Angle á€€ á€„á€šá€ºá€žá€½á€¬á€¸á€›á€™á€šá€º (á€¥á€•á€™á€¬ 180 -> 90)

        // Tracking Min/Max angles for range check
        _currentRepMinAngle = _currentRepMinAngle == null
            ? filteredAngle
            : min(_currentRepMinAngle!, filteredAngle);
        _currentRepMaxAngle = _currentRepMaxAngle == null
            ? filteredAngle
            : max(_currentRepMaxAngle!, filteredAngle);

        bool isTransitioningUp = false;

        if (_exerciseId == 'situp') {
          // Situp á€¡á€á€½á€€á€º: Angle á€€ Threshold (á€¥á€•á€™á€¬ 90) á€¡á€±á€¬á€€á€º á€›á€±á€¬á€€á€ºá€žá€½á€¬á€¸á€›á€„á€º á€‘á€œá€¬á€•á€¼á€®á€œá€­á€¯á€· á€šá€°á€†á€™á€šá€º
          if (filteredAngle < phase2Threshold) {
            // Range Check (Optional but good)
            final range = (_currentRepMaxAngle ?? 180) - filteredAngle;
            if (range > 45) {
              // á€¡á€”á€Šá€ºá€¸á€†á€¯á€¶á€¸ 30 á€’á€®á€‚á€›á€® á€œá€¾á€¯á€•á€ºá€›á€¾á€¬á€¸á€™á€¾
              isTransitioningUp = true;
            }
          }
        } else {
          // á€¡á€á€¼á€¬á€¸ Exercise á€™á€»á€¬á€¸á€¡á€á€½á€€á€º
          if (_evaluatePhaseCondition(
            phase: phase2,
            angle: filteredAngle,
            defaultLessThan: false,
            fallbackThreshold: phase2Threshold,
          )) {
            isTransitioningUp = true;
          }
        }

        if (_exerciseId == 'pushup') {
          if (isTransitioningUp) {
            _pushupUpConfirmFrames++;
          } else {
            _pushupUpConfirmFrames = 0;
          }
          isTransitioningUp =
              _pushupUpConfirmFrames >= _effectivePushupConfirmFramesRequired;
        }
        if (_exerciseId == 'bench_press') {
          if (isTransitioningUp) {
            _benchUpConfirmFrames++;
          } else {
            _benchUpConfirmFrames = 0;
          }
          isTransitioningUp =
              _benchUpConfirmFrames >= _effectiveBenchConfirmFramesRequired;
        }

        if (_exerciseId == 'bench_press' &&
            isTransitioningUp &&
            _isBenchPressWrongDirectionAtTop(
              jointAngles: jointAngles,
              filteredAngle: filteredAngle,
              phase2Threshold: phase2Threshold,
            )) {
          isTransitioningUp = false;
        }

        if (isTransitioningUp) {
          if (_exerciseId == 'pushup') {
            _pushupUpConfirmFrames = 0;
          }
          if (_exerciseId == 'bench_press') {
            _benchUpConfirmFrames = 0;
          }
          if (_requiresFullCycle) {
            _cycleReachedPhase2 = true;
            _cyclePhase2Accuracy = frameAccuracy;
            _transitionToUp(
              angle: filteredAngle,
              timestamp: now,
              warnings: formWarnings,
              accuracy: frameAccuracy,
              preserveRepRange: true,
            );
          } else {
            _completeRepetition(
              angle: filteredAngle,
              timestamp: now,
              warnings: formWarnings,
              accuracy: frameAccuracy,
            );
          }
        }
        break;
    }

    // Last recorded angle update
    _lastRecordedAngle = filteredAngle;

    _currentState = _currentState.copyWith(
      currentAccuracy: frameAccuracy,
      activeWarnings: formWarnings,
    );

    if (_currentState.phase == _phaseDown &&
        frameAccuracy > _currentRepPeakAccuracy) {
      _currentRepPeakAccuracy = frameAccuracy;
    }
  }

  int _situpRepAttempts = 0;
  static const int _maxSitupAttemptsWithoutProgress = 3;

  // Motion direction tracking for sit-up
  String _lastMotionDirection = 'none';
  List<double> _situpAngleHistory = [];
  static const int _situpHistorySize = 20;
  bool _situpArmed = false;
  int _situpBaselineFrames = 0;
  static const int _situpBaselineFramesRequired = 3;
  static const double _situpStandingTorsoRatioThreshold = 1.45;
  static const double _situpLyingTorsoRatioMax = 1.15;

  bool _isValidSitupMotion({
    required double startAngle,
    required double currentAngle,
    required String direction,
  }) {
    // Check motion direction
    final angleChange = currentAngle - startAngle;

    if (direction == 'down') {
      // Going down (lying back) - angle should increase
      return angleChange > 5.0; // At least 5Â° increase
    } else {
      // Going up (sitting up) - angle should decrease
      return angleChange < -5.0; // At least 5Â° decrease
    }
  }

  bool _checkSitupMotionQuality({
    required double minAngle,
    required double maxAngle,
    required Duration duration,
  }) {
    // Check for smooth motion
    if (_angleHistory.length < 5) return true;

    // Calculate consistency of motion
    int directionChanges = 0;
    for (int i = 1; i < _angleHistory.length - 1; i++) {
      final prevToCurrent = _angleHistory[i] - _angleHistory[i - 1];
      final currentToNext = _angleHistory[i + 1] - _angleHistory[i];

      // Check if direction changes (going up vs down)
      if (prevToCurrent > 0 && currentToNext < 0) directionChanges++;
      if (prevToCurrent < 0 && currentToNext > 0) directionChanges++;
    }

    // Too many direction changes means shaky motion
    if (directionChanges > 3) {
      print('âš ï¸ Sit-up motion too shaky: $directionChanges direction changes');
      return false;
    }

    // Check speed consistency
    final avgSpeed = (maxAngle - minAngle) / (duration.inMilliseconds / 1000);
    if (avgSpeed < 20.0 || avgSpeed > 120.0) {
      print('âš ï¸ Sit-up speed out of range: ${avgSpeed.toStringAsFixed(1)}Â°/s');
      return false;
    }

    return true;
  }

  bool _isSitupStandingLike(Map<String, double> jointAngles) {
    final double? hipAngle =
        jointAngles['hip'] ?? jointAngles['left_hip'] ?? jointAngles['right_hip'];
    final double? kneeAngle =
        jointAngles['knee'] ?? jointAngles['left_knee'] ?? jointAngles['right_knee'];
    final double torsoUprightRatio = jointAngles['torso_upright_ratio'] ?? 0.0;

    return hipAngle != null &&
        kneeAngle != null &&
        hipAngle >= 150.0 &&
        kneeAngle >= 150.0 &&
        torsoUprightRatio >= _situpStandingTorsoRatioThreshold;
  }

  bool _isSitupClearLyingBaseline(
    Map<String, double> jointAngles,
    double filteredAngle,
  ) {
    final double? hipAngle =
        jointAngles['hip'] ?? jointAngles['left_hip'] ?? jointAngles['right_hip'];
    final double? kneeAngle =
        jointAngles['knee'] ?? jointAngles['left_knee'] ?? jointAngles['right_knee'];
    final double torsoUprightRatio = jointAngles['torso_upright_ratio'] ?? 0.0;
    final bool hasTorsoRatio = torsoUprightRatio > 0.0;

    return hipAngle != null &&
        kneeAngle != null &&
        filteredAngle >= 145.0 &&
        hipAngle >= 145.0 &&
        kneeAngle >= 125.0 &&
        (!hasTorsoRatio || torsoUprightRatio <= _situpLyingTorsoRatioMax);
  }

  double _normalizeBenchPressElbowAngle(double rawAngle) {
    if (rawAngle <= 0.0) return 0.0;
    if (rawAngle < 45.0) {
      return (180.0 - rawAngle).clamp(0.0, 180.0).toDouble();
    }
    return rawAngle.clamp(0.0, 180.0).toDouble();
  }

  bool _isBenchPressWrongDirectionAtTop({
    required Map<String, double> jointAngles,
    required double filteredAngle,
    required double phase2Threshold,
  }) {
    if (filteredAngle < (phase2Threshold - 3.0)) {
      return false;
    }

    final verticalLift = jointAngles['bench_press_vertical_lift'] ?? 0.0;
    final wristLiftRatio = jointAngles['bench_press_wrist_lift_ratio'] ?? 0.0;
    final pressPerpendicularity =
        jointAngles['bench_press_press_perpendicularity'] ?? 0.0;
    final verticalDeviationDegrees =
        jointAngles['bench_press_vertical_deviation_degrees'] ?? 90.0;
    final forearmVerticalDeviationDegrees =
        jointAngles['bench_press_forearm_vertical_deviation_degrees'] ?? 90.0;
    final topPathValid = (jointAngles['bench_press_top_path_valid'] ?? 0.0) >= 0.5;
    final deviationQuality = ((1.0 - (verticalDeviationDegrees / 76.0))
                .clamp(0.0, 1.0) *
            0.55) +
        ((1.0 - (forearmVerticalDeviationDegrees / 80.0)).clamp(0.0, 1.0) * 0.45);
    final pathQuality = ((verticalLift.clamp(0.0, 1.0) * 0.30) +
            ((wristLiftRatio * 8.0).clamp(0.0, 1.0) * 0.30) +
            (pressPerpendicularity.clamp(0.0, 1.0) * 0.20) +
            (deviationQuality * 0.20))
        .clamp(0.0, 1.0);

    if (topPathValid) {
      return false;
    }

    if (pathQuality < 0.20) {
      return true;
    }

    return (verticalLift < 0.010 &&
            wristLiftRatio < 0.015 &&
            pressPerpendicularity < 0.08) ||
        (verticalDeviationDegrees > 68.0 &&
            forearmVerticalDeviationDegrees > 72.0 &&
            wristLiftRatio < 0.015);
  }

  double _computeBenchPressDirectionalAccuracy({
    required double filteredAngle,
    required double phase1Threshold,
    required double phase2Threshold,
    required Map<String, double> jointAngles,
    required double fallbackAccuracy,
  }) {
    final range = max(phase2Threshold - phase1Threshold, 1.0);
    final extensionProgress =
        ((filteredAngle - phase1Threshold) / range).clamp(0.0, 1.0).toDouble();

    final verticalLift = (jointAngles['bench_press_vertical_lift'] ?? 0.0)
        .clamp(0.0, 1.0)
        .toDouble();
    final wristLiftRatio = (jointAngles['bench_press_wrist_lift_ratio'] ?? 0.0)
        .clamp(0.0, 1.0)
        .toDouble();
    final pressPerpendicularity =
        (jointAngles['bench_press_press_perpendicularity'] ?? 0.0)
            .clamp(0.0, 1.0)
            .toDouble();
    final verticalDeviationDegrees =
        (jointAngles['bench_press_vertical_deviation_degrees'] ?? 90.0)
            .clamp(0.0, 90.0)
            .toDouble();
    final forearmVerticalDeviationDegrees =
        (jointAngles['bench_press_forearm_vertical_deviation_degrees'] ?? 90.0)
            .clamp(0.0, 90.0)
            .toDouble();
    final topPathValid =
        (jointAngles['bench_press_top_path_valid'] ?? 0.0) >= 0.5 ? 1.0 : 0.0;

    final liftScore = (verticalLift * 0.45) +
        ((wristLiftRatio * 8.0).clamp(0.0, 1.0) * 0.35) +
        (pressPerpendicularity * 0.20);
    final deviationMean =
        (verticalDeviationDegrees + forearmVerticalDeviationDegrees) / 2.0;
    final yAxisToleranceScore =
        (1.0 - (deviationMean / 72.0)).clamp(0.0, 1.0).toDouble();
    
    double pathScore =
        ((liftScore * 0.55) + (yAxisToleranceScore * 0.45)).clamp(0.0, 1.0);

    // Provide a bonus if the hand is lifted mostly straight up (near Y-axis)
    // with good extension. This stops accuracy from dropping when form is ideal.
    if (verticalLift >= 0.8 && verticalDeviationDegrees <= 15.0) {
      pathScore = (pathScore + 0.15).clamp(0.0, 1.0);
    }

    final pathConfidence =
        topPathValid > 0.0 ? pathScore : max(pathScore * 0.92 + 0.02, verticalLift * 0.90);

    final directionalAccuracy =
        ((extensionProgress * 0.60) + (pathConfidence * 0.40))
            .clamp(0.05, 0.99)
            .toDouble();

    // Keep bench scoring monotonic with extension: higher elbow extension
    // should not be dragged down by an opposite fallback trend.
    if (fallbackAccuracy <= directionalAccuracy) {
      return ((directionalAccuracy * 0.92) + (fallbackAccuracy * 0.08))
          .clamp(0.05, 0.99)
          .toDouble();
    }
    return directionalAccuracy;
  }


  void _processStaticExercise({
    required Map<String, double> jointAngles,
    required List<FormWarning> formWarnings,
    required double overallAccuracy,
  }) {
    // Static exercises use time-based counting with the same accuracy gate.
    if (overallAccuracy < _minAccuracyForRep) {
      print(
          'âš ï¸ Accuracy below threshold for static exercise: ${(overallAccuracy * 100).toStringAsFixed(1)}%');

      // Accuracy á€”á€­á€™á€·á€ºá€”á€±á€•á€«á€€ hold state á€€á€­á€¯á€›á€•á€ºá€á€”á€·á€ºá€›á€”á€º
      if (_currentState.phase == _phaseHold) {
        final now = DateTime.now();
        _transitionFromHold(
          timestamp: now,
          warnings: formWarnings,
          accuracy: overallAccuracy,
        );
      }
      return;
    }

    final repLogic = _resolveRepLogic();
    if (repLogic == null) return;

    final holdCondition = repLogic['hold_condition'] as Map<String, dynamic>?;
    if (holdCondition == null) return;

    bool isInPosition = true;
    int conditionsMet = 0;
    int totalConditions = holdCondition.length;

    // Hold á€¡á€”á€±á€¡á€‘á€¬á€¸á€¡á€¬á€¸á€œá€¯á€¶á€¸á€€á€­á€¯á€…á€…á€ºá€†á€±á€¸á€á€¼á€„á€ºá€¸
    holdCondition.forEach((conditionKey, range) {
      final rangeMap = range as Map<String, dynamic>;
      final minAngle = (rangeMap['min'] as num?)?.toDouble() ?? 0.0;
      final maxAngle = (rangeMap['max'] as num?)?.toDouble() ?? 180.0;

      // Joint name á€€á€­á€¯á€–á€±á€¬á€ºá€‘á€¯á€á€ºá€á€¼á€„á€ºá€¸
      final angle = _resolveHoldAngle(conditionKey, jointAngles) ?? 0.0;

      final isConditionMet = (angle >= minAngle && angle <= maxAngle);
      isInPosition = isInPosition && isConditionMet;

      if (isConditionMet) {
        conditionsMet++;
      }

      print(
          'ðŸ“ $conditionKey: ${angle.toStringAsFixed(1)}Â° (target: $minAngle-$maxAngleÂ°) - ${isConditionMet ? "âœ…" : "âŒ"}');
    });

    final now = DateTime.now();
    if (isInPosition) {
      if (_currentState.phase == _phaseHold) {
        final holdStart = _currentState.phaseStartTime ?? now;
        final holdDuration = now.difference(holdStart);
        _currentState = _currentState.copyWith(
          holdDuration: holdDuration,
          currentAccuracy: overallAccuracy,
          activeWarnings: formWarnings,
        );
        final secondsHeld = holdDuration.inSeconds;
        if (secondsHeld % 10 == 0 && secondsHeld > 0) {
          final repsFromHolding = secondsHeld ~/ 10;
          if (repsFromHolding > _currentState.repetitions) {
            _currentState = _currentState.copyWith(
              repetitions: repsFromHolding,
            );
            print('Hold rep counted! Total: $repsFromHolding');
          }
        }
        if (_holdTimer == null) {
          _startHoldTimer();
        }
      } else {
        _transitionToHold(
          timestamp: now,
          warnings: formWarnings,
          accuracy: overallAccuracy,
        );
      }
    } else if (_currentState.phase == _phaseHold) {
      _transitionFromHold(
        timestamp: now,
        warnings: formWarnings,
        accuracy: overallAccuracy,
      );
    }
    _emitStateUpdate();
  }

  double _applyNoiseFilter(double currentAngle) {
    _angleHistory.add(currentAngle);
    if (_angleHistory.length > _historySize) {
      _angleHistory.removeAt(0);
    }

    if (_angleHistory.isEmpty) return currentAngle;

    final sum = _angleHistory.fold(0.0, (total, angle) => total + angle);
    return sum / _angleHistory.length;
  }

  Map<String, dynamic>? _resolveRepLogic() {
    Map<String, dynamic>? repLogic;
    final rawRepLogic =
        _exerciseConfig['rep_logic'] ?? _exerciseConfig['repLogic'];
    if (rawRepLogic is Map<String, dynamic>) {
      repLogic = rawRepLogic;
    } else if (rawRepLogic is RepLogic) {
      repLogic = _repLogicToMap(rawRepLogic);
    }

    if (repLogic == null) {
      try {
        final fallbackConfig = ExerciseConfig.getExerciseById(_exerciseId);
        repLogic = fallbackConfig['rep_logic'] as Map<String, dynamic>?;
      } catch (_) {
        // Keep null if not found.
      }
    }

    if (repLogic != null) {
      repLogic = Map<String, dynamic>.from(repLogic);
      if (!repLogic.containsKey('phase_1_eccentric') &&
          repLogic.containsKey('phase_1_concentric')) {
        repLogic['phase_1_eccentric'] = repLogic['phase_1_concentric'];
      }
      if (!repLogic.containsKey('phase_2_concentric') &&
          repLogic.containsKey('phase_2_eccentric')) {
        repLogic['phase_2_concentric'] = repLogic['phase_2_eccentric'];
      }
    }

    if (repLogic != null && !repLogic.containsKey('alternative_joints')) {
      final derivedAlternatives =
          _deriveAlternativeJoints(repLogic['primary_joint'] as String?);
      if (derivedAlternatives.isNotEmpty) {
        repLogic['alternative_joints'] = derivedAlternatives;
      }
    }

    if (repLogic != null && _exerciseId == 'bicep_curl') {
      repLogic = _applyBicepCurlRepLogic(repLogic);
    }
    if (repLogic != null && _exerciseId == 'shoulder_press') {
      repLogic = _applyShoulderPressRepLogic(repLogic);
    }
    if (repLogic != null && _exerciseId == 'bench_press') {
      repLogic = _applyBenchPressRepLogic(repLogic);
    }
    if (repLogic != null && _exerciseId == 'situp') {
      repLogic = _applySitupRepLogic(repLogic);
    }

    return repLogic;
  }

  Map<String, dynamic> _repLogicToMap(RepLogic repLogic) {
    final result = <String, dynamic>{
      'primary_joint': repLogic.primaryJoint,
      'count_type': repLogic.countType,
    };
    if (repLogic.phase1Eccentric != null) {
      result['phase_1_eccentric'] = {
        'condition': repLogic.phase1Eccentric!.condition,
        'description': repLogic.phase1Eccentric!.description,
        'threshold': repLogic.phase1Eccentric!.threshold,
      };
    }
    if (repLogic.phase2Concentric != null) {
      result['phase_2_concentric'] = {
        'condition': repLogic.phase2Concentric!.condition,
        'description': repLogic.phase2Concentric!.description,
        'threshold': repLogic.phase2Concentric!.threshold,
      };
    }
    if (repLogic.holdCondition != null) {
      result['hold_condition'] = {
        'knee_angle': {
          'min': repLogic.holdCondition!.minKneeAngle,
          'max': repLogic.holdCondition!.maxKneeAngle,
        },
        'back_angle': {
          'min': repLogic.holdCondition!.minBackAngle,
          'max': repLogic.holdCondition!.maxBackAngle,
        },
      };
    }
    return result;
  }

// _applySitupRepLogic method á€€á€­á€¯á€•á€¼á€„á€ºá€†á€„á€ºá€•á€«
  Map<String, dynamic> _applySitupRepLogic(
    Map<String, dynamic> repLogic,
  ) {
    final normalized = Map<String, dynamic>.from(repLogic);

    // Sit-up á€¡á€á€½á€€á€º á€›á€­á€¯á€¸á€›á€¾á€„á€ºá€¸á€•á€¼á€®á€¸á€™á€¾á€”á€ºá€€á€”á€ºá€žá€±á€¬ configuration
    normalized['primary_joint'] = 'shoulder_hip_knee';
    normalized['alternative_joints'] = const [
      'hip',
      'back_angle',
      'torso_angle'
    ];

    // âœ… á€›á€­á€¯á€¸á€›á€¾á€„á€ºá€¸á€•á€¼á€®á€¸á€™á€¾á€”á€ºá€€á€”á€ºá€žá€±á€¬ phase logic
    // á€œá€¾á€²á€”á€±á€á€»á€­á€”á€º (Lying down): angle > 150Â°
    // á€‘á€­á€¯á€„á€ºá€”á€±á€á€»á€­á€”á€º (Sitting up): angle < 100Â°

    final phase1 = {
      'threshold': 132.0, // á€œá€¾á€²á€”á€±á€á€šá€ºá€œá€­á€¯á€· á€žá€á€ºá€™á€¾á€á€º (angle > 150)
      'condition': 'angle > 134',
      'description': 'Lying Down Position',
      'min_value': 140.0,
      'max_value': 180.0
    };

    final phase2 = {
      'threshold': 92.0, // á€‘á€­á€¯á€„á€ºá€”á€±á€á€šá€ºá€œá€­á€¯á€· á€žá€á€ºá€™á€¾á€á€º (angle < 100)
      'condition': 'angle < 92',
      'description': 'Sitting Up Position',
      'min_value': 60.0,
      'max_value': 120.0
    };

    normalized['phase_1_eccentric'] = phase1;
    normalized['phase_2_concentric'] = phase2;

    // Sit-up á€¡á€á€½á€€á€º á€¡á€›á€±á€¸á€€á€¼á€®á€¸á€žá€±á€¬ parameters
    normalized['situp_settings'] = {
      'min_range_of_motion': 35.0, // á€¡á€”á€Šá€ºá€¸á€†á€¯á€¶á€¸ 40Â° á€œá€¾á€¯á€•á€ºá€›á€¾á€¬á€¸á€™á€¾á€¯
      'min_rep_duration_ms': 1000, // á€¡á€”á€Šá€ºá€¸á€†á€¯á€¶á€¸ 0.8 á€…á€€á€¹á€€á€”á€·á€º
      'max_rep_duration_ms': 5000, // á€¡á€™á€»á€¬á€¸á€†á€¯á€¶á€¸ 5 á€…á€€á€¹á€€á€”á€·á€º
      'require_stable_start': true, // á€…á€á€»á€­á€”á€ºá€™á€¾á€¬ á€á€Šá€ºá€„á€¼á€­á€™á€ºá€™á€¾á€¯á€œá€­á€¯á€¡á€•á€º
      'noise_buffer_ms': 1800, // Noise filter
    };

    // âœ… Counting logic á€€á€­á€¯á€›á€­á€¯á€¸á€›á€¾á€„á€ºá€¸á€¡á€±á€¬á€„á€ºá€œá€¯á€•á€ºá€•á€«
    normalized['counting_logic'] = {
      'count_type': 'cycle', // á€á€…á€ºá€€á€¼á€±á€¬á€·á€•á€¼á€Šá€·á€ºá€™á€¾ count
      'reset_on_pause': true, // á€›á€•á€ºá€œá€­á€¯á€€á€ºá€›á€„á€º reset
      'auto_reset_after_ms': 1200, // 3 á€…á€€á€¹á€€á€”á€·á€ºá€€á€¼á€¬á€›á€„á€º auto reset
    };

    return normalized;
  }

  List<String> _deriveAlternativeJoints(String? primaryJoint) {
    if (primaryJoint == null || primaryJoint.isEmpty) return const [];
    switch (primaryJoint) {
      case 'knee':
        return const ['left_knee', 'right_knee'];
      case 'hip':
        return const ['left_hip', 'right_hip'];
      case 'elbow':
        return const ['left_elbow', 'right_elbow'];
      case 'shoulder':
        return const ['left_shoulder', 'right_shoulder'];
      case 'ankle':
        return const ['left_ankle', 'right_ankle'];
      case 'wrist':
        return const ['left_wrist', 'right_wrist'];
      default:
        return const [];
    }
  }

  Map<String, dynamic> _applyBicepCurlRepLogic(
    Map<String, dynamic> repLogic,
  ) {
    final normalized = Map<String, dynamic>.from(repLogic);

    normalized['primary_joint'] = 'elbow';

    final phase1Raw = normalized['phase_1_eccentric'] as Map<String, dynamic>?;
    final phase2Raw = normalized['phase_2_concentric'] as Map<String, dynamic>?;

    final phase1 = Map<String, dynamic>.from(phase1Raw ?? {});
    final phase2 = Map<String, dynamic>.from(phase2Raw ?? {});

    final double phase1Threshold =
        (phase1['threshold'] as num?)?.toDouble() ?? 90.0;
    final double phase2Threshold =
        (phase2['threshold'] as num?)?.toDouble() ?? 132.0;

    // Loosen thresholds to avoid no-count on typical curl ranges.
    final double newPhase1Threshold =
        phase1Threshold < 75 ? 86.0 : phase1Threshold;
    // Require a bit less extension so users don't need to lock out fully
    final double newPhase2Threshold =
        phase2Threshold > 150 ? 135.0 : phase2Threshold;

    phase1['threshold'] = newPhase1Threshold;
    phase1['condition'] = 'angle < ${newPhase1Threshold.toStringAsFixed(0)}';
    phase1['description'] = phase1['description'] ?? 'Curl Up';

    phase2['threshold'] = newPhase2Threshold;
    phase2['condition'] = 'angle > ${newPhase2Threshold.toStringAsFixed(0)}';
    phase2['description'] = phase2['description'] ?? 'Lower Arm';

    normalized['phase_1_eccentric'] = phase1;
    normalized['phase_2_concentric'] = phase2;

    if (!normalized.containsKey('alternative_joints')) {
      normalized['alternative_joints'] = const ['left_elbow', 'right_elbow'];
    }

    return normalized;
  }

  Map<String, dynamic> _applyShoulderPressRepLogic(
    Map<String, dynamic> repLogic,
  ) {
    final normalized = Map<String, dynamic>.from(repLogic);

    normalized['primary_joint'] = 'elbow';

    final phase1Raw = normalized['phase_1_eccentric'] as Map<String, dynamic>?;
    final phase2Raw = normalized['phase_2_concentric'] as Map<String, dynamic>?;

    final phase1 = Map<String, dynamic>.from(phase1Raw ?? {});
    final phase2 = Map<String, dynamic>.from(phase2Raw ?? {});

    final double phase1Threshold =
        (phase1['threshold'] as num?)?.toDouble() ?? 138.0;
    final double phase2Threshold =
        (phase2['threshold'] as num?)?.toDouble() ?? 155.0;

    // Shoulder press needs "down -> up" transitions for rep counting.
    // Start down when elbow is bent, complete rep when elbow is extended.
    final double newPhase1Threshold =
        phase1Threshold > 130 ? 130.0 : phase1Threshold;
    final double newPhase2Threshold =
        phase2Threshold < 160 ? 150.0 : phase2Threshold;

    phase1['threshold'] = newPhase1Threshold;
    phase1['condition'] = 'angle < ${newPhase1Threshold.toStringAsFixed(0)}';
    phase1['description'] = phase1['description'] ?? 'Lower Down';

    phase2['threshold'] = newPhase2Threshold;
    phase2['condition'] = 'angle > ${newPhase2Threshold.toStringAsFixed(0)}';
    phase2['description'] = phase2['description'] ?? 'Press Up';

    normalized['phase_1_eccentric'] = phase1;
    normalized['phase_2_concentric'] = phase2;
    normalized['min_range_of_motion'] = 17.0;
    // á€¡á€”á€Šá€ºá€¸á€†á€¯á€¶á€¸ 40Â° á€œá€¾á€¯á€•á€ºá€›á€¾á€¬á€¸á€™á€¾á€¯
    normalized['min_rep_duration_ms'] = 1000; // á€¡á€”á€Šá€ºá€¸á€†á€¯á€¶á€¸ 0.8 á€…á€€á€¹á€€á€”á€·á€º
    normalized['max_rep_duration_ms'] = 5000; // á€¡á€™á€»á€¬á€¸á€†á€¯á€¶á€¸ 5 á€…á€€á€¹á€€á€”á€·á€º
    normalized['require_stable_start'] = true;
    normalized['noise_buffer_ms'] = 900;

    if (!normalized.containsKey('alternative_joints')) {
      normalized['alternative_joints'] = const ['left_elbow', 'right_elbow'];
    }

    return normalized;
  }

  Map<String, dynamic> _applyBenchPressRepLogic(
    Map<String, dynamic> repLogic,
  ) {
    final normalized = Map<String, dynamic>.from(repLogic);

    normalized['primary_joint'] = 'elbow';

    final phase1Raw = normalized['phase_1_eccentric'] as Map<String, dynamic>?;
    final phase2Raw = normalized['phase_2_concentric'] as Map<String, dynamic>?;

    final phase1 = Map<String, dynamic>.from(phase1Raw ?? {});
    final phase2 = Map<String, dynamic>.from(phase2Raw ?? {});

    final double phase1Threshold =
        (phase1['threshold'] as num?)?.toDouble() ?? 104.0;
    final double phase2Threshold =
        (phase2['threshold'] as num?)?.toDouble() ?? 145.0;

    // Keep bench press counting simple and stable:
    // start rep when elbow is clearly bent, count rep when elbow re-extends.
    final double newPhase1Threshold =
        phase1Threshold.clamp(102.0, 120.0).toDouble();
    // Count only near lockout so rep direction matches scoring:
    // bend first, then complete on clear re-extension.
    final double newPhase2Threshold =
        phase2Threshold.clamp(148.0, 156.0).toDouble();

    phase1['threshold'] = newPhase1Threshold;
    phase1['condition'] = 'angle < ${newPhase1Threshold.toStringAsFixed(0)}';
    phase1['description'] = phase1['description'] ?? 'Lower Bar to Chest';

    phase2['threshold'] = newPhase2Threshold;
    phase2['condition'] = 'angle > ${newPhase2Threshold.toStringAsFixed(0)}';
    phase2['description'] = phase2['description'] ?? 'Press Bar Up';

    normalized['phase_1_eccentric'] = phase1;
    normalized['phase_2_concentric'] = phase2;
    normalized['min_range_of_motion'] = 20.0;
    normalized['min_rep_duration_ms'] = 220;
    normalized['max_rep_duration_ms'] = 6000;
    normalized['noise_buffer_ms'] = 450;

    if (!normalized.containsKey('alternative_joints')) {
      normalized['alternative_joints'] = const ['left_elbow', 'right_elbow'];
    }

    return normalized;
  }



  void _transitionToDown({
    required double angle,
    required DateTime timestamp,
    required List<FormWarning> warnings,
    required double accuracy,
  }) {
    _currentRepPeakAccuracy = accuracy;

    if (_exerciseId == 'pushup') {
      _currentRepMinAngle = angle;
      _currentRepMaxAngle = angle;
    }
    if (_exerciseId == 'bench_press') {
      _currentRepMinAngle = angle;
      _currentRepMaxAngle = angle;
    }

    if (_exerciseId == 'situp') {
      print('â¬‡ï¸ Sit-up: Starting rep (lying back)');
      _currentRepMinAngle = angle; // Starting angle (á€¡á€™á€¼á€„á€·á€ºá€†á€¯á€¶á€¸)
      _currentRepMaxAngle = angle;
    }
    // âœ… Create a Map instead of RepDetail class
    final repDetail = RepDetail(
      repNumber: _currentState.repetitions + 1,
      durationMs: 0,
      accuracy: accuracy,
      jointAngles: [], // Will be populated during the rep
      formPerfect: warnings.isEmpty,
    );

    _currentRepDetails.add(repDetail);

    _currentState = _currentState.copyWith(
      phase: _phaseDown,
      phaseStartTime: timestamp,
      currentAccuracy: accuracy,
      activeWarnings: warnings,
    );

    if (_requiresFullCycle) {
      _cycleStartTime = timestamp;
      _cycleReachedPhase2 = false;
      _cyclePhase2Accuracy = null;
    }

    if (_exerciseId == 'shoulder_press') {
      _currentRepMinAngle = angle;
      _currentRepMaxAngle = angle;
    }
    if (_exerciseId == 'situp') {
      _situpAngleHistory.clear();
      _situpAngleHistory.add(angle);
      _situpRepAttempts = 0;
      print('â¬‡ï¸ Sit-up: Starting downward motion (lying back)');
    } else {
      print('â¬‡ï¸ Down phase started');
    }

    print('â¬‡ï¸ Down phase started');
  }



  void _transitionToUp({
    required double angle,
    required DateTime timestamp,
    required List<FormWarning> warnings,
    required double accuracy,
    bool preserveRepRange = false,
  }) {
    _currentState = _currentState.copyWith(
      phase: _phaseUp,
      phaseStartTime: timestamp,
      currentAccuracy: accuracy,
      activeWarnings: warnings,
    );
    if (!preserveRepRange) {
      _currentRepMinAngle = null;
      _currentRepMaxAngle = null;
    }
  }

  void _completeRepetition({
    required double angle,
    required DateTime timestamp,
    required List<FormWarning> warnings,
    required double accuracy,
    DateTime? cycleStartTime,
  }) {
    if (_currentRepDetails.isEmpty) return;

    // Calculate rep duration
    final repStartTime =
        cycleStartTime ?? _currentState.phaseStartTime ?? timestamp;
    final repDuration = timestamp.difference(repStartTime);
    if (_exerciseId == 'pushup') {
      final minAngle = _currentRepMinAngle ?? angle;
      final maxAngle = _currentRepMaxAngle ?? angle;
      final range = maxAngle - minAngle;

      if (repDuration.inMilliseconds < _pushupMinRepDurationMs ||
          repDuration.inMilliseconds > _pushupMaxRepDurationMs) {
        print(
            'âŒ Push-up rep duration invalid: ${repDuration.inMilliseconds}ms');
        _currentRepDetails.removeLast();
        _currentRepPeakAccuracy = 0.0;
        _transitionToUp(
          angle: angle,
          timestamp: timestamp,
          warnings: warnings,
          accuracy: accuracy,
        );
        return;
      }

      if (range < _pushupMinRange) {
        print(
            'âŒ Push-up range too small: ${range.toStringAsFixed(1)}Â° (required: $_pushupMinRangeÂ°)');
        _currentRepDetails.removeLast();
        _currentRepPeakAccuracy = 0.0;
        _transitionToUp(
          angle: angle,
          timestamp: timestamp,
          warnings: warnings,
          accuracy: accuracy,
        );
        return;
      }
    }

    if (_exerciseId == 'bench_press') {
      final minAngle = _currentRepMinAngle ?? angle;
      final maxAngle = _currentRepMaxAngle ?? angle;
      final range = maxAngle - minAngle;

      const int minBenchRepDurationMs = 220;
      const int maxBenchRepDurationMs = 6000;
      const double minBenchRange = 12.0;

      if (repDuration.inMilliseconds < minBenchRepDurationMs ||
          repDuration.inMilliseconds > maxBenchRepDurationMs) {
        print(
            '❌ Bench press rep duration invalid: ${repDuration.inMilliseconds}ms');
        _currentRepDetails.removeLast();
        _currentRepPeakAccuracy = 0.0;
        _transitionToUp(
          angle: angle,
          timestamp: timestamp,
          warnings: warnings,
          accuracy: accuracy,
        );
        return;
      }

      if (range < minBenchRange) {
        print(
            '❌ Bench press range too small: ${range.toStringAsFixed(1)}° (required: ${minBenchRange.toStringAsFixed(1)}°)');
        _currentRepDetails.removeLast();
        _currentRepPeakAccuracy = 0.0;
        _transitionToUp(
          angle: angle,
          timestamp: timestamp,
          warnings: warnings,
          accuracy: accuracy,
        );
        return;
      }
    }

    if (_exerciseId == 'leg_extension') {
      final minAngle = _currentRepMinAngle ?? angle;
      final maxAngle = _currentRepMaxAngle ?? angle;
      final range = maxAngle - minAngle;

      // config á€‘á€²á€€ min_range_of_motion á€€á€­á€¯á€–á€á€ºá€•á€« (default 70Â°)
      final configMinRange = (_exerciseConfig['leg_extension_settings']
                  ?['min_range_of_motion'] as num?)
              ?.toDouble() ??
          50.0;
      final configMinRepDuration = (_exerciseConfig['leg_extension_settings']
                  ?['min_rep_duration_ms'] as num?)
              ?.toInt() ??
          1600; // min_rep_duration_ms
      final confignoisebuffer = (_exerciseConfig['leg_extension_settings']
                  ?['noise_buffer_ms'] as num?)
              ?.toInt() ??
          1600;
      if (range < configMinRange) {
        print(
            'âŒ Leg extension range too small: ${range.toStringAsFixed(1)}Â° (required: ${configMinRange}Â°)');
        _currentRepDetails.removeLast();
        _currentRepPeakAccuracy = 0.0;
        _transitionToUp(
          angle: angle,
          timestamp: timestamp,
          warnings: warnings,
          accuracy: accuracy,
        );
        return;
      }
    }

    if (_exerciseId == 'situp') {
      if (repDuration.inMilliseconds < 800) {
        // á€¡á€”á€Šá€ºá€¸á€†á€¯á€¶á€¸ 0.8 á€…á€€á€¹á€€á€”á€·á€º
        print('âŒ Sit-up too fast: ${repDuration.inMilliseconds}ms');
        _currentRepDetails.removeLast();
        _currentRepPeakAccuracy = 0.0;
        _transitionToUp(
          angle: angle,
          timestamp: timestamp,
          warnings: warnings,
          accuracy: accuracy,
        );
        return;
      }

      if (repDuration.inMilliseconds > 8000) {
        // á€¡á€™á€»á€¬á€¸á€†á€¯á€¶á€¸ 5 á€…á€€á€¹á€€á€”á€·á€º
        print('âŒ Sit-up too slow: ${repDuration.inMilliseconds}ms');
        _currentRepDetails.removeLast();
        _currentRepPeakAccuracy = 0.0;
        _transitionToUp(
          angle: angle,
          timestamp: timestamp,
          warnings: warnings,
          accuracy: accuracy,
        );
        return;
      }

      // Range check
      final minAngle = _currentRepMinAngle ?? angle;
      final maxAngle = _currentRepMaxAngle ?? angle;
      final range = maxAngle - minAngle;

      if (range < 50.0) {
        // á€¡á€”á€Šá€ºá€¸á€†á€¯á€¶á€¸ 40Â° range
        print('âŒ Sit-up range too small: ${range.toStringAsFixed(1)}Â°');
        _currentRepDetails.removeLast();
        _currentRepPeakAccuracy = 0.0;
        _transitionToUp(
          angle: angle,
          timestamp: timestamp,
          warnings: warnings,
          accuracy: accuracy,
        );
        return;
      }
    }
  

    // Update last rep detail
    final lastIndex = _currentRepDetails.length - 1;
    _currentRepDetails[lastIndex] = _currentRepDetails[lastIndex].copyWith(
      durationMs: repDuration.inMilliseconds,
      accuracy: _currentRepPeakAccuracy > accuracy
          ? _currentRepPeakAccuracy
          : accuracy,
      formPerfect:
          warnings.isEmpty && _currentRepDetails[lastIndex].formPerfect,
    );
    _currentRepPeakAccuracy = 0.0;

    // Increment rep count
    final newRepCount = _currentState.repetitions + 1;
    _lastRepTime = timestamp;

    _currentState = _currentState.copyWith(
      phase: _phaseUp,
      repetitions: newRepCount,
      phaseStartTime: timestamp,
      currentAccuracy: accuracy,
      activeWarnings: warnings,
    );

    print('âœ… SIT-UP REP #$newRepCount COMPLETED!');
    print('   Duration: ${repDuration.inMilliseconds}ms');
    if (_exerciseId == 'situp') {
      final minA = _currentRepMinAngle ?? 0;
      final maxA = _currentRepMaxAngle ?? 0;
      print('   Range: ${(maxA - minA).toStringAsFixed(1)}Â°');
    }

    // Reset tracking
    _currentRepMinAngle = null;
    _currentRepMaxAngle = null;

    print('âœ… REP #$newRepCount COMPLETED!');
  }

  void _transitionToHold({
    required DateTime timestamp,
    required List<FormWarning> warnings,
    required double accuracy,
  }) {
    _currentState = _currentState.copyWith(
      phase: _phaseHold,
      phaseStartTime: timestamp,
      currentAccuracy: accuracy,
      activeWarnings: warnings,
      holdDuration: Duration.zero,
    );

    print('â±ï¸ Started holding');
    _startHoldTimer();
  }

  void _transitionFromHold({
    required DateTime timestamp,
    required List<FormWarning> warnings,
    required double accuracy,
  }) {
    _holdTimer?.cancel();
    _holdTimer = null;

    _currentState = _currentState.copyWith(
      phase: _phaseUp,
      phaseStartTime: timestamp,
      currentAccuracy: accuracy,
      activeWarnings: warnings,
      holdDuration: null,
    );

    print('â¹ï¸ Hold ended');
  }

  void _startHoldTimer() {
    _holdTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final holdStart = _currentState.phaseStartTime ?? now;
      final holdDuration = now.difference(holdStart);

      _currentState = _currentState.copyWith(
        holdDuration: holdDuration,
      );

      _emitStateUpdate();

      // Every 10 seconds, increment reps for static exercises
      if (holdDuration.inSeconds % 10 == 0 && holdDuration.inSeconds > 0) {
        final repsFromHolding = holdDuration.inSeconds ~/ 10;
        if (repsFromHolding > _currentState.repetitions) {
          _currentState = _currentState.copyWith(
            repetitions: repsFromHolding,
          );
          print('â±ï¸ Timer: Hold rep counted! Total: $repsFromHolding');
        }
      }
    });
  }

  double? _selectJointAngle({
    required String primaryJoint,
    required List<String> alternativeJoints,
    required Map<String, double> jointAngles,
  }) {
    if (primaryJoint == 'elbow' ||
        primaryJoint == 'left_elbow' ||
        primaryJoint == 'right_elbow') {
      double? left = jointAngles['left_elbow'] ??
          jointAngles['left_shoulder_left_elbow_left_wrist'];
      double? right = jointAngles['right_elbow'] ??
          jointAngles['right_shoulder_right_elbow_right_wrist'];

      // For bicep curl and generic elbow selection, prefer choosing an "active" side
      // (the side showing larger motion) instead of averaging. This avoids missed
      // counts when the camera flips perceived left/right.
      if (_exerciseId == 'bench_press') {
        left = left == null ? null : _normalizeBenchPressElbowAngle(left);
        right = right == null ? null : _normalizeBenchPressElbowAngle(right);
        final genericRaw =
            jointAngles['elbow'] ?? jointAngles['shoulder_elbow_wrist'];
        final generic = genericRaw == null
            ? null
            : _normalizeBenchPressElbowAngle(genericRaw);

        if (left != null && left > 0 && right != null && right > 0) {
          final elbowGap = (left - right).abs();

          if (elbowGap <= 14.0) {
            final avgAngle = (left + right) / 2;
            print(
                '🎯 Using balanced bench elbows: L=${left.toStringAsFixed(1)}°, R=${right.toStringAsFixed(1)}° → avg=${avgAngle.toStringAsFixed(1)}°');
            return avgAngle;
          }

          if (generic != null && generic > 0) {
            final leftDelta = (left - generic).abs();
            final rightDelta = (right - generic).abs();

            if ((leftDelta - rightDelta).abs() >= 4.0) {
              final resolved = leftDelta <= rightDelta ? left : right;
              print(
                  '🎯 Using generic-aligned bench elbow: L=${left.toStringAsFixed(1)}°, R=${right.toStringAsFixed(1)}°, G=${generic.toStringAsFixed(1)}° → ${resolved.toStringAsFixed(1)}°');
              return resolved;
            }

            final sorted = <double>[left, right, generic]..sort();
            print(
                '🎯 Using median bench elbow: L=${left.toStringAsFixed(1)}°, R=${right.toStringAsFixed(1)}°, G=${generic.toStringAsFixed(1)}° → ${sorted[1].toStringAsFixed(1)}°');
            return sorted[1];
          }

          final avgAngle = (left + right) / 2;
          print(
              '🎯 Using averaged bench elbows after side mismatch: L=${left.toStringAsFixed(1)}°, R=${right.toStringAsFixed(1)}° → ${avgAngle.toStringAsFixed(1)}°');
          return avgAngle;
        } else if (left != null && left > 0) {
          print('🎯 Using left bench elbow only: ${left.toStringAsFixed(1)}°');
          return left;
        } else if (right != null && right > 0) {
          print('🎯 Using right bench elbow only: ${right.toStringAsFixed(1)}°');
          return right;
        } else if (generic != null && generic > 0) {
          print('🎯 Using generic bench elbow only: ${generic.toStringAsFixed(1)}°');
          return generic;
        }
      }

      if (left != null && left > 0 && right != null && right > 0) {
        // Choose active side (no default left bias). Use recent per-side motion to prefer
        // the elbow that is currently moving more. If motion is similar, prefer the
        // previously selected side (hysteresis).
        final leftMotion = _lastLeftElbowAngle == null ? 0.0 : (left - _lastLeftElbowAngle!).abs();
        final rightMotion = _lastRightElbowAngle == null ? 0.0 : (right - _lastRightElbowAngle!).abs();

        String selectedSide;
        double selectedAngle;

        if ((leftMotion - rightMotion).abs() >= 2.0) {
          selectedSide = leftMotion > rightMotion ? 'left' : 'right';
        } else if (_lastSelectedElbowSide != null && (_lastSelectedElbowSide == 'left' || _lastSelectedElbowSide == 'right')) {
          selectedSide = _lastSelectedElbowSide!;
        } else {
          // Fallback: choose the side with the larger absolute angle change relative to neutral (higher variance)
          selectedSide = (left - right).abs() >= 1.0 ? (left > right ? 'left' : 'right') : 'left';
        }

        if (selectedSide == 'left') {
          selectedAngle = left;
        } else {
          selectedAngle = right;
        }

        // Save for next-frame hysteresis
        _lastLeftElbowAngle = left;
        _lastRightElbowAngle = right;
        _lastSelectedElbowSide = selectedSide;

        print('🎯 Using active elbow ($selectedSide): L=${left.toStringAsFixed(1)}°, R=${right.toStringAsFixed(1)}° → ${selectedAngle.toStringAsFixed(1)}° (motions L=${leftMotion.toStringAsFixed(1)}, R=${rightMotion.toStringAsFixed(1)})');

        return selectedAngle;
      } else if (left != null && left > 0) {
        _lastLeftElbowAngle = left;
        _lastSelectedElbowSide = 'left';
        print('ðŸŽ¯ Using left elbow only: ${left.toStringAsFixed(1)}Â°');
        return left;
      } else if (right != null && right > 0) {
        _lastRightElbowAngle = right;
        _lastSelectedElbowSide = 'right';
        print('ðŸŽ¯ Using right elbow only: ${right.toStringAsFixed(1)}Â°');
        return right;
      }
    }
    if (jointAngles.containsKey(primaryJoint)) {
      return jointAngles[primaryJoint];
    }
    for (final alt in alternativeJoints) {
      if (jointAngles.containsKey(alt)) {
        return jointAngles[alt];
      }
    }
    // Fallback: match any angle key that contains the joint name (e.g., shoulder_elbow_wrist)
    for (final entry in jointAngles.entries) {
      final key = entry.key.toLowerCase();
      if (key.contains(primaryJoint.toLowerCase()) && entry.value > 0) {
        return entry.value;
      }
      for (final alt in alternativeJoints) {
        if (key.contains(alt.toLowerCase()) && entry.value > 0) {
          return entry.value;
        }
      }
    }
    return null;
  }

  double? _resolveHoldAngle(
    String conditionKey,
    Map<String, double> jointAngles,
  ) {
    if (jointAngles.containsKey(conditionKey)) {
      return jointAngles[conditionKey];
    }

    final key = conditionKey.toLowerCase();
    if (key.contains('knee')) {
      return _selectJointAngle(
        primaryJoint: 'knee',
        alternativeJoints: const [
          'left_knee',
          'right_knee',
          'hip_knee_ankle',
          'left_hip_left_knee_left_ankle',
          'right_hip_right_knee_right_ankle',
        ],
        jointAngles: jointAngles,
      );
    }
    if (key.contains('hip')) {
      return _selectJointAngle(
        primaryJoint: 'hip',
        alternativeJoints: const [
          'left_hip',
          'right_hip',
          'shoulder_hip_knee',
          'shoulder_hip_ankle',
        ],
        jointAngles: jointAngles,
      );
    }
    if (key.contains('back') || key.contains('torso')) {
      return jointAngles['shoulder_hip_knee'] ??
          jointAngles['shoulder_hip_ankle'] ??
          jointAngles['torso_angle'] ??
          jointAngles['back_angle'];
    }
    if (key.contains('shoulder')) {
      return _selectJointAngle(
        primaryJoint: 'shoulder',
        alternativeJoints: const [
          'left_shoulder',
          'right_shoulder',
        ],
        jointAngles: jointAngles,
      );
    }

    final fallbackKey = conditionKey.replaceAll('_angle', '');
    return jointAngles[fallbackKey] ?? jointAngles[conditionKey];
  }

  bool get _requiresFullCycle =>
      _exerciseId == 'shoulder_press' ||
      _exerciseId == 'situp' ||
      _exerciseId == 'leg_extension';

  void _resetCycleTracking() {
    _cycleReachedPhase2 = false;
    _cycleStartTime = null;
    _cyclePhase2Accuracy = null;
  }

  void _abortCurrentDynamicRep({
    required double angle,
    required DateTime timestamp,
    required List<FormWarning> warnings,
    required double accuracy,
  }) {
    if (_currentState.phase == _phaseDown && _currentRepDetails.isNotEmpty) {
      _currentRepDetails.removeLast();
    }
    _currentRepPeakAccuracy = 0.0;
    _currentRepMinAngle = null;
    _currentRepMaxAngle = null;
    _benchDownConfirmFrames = 0;
    _benchUpConfirmFrames = 0;
    _resetCycleTracking();
    _currentState = _currentState.copyWith(
      phase: _phaseUp,
      phaseStartTime: timestamp,
      currentAccuracy: accuracy,
      activeWarnings: warnings,
    );
  }

  bool _evaluatePhaseCondition({
    required Map<String, dynamic> phase,
    required double angle,
    required bool defaultLessThan,
    required double fallbackThreshold,
  }) {
    final condition = phase['condition'] as String?;

    // âœ… Sit-up á€¡á€á€½á€€á€º special handling
    if (_exerciseId == 'situp') {
      if (_currentState.phase == _phaseUp) {
        // Down phase á€á€„á€ºá€–á€­á€¯á€·: angle á€€ threshold á€‘á€€á€ºá€€á€¼á€®á€¸á€›á€™á€šá€º
        return angle > fallbackThreshold;
      } else if (_currentState.phase == _phaseDown) {
        // Up phase á€•á€¼á€”á€ºá€á€„á€ºá€–á€­á€¯á€·: angle á€€ threshold á€‘á€€á€ºá€„á€šá€ºá€›á€™á€šá€º
        return angle < fallbackThreshold;
      }
    }

    if (condition != null) {
      final match = RegExp(r'angle\s*([<>]=?)\s*([0-9]+(?:\.[0-9]+)?)')
          .firstMatch(condition);
      if (match != null) {
        final op = match.group(1)!;
        final value = double.parse(match.group(2)!);
        return _compareAngle(angle, op, value);
      }
    }

    return defaultLessThan
        ? angle < fallbackThreshold
        : angle > fallbackThreshold;
  }

  bool _compareAngle(double angle, String op, double value) {
    switch (op) {
      case '<':
        return angle < value;
      case '<=':
        return angle <= value;
      case '>':
        return angle > value;
      case '>=':
        return angle >= value;
      default:
        return false;
    }
  }

  void _emitStateUpdate() {
    if (!_stateController.isClosed) {
      _stateController.add(_currentState);
    }
  }

  Future<ExerciseLog> completeSession() async {
    final sessionEndTime = DateTime.now();
    final sessionDuration = _sessionStartTime != null
        ? sessionEndTime.difference(_sessionStartTime!).inSeconds
        : 0;

    // Calculate average accuracy for the session
    double totalAccuracy = 0.0;
    double maxAccuracy = 0.0;
    double minAccuracy = 1.0;

    for (final rep in _currentRepDetails) {
      totalAccuracy += rep.accuracy;
      maxAccuracy = rep.accuracy > maxAccuracy ? rep.accuracy : maxAccuracy;
      minAccuracy = rep.accuracy < minAccuracy ? rep.accuracy : minAccuracy;
    }

    double averageAccuracy = 0.0;
    if (_currentRepDetails.isNotEmpty) {
      averageAccuracy = totalAccuracy / _currentRepDetails.length;
    } else {
      maxAccuracy = 0.0;
      minAccuracy = 0.0;
      averageAccuracy = 0.0;
    }

    // Aggregate form warnings
    final allWarnings = <FormWarning>[];
    for (final rep in _currentRepDetails) {
      if (!rep.formPerfect) {
        // Add warnings for imperfect reps
      }
    }

    // âœ… Now using ExerciseLog constructor with RepDetail list
    final log = ExerciseLog(
      exerciseId: _exerciseId,
      timestamp: sessionEndTime,
      sessionDuration: sessionDuration,
      totalRepetitions: _currentState.repetitions,
      averageAccuracy: averageAccuracy,
      maxAccuracy: maxAccuracy,
      minAccuracy: minAccuracy,
      repDetails: _currentRepDetails, // âœ… This works now - same type
      formWarnings: allWarnings,
      isPremiumSession: false,
    );

    print('\nðŸ“Š SESSION COMPLETED');
    print('   Reps: ${_currentState.repetitions}');
    print('   Avg Accuracy: ${(averageAccuracy * 100).toStringAsFixed(1)}%');
    print('   Duration: ${sessionDuration}s');

    _resetState();

    return log;
  }

  void _resetState() {
    _currentState = ExerciseState(
      exerciseId: _exerciseId,
      phase: _phaseUp,
      repetitions: 0,
      currentAccuracy: 0.0,
      activeWarnings: [],
      phaseStartTime: DateTime.now(),
    );

    _currentRepDetails.clear();
    _angleHistory.clear();
    _shoulderPressElbowHistory.clear();
    _lastRepTime = null;
    _sessionStartTime = DateTime.now();
    _readyForCounting = false;
    _readyFrameCount = 0;
    _pushupDownConfirmFrames = 0;
    _pushupUpConfirmFrames = 0;
    _benchDownConfirmFrames = 0;
    _benchUpConfirmFrames = 0;
    _situpArmed = false;
    _situpBaselineFrames = 0;
    _resetCycleTracking();
    _currentRepPeakAccuracy = 0.0;

    _holdTimer?.cancel();
    _holdTimer = null;
  }

  Future<void> dispose() async {
    _holdTimer?.cancel();
    await _stateController.close();
  }
}

