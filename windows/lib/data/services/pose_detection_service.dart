import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:vector_math/vector_math.dart';
import '../../core/utils/angle_calculator.dart';
import '../models/exercise_log.dart';
import '../models/exercise_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/foundation.dart'; // Ã¡â‚¬â€™Ã¡â‚¬Â«Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯ Ã¡â‚¬â€˜Ã¡â‚¬Å Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬â„¢Ã¡â‚¬Â¾ WriteBuffer Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯ Ã¡â‚¬Å¾Ã¡â‚¬Â¯Ã¡â‚¬Â¶Ã¡â‚¬Â¸Ã¡â‚¬Å“Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬Â·Ã¡â‚¬â€ºÃ¡â‚¬â„¢Ã¡â‚¬Â¾Ã¡â‚¬Â¬Ã¡â‚¬â€¢Ã¡â‚¬Â«
import 'dart:io';
import 'exercise_logic_engine.dart';
import '../../core/constants/exercise_config.dart';

const bool _enablePoseDetectionVerboseLogs = false;

void print(Object? object) {
  if (_enablePoseDetectionVerboseLogs) {
    debugPrint('$object');
  }
}

class PoseDetectionResult {
  final Pose? pose;
  final Map<String, double> jointAngles;
  final List<FormWarning> formWarnings;
  final double overallAccuracy;
  final bool isPoseDetected;
  final DateTime timestamp;
  // Exercise Logic Engine Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯ Ã¡â‚¬â‚¬Ã¡â‚¬Â¼Ã¡â‚¬Â±Ã¡â‚¬Å Ã¡â‚¬Â¬Ã¡â‚¬ÂÃ¡â‚¬Â¼Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸

  // UI Ã¡â‚¬â‚¬Ã¡â‚¬â€Ã¡â‚¬Â± Rep count Ã¡â‚¬ÂÃ¡â‚¬Â½Ã¡â‚¬Â±Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯ Ã¡â‚¬Å“Ã¡â‚¬Â¾Ã¡â‚¬â„¢Ã¡â‚¬ÂºÃ¡â‚¬Â¸Ã¡â‚¬Å¡Ã¡â‚¬Â°Ã¡â‚¬â€Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬â€“Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬Â· Getter Ã¡â‚¬ÂÃ¡â‚¬â€¦Ã¡â‚¬ÂºÃ¡â‚¬ÂÃ¡â‚¬Â¯ Ã¡â‚¬â€˜Ã¡â‚¬Â¬Ã¡â‚¬Â¸Ã¡â‚¬â€¢Ã¡â‚¬Â±Ã¡â‚¬Â¸Ã¡â‚¬â€ºÃ¡â‚¬â€žÃ¡â‚¬Âº Ã¡â‚¬â€¢Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬â‚¬Ã¡â‚¬Â±Ã¡â‚¬Â¬Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸Ã¡â‚¬â€¢Ã¡â‚¬Â«Ã¡â‚¬ÂÃ¡â‚¬Å¡Ã¡â‚¬Âº
  PoseDetectionResult({
    this.pose,
    required this.jointAngles,
    required this.formWarnings,
    required this.overallAccuracy,
    required this.isPoseDetected,
    required this.timestamp,
  });
}

class _AngleResult {
  final double angle;
  final double confidence;

  const _AngleResult(this.angle, this.confidence);
}

class _JointPair {
  final PoseLandmarkType start;
  final PoseLandmarkType end;

  const _JointPair(this.start, this.end);
}

class PoseDetectionService {
  static const double _minDetectionConfidence = 0.5;
  static const double _minTrackingConfidence = 0.5;
  static const int _maxPoseDetections = 2;
  static const double _minReliableLandmarkLikelihood = 0.1;
  static const double _minAcceptedPoseConfidence = 0.15;

  PoseDetector? _poseDetector;
  StreamController<PoseDetectionResult>? _resultController;
  Timer? _throttleTimer;
  bool _isProcessing = false;
  int _processingFrameCount = 0;
  DateTime? _lastProcessedTime;
  List<double> _accuracyHistory = [];
  List<List<double>> _jointAngleHistory = [];
  PoseDetectionResult? _lastReliableDetectionResult;
  DateTime? _lastReliableDetectionAt;
  bool _servicesReady = false;

  final AngleCalculator _angleCalculator = AngleCalculator();

  // UI Ã¡â‚¬â‚¬Ã¡â‚¬â€Ã¡â‚¬Â± Rep count Ã¡â‚¬ÂÃ¡â‚¬Â½Ã¡â‚¬Â±Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯ Ã¡â‚¬Å“Ã¡â‚¬Â¾Ã¡â‚¬â„¢Ã¡â‚¬ÂºÃ¡â‚¬Â¸Ã¡â‚¬Å¡Ã¡â‚¬Â°Ã¡â‚¬â€Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬â€“Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬Â· Getter Ã¡â‚¬ÂÃ¡â‚¬â€¦Ã¡â‚¬ÂºÃ¡â‚¬ÂÃ¡â‚¬Â¯ Ã¡â‚¬â€˜Ã¡â‚¬Â¬Ã¡â‚¬Â¸Ã¡â‚¬â€¢Ã¡â‚¬Â±Ã¡â‚¬Â¸Ã¡â‚¬â€ºÃ¡â‚¬â€žÃ¡â‚¬Âº Ã¡â‚¬â€¢Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬â‚¬Ã¡â‚¬Â±Ã¡â‚¬Â¬Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸Ã¡â‚¬â€¢Ã¡â‚¬Â«Ã¡â‚¬ÂÃ¡â‚¬Å¡Ã¡â‚¬Âº

  //static const double _smoothingFactor = 0.15; // 0.1-0.3 Ã¡â‚¬â‚¬Ã¡â‚¬Â¼Ã¡â‚¬Â¬Ã¡â‚¬Â¸
  // static const int _historySize = 10;
  static const double _minConfidenceThreshold =
      0.25; // Minimum confidence to update

  // State for smoothing
  double _smoothedAccuracy = 0.1; // Start at 50%
  List<double> _recentAccuracies = [];
  DateTime? _lastSignificantUpdate;
  static const int _updateCooldownMs = 300;

  // Old recording-mode smoothing kept updates gradual by blending recent
  // history and capping each frame's movement.
  static const double _smoothingFactor = 0.28;
  double _lastStableAccuracy = 0.5;

  // Minimum pose confidence to allow accuracy to update.
  // At 0.35 the bar starts responding the moment the ML model gains a clear
  // lock on the body â€“ earlier than before, removing the "stuck at 0" delay.
  static const double _minConfidenceForUpdate = 0.4;

  static const Duration _transientDetectionGrace = Duration(milliseconds: 400);
  static const int _historySize = 5;
  static const double _maxAccuracyStepPerFrame = 0.1;
  static const double _benchPressMetricSmoothingFactor = 0.35;
  static const double _benchPressSideSwitchMargin = 0.16;

  int _benchPressTrackingSide = -1;
  Map<String, double>? _lastBenchPressMetrics;

  double _smoothAccuracyValue(
      double newAccuracy, double confidence, Map<String, double> jointAngles, {String? exerciseId}) {
    if (confidence < _minConfidenceForUpdate) {
      return _lastStableAccuracy;
    }

    _accuracyHistory.add(newAccuracy);
    if (_accuracyHistory.length > _historySize) {
      _accuracyHistory.removeAt(0);
    }

    double sum = 0.0;
    for (final accuracy in _accuracyHistory) {
      sum += accuracy;
    }
    final double averageAccuracy = sum / _accuracyHistory.length;

    if (!_shouldApplyOldSmoothingUpdate(averageAccuracy)) {
      return _lastStableAccuracy.clamp(0.0, 1.0);
    }

    double currentSmoothingFactor = _smoothingFactor;
    double maxStep = _maxAccuracyStepPerFrame;

    if (exerciseId == 'bench_press') {
      currentSmoothingFactor = 0.05; // Noticeably slower smoothing for bench press
      maxStep = 0.02;                // Much smaller max step per frame
    }

    final double blendedTarget =
        (averageAccuracy * 0.7) + (newAccuracy * 0.3);
    final double rawStep =
        (blendedTarget - _lastStableAccuracy) * (currentSmoothingFactor * confidence);
    final double clampedStep = rawStep.clamp(
      -maxStep,
      maxStep,
    );
    double smoothedValue = _lastStableAccuracy + clampedStep;

    if ((blendedTarget - _lastStableAccuracy).abs() < 0.015) {
      smoothedValue = blendedTarget;
    }

    _lastStableAccuracy = smoothedValue;
    return smoothedValue.clamp(0.0, 1.0);
  }

  bool _shouldApplyOldSmoothingUpdate(double newAccuracy) {
    if (_accuracyHistory.length < 2) {
      return true;
    }

    final double lastAccuracy = _accuracyHistory.last;
    final double change = (newAccuracy - lastAccuracy).abs();

    if (change < 0.02) {
      print(
          'Small change (${(change * 100).toStringAsFixed(1)}%), but updating anyway');
      return true;
    }

    return true;
  }

  void _resetDetectionStability() {
    _lastStableAccuracy = 0.0;
    _accuracyHistory.clear();
    _recentAccuracies.clear();
    _jointAngleHistory.clear();
    _lastReliableDetectionResult = null;
    _lastReliableDetectionAt = null;
    _benchPressTrackingSide = -1;
    _lastBenchPressMetrics = null;
  }

  void _cacheReliableDetection(PoseDetectionResult result) {
    _lastReliableDetectionResult = result;
    _lastReliableDetectionAt = result.timestamp;
  }

  bool _shouldReuseReliableDetection() {
    final cachedAt = _lastReliableDetectionAt;
    if (cachedAt == null || _lastReliableDetectionResult == null) {
      return false;
    }

    return DateTime.now().difference(cachedAt) <= _transientDetectionGrace;
  }

  void _emitDetectionResult(PoseDetectionResult result, {bool cache = false}) {
    if (cache) {
      _cacheReliableDetection(result);
    }
    _ensureResultController().add(result);
  }

  void _emitTransientAwareFailure({
    Pose? pose,
    Map<String, double> jointAngles = const {},
    List<FormWarning> formWarnings = const [],
    bool isPoseDetected = false,
  }) {
    _resetDetectionStability();
    _ensureResultController().add(
      PoseDetectionResult(
        pose: pose,
        jointAngles: jointAngles,
        formWarnings: formWarnings,
        overallAccuracy: 0.0,
        isPoseDetected: isPoseDetected,
        timestamp: DateTime.now(),
      ),
    );
  }

// Update condition Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬â€ºÃ¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬Â¸Ã¡â‚¬â€ºÃ¡â‚¬Â¾Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸Ã¡â‚¬Â¡Ã¡â‚¬Â±Ã¡â‚¬Â¬Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Å“Ã¡â‚¬Â¯Ã¡â‚¬â€¢Ã¡â‚¬ÂºÃ¡â‚¬â€¢Ã¡â‚¬Â«
  bool _checkUpdateConditions(
      double newAccuracy, Map<String, double> jointAngles) {
    return _shouldApplyOldSmoothingUpdate(newAccuracy);
  }

// Angle stability check Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬Å“Ã¡â‚¬Â»Ã¡â‚¬Â¾Ã¡â‚¬Â±Ã¡â‚¬Â¬Ã¡â‚¬Â·Ã¡â‚¬ÂÃ¡â‚¬Â»
  bool _areAnglesStable(Map<String, double> currentAngles) {
    if (currentAngles.isEmpty) return true;

    final currentValues = currentAngles.values.toList(growable: false);
    if (_jointAngleHistory.isEmpty) {
      _jointAngleHistory.add(currentValues);
      return true;
    }

    final lastAngles = _jointAngleHistory.last;
    final minLength = min(lastAngles.length, currentValues.length);
    if (minLength == 0) {
      _jointAngleHistory.add(currentValues);
      return true;
    }

    double totalChange = 0.0;
    for (var i = 0; i < minLength; i++) {
      totalChange += (currentValues[i] - lastAngles[i]).abs();
    }

    _jointAngleHistory.add(currentValues);
    if (_jointAngleHistory.length > _historySize) {
      _jointAngleHistory.removeAt(0);
    }

    final avgChange = totalChange / minLength;
    return avgChange < 8.0;
  }

  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    return values.last - values.first;
  }

  double _applyVerySlowSmoothing(double newAccuracy) {
    const smoothingFactor = 0.2;
    _lastStableAccuracy = (smoothingFactor * newAccuracy) +
        ((1 - smoothingFactor) * _lastStableAccuracy);
    return _lastStableAccuracy;
  }

  double _applyStableSmoothing(double newAccuracy, double trend) {
    double smoothingFactor = 0.3;
    if (trend > 0.1) {
      smoothingFactor = 0.4;
    } else if (trend < -0.1) {
      smoothingFactor = 0.2;
    }

    _lastStableAccuracy = (smoothingFactor * newAccuracy) +
        ((1 - smoothingFactor) * _lastStableAccuracy);
    return _lastStableAccuracy;
  }

  double _calculatePoseConfidence(Pose pose) {
    final keyLandmarks = <PoseLandmarkType>[
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ];

    double totalConfidence = 0.0;
    int validLandmarks = 0;
    for (final type in keyLandmarks) {
      final landmark = pose.landmarks[type];
      if (landmark != null && landmark.likelihood > 0.1) {
        totalConfidence += landmark.likelihood;
        validLandmarks++;
      }
    }

    if (validLandmarks == 0) return 0.0;
    final averageConfidence = totalConfidence / validLandmarks;
    final visibilityFactor = validLandmarks / keyLandmarks.length;
    return (averageConfidence * visibilityFactor).clamp(0.0, 1.0).toDouble();
  }

  StreamController<PoseDetectionResult> _ensureResultController() {
    final controller = _resultController;
    if (controller == null || controller.isClosed) {
      _resultController = StreamController<PoseDetectionResult>.broadcast();
    }
    return _resultController!;
  }

  Stream<PoseDetectionResult> get resultStream => _ensureResultController().stream;
  Stream<PoseDetectionResult> get detectionStream => resultStream;

  Future<void> initialize() async {
    if (_servicesReady) return;
    try {
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          // Use the stream-optimized model for live camera analysis.
          model: PoseDetectionModel.base,
          mode: PoseDetectionMode.stream,
        ),
      );
      _ensureResultController();
      _servicesReady = true;
      print('Pose Detection Service initialized successfully');
    } catch (e) {
      print('Error initializing pose detection: ');
      rethrow;
    }
  }

  bool _poseHasExplicitLikelihoods(Pose pose) {
    return pose.landmarks.values.any((landmark) => landmark.likelihood > 0.0);
  }

  bool _isLandmarkReliable(
    PoseLandmark? landmark, {
    required bool allowMissingLikelihoodFallback,
    required double minLikelihood,
  }) {
    if (landmark == null) {
      return false;
    }

    if (allowMissingLikelihoodFallback && landmark.likelihood <= 0.0) {
      return true;
    }

    return landmark.likelihood >= minLikelihood;
  }

  double _resolveLandmarkConfidence(
    PoseLandmark landmark, {
    required bool allowMissingLikelihoodFallback,
  }) {
    if (allowMissingLikelihoodFallback && landmark.likelihood <= 0.0) {
      return 1.0;
    }

    return landmark.likelihood.clamp(0.0, 1.0).toDouble();
  }

  Map<String, double> _calculateBenchPressPathMetrics(Pose pose) {
    final allowMissingLikelihoodFallback = !_poseHasExplicitLikelihoods(pose);
    const minLikelihood = 0.2;

    final sideCandidates = <Map<String, double>>[];

    void addSideCandidate({
      required String side,
      required PoseLandmarkType shoulderType,
      required PoseLandmarkType hipType,
      required PoseLandmarkType elbowType,
      required PoseLandmarkType wristType,
    }) {
      final shoulder = pose.landmarks[shoulderType];
      final hip = pose.landmarks[hipType];
      final elbow = pose.landmarks[elbowType];
      final wrist = pose.landmarks[wristType];

      if (!_isLandmarkReliable(
            shoulder,
            allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
            minLikelihood: minLikelihood,
          ) ||
          !_isLandmarkReliable(
            hip,
            allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
            minLikelihood: minLikelihood,
          ) ||
          !_isLandmarkReliable(
            elbow,
            allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
            minLikelihood: minLikelihood,
          ) ||
          !_isLandmarkReliable(
            wrist,
            allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
            minLikelihood: minLikelihood,
          )) {
        return;
      }

      final torsoDx = hip!.x - shoulder!.x;
      final torsoDy = hip.y - shoulder.y;
      final pressDx = wrist!.x - shoulder.x;
      final pressDy = wrist.y - shoulder.y;
      final forearmDx = wrist.x - elbow!.x;
      final forearmDy = wrist.y - elbow.y;
      final upperArmDx = elbow.x - shoulder.x;
      final upperArmDy = elbow.y - shoulder.y;

      final torsoMagnitude = sqrt((torsoDx * torsoDx) + (torsoDy * torsoDy));
      final pressMagnitude = sqrt((pressDx * pressDx) + (pressDy * pressDy));
      final forearmMagnitude =
          sqrt((forearmDx * forearmDx) + (forearmDy * forearmDy));
      final upperArmMagnitude =
          sqrt((upperArmDx * upperArmDx) + (upperArmDy * upperArmDy));
      if (torsoMagnitude < 1.0 ||
          pressMagnitude < 1.0 ||
          forearmMagnitude < 1.0 ||
          upperArmMagnitude < 1.0) {
        return;
      }

      final torsoDotPress =
          ((torsoDx * pressDx) + (torsoDy * pressDy)) /
          (torsoMagnitude * pressMagnitude);
      final torsoDotForearm =
          ((torsoDx * forearmDx) + (torsoDy * forearmDy)) /
          (torsoMagnitude * forearmMagnitude);

      // Use torso-normal projection so bench press direction stays stable even
      // when camera rotation swaps image X/Y axes.
      final torsoNormalX = -torsoDy / torsoMagnitude;
      final torsoNormalY = torsoDx / torsoMagnitude;
      final torsoUnitX = torsoDx / torsoMagnitude;
      final torsoUnitY = torsoDy / torsoMagnitude;
      final pressUnitX = pressDx / pressMagnitude;
      final pressUnitY = pressDy / pressMagnitude;
      final forearmUnitX = forearmDx / forearmMagnitude;
      final forearmUnitY = forearmDy / forearmMagnitude;
      final pressNormalAlignment =
          ((pressUnitX * torsoNormalX) + (pressUnitY * torsoNormalY))
              .abs()
              .clamp(0.0, 1.0)
              .toDouble();
      final forearmNormalAlignment =
          ((forearmUnitX * torsoNormalX) + (forearmUnitY * torsoNormalY))
              .abs()
              .clamp(0.0, 1.0)
              .toDouble();

      final perpendicularity =
          (1.0 - torsoDotPress.abs()).clamp(0.0, 1.0).toDouble();
      final forearmPerpendicularity =
          (1.0 - torsoDotForearm.abs()).clamp(0.0, 1.0).toDouble();
      final upwardLift = pressNormalAlignment;
      final forearmLift = forearmNormalAlignment;
      final armLength = upperArmMagnitude + forearmMagnitude;
      final wristLiftRatio =
          ((pressMagnitude / armLength) * pressNormalAlignment)
              .clamp(0.0, 1.0)
              .toDouble();
      final wristStackRatio =
          (1.0 -
                  (((pressDx * torsoUnitX) + (pressDy * torsoUnitY)).abs() /
                      (armLength * 0.45)))
              .clamp(0.0, 1.0)
              .toDouble();
      final forearmVerticalRatio =
          forearmNormalAlignment.clamp(0.0, 1.0).toDouble();
      final pressVerticalDeviationDegrees =
          degrees(acos(pressNormalAlignment.clamp(-1.0, 1.0))).clamp(0.0, 90.0);
      final forearmVerticalDeviationDegrees =
          degrees(acos(forearmNormalAlignment.clamp(-1.0, 1.0)))
              .clamp(0.0, 90.0);
      final pressVerticalToleranceScore =
          (1.0 - (pressVerticalDeviationDegrees / 32.0))
              .clamp(0.0, 1.0)
              .toDouble();
      final forearmVerticalToleranceScore =
          (1.0 - (forearmVerticalDeviationDegrees / 36.0))
              .clamp(0.0, 1.0)
              .toDouble();

      final confidence =
          (_resolveLandmarkConfidence(
                shoulder,
                allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
              ) +
              _resolveLandmarkConfidence(
                hip,
                allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
              ) +
              _resolveLandmarkConfidence(
                elbow,
                allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
              ) +
              _resolveLandmarkConfidence(
                wrist,
                allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
              )) /
          4.0;

      final alignmentScore =
          (0.05 +
                  0.95 *
                      ((wristStackRatio * 0.34) +
                          (forearmVerticalRatio * 0.28) +
                          (upwardLift * 0.18) +
                          (forearmLift * 0.06) +
                          (pressVerticalToleranceScore * 0.08) +
                          (forearmVerticalToleranceScore * 0.04) +
                          (perpendicularity * 0.06) +
                          (forearmPerpendicularity * 0.04)))
              .clamp(0.0, 1.0)
              .toDouble();

      sideCandidates.add({
        'confidence': confidence,
        'alignment': alignmentScore,
        'upward_lift': upwardLift,
        'forearm_lift': forearmLift,
        'perpendicularity': perpendicularity,
        'forearm_perpendicularity': forearmPerpendicularity,
        'wrist_lift_ratio': wristLiftRatio,
        'wrist_stack_ratio': wristStackRatio,
        'forearm_vertical_ratio': forearmVerticalRatio,
        'press_vertical_deviation_degrees': pressVerticalDeviationDegrees,
        'forearm_vertical_deviation_degrees': forearmVerticalDeviationDegrees,
        'press_vertical_tolerance_score': pressVerticalToleranceScore,
        'forearm_vertical_tolerance_score': forearmVerticalToleranceScore,
        'side': side == 'left' ? 0.0 : 1.0,
      });
    }

    addSideCandidate(
      side: 'left',
      shoulderType: PoseLandmarkType.leftShoulder,
      hipType: PoseLandmarkType.leftHip,
      elbowType: PoseLandmarkType.leftElbow,
      wristType: PoseLandmarkType.leftWrist,
    );
    addSideCandidate(
      side: 'right',
      shoulderType: PoseLandmarkType.rightShoulder,
      hipType: PoseLandmarkType.rightHip,
      elbowType: PoseLandmarkType.rightElbow,
      wristType: PoseLandmarkType.rightWrist,
    );

    if (sideCandidates.isEmpty) {
      return const {
        'bench_press_lockout_alignment': 0.0,
        'bench_press_vertical_lift': 0.0,
        'bench_press_forearm_lift': 0.0,
        'bench_press_press_perpendicularity': 0.0,
        'bench_press_top_path_valid': 0.0,
        'bench_press_wrist_lift_ratio': 0.0,
        'bench_press_wrist_stack_ratio': 0.0,
        'bench_press_forearm_vertical_ratio': 0.0,
        'bench_press_vertical_deviation_degrees': 90.0,
        'bench_press_forearm_vertical_deviation_degrees': 90.0,
        'bench_press_vertical_tolerance_score': 0.0,
        'bench_press_forearm_vertical_tolerance_score': 0.0,
        'bench_press_tracking_side': -1.0,
      };
    }

    sideCandidates.sort(
      (a, b) => _scoreBenchSideCandidate(b).compareTo(
        _scoreBenchSideCandidate(a),
      ),
    );

    var best = sideCandidates.first;
    if (_benchPressTrackingSide >= 0) {
      final currentSideCandidate = sideCandidates.firstWhere(
        (candidate) =>
            (candidate['side']?.round() ?? -1) == _benchPressTrackingSide,
        orElse: () => const <String, double>{},
      );

      if (currentSideCandidate.isNotEmpty) {
        final currentScore = _scoreBenchSideCandidate(currentSideCandidate);
        final bestScore = _scoreBenchSideCandidate(best);
        if ((bestScore - currentScore) < _benchPressSideSwitchMargin) {
          best = currentSideCandidate;
        }
      }
    }

    final alignment = best['alignment'] ?? 0.0;
    final upwardLift = best['upward_lift'] ?? 0.0;
    final forearmLift = best['forearm_lift'] ?? 0.0;
    final pressPerpendicularity = best['perpendicularity'] ?? 0.0;
    final wristLiftRatio = best['wrist_lift_ratio'] ?? 0.0;
    final wristStackRatio = best['wrist_stack_ratio'] ?? 0.0;
    final forearmVerticalRatio = best['forearm_vertical_ratio'] ?? 0.0;
    final verticalDeviationDegrees =
        best['press_vertical_deviation_degrees'] ?? 90.0;
    final forearmVerticalDeviationDegrees =
        best['forearm_vertical_deviation_degrees'] ?? 90.0;
    final verticalToleranceScore = best['press_vertical_tolerance_score'] ?? 0.0;
    final forearmVerticalToleranceScore =
        best['forearm_vertical_tolerance_score'] ?? 0.0;
    _benchPressTrackingSide = best['side']?.round() ?? -1;

    final rawMetrics = {
      'bench_press_lockout_alignment': alignment,
      'bench_press_vertical_lift': upwardLift,
      'bench_press_forearm_lift': forearmLift,
      'bench_press_press_perpendicularity': pressPerpendicularity,
      'bench_press_wrist_lift_ratio': wristLiftRatio,
      'bench_press_wrist_stack_ratio': wristStackRatio,
      'bench_press_forearm_vertical_ratio': forearmVerticalRatio,
      'bench_press_vertical_deviation_degrees': verticalDeviationDegrees,
      'bench_press_forearm_vertical_deviation_degrees':
          forearmVerticalDeviationDegrees,
      'bench_press_vertical_tolerance_score': verticalToleranceScore,
      'bench_press_forearm_vertical_tolerance_score':
          forearmVerticalToleranceScore,
      'bench_press_tracking_side': _benchPressTrackingSide.toDouble(),
    };

    final smoothedMetrics =
        _smoothBenchPressMetrics(rawMetrics, trackingSide: _benchPressTrackingSide);

    final smoothedTopPathValid =
        (smoothedMetrics['bench_press_vertical_deviation_degrees'] ?? 90.0) <=
                30.0 &&
            (smoothedMetrics['bench_press_forearm_vertical_deviation_degrees'] ??
                    90.0) <=
                35.0 &&
            (smoothedMetrics['bench_press_wrist_lift_ratio'] ?? 0.0) >= 0.018 &&
            (smoothedMetrics['bench_press_vertical_lift'] ?? 0.0) >= 0.020
        ? 1.0
        : 0.0;

    return {
      ...smoothedMetrics,
      'bench_press_top_path_valid': smoothedTopPathValid,
    };
  }

  double _scoreBenchSideCandidate(Map<String, double> candidate) {
    return ((candidate['confidence'] ?? 0.0) * 0.45) +
        ((candidate['alignment'] ?? 0.0) * 0.35) +
        ((candidate['upward_lift'] ?? 0.0) * 0.20);
  }

  Map<String, double> _smoothBenchPressMetrics(
    Map<String, double> rawMetrics, {
    required int trackingSide,
  }) {
    final previous = _lastBenchPressMetrics;
    if (previous == null ||
        (previous['bench_press_tracking_side']?.round() ?? -1) != trackingSide) {
      _lastBenchPressMetrics = Map<String, double>.from(rawMetrics);
      return _lastBenchPressMetrics!;
    }

    final smoothed = <String, double>{};
    rawMetrics.forEach((key, value) {
      if (key == 'bench_press_tracking_side') {
        smoothed[key] = value;
        return;
      }

      final previousValue = previous[key] ?? value;
      smoothed[key] =
          previousValue + ((value - previousValue) * _benchPressMetricSmoothingFactor);
    });
    smoothed['bench_press_tracking_side'] = trackingSide.toDouble();
    _lastBenchPressMetrics = smoothed;
    return smoothed;
  }

  Vector3 _landmarkToVector3(PoseLandmark landmark) {
    return Vector3(landmark.x, landmark.y, landmark.z);
  }

  bool _isFullBodyVisible(Pose pose) {
    const minLikelihood = 0.3;
    final allowMissingLikelihoodFallback = !_poseHasExplicitLikelihoods(pose);

    final bool leftShoulderVisible = _isLandmarkReliable(
      pose.landmarks[PoseLandmarkType.leftShoulder],
      allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
      minLikelihood: minLikelihood,
    );
    final bool rightShoulderVisible = _isLandmarkReliable(
      pose.landmarks[PoseLandmarkType.rightShoulder],
      allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
      minLikelihood: minLikelihood,
    );
    final bool leftHipVisible = _isLandmarkReliable(
      pose.landmarks[PoseLandmarkType.leftHip],
      allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
      minLikelihood: minLikelihood,
    );
    final bool rightHipVisible = _isLandmarkReliable(
      pose.landmarks[PoseLandmarkType.rightHip],
      allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
      minLikelihood: minLikelihood,
    );
    final bool leftKneeVisible = _isLandmarkReliable(
      pose.landmarks[PoseLandmarkType.leftKnee],
      allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
      minLikelihood: minLikelihood,
    );
    final bool rightKneeVisible = _isLandmarkReliable(
      pose.landmarks[PoseLandmarkType.rightKnee],
      allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
      minLikelihood: minLikelihood,
    );

    return leftShoulderVisible &&
        rightShoulderVisible &&
        leftHipVisible &&
        rightHipVisible &&
        leftKneeVisible &&
        rightKneeVisible;
  }

  bool _isLandmarkVisible(
    Pose pose,
    PoseLandmarkType type,
    double minLikelihood,
  ) {
    return _isLandmarkReliable(
      pose.landmarks[type],
      allowMissingLikelihoodFallback: !_poseHasExplicitLikelihoods(pose),
      minLikelihood: minLikelihood,
    );
  }



  Future<void> processCameraImage(
    CameraImage cameraImage,
    InputImageRotation rotation,
    Size imageSize,
    String exerciseId,
    Map<String, dynamic> exerciseConfig,
  ) async {
    // Ã¢Å“â€¦ FIX 1: Correct InputImage creation
    InputImage inputImage;
    try {
      inputImage = _createCorrectInputImage(cameraImage, rotation);
      print('Ã¢Å“â€¦ Created InputImage successfully');
    } catch (e) {
      print('Ã¢ÂÅ’ Error creating InputImage: $e');
      // Try alternative method
      inputImage = _createInputImageFromBytes(cameraImage, rotation);
    }

    await _processInputImageInternal(
      inputImage: inputImage,
      exerciseId: exerciseId,
      exerciseConfig: exerciseConfig,
    );
  }

  Future<void> processInputImage({
    required InputImage inputImage,
    required String exerciseId,
    required Map<String, dynamic> exerciseConfig,
  }) async {
    await _processInputImageInternal(
      inputImage: inputImage,
      exerciseId: exerciseId,
      exerciseConfig: exerciseConfig,
    );
  }

  Future<void> _processInputImageInternal({
    required InputImage inputImage,
    required String exerciseId,
    required Map<String, dynamic> exerciseConfig,
  }) async {
    // Skip if already processing
    if (_isProcessing) {
      print('Ã¢ÂÂ­Ã¯Â¸Â Skipping frame - already processing');
      return;
    }

    _isProcessing = true;

    try {
      print('\nÃ°Å¸Å½Â¬ === PROCESSING FRAME ${++_processingFrameCount} ===');
      print('Ã°Å¸â€Â Calling pose detector...');

      // Test pose detector
      List<Pose> poses = [];
      try {
        final poseDetector = _poseDetector;
        if (poseDetector == null) {
          _emitTransientAwareFailure();
          return;
        }
        poses = await poseDetector.processImage(inputImage);
        print('Ã¢Å“â€¦ Pose detection completed. Found ${poses.length} poses');
      } catch (e) {
        print('Ã¢ÂÅ’ Pose detector error: $e');
        _emitTransientAwareFailure();
        return;
      }

      if (poses.isEmpty) {
        print('Ã¢ÂÅ’ No poses detected in this frame');
        _emitTransientAwareFailure();
        return;
      }

      // Ã¢Å“â€¦ IMPORTANT: Ã¡â‚¬â„¢Ã¡â‚¬Â°Ã¡â‚¬â€ºÃ¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸ code Ã¡â‚¬ÂÃ¡â‚¬Â½Ã¡â‚¬Â± Ã¡â‚¬â€¢Ã¡â‚¬Â¼Ã¡â‚¬â€Ã¡â‚¬ÂºÃ¡â‚¬â€˜Ã¡â‚¬Å Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬â€ºÃ¡â‚¬â„¢Ã¡â‚¬Å¡Ã¡â‚¬Âº
      // Process detected pose
      print('Ã°Å¸Å½â€° Pose detected!');
      final Pose primaryPose = _getPrimaryPose(poses);
      final allowMissingLikelihoodFallback =
          !_poseHasExplicitLikelihoods(primaryPose);
      if (allowMissingLikelihoodFallback) {
        print(
            'Ã¢Å¡Â Ã¯Â¸Â Pose landmarks do not expose confidence values, using fallback visibility checks');
      }

      final bool isFullBodyVisible = _isFullBodyVisible(primaryPose);
      // final bool isPushupSideVisible =
      //     exerciseId == 'pushup' && _isPushupSideVisible(primaryPose);
      if (!isFullBodyVisible) {
        print(
            'Ã¢Å¡Â Ã¯Â¸Â Full body not visible - continuing with available landmarks');
        // if (isPushupSideVisible) {
        //   print('Ã¢Å¡Â Ã¯Â¸Â Push-up side view detected - allowing single-side tracking');
        // }
      }

      // Check landmark confidence
      final goodLandmarks = primaryPose.landmarks.values
          .where(
            (landmark) => _isLandmarkReliable(
              landmark,
              allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
              minLikelihood: _minReliableLandmarkLikelihood,
            ),
          )
          .toList();

      print('Ã°Å¸â€œË† ${goodLandmarks.length}/33 landmarks with confidence > 0.5');

      if (goodLandmarks.isEmpty) {
        print('Ã¢Å¡Â Ã¯Â¸Â No landmarks with sufficient confidence');
        _emitTransientAwareFailure(
          pose: primaryPose,
        );
        return;
      }

      // Calculate joint angles
      final jointAngles = _calculateJointAngles(
        primaryPose,
        exerciseConfig,
      );
      // if (isPushupSideVisible) {
      //   // Mark side-view to avoid upright guards blocking push-up accuracy.
      //   jointAngles['pushup_side_view'] = 1.0;
      // }

      // Check form
      final formWarnings = _checkForm(
        primaryPose,
        jointAngles,
        exerciseConfig,
      );
      if (!isFullBodyVisible) {
        _emitTransientAwareFailure(
          pose: primaryPose,
          jointAngles: const {},
          formWarnings: formWarnings,
          isPoseDetected: true,
        );
        return;
      }

      // Calculate accuracy
      final rawAccuracy = _calculateUniversalAccuracy(
        jointAngles,
        formWarnings,
        exerciseConfig,
      );

      // Ã¢Å“â€¦ FIX 2: Better pose confidence calculation
      double poseConfidence = _calculateImprovedPoseConfidence(primaryPose);
      // if (exerciseId == 'pushup' ) {//&& isPushupSideVisible
      //  // final sideConfidence = _calculatePushupSideConfidence(primaryPose);
      //   if (sideConfidence > poseConfidence) {
      //     print(
      //         'Ã¢Å“â€¦ Using push-up side confidence: ${(sideConfidence * 100).toStringAsFixed(1)}%');
      //   }
      //   poseConfidence = max(poseConfidence, sideConfidence);
      //   if (poseConfidence < 0.45) {
      //     poseConfidence = 0.45;
      //     print(
      //         'Ã¢Å“â€¦ Push-up side view confidence boost: ${(poseConfidence * 100).toStringAsFixed(1)}%');
      //   }
      // }

      if (poseConfidence < _minAcceptedPoseConfidence) {
        print(
            'Ã¢Å¡Â Ã¯Â¸Â Low pose confidence: ${(poseConfidence * 100).toStringAsFixed(1)}%');
        _emitTransientAwareFailure(
          pose: primaryPose,
          jointAngles: jointAngles,
          formWarnings: formWarnings,
        );
        return;
      }

      // Ã¢Å“â€¦ Apply smoothing
      final String? exerciseId = (exerciseConfig['id'] ?? exerciseConfig['exerciseId']) as String?;
      final smoothedAccuracy =
          _smoothAccuracyValue(rawAccuracy, poseConfidence, jointAngles, exerciseId: exerciseId);

      print('Raw Accuracy: ${(rawAccuracy * 100).toStringAsFixed(1)}%');
      print('Pose Confidence: ${(poseConfidence * 100).toStringAsFixed(1)}%');
      print(
          'Smoothed Accuracy: ${(smoothedAccuracy * 100).toStringAsFixed(1)}%');
      print('Ã°Å¸â€œÂ Joint angles: $jointAngles');

      // Send final result with ALL data
      _emitDetectionResult(PoseDetectionResult(
        pose: primaryPose,
        jointAngles: jointAngles,
        formWarnings: formWarnings,
        overallAccuracy: smoothedAccuracy,
        isPoseDetected: true,
        timestamp: DateTime.now(),
      ), cache: true);
    } catch (e, stackTrace) {
      print('Ã¢ÂÅ’Ã¢ÂÅ’Ã¢ÂÅ’ CRITICAL ERROR in processCameraImage: $e');
      print('Stack trace: $stackTrace');

      // Send error result
      _ensureResultController().add(PoseDetectionResult(
        pose: null,
        jointAngles: {},
        formWarnings: [
          FormWarning(
            warningId: 'processing_error',
            message: 'Error processing frame',
            timestamp: DateTime.now(),
          )
        ],
        overallAccuracy: 0.0,
        isPoseDetected: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isProcessing = false;
    }
  }

// Ã¢Å“â€¦ FIX 3: Correct InputImage creation for ML Kit
  InputImage _createCorrectInputImage(
      CameraImage cameraImage, InputImageRotation rotation) {
    if (cameraImage.planes.isEmpty) {
      throw Exception('CameraImage has no planes');
    }

    // For Android (YUV format)
    if (Platform.isAndroid) {
      return _createAndroidInputImage(cameraImage, rotation);
    }
    // For iOS
    else {
      return _createIOSInputImage(cameraImage, rotation);
    }
  }

  InputImage _createAndroidInputImage(
      CameraImage cameraImage, InputImageRotation rotation) {
    // Android Ã¡â‚¬Â¡Ã¡â‚¬ÂÃ¡â‚¬Â½Ã¡â‚¬â‚¬Ã¡â‚¬Âº NV21 format Ã¡â‚¬â€¢Ã¡â‚¬Â¼Ã¡â‚¬Â±Ã¡â‚¬Â¬Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸Ã¡â‚¬ÂÃ¡â‚¬Â¼Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸
    final plane = cameraImage.planes[0];
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    // Get actual image dimensions from camera
    final Size imageSize = Size(width.toDouble(), height.toDouble());

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  InputImage _createIOSInputImage(
      CameraImage cameraImage, InputImageRotation rotation) {
    // iOS Ã¡â‚¬Â¡Ã¡â‚¬ÂÃ¡â‚¬Â½Ã¡â‚¬â‚¬Ã¡â‚¬Âº BGRA format
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final Size imageSize = Size(width.toDouble(), height.toDouble());
    final plane = cameraImage.planes[0];

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: InputImageFormat.bgra8888,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  InputImage _createInputImageFromBytes(
      CameraImage cameraImage, InputImageRotation rotation) {
    // Fallback method
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final Size imageSize = Size(width.toDouble(), height.toDouble());

    final plane = cameraImage.planes[0];

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

// Ã¢Å“â€¦ FIX 4: Better pose confidence calculation
  double _calculateImprovedPoseConfidence(Pose pose) {
    final allowMissingLikelihoodFallback = !_poseHasExplicitLikelihoods(pose);

    // Essential landmarks for accuracy calculation
    final Map<PoseLandmarkType, String> essentialLandmarks = {
      PoseLandmarkType.leftShoulder: "Left Shoulder",
      PoseLandmarkType.rightShoulder: "Right Shoulder",
      PoseLandmarkType.leftElbow: "Left Elbow",
      PoseLandmarkType.rightElbow: "Right Elbow",
      PoseLandmarkType.leftHip: "Left Hip",
      PoseLandmarkType.rightHip: "Right Hip",
      PoseLandmarkType.leftKnee: "Left Knee",
      PoseLandmarkType.rightKnee: "Right Knee",
      PoseLandmarkType.leftAnkle: "Left Ankle",
      PoseLandmarkType.rightAnkle: "Right Ankle",
    };

    double totalConfidence = 0.0;
    int detectedLandmarks = 0;

    for (final entry in essentialLandmarks.entries) {
      final landmark = pose.landmarks[entry.key];
      if (_isLandmarkReliable(
        landmark,
        allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        minLikelihood: 0.1,
      )) {
        final landmarkConfidence = _resolveLandmarkConfidence(
          landmark!,
          allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        );
        detectedLandmarks++;
        totalConfidence += landmarkConfidence;

        print(
            'Ã°Å¸â€œÂ ${entry.value}: ${(landmarkConfidence * 100).toStringAsFixed(1)}%');
      }
    }

    if (detectedLandmarks == 0) return 0.0;

    final double averageConfidence = totalConfidence / detectedLandmarks;
    final double detectionRatio = detectedLandmarks / essentialLandmarks.length;

    // Combined score: 60% average confidence + 40% detection ratio
    final double combinedScore =
        (averageConfidence * 0.6) + (detectionRatio * 0.4);

    print('Ã°Å¸â€œÅ  POSE CONFIDENCE REPORT:');
    print(
        '   Detected landmarks: $detectedLandmarks/${essentialLandmarks.length}');
    print(
        '   Average confidence: ${(averageConfidence * 100).toStringAsFixed(1)}%');
    print('   Detection ratio: ${(detectionRatio * 100).toStringAsFixed(1)}%');
    print('   Combined score: ${(combinedScore * 100).toStringAsFixed(1)}%');

    return combinedScore.clamp(0.0, 1.0);
  }

// Add this helper function for testing
  void _sendSimulatedPose(Map<String, dynamic> exerciseConfig) {
    print('Ã°Å¸â€â€ž Sending simulated pose for testing');

    final simulatedAngles = {
      'knee': 120.0,
      'hip': 90.0,
      'shoulder': 170.0,
    };

    _ensureResultController().add(PoseDetectionResult(
      pose: null,
      jointAngles: simulatedAngles,
      formWarnings: [],
      overallAccuracy: 0.7, // 70% accuracy for testing
      isPoseDetected: true,
      timestamp: DateTime.now(),
    ));
  }

  Pose _getPrimaryPose(List<Pose> poses) {
    // Select pose with highest confidence and closest to camera
    if (poses.length == 1) return poses.first;

    return poses.reduce((a, b) {
      final allowMissingLikelihoodFallbackA = !_poseHasExplicitLikelihoods(a);
      final allowMissingLikelihoodFallbackB = !_poseHasExplicitLikelihoods(b);
      final aConfidence = a.landmarks.values
              .map(
                (landmark) => _resolveLandmarkConfidence(
                  landmark,
                  allowMissingLikelihoodFallback:
                      allowMissingLikelihoodFallbackA,
                ),
              )
              .fold(0.0, (sum, c) => sum + c) /
          a.landmarks.length;

      final bConfidence = b.landmarks.values
              .map(
                (landmark) => _resolveLandmarkConfidence(
                  landmark,
                  allowMissingLikelihoodFallback:
                      allowMissingLikelihoodFallbackB,
                ),
              )
              .fold(0.0, (sum, c) => sum + c) /
          b.landmarks.length;

      // Consider depth (z-coordinate) for proximity
      final aDepth = a.landmarks[PoseLandmarkType.leftHip]?.z ?? 0;
      final bDepth = b.landmarks[PoseLandmarkType.leftHip]?.z ?? 0;

      // Lower z means closer to camera
      final aScore = aConfidence * (1 / (1 + aDepth.abs()));
      final bScore = bConfidence * (1 / (1 + bDepth.abs()));

      return aScore > bScore ? a : b;
    });
  }

  Map<String, double> _calculateJointAngles(
    Pose pose,
    Map<String, dynamic> exerciseConfig,
  ) {
    final Map<String, double> angles = {};

    print('\nÃ°Å¸â€Â¢ === CALCULATING ALL JOINT ANGLES ===');

    // Always calculate primary joint angle first
    Map<String, dynamic>? repLogic;
    final rawRepLogic =
        exerciseConfig['rep_logic'] ?? exerciseConfig['repLogic'];
    if (rawRepLogic is Map<String, dynamic>) {
      repLogic = rawRepLogic;
    } else if (rawRepLogic is RepLogic) {
      repLogic = _repLogicToMap(rawRepLogic);
    }
    if (repLogic == null) {
      final resolvedId =
          (exerciseConfig['id'] ?? exerciseConfig['exerciseId']) as String?;
      if (resolvedId != null && resolvedId.isNotEmpty) {
        try {
          final fallbackConfig = ExerciseConfig.getExerciseById(resolvedId);
          repLogic = fallbackConfig['rep_logic'] as Map<String, dynamic>?;
        } catch (_) {
          // Keep null if not found.
        }
      }
    }
    if (repLogic != null) {
      if (!repLogic.containsKey('alternative_joints')) {
        final derivedAlternatives =
            _deriveAlternativeJoints(repLogic['primary_joint'] as String?);
        if (derivedAlternatives.isNotEmpty) {
          repLogic['alternative_joints'] = derivedAlternatives;
        }
      }
      final primaryJoint = repLogic['primary_joint'] as String? ?? 'knee';

      print('Ã°Å¸Å½Â¯ Primary Joint: $primaryJoint');
      final primaryAngle = _calculateJointAngle(pose, primaryJoint);

      if (primaryAngle > 0) {
        angles[primaryJoint] = primaryAngle;
        print(
            'Ã¢Å“â€¦ Added primary angle: $primaryJoint = ${primaryAngle.toStringAsFixed(1)}Ã‚Â°');
      } else {
        print('Ã¢ÂÅ’ Failed to calculate primary angle for: $primaryJoint');
        // Try alternative joints if primary is missing
        final alternativeJoints =
            (repLogic['alternative_joints'] as List<dynamic>?)
                    ?.cast<String>() ??
                [];
        for (final alt in alternativeJoints) {
          final altAngle = _calculateJointAngle(pose, alt);
          if (altAngle > 0) {
            angles[alt] = altAngle;
            angles[primaryJoint] = altAngle; // map back to primary
            print(
                'Ã¢Å“â€¦ Added alternative angle: $alt = ${altAngle.toStringAsFixed(1)}Ã‚Â°');
            print('Ã¢Å“â€¦ Mapped $alt to primary $primaryJoint');
            break;
          }
        }
      }
    }

    // Calculate angles for all form checks
    final rawFormChecks =
        exerciseConfig['form_checks'] ?? exerciseConfig['formChecks'];
    final formChecks = rawFormChecks is List ? rawFormChecks : const [];
    print('Ã°Å¸â€œâ€¹ Form checks count: ${formChecks.length}');

    for (int i = 0; i < formChecks.length; i++) {
      final check = formChecks[i];
      Map<String, dynamic>? checkMap;
      if (check is Map<String, dynamic>) {
        checkMap = check;
      } else if (check is FormCheck) {
        checkMap = {
          'joints': check.joints,
        };
      }
      if (checkMap == null) {
        continue;
      }
      final joints =
          (checkMap['joints'] as List<dynamic>?)?.cast<String>() ?? [];

      if (joints.length == 3) {
        final startJoint = joints[0];
        final vertexJoint = joints[1];
        final endJoint = joints[2];

        final angleName = '${startJoint}_${vertexJoint}_${endJoint}';
        print('\nÃ°Å¸â€â€ž Calculating form check angle $i: $angleName');

        final angle = _calculateJointAngle(
          pose,
          vertexJoint,
          startJoint: startJoint,
          endJoint: endJoint,
        );

        if (angle > 0) {
          angles[angleName] = angle;
          print(
              'Ã¢Å“â€¦ Added form check angle: $angleName = ${angle.toStringAsFixed(1)}Ã‚Â°');
          if (vertexJoint == 'elbow' && !angles.containsKey('elbow')) {
            angles['elbow'] = angle;
            print('Ã¢Å“â€¦ Mapped form check elbow angle to primary elbow');
          }
        } else {
          print('Ã¢ÂÅ’ Failed to calculate form check angle: $angleName');
        }
      }
    }

    // Always calculate basic angles even if not in config
    if (!angles.containsKey('knee')) {
      final kneeAngle = _calculateKneeAngleFromLandmarks(pose);
      if (kneeAngle > 0) {
        angles['knee'] = kneeAngle;
        print('Ã¢Å“â€¦ Added basic knee angle: ${kneeAngle.toStringAsFixed(1)}Ã‚Â°');
      }
    }

    if (!angles.containsKey('hip')) {
      final hipAngle = _calculateJointAngle(pose, 'hip');
      if (hipAngle > 0) {
        angles['hip'] = hipAngle;
        print('Ã¢Å“â€¦ Added basic hip angle: ${hipAngle.toStringAsFixed(1)}Ã‚Â°');
      }
    }

    if (!angles.containsKey('elbow')) {
      final elbowAngle = _calculateJointAngle(pose, 'elbow');
      if (elbowAngle > 0) {
        angles['elbow'] = elbowAngle;
        print(
            'Ã¢Å“â€¦ Added basic elbow angle: ${elbowAngle.toStringAsFixed(1)}Ã‚Â°');
      }
    }

    final resolvedExerciseId =
        (exerciseConfig['id'] ?? exerciseConfig['exerciseId']) as String?;

    if (resolvedExerciseId == 'pushup' || resolvedExerciseId == 'bench_press') {
      // 1. Elbow angles (standard)
      if (!angles.containsKey('left_elbow')) {
        final leftElbow = _calculateJointAngle(pose, 'left_elbow');
        if (leftElbow > 0) {
          angles['left_elbow'] = leftElbow;
          print('âœ… Added left elbow: ${leftElbow.toStringAsFixed(1)}Â°');
        }
      }
      if (!angles.containsKey('right_elbow')) {
        final rightElbow = _calculateJointAngle(pose, 'right_elbow');
        if (rightElbow > 0) {
          angles['right_elbow'] = rightElbow;
          print('âœ… Added right elbow: ${rightElbow.toStringAsFixed(1)}Â°');
        }
      }

      // 2. Elbow triplets (as alternative keys)
      if (!angles.containsKey('left_shoulder_left_elbow_left_wrist')) {
        final leftTriplet = _calculateJointAngle(
          pose,
          'left_elbow',
          startJoint: 'left_shoulder',
          endJoint: 'left_wrist',
        );
        if (leftTriplet > 0) {
          angles['left_shoulder_left_elbow_left_wrist'] = leftTriplet;
          print(
              'âœ… Added left elbow triplet: ${leftTriplet.toStringAsFixed(1)}Â°');
        }
      }
      if (!angles.containsKey('right_shoulder_right_elbow_right_wrist')) {
        final rightTriplet = _calculateJointAngle(
          pose,
          'right_elbow',
          startJoint: 'right_shoulder',
          endJoint: 'right_wrist',
        );
        if (rightTriplet > 0) {
          angles['right_shoulder_right_elbow_right_wrist'] = rightTriplet;
          print(
              'âœ… Added right elbow triplet: ${rightTriplet.toStringAsFixed(1)}Â°');
        }
      }

      // 3. Generic elbow triplet (tries both sides)
      if (!angles.containsKey('shoulder_elbow_wrist')) {
        double? bestAngle;
        // Try left side
        final leftTry = _calculateJointAngle(
          pose,
          'left_elbow',
          startJoint: 'left_shoulder',
          endJoint: 'left_wrist',
        );
        if (leftTry > 0) bestAngle = leftTry;
        // Try right side
        final rightTry = _calculateJointAngle(
          pose,
          'right_elbow',
          startJoint: 'right_shoulder',
          endJoint: 'right_wrist',
        );
        if (rightTry > 0) {
          if (bestAngle == null || rightTry > 0) bestAngle = rightTry;
        }
        if (bestAngle != null) {
          angles['shoulder_elbow_wrist'] = bestAngle;
          print(
              'âœ… Added generic elbow triplet: ${bestAngle.toStringAsFixed(1)}Â°');
        }
      }

      // 4. Body angle (shoulder-hip-ankle)
      if (!angles.containsKey('shoulder_hip_ankle')) {
        final bodyAngle = _calculateShoulderHipAnkleAngle(pose);
        if (bodyAngle > 0) {
          angles['shoulder_hip_ankle'] = bodyAngle;
          print('âœ… Added body angle: ${bodyAngle.toStringAsFixed(1)}Â°');
        }
      }

      // 5. Back angle (shoulder-hip-knee)
      if (!angles.containsKey('shoulder_hip_knee')) {
        final backAngle = _calculateBackAngle(pose);
        if (backAngle > 0) {
          angles['shoulder_hip_knee'] = backAngle;
          print('âœ… Added back angle: ${backAngle.toStringAsFixed(1)}Â°');
        }
      }

      // 6. Torso upright ratio (for standing detection)
      if (!angles.containsKey('torso_upright_ratio')) {
        final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
        final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
        final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
        final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

        const minLikelihood = 0.2;
        final ratios = <double>[];

        if (leftShoulder != null &&
            leftHip != null &&
            leftShoulder.likelihood > minLikelihood &&
            leftHip.likelihood > minLikelihood) {
          final dx = (leftShoulder.x - leftHip.x).abs();
          final dy = (leftShoulder.y - leftHip.y).abs();
          if (dx > 0) ratios.add(dy / dx);
        }

        if (rightShoulder != null &&
            rightHip != null &&
            rightShoulder.likelihood > minLikelihood &&
            rightHip.likelihood > minLikelihood) {
          final dx = (rightShoulder.x - rightHip.x).abs();
          final dy = (rightShoulder.y - rightHip.y).abs();
          if (dx > 0) ratios.add(dy / dx);
        }

        if (ratios.isNotEmpty) {
          final uprightRatio = ratios.reduce(min);
          angles['torso_upright_ratio'] = uprightRatio;
          print(
              'âœ… Added torso upright ratio: ${uprightRatio.toStringAsFixed(3)}');
        }
      }

      if (resolvedExerciseId == 'bench_press') {
        final benchMetrics = _calculateBenchPressPathMetrics(pose);
        angles.addAll(benchMetrics);
        print(
            'âœ… Added bench press path metrics: alignment=${(benchMetrics['bench_press_lockout_alignment']! * 100).toStringAsFixed(1)}%, vertical=${(benchMetrics['bench_press_vertical_lift']! * 100).toStringAsFixed(1)}%, topValid=${benchMetrics['bench_press_top_path_valid']!.toStringAsFixed(0)}');
      }
    }

    // Calculate back angle for squat
    if (resolvedExerciseId == 'squat' &&
        !angles.containsKey('shoulder_hip_knee')) {
      final backAngle = _calculateBackAngle(pose);
      if (backAngle > 0) {
        angles['shoulder_hip_knee'] = backAngle;
        print('Ã¢Å“â€¦ Added back angle: ${backAngle.toStringAsFixed(1)}Ã‚Â°');
      }
    }

    // Push-up: add a torso upright ratio to filter standing posture
    if (!angles.containsKey('torso_upright_ratio')) {
      //resolvedExerciseId == 'pushup' &&
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

      const minLikelihood = 0.2;
      final ratios = <double>[];

      if (leftShoulder != null &&
          leftHip != null &&
          leftShoulder.likelihood > minLikelihood &&
          leftHip.likelihood > minLikelihood) {
        final dx = (leftShoulder.x - leftHip.x).abs();
        final dy = (leftShoulder.y - leftHip.y).abs();
        ratios.add(dy / max(dx, 1.0));
      }

      if (rightShoulder != null &&
          rightHip != null &&
          rightShoulder.likelihood > minLikelihood &&
          rightHip.likelihood > minLikelihood) {
        final dx = (rightShoulder.x - rightHip.x).abs();
        final dy = (rightShoulder.y - rightHip.y).abs();
        ratios.add(dy / max(dx, 1.0));
      }

      if (ratios.isNotEmpty) {
        final uprightRatio = ratios.reduce(min);
        angles['torso_upright_ratio'] = uprightRatio;
        print('Added torso upright ratio: ${uprightRatio.toStringAsFixed(3)}');
      }
    }

    if (resolvedExerciseId == 'lateral_raise' ||
        resolvedExerciseId == 'front_raise') {
      if (!angles.containsKey('left_shoulder')) {
        final leftShoulder = _calculateJointAngle(pose, 'left_shoulder');
        if (leftShoulder > 0) {
          angles['left_shoulder'] = leftShoulder;
          print('âœ… Added left shoulder: ${leftShoulder.toStringAsFixed(1)}Â°');
        }
      }
      if (!angles.containsKey('right_shoulder')) {
        final rightShoulder = _calculateJointAngle(pose, 'right_shoulder');
        if (rightShoulder > 0) {
          angles['right_shoulder'] = rightShoulder;
          print('âœ… Added right shoulder: ${rightShoulder.toStringAsFixed(1)}Â°');
        }
      }
      if (!angles.containsKey('left_elbow')) {
        final leftElbow = _calculateJointAngle(pose, 'left_elbow');
        if (leftElbow > 0) {
          angles['left_elbow'] = leftElbow;
          print('âœ… Added left elbow: ${leftElbow.toStringAsFixed(1)}Â°');
        }
      }
      if (!angles.containsKey('right_elbow')) {
        final rightElbow = _calculateJointAngle(pose, 'right_elbow');
        if (rightElbow > 0) {
          angles['right_elbow'] = rightElbow;
          print('âœ… Added right elbow: ${rightElbow.toStringAsFixed(1)}Â°');
        }
      }
    }

    // Squat/Bicep/Leg Extension/Lateral Raise/Front Raise: add a simple front-view ratio (body width vs torso height)
    if ((resolvedExerciseId == 'squat' ||
            resolvedExerciseId == 'bicep_curl' ||
            resolvedExerciseId == 'leg_extension' ||
            resolvedExerciseId == 'lateral_raise' ||
            resolvedExerciseId == 'front_raise') &&
        !angles.containsKey('front_view_ratio')) {
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

      const minLikelihood = 0.2;
      if (leftShoulder != null &&
          rightShoulder != null &&
          leftShoulder.likelihood > minLikelihood &&
          rightShoulder.likelihood > minLikelihood) {
        final shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
        final torsoHeights = <double>[];
        if (leftHip != null && leftHip.likelihood > minLikelihood) {
          torsoHeights.add((leftShoulder.y - leftHip.y).abs());
        }
        if (rightHip != null && rightHip.likelihood > minLikelihood) {
          torsoHeights.add((rightShoulder.y - rightHip.y).abs());
        }

        if (torsoHeights.isNotEmpty) {
          final torsoHeight = max(
              torsoHeights.reduce((a, b) => a + b) / torsoHeights.length, 1.0);
          double bodyWidth = shoulderWidth;
          if (leftHip != null &&
              rightHip != null &&
              leftHip.likelihood > minLikelihood &&
              rightHip.likelihood > minLikelihood) {
            final hipWidth = (leftHip.x - rightHip.x).abs();
            bodyWidth = (shoulderWidth + hipWidth) / 2;
          }

          final viewRatio = bodyWidth / torsoHeight;
          angles['front_view_ratio'] = viewRatio;
          print('Added front view ratio: ${viewRatio.toStringAsFixed(3)}');
        }
      }
    }

    // Sit-up: add body line angle to detect upright/chair posture
    // if (resolvedExerciseId == 'situp' &&
    //     !angles.containsKey('shoulder_hip_ankle')) {
    //   final bodyAngle = _calculateShoulderHipAnkleAngle(pose);
    //   if (bodyAngle > 0) {
    //     angles['shoulder_hip_ankle'] = bodyAngle;
    //     print('Ã¢Å“â€¦ Added body angle: ${bodyAngle.toStringAsFixed(1)}Ã‚Â°');
    //   }
    // }
    // if (resolvedExerciseId == 'situp' &&
    //     !angles.containsKey('shoulder_hip_knee')) {
    //   final backAngle = _calculateBackAngle(pose);
    //   if (backAngle > 0) {
    //     angles['shoulder_hip_knee'] = backAngle;
    //     print('Ã¢Å“â€¦ Added back angle: ${backAngle.toStringAsFixed(1)}Ã‚Â°');
    //   }
    // }

    if (resolvedExerciseId == 'situp') {
      // Sit-up Ã¡â‚¬Â¡Ã¡â‚¬ÂÃ¡â‚¬Â½Ã¡â‚¬â‚¬Ã¡â‚¬Âº Ã¡â‚¬â„¢Ã¡â‚¬Â¾Ã¡â‚¬â€Ã¡â‚¬ÂºÃ¡â‚¬â‚¬Ã¡â‚¬â€Ã¡â‚¬ÂºÃ¡â‚¬Å¾Ã¡â‚¬Â±Ã¡â‚¬Â¬ angle Ã¡â‚¬â„¢Ã¡â‚¬Â»Ã¡â‚¬Â¬Ã¡â‚¬Â¸
      final backAngle = _calculateBackAngle(pose);
      if (backAngle > 0) {
        angles['shoulder_hip_knee'] = backAngle;
        print('Ã¢Å“â€¦ Sit-up back angle: ${backAngle.toStringAsFixed(1)}Ã‚Â°');
      }

      // Hip angle (Ã¡â‚¬â€¢Ã¡â‚¬Â±Ã¡â‚¬Â«Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬â€Ã¡â‚¬Â²Ã¡â‚¬Â·Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬Å¡Ã¡â‚¬ÂºÃ¡â‚¬â€˜Ã¡â‚¬Å Ã¡â‚¬ÂºÃ¡â‚¬â‚¬Ã¡â‚¬Â¼Ã¡â‚¬Â¬Ã¡â‚¬Â¸)
      final hipAngle = _calculateJointAngle(pose, 'hip');
      if (hipAngle > 0) {
        angles['hip'] = hipAngle;
        print('Ã¢Å“â€¦ Sit-up hip angle: ${hipAngle.toStringAsFixed(1)}Ã‚Â°');
      }

      // Torso angle (Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬Å¡Ã¡â‚¬ÂºÃ¡â‚¬â€˜Ã¡â‚¬Å Ã¡â‚¬ÂºÃ¡â‚¬ÂÃ¡â‚¬Å Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬â„¢Ã¡â‚¬ÂÃ¡â‚¬ÂºÃ¡â‚¬â„¢Ã¡â‚¬Â¾Ã¡â‚¬Â¯)
      final torsoAngle = _calculateShoulderHipAnkleAngle(pose);
      if (torsoAngle > 0) {
        angles['torso_angle'] = torsoAngle;
        print('Ã¢Å“â€¦ Sit-up torso angle: ${torsoAngle.toStringAsFixed(1)}Ã‚Â°');
      }
    }

    // Shoulder press: add a simple "elbow raised" flag using landmarks
    if (resolvedExerciseId == 'shoulder_press') {
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];

      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

      bool leftRaised = false;
      bool rightRaised = false;

      if (leftShoulder != null &&
          leftElbow != null &&
          leftHip != null &&
          leftShoulder.likelihood > 0.2 &&
          leftElbow.likelihood > 0.2 &&
          leftHip.likelihood > 0.2) {
        final torso = (leftShoulder.y - leftHip.y).abs();
        final threshold = torso * 0.08; // small margin above shoulder
        leftRaised = leftElbow.y < (leftShoulder.y - threshold);
      }

      if (rightShoulder != null &&
          rightElbow != null &&
          rightHip != null &&
          rightShoulder.likelihood > 0.2 &&
          rightElbow.likelihood > 0.2 &&
          rightHip.likelihood > 0.2) {
        final torso = (rightShoulder.y - rightHip.y).abs();
        final threshold = torso * 0.08;
        rightRaised = rightElbow.y < (rightShoulder.y - threshold);
      }

      angles['elbow_raised'] = (leftRaised || rightRaised) ? 1.0 : 0.0;
      print('Ã¢Å“â€¦ Elbow raised flag: ${angles['elbow_raised']}');
    }

    print('\nÃ°Å¸â€œÅ  FINAL ANGLES CALCULATED:');
    if (angles.isEmpty) {
      print('Ã¢ÂÅ’ NO ANGLES CALCULATED!');
    } else {
      angles.forEach((key, value) {
        print('   $key: ${value.toStringAsFixed(1)}Ã‚Â°');
      });
    }
    

    return angles;
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

  bool _isSideSpecificJointName(String jointName) {
    final normalized = jointName.toLowerCase();
    return normalized.contains('left_') || normalized.contains('right_');
  }

  String _applySideToJointName(String jointName, String side) {
    if (_isSideSpecificJointName(jointName)) {
      return jointName;
    }
    return '${side}_${jointName.toLowerCase()}';
  }

  String? _inferSideFromJointNames(List<String> joints) {
    bool hasLeft = false;
    bool hasRight = false;
    for (final joint in joints) {
      final normalized = joint.toLowerCase();
      if (normalized.contains('left_')) {
        hasLeft = true;
      }
      if (normalized.contains('right_')) {
        hasRight = true;
      }
    }
    if (hasLeft && !hasRight) return 'left';
    if (hasRight && !hasLeft) return 'right';
    return null;
  }

  _AngleResult _calculateAngleFromLandmarkTypes(
    Pose pose,
    PoseLandmarkType startType,
    PoseLandmarkType vertexType,
    PoseLandmarkType endType,
  ) {
    const minLikelihood = 0.2;
    final allowMissingLikelihoodFallback = !_poseHasExplicitLikelihoods(pose);
    final startLandmark = pose.landmarks[startType];
    final vertexLandmark = pose.landmarks[vertexType];
    final endLandmark = pose.landmarks[endType];
    if (startLandmark == null ||
        vertexLandmark == null ||
        endLandmark == null) {
      return const _AngleResult(0.0, 0.0);
    }
    if (!_isLandmarkReliable(
          startLandmark,
          allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
          minLikelihood: minLikelihood,
        ) ||
        !_isLandmarkReliable(
          vertexLandmark,
          allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
          minLikelihood: minLikelihood,
        ) ||
        !_isLandmarkReliable(
          endLandmark,
          allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
          minLikelihood: minLikelihood,
        )) {
      return const _AngleResult(0.0, 0.0);
    }
    final resolvedStartLandmark = startLandmark!;
    final resolvedVertexLandmark = vertexLandmark!;
    final resolvedEndLandmark = endLandmark!;
    final angle = _calculateRobustAngle(
      _landmarkToVector3(resolvedStartLandmark),
      _landmarkToVector3(resolvedVertexLandmark),
      _landmarkToVector3(resolvedEndLandmark),
    );
    final confidence = min(
      _resolveLandmarkConfidence(
        startLandmark,
        allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
      ),
      min(
        _resolveLandmarkConfidence(
          vertexLandmark,
          allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        ),
        _resolveLandmarkConfidence(
          endLandmark,
          allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        ),
      ),
    );
    return _AngleResult(angle, confidence);
  }

  _AngleResult _calculateStandardAngleForVertex(
    Pose pose,
    PoseLandmarkType vertexType,
  ) {
    final adjacentJoints = _getAdjacentJoints(vertexType);
    return _calculateAngleFromLandmarkTypes(
      pose,
      adjacentJoints.start,
      vertexType,
      adjacentJoints.end,
    );
  }

  _AngleResult _calculateCustomAngleForJointNames(
    Pose pose,
    String startJoint,
    String vertexJoint,
    String endJoint,
  ) {
    final startType = _getLandmarkType(startJoint, pose);
    final vertexType = _getLandmarkType(vertexJoint, pose);
    final endType = _getLandmarkType(endJoint, pose);
    if (startType == null || vertexType == null || endType == null) {
      return const _AngleResult(0.0, 0.0);
    }
    return _calculateAngleFromLandmarkTypes(
      pose,
      startType,
      vertexType,
      endType,
    );
  }

// Helper function to calculate back angle (shoulder-hip-knee)
  double _calculateBackAngle(Pose pose) {
    final leftResult = _calculateAngleFromLandmarkTypes(
      pose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
    );
    final rightResult = _calculateAngleFromLandmarkTypes(
      pose,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
    );

    if (leftResult.angle == 0.0 && rightResult.angle == 0.0) {
      return 0.0;
    }

    if (rightResult.confidence > leftResult.confidence) {
      print('Ã¢Å“â€¦ Right back angle: ${rightResult.angle.toStringAsFixed(1)}Ã‚Â°');
      return rightResult.angle;
    }

    print('Ã¢Å“â€¦ Left back angle: ${leftResult.angle.toStringAsFixed(1)}Ã‚Â°');
    return leftResult.angle;
  }

// Helper function to calculate shoulder-hip-ankle angle (body line)
  double _calculateShoulderHipAnkleAngle(Pose pose) {
    final leftResult = _calculateAngleFromLandmarkTypes(
      pose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftAnkle,
    );
    final rightResult = _calculateAngleFromLandmarkTypes(
      pose,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightAnkle,
    );

    if (leftResult.angle == 0.0 && rightResult.angle == 0.0) {
      return 0.0;
    }

    if (rightResult.confidence > leftResult.confidence) {
      print('Ã¢Å“â€¦ Right body angle: ${rightResult.angle.toStringAsFixed(1)}Ã‚Â°');
      return rightResult.angle;
    }

    print('Ã¢Å“â€¦ Left body angle: ${leftResult.angle.toStringAsFixed(1)}Ã‚Â°');
    return leftResult.angle;
  }

// Ã¡â‚¬â€™Ã¡â‚¬Â® function Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬Å“Ã¡â‚¬Â¯Ã¡â‚¬Â¶Ã¡â‚¬Â¸Ã¡â‚¬ÂÃ¡â‚¬Â¡Ã¡â‚¬Å¾Ã¡â‚¬â€¦Ã¡â‚¬ÂºÃ¡â‚¬â€¢Ã¡â‚¬Â¼Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬â€ Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬â€¢Ã¡â‚¬Â«
  PoseLandmarkType? _getLandmarkType(String jointName, Pose pose) {
    final allowMissingLikelihoodFallback = !_poseHasExplicitLikelihoods(pose);

    // First, normalize the joint name
    final normalizedName = jointName.toLowerCase().trim();

    // Direct mapping for specific joints
    final Map<String, PoseLandmarkType> directMapping = {
      // Left side
      'left_shoulder': PoseLandmarkType.leftShoulder,
      'left_elbow': PoseLandmarkType.leftElbow,
      'left_wrist': PoseLandmarkType.leftWrist,
      'left_hip': PoseLandmarkType.leftHip,
      'left_knee': PoseLandmarkType.leftKnee,
      'left_ankle': PoseLandmarkType.leftAnkle,
      'left_ear': PoseLandmarkType.leftEar,

      // Right side
      'right_shoulder': PoseLandmarkType.rightShoulder,
      'right_elbow': PoseLandmarkType.rightElbow,
      'right_wrist': PoseLandmarkType.rightWrist,
      'right_hip': PoseLandmarkType.rightHip,
      'right_knee': PoseLandmarkType.rightKnee,
      'right_ankle': PoseLandmarkType.rightAnkle,
      'right_ear': PoseLandmarkType.rightEar,

      // Generic names (default to left side)
      'shoulder': PoseLandmarkType.leftShoulder,
      'elbow': PoseLandmarkType.leftElbow,
      'wrist': PoseLandmarkType.leftWrist,
      'hip': PoseLandmarkType.leftHip,
      'knee': PoseLandmarkType.leftKnee,
      'ankle': PoseLandmarkType.leftAnkle,
      'ear': PoseLandmarkType.leftEar,
    };

    // Try direct mapping first
    if (directMapping.containsKey(normalizedName)) {
      final landmarkType = directMapping[normalizedName]!;
      final landmark = pose.landmarks[landmarkType];

      // Check if landmark exists and has sufficient confidence
      if (_isLandmarkReliable(
        landmark,
        allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        minLikelihood: 0.2,
      )) {
        final confidence = _resolveLandmarkConfidence(
          landmark!,
          allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        );
        print(
            'Ã¢Å“â€¦ Found $normalizedName: ${landmarkType.toString()} (confidence: ${(confidence * 100).toStringAsFixed(1)}%)');
        return landmarkType;
      }
    }

    // If not found, try to find by partial match
    for (final entry in directMapping.entries) {
      if (normalizedName.contains(entry.key) ||
          entry.key.contains(normalizedName)) {
        final landmark = pose.landmarks[entry.value];
        if (_isLandmarkReliable(
          landmark,
          allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
          minLikelihood: 0.2,
        )) {
          print('Ã¢Å“â€¦ Partial match: $normalizedName Ã¢â€ â€™ ${entry.key}');
          return entry.value;
        }
      }
    }

    // For squat-specific joints
    if (normalizedName.contains('knee')) {
      // Try both knees
      final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
      final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

      if (_isLandmarkReliable(
        leftKnee,
        allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        minLikelihood: 0.2,
      )) {
        print('Ã¢Å“â€¦ Using left knee for $normalizedName');
        return PoseLandmarkType.leftKnee;
      } else if (_isLandmarkReliable(
        rightKnee,
        allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        minLikelihood: 0.2,
      )) {
        print('Ã¢Å“â€¦ Using right knee for $normalizedName');
        return PoseLandmarkType.rightKnee;
      }
    }

    if (normalizedName.contains('hip')) {
      // Try both hips
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

      if (_isLandmarkReliable(
        leftHip,
        allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        minLikelihood: 0.2,
      )) {
        return PoseLandmarkType.leftHip;
      } else if (_isLandmarkReliable(
        rightHip,
        allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        minLikelihood: 0.2,
      )) {
        return PoseLandmarkType.rightHip;
      }
    }

    print('Ã¢ÂÅ’ Could not find landmark for: $jointName ($normalizedName)');
    return null;
  }

  double _calculateJointAngle(
    Pose pose,
    String vertexJoint, {
    String? startJoint,
    String? endJoint,
  }) {
    final allowMissingLikelihoodFallback = !_poseHasExplicitLikelihoods(pose);

    print('\nÃ°Å¸â€œÂ === CALCULATING JOINT ANGLE ===');
    print('Vertex Joint: $vertexJoint');
    print('Start Joint: $startJoint');
    print('End Joint: $endJoint');

    // Prefer the most confident side for generic standard joints
    if ((startJoint == null || endJoint == null) &&
        !_isSideSpecificJointName(vertexJoint)) {
      final leftVertexType = _getLandmarkType('left_$vertexJoint', pose);
      final rightVertexType = _getLandmarkType('right_$vertexJoint', pose);

      final leftResult = leftVertexType == null
          ? const _AngleResult(0.0, 0.0)
          : _calculateStandardAngleForVertex(pose, leftVertexType);
      final rightResult = rightVertexType == null
          ? const _AngleResult(0.0, 0.0)
          : _calculateStandardAngleForVertex(pose, rightVertexType);

      if (leftResult.angle > 0.0 || rightResult.angle > 0.0) {
        if (rightResult.confidence > leftResult.confidence) {
          print('Ã¢Å“â€¦ Using right side for $vertexJoint angle');
          return rightResult.angle;
        }
        print('Ã¢Å“â€¦ Using left side for $vertexJoint angle');
        return leftResult.angle;
      }
    }

    // For custom triplets, keep joints on the same side when generic names are used
    if (startJoint != null && endJoint != null) {
      final hasGenericJoint = !_isSideSpecificJointName(startJoint) ||
          !_isSideSpecificJointName(vertexJoint) ||
          !_isSideSpecificJointName(endJoint);

      if (hasGenericJoint) {
        final inferredSide =
            _inferSideFromJointNames([startJoint, vertexJoint, endJoint]);
        if (inferredSide != null) {
          final resolvedStart = _applySideToJointName(startJoint, inferredSide);
          final resolvedVertex =
              _applySideToJointName(vertexJoint, inferredSide);
          final resolvedEnd = _applySideToJointName(endJoint, inferredSide);
          final result = _calculateCustomAngleForJointNames(
            pose,
            resolvedStart,
            resolvedVertex,
            resolvedEnd,
          );
          if (result.angle > 0.0) {
            print('Ã¢Å“â€¦ Using $inferredSide side for $vertexJoint triplet');
            return result.angle;
          }
        } else {
          final leftResult = _calculateCustomAngleForJointNames(
            pose,
            _applySideToJointName(startJoint, 'left'),
            _applySideToJointName(vertexJoint, 'left'),
            _applySideToJointName(endJoint, 'left'),
          );
          final rightResult = _calculateCustomAngleForJointNames(
            pose,
            _applySideToJointName(startJoint, 'right'),
            _applySideToJointName(vertexJoint, 'right'),
            _applySideToJointName(endJoint, 'right'),
          );

          if (leftResult.angle > 0.0 || rightResult.angle > 0.0) {
            if (rightResult.confidence > leftResult.confidence) {
              print('Ã¢Å“â€¦ Using right side for $vertexJoint triplet');
              return rightResult.angle;
            }
            print('Ã¢Å“â€¦ Using left side for $vertexJoint triplet');
            return leftResult.angle;
          }
        }
      }
    }

    // Get the vertex landmark
    final vertexType = _getLandmarkType(vertexJoint, pose);
    if (vertexType == null) {
      print('Ã¢ÂÅ’ Vertex joint type not found for: $vertexJoint');

      // Try alternative names for common joints
      if (vertexJoint == 'knee') {
        // Try to get knee angle from left or right knee directly
        return _calculateKneeAngleFromLandmarks(pose);
      }
      return 0.0;
    }

    final vertexLandmark = pose.landmarks[vertexType];
    if (!_isLandmarkReliable(
      vertexLandmark,
      allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
      minLikelihood: 0.2,
    )) {
      print(
          'Ã¢ÂÅ’ Vertex landmark not found or low confidence: ${vertexLandmark?.likelihood ?? 0}');
      return 0.0;
    }
    final resolvedVertexLandmark = vertexLandmark!;

    print(
        'Ã¢Å“â€¦ Vertex landmark found: (${resolvedVertexLandmark.x.toStringAsFixed(2)}, ${resolvedVertexLandmark.y.toStringAsFixed(2)})');

    // For standard joints (knee, elbow, etc.)
    if (startJoint == null || endJoint == null) {
      final adjacentJoints = _getAdjacentJoints(vertexType);

      final startType = adjacentJoints.start;
      final endType = adjacentJoints.end;

      final startLandmark = pose.landmarks[startType];
      final endLandmark = pose.landmarks[endType];

      if (!_isLandmarkReliable(
            startLandmark,
            allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
            minLikelihood: 0.2,
          ) ||
          !_isLandmarkReliable(
            endLandmark,
            allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
            minLikelihood: 0.2,
          )) {
        print('Ã¢ÂÅ’ Adjacent landmarks not found or low confidence');
        return 0.0;
      }
      final resolvedStartLandmark = startLandmark!;
      final resolvedEndLandmark = endLandmark!;

      final angle = _calculateRobustAngle(
        _landmarkToVector3(resolvedStartLandmark),
        _landmarkToVector3(resolvedVertexLandmark),
        _landmarkToVector3(resolvedEndLandmark),
      );

      print('Ã¢Å“â€¦ Calculated angle: ${angle.toStringAsFixed(1)}Ã‚Â°');
      return angle;
    }

    // For custom triplets
    final startType = _getLandmarkType(startJoint, pose);
    final endType = _getLandmarkType(endJoint, pose);

    if (startType == null || endType == null) {
      print('Ã¢ÂÅ’ Start or end joint type not found');
      return 0.0;
    }

    final startLandmark = pose.landmarks[startType];
    final endLandmark = pose.landmarks[endType];

    if (!_isLandmarkReliable(
          startLandmark,
          allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
          minLikelihood: 0.2,
        ) ||
        !_isLandmarkReliable(
          endLandmark,
          allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
          minLikelihood: 0.2,
        )) {
      print('Ã¢ÂÅ’ Start or end landmark not found or low confidence');
      return 0.0;
    }
    final resolvedStartLandmark = startLandmark!;
    final resolvedEndLandmark = endLandmark!;

    final angle = _calculateRobustAngle(
      _landmarkToVector3(resolvedStartLandmark),
      _landmarkToVector3(resolvedVertexLandmark),
      _landmarkToVector3(resolvedEndLandmark),
    );

    print('Ã¢Å“â€¦ Calculated custom angle: ${angle.toStringAsFixed(1)}Ã‚Â°');
    return angle;
  }

// Helper function to calculate knee angle directly
  double _calculateKneeAngleFromLandmarks(Pose pose) {
    final leftResult = _calculateAngleFromLandmarkTypes(
      pose,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
    );
    final rightResult = _calculateAngleFromLandmarkTypes(
      pose,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
    );

    if (leftResult.angle == 0.0 && rightResult.angle == 0.0) {
      print('Ã¢ÂÅ’ Could not calculate knee angle from landmarks');
      return 0.0;
    }

    if (rightResult.confidence > leftResult.confidence) {
      print('Ã¢Å“â€¦ Right knee angle: ${rightResult.angle.toStringAsFixed(1)}Ã‚Â°');
      return rightResult.angle;
    }

    print('Ã¢Å“â€¦ Left knee angle: ${leftResult.angle.toStringAsFixed(1)}Ã‚Â°');
    return leftResult.angle;
  }

// More robust angle calculation
  double _calculateRobustAngle(Vector3 a, Vector3 b, Vector3 c) {
    try {
      // Method 1: Standard vector angle (for 3D)
      final Vector3 ba = a - b;
      final Vector3 bc = c - b;

      // Normalize vectors
      final double magBA = ba.length;
      final double magBC = bc.length;

      if (magBA < 0.001 || magBC < 0.001) {
        return 0.0;
      }

      final Vector3 normBA = ba / magBA;
      final Vector3 normBC = bc / magBC;

      // Dot product
      final double dot = normBA.dot(normBC);

      // Clamp to avoid numerical errors
      final double clampedDot = dot.clamp(-1.0, 1.0);

      // Angle in radians
      double angleRad = acos(clampedDot);

      // Convert to degrees
      double angleDeg = degrees(angleRad);

      // Ensure angle is between 0-180
      if (angleDeg > 180) {
        angleDeg = 360 - angleDeg;
      }

      // For squat knee angle: we want 0-180 range
      // Full extension ~180Ã‚Â°, Deep squat ~50-60Ã‚Â°

      return angleDeg;
    } catch (e) {
      print('Angle calculation error: $e');
      return 0.0;
    }
  }

 

  Map<String, PoseLandmarkType> _getLandmarkMap() {
    return {
      'nose': PoseLandmarkType.nose,
      'left_eye_inner': PoseLandmarkType.leftEyeInner,
      'left_eye': PoseLandmarkType.leftEye,
      'left_eye_outer': PoseLandmarkType.leftEyeOuter,
      'right_eye_inner': PoseLandmarkType.rightEyeInner,
      'right_eye': PoseLandmarkType.rightEye,
      'right_eye_outer': PoseLandmarkType.rightEyeOuter,
      'left_ear': PoseLandmarkType.leftEar,
      'right_ear': PoseLandmarkType.rightEar,
      'mouth_left': PoseLandmarkType.leftMouth,
      'mouth_right': PoseLandmarkType.rightMouth,
      'left_shoulder': PoseLandmarkType.leftShoulder,
      'right_shoulder': PoseLandmarkType.rightShoulder,
      'left_elbow': PoseLandmarkType.leftElbow,
      'right_elbow': PoseLandmarkType.rightElbow,
      'left_wrist': PoseLandmarkType.leftWrist,
      'right_wrist': PoseLandmarkType.rightWrist,
      'left_pinky': PoseLandmarkType.leftPinky,
      'right_pinky': PoseLandmarkType.rightPinky,
      'left_index': PoseLandmarkType.leftIndex,
      'right_index': PoseLandmarkType.rightIndex,
      'left_thumb': PoseLandmarkType.leftThumb,
      'right_thumb': PoseLandmarkType.rightThumb,
      'left_hip': PoseLandmarkType.leftHip,
      'right_hip': PoseLandmarkType.rightHip,
      'left_knee': PoseLandmarkType.leftKnee,
      'right_knee': PoseLandmarkType.rightKnee,
      'left_ankle': PoseLandmarkType.leftAnkle,
      'right_ankle': PoseLandmarkType.rightAnkle,
      'left_heel': PoseLandmarkType.leftHeel,
      'right_heel': PoseLandmarkType.rightHeel,
      'left_foot_index': PoseLandmarkType.leftFootIndex,
      'right_foot_index': PoseLandmarkType.rightFootIndex,

      // Aliases for easier reference
      'shoulder': PoseLandmarkType.leftShoulder, // Default to left
      'elbow': PoseLandmarkType.leftElbow,
      'wrist': PoseLandmarkType.leftWrist,
      'hip': PoseLandmarkType.leftHip,
      'knee': PoseLandmarkType.leftKnee,
      'ankle': PoseLandmarkType.leftAnkle,
      'ear': PoseLandmarkType.leftEar,
    };
  }

  _JointPair _getAdjacentJoints(PoseLandmarkType joint) {
    switch (joint) {
      case PoseLandmarkType.leftElbow:
        return const _JointPair(
          PoseLandmarkType.leftShoulder,
          PoseLandmarkType.leftWrist,
        );
      case PoseLandmarkType.rightElbow:
        return const _JointPair(
          PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightWrist,
        );
      case PoseLandmarkType.leftKnee:
        return const _JointPair(
          PoseLandmarkType.leftHip,
          PoseLandmarkType.leftAnkle,
        );
      case PoseLandmarkType.rightKnee:
        return const _JointPair(
          PoseLandmarkType.rightHip,
          PoseLandmarkType.rightAnkle,
        );
      case PoseLandmarkType.leftShoulder:
        return const _JointPair(
          PoseLandmarkType.leftHip,
          PoseLandmarkType.leftElbow,
        );
      case PoseLandmarkType.rightShoulder:
        return const _JointPair(
          PoseLandmarkType.rightHip,
          PoseLandmarkType.rightElbow,
        );
      case PoseLandmarkType.leftHip:
        return const _JointPair(
          PoseLandmarkType.leftShoulder,
          PoseLandmarkType.leftKnee,
        );
      case PoseLandmarkType.rightHip:
        return const _JointPair(
          PoseLandmarkType.rightShoulder,
          PoseLandmarkType.rightKnee,
        );
      default:
        return const _JointPair(
          PoseLandmarkType.nose,
          PoseLandmarkType.nose,
        );
    }
  }

  List<FormWarning> _checkForm(
    Pose pose,
    Map<String, double> jointAngles,
    Map<String, dynamic> exerciseConfig,
  ) {
    final List<FormWarning> warnings = [];
    final rawFormChecks =
        exerciseConfig['form_checks'] ?? exerciseConfig['formChecks'];
    final formChecks = rawFormChecks is List ? rawFormChecks : const [];

    for (final check in formChecks) {
      Map<String, dynamic>? checkMap;
      if (check is Map<String, dynamic>) {
        checkMap = check;
      } else if (check is FormCheck) {
        checkMap = {
          'id': check.id,
          'joints': check.joints,
          'check_type': check.checkType,
          'target_joint': check.targetJoint,
          'joints_pair': check.jointsPair,
          'tolerance': check.tolerance,
          'min_angle': check.minAngle,
          'max_angle': check.maxAngle,
          'warning_message': check.warningMessage,
        };
      }

      if (checkMap == null) {
        continue;
      }

      final checkType = checkMap['check_type'] as String?;
      final warningMessage = checkMap['warning_message'] as String? ?? '';

      if (checkType == 'symmetry') {
        // Check symmetry between left and right joints
        final jointsPair =
            (checkMap['joints_pair'] as List<dynamic>?)?.cast<String>() ?? [];
        final tolerance = (checkMap['tolerance'] as num?)?.toDouble() ?? 15.0;

        if (jointsPair.length == 2) {
          final leftAngle = jointAngles[jointsPair[0]] ?? 0.0;
          final rightAngle = jointAngles[jointsPair[1]] ?? 0.0;

          if ((leftAngle - rightAngle).abs() > tolerance) {
            warnings.add(FormWarning(
              warningId: checkMap['id'] as String? ?? '',
              message: warningMessage,
              timestamp: DateTime.now(),
            ));
          }
        }
      } else if (checkType == 'static_joint_position') {
        // Check if a joint is moving too much
        // This requires tracking previous positions
        final targetJoint = checkMap['target_joint'] as String?;
        if (targetJoint != null) {
          // Implementation would track joint movement over time
          // and warn if excessive movement is detected
        }
      } else {
        // Standard angle range check
        final minAngle = (checkMap['min_angle'] as num?)?.toDouble() ?? 0.0;
        final maxAngle = (checkMap['max_angle'] as num?)?.toDouble() ?? 180.0;
        final joints =
            (checkMap['joints'] as List<dynamic>?)?.cast<String>() ?? [];

        if (joints.length == 3) {
          final angleName = '${joints[0]}_${joints[1]}_${joints[2]}';
          final angle = jointAngles[angleName] ?? 0.0;

          if (angle < minAngle || angle > maxAngle) {
            warnings.add(FormWarning(
              warningId: checkMap['id'] as String? ?? '',
              message: warningMessage,
              timestamp: DateTime.now(),
            ));
          }
        }
      }
    }

    return warnings;
  }

  double _calculateAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    final String? exerciseId =
        (exerciseConfig['id'] ?? exerciseConfig['exerciseId']) as String?;
    final String? exerciseName = exerciseConfig['name'] as String?;

    print('\nÃ°Å¸Å½Â¯ === ACCURACY CALCULATION FOR: $exerciseName ===');

    // Exercise-specific calculations
    if (exerciseId == 'squat') {
      return _calculateSquatAccuracy(jointAngles, warnings, exerciseConfig);
    } else if (exerciseId == 'pushup') {
      return _calculatePushupAccuracy(jointAngles, warnings, exerciseConfig);
    } else if (exerciseId == 'bicep_curl') {
      return _calculateBicepCurlAccuracy(jointAngles, warnings, exerciseConfig);
    } else if (exerciseId == 'bench_press') {
      return _calculateBenchPressAccuracy(jointAngles, warnings, exerciseConfig);
    } else if (exerciseId == 'lateral_raise' || exerciseId == 'front_raise') {
      return _calculateLateralRaiseAccuracy(
          jointAngles, warnings, exerciseConfig);
    }
    // else if (exerciseId == 'shoulder_press') {
    //   return _calculateShoulderPressAccuracy(jointAngles, warnings, exerciseConfig);
    // }
    else if (exerciseId == 'situp') {
      return _calculateSitupAccuracy(jointAngles, warnings, exerciseConfig);
    }
    // else if (exerciseId == 'leg_extension') {
    //   return _calculateLegExtensionAccuracy(jointAngles, warnings, exerciseConfig);
    // }

    // Default calculation for unknown exercises
    return _calculateDefaultAccuracy(jointAngles, warnings, exerciseConfig);
  }

// Squat accuracy calculation Ã¡â‚¬â„¢Ã¡â‚¬Â¾Ã¡â‚¬Â¬ range Ã¡â‚¬ÂÃ¡â‚¬Â½Ã¡â‚¬Â±Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬â€¢Ã¡â‚¬Â¼Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬â„¢Ã¡â‚¬Å¡Ã¡â‚¬Âº
  bool _squatDescentStarted = false;
  int _squatBelowStartFrames = 0;
  bool _squatReadyFromStanding = false;
  int _squatStandingFrames = 0;
  double? _squatFrontViewBaselineKnee;

  double _calculateSquatAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\nÃ°Å¸Ââ€¹Ã¯Â¸Â === SQUAT ACCURACY CALCULATION ===');

    double kneeAngle = 180.0;
    final possibleKneeKeys = [
      'knee',
      'left_knee',
      'right_knee',
      'hip_knee_ankle',
      'left_hip_left_knee_left_ankle',
      'right_hip_right_knee_right_ankle'
    ];

    for (final key in possibleKneeKeys) {
      if (jointAngles.containsKey(key) && jointAngles[key]! > 0) {
        kneeAngle = jointAngles[key]!;
        print(
            'Ã¢Å“â€¦ Found knee angle from key "${key}": ${kneeAngle.toStringAsFixed(1)}Ã‚Â°');
        break;
      }
    }

    if (kneeAngle == 180.0) {
      for (final entry in jointAngles.entries) {
        if (entry.key.toLowerCase().contains('knee') && entry.value > 0) {
          kneeAngle = entry.value;
          print(
              'Ã¢Å“â€¦ Found knee angle from "${entry.key}": ${kneeAngle.toStringAsFixed(1)}Ã‚Â°');
          break;
        }
      }
    }

    print('Ã°Å¸Â¦Âµ FINAL KNEE ANGLE: ${kneeAngle.toStringAsFixed(1)}Ã‚Â°');

    // Prevent idle standing from generating accuracy
    const double standResetAngle =
        168.0; // treat near-straight legs as standing
    const double startDescentAngle = 160.0; // need visible bend before tracking
    const int standingFramesToPrime =
        2; // require clear standing baseline first
    const int framesToUnlock = 3; // require sustained bend to avoid noise

    final double hipAngle = jointAngles['hip'] ??
        jointAngles['left_hip'] ??
        jointAngles['right_hip'] ??
        180.0;
    final double backAngle = jointAngles['shoulder_hip_knee'] ??
        jointAngles['shoulder_hip_ankle'] ??
        180.0;

    // Extra guard for front-view standing (2D projection can fake knee bend)
    const double frontViewRatioThreshold = 0.35;
    const double frontViewStandingKnee = 145.0;
    const double frontViewStandingHip = 145.0;
    const double frontViewStandingBack = 150.0;
    const double frontViewUprightHip = 155.0;
    const double frontViewUprightBack = 155.0;

    final double frontViewRatio = jointAngles['front_view_ratio'] ?? 0.0;
    final bool isFrontView = frontViewRatio >= frontViewRatioThreshold;
    // Extra strict lock for front-view upright standing even if knee looks bent.
    final bool frontViewUpright =
        isFrontView && hipAngle >= 165.0 && backAngle >= 165.0;
    if (frontViewUpright) {
      _squatFrontViewBaselineKnee = _squatFrontViewBaselineKnee == null
          ? kneeAngle
          : (_squatFrontViewBaselineKnee! * 0.8 + kneeAngle * 0.2);
      _squatStandingFrames++;
      if (_squatStandingFrames >= standingFramesToPrime) {
        _squatReadyFromStanding = true;
      }
      _squatDescentStarted = false;
      _squatBelowStartFrames = 0;
      _lastStableAccuracy = 0.0;
      print('Front view upright lock: 0% until descent detected');
      return 0.0;
    }
    if (isFrontView &&
        hipAngle >= frontViewUprightHip &&
        backAngle >= frontViewUprightBack) {
      if (kneeAngle >= 145.0) {
        _squatFrontViewBaselineKnee = _squatFrontViewBaselineKnee == null
            ? kneeAngle
            : (_squatFrontViewBaselineKnee! * 0.8 + kneeAngle * 0.2);
      }
      _squatStandingFrames++;
      if (_squatStandingFrames >= standingFramesToPrime) {
        _squatReadyFromStanding = true;
      }
      _squatDescentStarted = false;
      _squatBelowStartFrames = 0;
      _lastStableAccuracy = 0.0;
      print('Front view upright guard: 0% until descent detected');
      return 0.0;
    }
    if (isFrontView &&
        kneeAngle >= frontViewStandingKnee &&
        hipAngle >= frontViewStandingHip &&
        backAngle >= frontViewStandingBack) {
      if (kneeAngle >= 145.0) {
        _squatFrontViewBaselineKnee = _squatFrontViewBaselineKnee == null
            ? kneeAngle
            : (_squatFrontViewBaselineKnee! * 0.8 + kneeAngle * 0.2);
      }
      _squatStandingFrames++;
      if (_squatStandingFrames >= standingFramesToPrime) {
        _squatReadyFromStanding = true;
      }
      _squatDescentStarted = false;
      _squatBelowStartFrames = 0;
      _lastStableAccuracy = 0.0;
      print('Front view standing lock: 0% until descent detected');
      return 0.0;
    }
    if (!_squatReadyFromStanding) {
      if (kneeAngle >= standResetAngle &&
          hipAngle >= frontViewStandingHip &&
          backAngle >= frontViewStandingBack) {
        _squatStandingFrames++;
        if (_squatStandingFrames >= standingFramesToPrime) {
          _squatReadyFromStanding = true;
        } else {
          _lastStableAccuracy = 0.0;
          print('Front view baseline lock: 0% until descent detected');
          return 0.0;
        }
      } else {
        _squatStandingFrames = 0;
      }

      if (!_squatReadyFromStanding) {
        print('â¸ Waiting for standing baseline before squat tracking');
        return 0.0;
      }
    }

    final bool frontViewDescent = isFrontView &&
        _squatFrontViewBaselineKnee != null &&
        kneeAngle <= (_squatFrontViewBaselineKnee! - 12.0);

    if ((frontViewDescent ||
        (kneeAngle < startDescentAngle &&
            (hipAngle < 165.0 || backAngle < 165.0)))) {
      _squatBelowStartFrames++;
    } else {
      _squatBelowStartFrames = 0;
    }

    if (!_squatDescentStarted) {
      if (_squatBelowStartFrames < framesToUnlock) {
        _lastStableAccuracy = 0.0;
        print(
            'â¸ Waiting for sustained descent (${_squatBelowStartFrames}/$framesToUnlock frames)');
        return 0.0;
      }
      _squatDescentStarted = true;
      print('â–¶ï¸ Descent detected â€” unlocking squat accuracy');
    }

    double accuracy = 0.0;
    if (kneeAngle >= 170) {
      accuracy = 0.0;
      print('Ã°Å¸â€ºÅ’ STANDING: 0%');
    } else if (kneeAngle >= 140) {
      final progress = (170 - kneeAngle) / (170 - 140);
      accuracy = 0.2 + (0.3 * progress);
      print('Ã¢â€ â€”Ã¯Â¸Â SHALLOW SQUAT: ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle >= 110) {
      final progress = (140 - kneeAngle) / (140 - 110);
      accuracy = 0.5 + (0.3 * progress);
      print('Ã¢â€ â€”Ã¯Â¸Â MID SQUAT: ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle >= 80) {
      final progress = (110 - kneeAngle) / (110 - 80);
      accuracy = 0.8 + (0.2 * progress);
      print('Ã¢â€ â€”Ã¯Â¸Â DEEP SQUAT: ${(accuracy * 100).toStringAsFixed(1)}%');
    } else {
      accuracy = 1.0;
      print('Ã¢Å“â€¦ FULL SQUAT: 100%');
    }

    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('Ã¢Å¡Â Ã¯Â¸Â Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    print('Ã°Å¸Å½Â¯ FINAL SQUAT ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');

    return accuracy;
  }

// SIT-UP ACCURACY
  bool _isUserLyingDown = false;
  bool _situpPrimed = false;
  int _situpLyingFrames = 0;
  int _situpLyingFramesNeeded = 3;
  double? _situpLastHipAngle;
  double? _situpLastBackAngle;
  double? _situpLastKneeAngle;
  int _situpStillFrames = 0;
  final int _situpStillFramesToLock = 6;
  int _situpUprightIdleMs = 0;
  double? _situpSmoothedHipAngle;
  bool _situpSittingLocked = false;
  DateTime? _situpSittingStartedAt;
  int _situpNonSittingFrames = 0;
  double _situpOutputAccuracy = 0.0;
  int _situpStillJitterFrames = 0;

  double _calculateSitupAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\nÃ°Å¸Â§Ëœ === SIT-UP CALCULATION ===');

    final double? hipAngleRaw = jointAngles['hip'] ??
        jointAngles['left_hip'] ??
        jointAngles['right_hip'];
    final double? kneeAngleRaw = jointAngles['knee'] ??
        jointAngles['left_knee'] ??
        jointAngles['right_knee'];
    final double? backAngleRaw =
        jointAngles['shoulder_hip_knee'] ?? jointAngles['shoulder_hip_ankle'];

    final bool hasHipAngle = (hipAngleRaw ?? 0) > 0;
    final bool hasKneeAngle = (kneeAngleRaw ?? 0) > 0;
    final bool hasBackAngle = (backAngleRaw ?? 0) > 0;

    double hipAngle = hasHipAngle
        ? hipAngleRaw!
        : ((_situpSmoothedHipAngle ?? _situpLastHipAngle) ?? 0.0);
    double kneeAngle =
        hasKneeAngle ? kneeAngleRaw! : (_situpLastKneeAngle ?? 0.0);
    double backAngle =
        hasBackAngle ? backAngleRaw! : (_situpLastBackAngle ?? 0.0);

    final now = DateTime.now();

    // Do not unlock sit-up from incomplete landmarks on startup.
    if ((!hasHipAngle || !hasKneeAngle) && !_situpPrimed) {
      _situpLyingFrames = 0;
      _isUserLyingDown = false;
      _situpOutputAccuracy = 0.0;
      _situpStillJitterFrames = 0;
      _lastStableAccuracy = 0.0;
      print('ðŸš§ Waiting for stable hip/knee landmarks before sit-up tracking');
      return 0.0;
    }

    final double hipAlpha = _situpPrimed ? 0.5 : 0.25;
    _situpSmoothedHipAngle = _situpSmoothedHipAngle == null
        ? hipAngle
        : (_situpSmoothedHipAngle! * (1 - hipAlpha) + hipAngle * hipAlpha);
    final double smoothedHipAngle = _situpSmoothedHipAngle!;

    final double? lastHipAngle = _situpLastHipAngle;
    _situpLastHipAngle = smoothedHipAngle;
    final double? lastBackAngle = _situpLastBackAngle;
    _situpLastBackAngle = backAngle;
    final double? lastKneeAngle = _situpLastKneeAngle;
    _situpLastKneeAngle = kneeAngle;
    final double hipDelta =
        lastHipAngle == null ? 0.0 : (lastHipAngle - smoothedHipAngle).abs();
    final double backDelta =
        lastBackAngle == null ? 0.0 : (lastBackAngle - backAngle).abs();
    final double kneeDelta =
        lastKneeAngle == null ? 0.0 : (lastKneeAngle - kneeAngle).abs();
    final bool hipMoving = lastHipAngle != null && hipDelta > 2.5;
    final bool backMoving = lastBackAngle != null && backDelta > 3.5;
    final bool kneeMoving = lastKneeAngle != null && kneeDelta > 2.5;
    final bool isMoving = hipMoving || backMoving || kneeMoving;

    // Sitting detection for chair-style, folded-leg, and straight-leg seated posture.
    final bool backAvailable = backAngle > 0;
    final bool isChairSitting = smoothedHipAngle >= 60 &&
        smoothedHipAngle <= 150 &&
        kneeAngle >= 60 &&
        kneeAngle <= 150 &&
        (!backAvailable || backAngle >= 120);
    final bool isFoldedLegSitting = smoothedHipAngle >= 45 &&
        smoothedHipAngle <= 150 &&
        kneeAngle >= 25 &&
        kneeAngle <= 115;
    final bool isStraightLegSitting = smoothedHipAngle >= 55 &&
        smoothedHipAngle <= 150 &&
        kneeAngle >= 145 &&
        (!backAvailable || backAngle >= 110);
    final bool isHipOnlySitting =
        smoothedHipAngle >= 60 && smoothedHipAngle <= 130 && !isMoving;
    final bool isSittingPose = isChairSitting ||
        isFoldedLegSitting ||
        isStraightLegSitting ||
        isHipOnlySitting;

    // Use wall-clock timing for sitting detection so post-rep sitting is
    // consistently locked after ~1.5s even when angle jitter exists.
    if (isSittingPose) {
      _situpNonSittingFrames = 0;
      _situpSittingStartedAt ??= now;
      _situpUprightIdleMs =
          now.difference(_situpSittingStartedAt!).inMilliseconds.clamp(0, 3000);
    } else {
      _situpNonSittingFrames++;
      // Require a short non-sitting streak before reset to avoid one-frame flicker.
      if (_situpNonSittingFrames >= 2) {
        _situpSittingStartedAt = null;
        _situpUprightIdleMs = 0;
      }
    }
    final bool uprightTooLong = _situpUprightIdleMs >= 1500;

    if (isSittingPose && uprightTooLong) {
      _situpSittingLocked = true;
    }

    final bool isClearLyingPose = smoothedHipAngle >= 150 &&
        kneeAngle >= 145 &&
        (!hasBackAngle || backAngle >= 145);
    if (_situpSittingLocked) {
      if (isClearLyingPose && !isSittingPose) {
        _situpSittingLocked = false;
        _situpUprightIdleMs = 0;
        _situpSittingStartedAt = null;
        _situpNonSittingFrames = 0;
      } else {
        _situpPrimed = false;
        _isUserLyingDown = false;
        _situpLyingFrames = 0;
        _lastStableAccuracy = 0.0;
        _situpOutputAccuracy = 0.0;
        _situpStillJitterFrames = 0;
        print('âš ï¸ SITTING LOCK ACTIVE: Accuracy locked at 0%');
        return 0.0;
      }
    }

    if (isSittingPose && !_situpPrimed) {
      _situpPrimed = false;
      _isUserLyingDown = false;
      _situpLyingFrames = 0;
      _lastStableAccuracy = 0.0;
      _situpOutputAccuracy = 0.0;
      _situpStillJitterFrames = 0;
      print('âš ï¸ SITTING DETECTED: Accuracy locked at 0%');
      return 0.0;
    }

    final bool isUprightRest =
        smoothedHipAngle >= 70 && smoothedHipAngle <= 120 && kneeAngle >= 80;
    if (isUprightRest && !isMoving) {
      _situpStillFrames++;
    } else {
      _situpStillFrames = 0;
    }

    if (_situpStillFrames >= _situpStillFramesToLock) {
      _situpPrimed = false;
      _isUserLyingDown = false;
      _situpLyingFrames = 0;
      _lastStableAccuracy = 0.0;
      _situpOutputAccuracy = 0.0;
      _situpStillJitterFrames = 0;
      print('âš ï¸ SITTING REST DETECTED: Accuracy locked at 0%');
      return 0.0;
    }

    final bool isPositionLikeChair =
        (smoothedHipAngle > 70 && smoothedHipAngle < 110) &&
            (kneeAngle > 70 && kneeAngle < 120);

    // Require a lying baseline before counting reps
    // Slightly relax priming so sit-ups start counting sooner
    if (hasKneeAngle && smoothedHipAngle > 145 && kneeAngle > 135) {
      _situpLyingFrames++;
      if (_situpLyingFrames >= _situpLyingFramesNeeded) {
        _situpPrimed = true;
        _isUserLyingDown = true;
        print(
            'âœ… Lying baseline locked (${_situpLyingFrames}/$_situpLyingFramesNeeded frames)');
      }
    } else {
      _situpLyingFrames = 0;
    }

    if (isPositionLikeChair) {
      _situpOutputAccuracy = 0.0;
      _situpStillJitterFrames = 0;
      print('Ã¢Å¡Â Ã¯Â¸Â SITTING POSITION DETECTED: Accuracy locked at 0%');
      return 0.0;
    }

    if (!_situpPrimed) {
      _situpOutputAccuracy = 0.0;
      _situpStillJitterFrames = 0;
      print('ðŸš§ Waiting for lying start (hips & knees extended) â†’ 0%');
      return 0.0;
    }

    print(
        'Ã°Å¸Â§Ëœ SIT-UP CALCULATION - Hip Angle: ${smoothedHipAngle.toStringAsFixed(1)}Ã‚Â°');

    const double startAngle = 140.0;
    const double targetAngle = 92.0;

    double accuracy = 0.0;
    if (smoothedHipAngle >= startAngle) {
      accuracy = 0.0;
      print('Ã°Å¸â€ºÅ’ LYING DOWN: 0%');
    } else if (smoothedHipAngle <= targetAngle) {
      accuracy = 1.0;
      print('Ã¢Å“â€¦ FULL SIT-UP');
    } else {
      final double progress =
          (startAngle - smoothedHipAngle) / (startAngle - targetAngle);
      // Faster response: boost early progress for real-time feel
      final double eased = pow(progress.clamp(0.0, 1.0), 0.55).toDouble();
      accuracy = eased;
      print('Ã°Å¸â€œ88 SMOOTH PROGRESS: ${(accuracy * 100).toStringAsFixed(1)}%');
    }

    if (kneeAngle > 80 && smoothedHipAngle < 100) {
      accuracy *= 0.9;
      print('Ã¢Å¡Â Ã¯Â¸Â Keep your feet on the ground!');
    }

    if (warnings.isNotEmpty) {
      accuracy -= (warnings.length * 0.05);
    }

    final finalAccuracy = accuracy.clamp(0.0, 1.0);
    final bool isMicroJitter =
        hipDelta <= 1.3 && kneeDelta <= 1.8 && backDelta <= 2.2;
    if (!isMoving && isMicroJitter) {
      _situpStillJitterFrames = (_situpStillJitterFrames + 1).clamp(0, 120);
    } else {
      _situpStillJitterFrames = 0;
    }

    double stabilizedAccuracy = finalAccuracy;
    final double diffFromPrevious =
        (finalAccuracy - _situpOutputAccuracy).abs();
    if (!isMoving) {
      if (_situpStillJitterFrames >= 2 && diffFromPrevious < 0.04) {
        stabilizedAccuracy = _situpOutputAccuracy;
      } else {
        stabilizedAccuracy = _situpOutputAccuracy +
            ((finalAccuracy - _situpOutputAccuracy) * 0.15);
      }
    }

    _situpOutputAccuracy = stabilizedAccuracy.clamp(0.0, 1.0);
    print(
        'Ã°Å¸Å½Â¯ SIT-UP ACCURACY: ${(_situpOutputAccuracy * 100).toStringAsFixed(1)}%');

    return _situpOutputAccuracy;
  }

  double _calculatePushupAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\nðŸ’ª === PUSH-UP ACCURACY (FIXED) ===');

    // --- 1. Elbow Angle á€€á€­á€¯ á€›á€¾á€¬á€–á€½á€±á€á€¼á€„á€ºá€¸ ---
    double elbowAngle = 0.0;
    String source = "";

    double rightElbow = jointAngles['right_elbow'] ??
        jointAngles['right_shoulder_right_elbow_right_wrist'] ??
        0.0;

    double leftElbow = jointAngles['left_elbow'] ??
        jointAngles['left_shoulder_left_elbow_left_wrist'] ??
        0.0;

    double genericElbow =
        jointAngles['elbow'] ?? jointAngles['shoulder_elbow_wrist'] ?? 0.0;

    if (leftElbow > 0 && rightElbow > 0) {
      elbowAngle = (leftElbow + rightElbow) / 2;
      source = "average of both sides";
      print(
          'âœ… Using average of both sides: ${elbowAngle.toStringAsFixed(1)}Â° (L:${leftElbow.toStringAsFixed(1)}Â°, R:${rightElbow.toStringAsFixed(1)}Â°)');
    } else if (rightElbow > 0 && leftElbow == 0) {
      elbowAngle = rightElbow;
      source = "right elbow (only)";
      print('âœ… Found right elbow only: ${elbowAngle.toStringAsFixed(1)}Â°');
    } else if (leftElbow > 0 && rightElbow == 0) {
      elbowAngle = leftElbow;
      source = "left elbow (only)";
      print('âœ… Found left elbow only: ${elbowAngle.toStringAsFixed(1)}Â°');
    } else if (genericElbow > 0) {
      elbowAngle = genericElbow;
      source = "generic";
      print('âœ… Found generic elbow: ${elbowAngle.toStringAsFixed(1)}Â°');
    } else {
      print('âŒ No valid elbow angle found!');
      return 0.0;
    }

    if (elbowAngle > 120 && elbowAngle < 180) {
      double reversedAngle = 180 - elbowAngle;
      if (reversedAngle >= 30 && reversedAngle <= 90) {
        print('âš ï¸ Angle may be reversed: $elbowAngleÂ° â†’ $reversedAngleÂ°');
        elbowAngle = reversedAngle;
      }
    }

    if (leftElbow > 0 && rightElbow > 0) {
      double avgRaw = (leftElbow + rightElbow) / 2;
      double leftReversed = 180 - leftElbow;
      double rightReversed = 180 - rightElbow;
      double avgReversed = (leftReversed + rightReversed) / 2;

      bool rawValid = avgRaw >= 50 && avgRaw <= 170;
      bool reversedValid = avgReversed >= 50 && avgReversed <= 170;

      if (reversedValid && !rawValid) {
        elbowAngle = avgReversed;
        source = "average of both sides (reversed)";
        print(
            'âš ï¸ Both sides may be reversed: using reversed average: ${elbowAngle.toStringAsFixed(1)}Â°');
      }
    }

    // --- 3. Standing Posture á€…á€…á€ºá€†á€±á€¸á€á€¼á€„á€ºá€¸ ---
    double? torsoRatio = jointAngles['torso_upright_ratio'];
    if (torsoRatio != null && torsoRatio > 1.5) {
      print('ðŸš« Standing detected by torso ratio: $torsoRatio');
      return 0.0;
    }

    double? bodyAngle =
        jointAngles['shoulder_hip_ankle'] ?? jointAngles['shoulder_hip_knee'];
    if (bodyAngle != null && bodyAngle < 140) {
      print('ðŸš« Body not straight enough: ${bodyAngle.toStringAsFixed(1)}Â°');
      return 0.0;
    }

    // ========== á€¡á€•á€­á€¯á€„á€ºá€¸á€¡á€žá€…á€º á€‘á€Šá€·á€ºá€›á€”á€º ==========
    // --- á€á€”á€¹á€“á€¬á€€á€­á€¯á€šá€º á€…á€±á€¬á€„á€ºá€¸á€á€¼á€„á€ºá€¸á€€á€­á€¯ á€…á€…á€ºá€†á€±á€¸á€á€¼á€„á€ºá€¸ ---
    // torso_upright_ratio á€€ á€á€”á€¹á€“á€¬á€€á€­á€¯á€šá€º á€™á€á€ºá€™á€á€ºá€›á€¾á€­á€™á€¾á€¯á€€á€­á€¯ á€•á€¼á€á€šá€ºá‹
    // push-up á€¡á€á€½á€€á€º á€’á€®á€á€”á€ºá€–á€­á€¯á€¸ á€”á€Šá€ºá€¸á€”á€±á€›á€™á€šá€ºá‹ (á€á€”á€¹á€“á€¬á€€á€­á€¯á€šá€º á€œá€²á€œá€»á€±á€¬á€„á€ºá€¸á€”á€±á€›á€™á€šá€º)
    // á€’á€®á€á€”á€ºá€–á€­á€¯á€¸ á€™á€»á€¬á€¸á€œá€±á€œá€± á€á€”á€¹á€“á€¬á€€á€­á€¯á€šá€º á€™á€á€ºá€œá€±á€œá€± á€–á€¼á€…á€ºá€á€šá€ºá‹

    double torsoUprightRatio = jointAngles['torso_upright_ratio'] ?? 0.0;

    // á€á€”á€¹á€“á€¬á€€á€­á€¯á€šá€º á€…á€á€„á€º á€…á€±á€¬á€„á€ºá€¸á€œá€¬á€›á€„á€º torsoUprightRatio á€á€”á€ºá€–á€­á€¯á€¸ á€á€€á€ºá€œá€¬á€™á€šá€ºá‹
    // á€’á€®á€á€”á€ºá€–á€­á€¯á€¸ á€žá€á€ºá€™á€¾á€á€ºá€á€»á€€á€ºá€‘á€€á€º á€€á€»á€±á€¬á€ºá€œá€½á€”á€ºá€›á€„á€º á€á€”á€¹á€“á€¬á€€á€­á€¯á€šá€º á€…á€±á€¬á€„á€ºá€¸á€”á€±á€•á€¼á€®á€œá€­á€¯á€· á€šá€°á€†á€•á€¼á€®á€¸ accuracy á€€á€­á€¯ á€œá€»á€¾á€±á€¬á€·á€á€»á€™á€šá€ºá‹

    const double uprightThreshold =
        0.04; // á€’á€®á€á€”á€ºá€–á€­á€¯á€¸á€€á€­á€¯ á€œá€­á€¯á€¡á€•á€ºá€žá€œá€­á€¯ á€á€»á€­á€”á€ºá€Šá€¾á€­á€”á€­á€¯á€„á€ºá€•á€«á€á€šá€ºá‹

    if (torsoUprightRatio > uprightThreshold) {
      // á€á€”á€¹á€“á€¬á€€á€­á€¯á€šá€º á€…á€±á€¬á€„á€ºá€¸á€”á€±á€á€šá€ºá‹ á€’á€«á€†á€­á€¯ pushup á€™á€Ÿá€¯á€á€ºá€žá€±á€¸á€˜á€°á€¸á‹
      // accuracy á€€á€­á€¯ á€œá€€á€ºá€›á€¾á€­ á€á€½á€€á€ºá€‘á€¬á€¸á€á€²á€·á€¡á€á€­á€¯á€„á€ºá€¸ á€™á€‘á€¬á€¸á€˜á€² á€œá€»á€¾á€±á€¬á€·á€á€»á€™á€šá€ºá‹
      // á€¥á€•á€™á€¬ - á€…á€±á€¬á€„á€ºá€¸á€œá€±á€œá€± accuracy á€”á€Šá€ºá€¸á€œá€±á€œá€± á€–á€¼á€…á€ºá€¡á€±á€¬á€„á€º á€œá€¯á€•á€ºá€™á€šá€ºá‹

      // á€’á€®á€”á€±á€›á€¬á€™á€¾á€¬ á€›á€½á€±á€¸á€á€»á€šá€ºá€…á€›á€¬ á€”á€¾á€…á€ºá€™á€»á€­á€¯á€¸á€›á€¾á€­á€á€šá€ºá‹
      // á€›á€½á€±á€¸á€á€»á€šá€ºá€…á€›á€¬ á: á€œá€¯á€¶á€¸á€ 0% á€•á€±á€¸á€œá€­á€¯á€€á€ºá€™á€šá€º (á€á€”á€¹á€“á€¬á€€á€­á€¯á€šá€ºá€…á€±á€¬á€„á€ºá€¸á€›á€„á€º pushup á€…á€™á€œá€¯á€•á€ºá€›á€žá€±á€¸á€˜á€°á€¸á€œá€­á€¯á€· á€žá€á€ºá€™á€¾á€á€º)
      // return 0.0;

      // á€›á€½á€±á€¸á€á€»á€šá€ºá€…á€›á€¬ á‚: á€…á€±á€¬á€„á€ºá€¸á€á€²á€·á€¡á€á€­á€¯á€„á€ºá€¸á€¡á€†á€•á€±á€«á€ºá€™á€°á€á€Šá€ºá€•á€¼á€®á€¸ accuracy á€€á€­á€¯ á€œá€»á€¾á€±á€¬á€·á€á€»á€™á€šá€ºá‹
      double uprightPenalty = (torsoUprightRatio - uprightThreshold) *
          1.5; // á€…á€±á€¬á€„á€ºá€¸á€œá€±á€œá€± á€•á€­á€¯á€œá€»á€¾á€±á€¬á€·á€œá€±á€œá€±
      uprightPenalty =
          uprightPenalty.clamp(0.0, 0.5); // á€¡á€™á€»á€¬á€¸á€†á€¯á€¶á€¸ 80% á€‘á€­á€•á€² á€œá€»á€¾á€±á€¬á€·á€™á€šá€ºá‹

      // á€™á€°á€œ á€á€½á€€á€ºá€‘á€¬á€¸á€á€²á€· accuracy á€€á€­á€¯ á€žá€­á€™á€ºá€¸á€‘á€¬á€¸á€–á€­á€¯á€· á€œá€­á€¯á€á€šá€ºá‹ á€’á€«á€•á€±á€™á€šá€·á€º á€’á€®á€”á€±á€›á€¬á€™á€¾á€¬ accuracy á€€á€­á€¯ á€¡á€±á€¬á€€á€ºá€™á€¾á€¬á€™á€¾ á€á€½á€€á€ºá€™á€¾á€¬á€™á€­á€¯á€·á€œá€­á€¯á€·
      // á€’á€®á€…á€…á€ºá€†á€±á€¸á€™á€¾á€¯á€€á€­á€¯ accuracy á€á€½á€€á€ºá€•á€¼á€®á€¸á€™á€¾ á€œá€¯á€•á€ºá€žá€„á€·á€ºá€á€šá€ºá‹
      // á€’á€«á€€á€¼á€±á€¬á€„á€·á€º á€’á€®á€¡á€•á€­á€¯á€„á€ºá€¸á€€á€­á€¯ á€¡á€±á€¬á€€á€ºá€€ accuracy á€á€½á€€á€ºá€•á€¼á€®á€¸á€á€²á€·á€”á€±á€¬á€€á€ºá€™á€¾á€¬ á€‘á€Šá€·á€ºá€›á€™á€šá€ºá‹
    }
    // ============================================

    // --- 4. Accuracy á€á€½á€€á€ºá€á€»á€€á€ºá€á€¼á€„á€ºá€¸ ---
    double accuracy = 0.0;
    const double extensionAngle = 160.0; // á€œá€€á€ºá€–á€¼á€±á€¬á€„á€·á€ºá€á€»á€­á€”á€º (á€¡á€•á€±á€«á€ºá€†á€¯á€¶á€¸) -> 0%
    const double targetAngle = 100.0; // á€œá€€á€ºá€€á€½á€±á€¸á€žá€„á€·á€ºá€á€²á€· á€¡á€”á€­á€™á€·á€ºá€†á€¯á€¶á€¸ -> 100%

    if (elbowAngle >= extensionAngle) {
      accuracy = 0.0;
      print('â¬†ï¸ EXTENDED (${elbowAngle.toStringAsFixed(1)}Â°) â†’ 0%');
    } else if (elbowAngle <= targetAngle) {
      accuracy = 1.0;
      print('â¬‡ï¸ TARGET DEPTH (${elbowAngle.toStringAsFixed(1)}Â°) â†’ 100%');
    } else {
      double progress =
          (extensionAngle - elbowAngle) / (extensionAngle - targetAngle);
      double easedProgress = pow(progress, 0.8).toDouble();
      accuracy = easedProgress.clamp(0.0, 1.0);
      print(
          'ðŸ“ˆ Elbow: ${elbowAngle.toStringAsFixed(1)}Â° â†’ Progress: ${(progress * 100).toStringAsFixed(1)}% â†’ Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%');
    }

    // --- 5. Body alignment bonus/penalty ---
    if (bodyAngle != null) {
      if (bodyAngle >= 155) {
        accuracy = (accuracy * 1.05).clamp(0.0, 1.0);
        print('âœ… Good body alignment (+5%): ${bodyAngle.toStringAsFixed(1)}Â°');
      }
    }
    // else if (bodyAngle < 150) {
    //      accuracy *= 0.9;
    //      print('âš ï¸ Poor body alignment (-10%): ${bodyAngle.toStringAsFixed(1)}Â°');
    //    }

    // --- 6. Asymmetry penalty ---
    if (leftElbow > 0 && rightElbow > 0) {
      double asymmetry = (leftElbow - rightElbow).abs();
      if (asymmetry > 20) {
        double penalty = ((asymmetry - 20) / 40).clamp(0.0, 0.10);
        accuracy *= (1.0 - penalty);
        print('âš ï¸ Asymmetry penalty -${(penalty * 100).toStringAsFixed(1)}%');
      }
    }

    // --- 7. Form warnings ---
    // if (warnings.isNotEmpty) {
    //   double penalty = (warnings.length * 0.02).clamp(0.0, 0.1);
    //   accuracy *= (1.0 - penalty);
    //   print('âš ï¸ Form warnings penalty -${(penalty*100).toStringAsFixed(1)}%');
    // }

    // ========== á€’á€®á€”á€±á€›á€¬á€™á€¾á€¬ á€‘á€Šá€·á€ºá€›á€”á€º (á€›á€½á€±á€¸á€á€»á€šá€ºá€…á€›á€¬ á‚ á€¡á€á€½á€€á€º) ==========
    // // --- á€á€”á€¹á€“á€¬á€€á€­á€¯á€šá€º á€…á€±á€¬á€„á€ºá€¸á€á€¼á€„á€ºá€¸á€€á€­á€¯ á€…á€…á€ºá€†á€±á€¸á€•á€¼á€®á€¸ accuracy á€€á€­á€¯ á€‘á€•á€ºá€œá€»á€¾á€±á€¬á€·á€á€¼á€„á€ºá€¸ ---
    // double torsoUprightRatio = jointAngles['torso_upright_ratio'] ?? 0.0;
    // const double uprightThreshold = 0.1; // á€’á€®á€á€”á€ºá€–á€­á€¯á€¸á€€á€­á€¯ á€œá€­á€¯á€¡á€•á€ºá€žá€œá€­á€¯ á€á€»á€­á€”á€ºá€Šá€¾á€­á€•á€«á‹

    if (torsoUprightRatio > uprightThreshold) {
      // á€á€”á€¹á€“á€¬á€€á€­á€¯á€šá€º á€…á€±á€¬á€„á€ºá€¸á€”á€±á€á€šá€ºá‹ á€…á€±á€¬á€„á€ºá€¸á€á€²á€·á€¡á€á€­á€¯á€„á€ºá€¸á€¡á€†á€•á€±á€«á€ºá€™á€°á€á€Šá€ºá€•á€¼á€®á€¸ accuracy á€€á€­á€¯ á€œá€»á€¾á€±á€¬á€·á€á€»á€™á€šá€ºá‹
      double uprightPenalty = (torsoUprightRatio - uprightThreshold) * 1.5;
      uprightPenalty =
          uprightPenalty.clamp(0.0, 0.5); // á€¡á€™á€»á€¬á€¸á€†á€¯á€¶á€¸ 80% á€œá€»á€¾á€±á€¬á€·á€™á€šá€ºá‹

      accuracy *= (1.0 - uprightPenalty);
      print(
          'âš ï¸ Body tilt penalty: -${(uprightPenalty * 100).toStringAsFixed(1)}% (torso ratio: $torsoUprightRatio)');
    }
    // ================================================================

    accuracy = accuracy.clamp(0.0, 1.0);
    print(
        'ðŸŽ¯ FINAL ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}% (source: $source)');
    return accuracy;
  }

// ===========================================
// BICEP CURL ACCURACY
// ===========================================
  bool _bicepCurlStarted = false;
  int _bicepCurlBelowStartFrames = 0;
  bool _bicepReadyFromExtension = false;
  int _bicepExtensionFrames = 0;
  double? _bicepLastElbowAngle;
  int _bicepStandingIdleFrames = 0;
  int _bicepFrontViewFrames = 0;

  bool _legExtensionStarted = false;
  int _legExtensionMotionFrames = 0;
  bool _legExtensionReadyFromSeated = false;
  int _legExtensionSeatedFrames = 0;
  double? _legExtensionLastKneeAngle;



  double _calculateBicepCurlAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\nðŸ’ª === BICEP CURL ACCURACY CALCULATION ===');

    double elbowAngle = 180.0;
    String? usedElbowKey; // remember which key gave us the angle

    // Prefer explicit side keys first, then fall back to generic 'elbow'
    final possibleElbowKeys = [
      'left_elbow',
      'right_elbow',
      'elbow',
      'shoulder_elbow_wrist',
      'left_shoulder_left_elbow_left_wrist',
      'right_shoulder_right_elbow_right_wrist'
    ];

    for (final key in possibleElbowKeys) {
      if (jointAngles.containsKey(key) && jointAngles[key]! > 0) {
        elbowAngle = jointAngles[key]!;
        usedElbowKey = key;
        print(
            'âœ… Found elbow angle from "$key": ${elbowAngle.toStringAsFixed(1)}Â°');
        break;
      }
    }

    print('ðŸ’ª ELBOW ANGLE: ${elbowAngle.toStringAsFixed(1)}Â°');

    // Determine which side the elbow angle came from (if any)
    String? side;
    if (usedElbowKey != null) {
      if (usedElbowKey.contains('left'))
        side = 'left';
      else if (usedElbowKey.contains('right')) side = 'right';
    }

    // Get the shoulder angle from the same side, or fallback to generic
    double shoulderAngle = 180.0;
    if (side != null) {
      // Try sideâ€‘specific shoulder key
      shoulderAngle =
          jointAngles['${side}_shoulder'] ?? jointAngles['shoulder'] ?? 180.0;
    } else {
      // No side info â€“ use generic shoulder (should match the generic elbow)
      shoulderAngle = jointAngles['shoulder'] ??
          jointAngles['left_shoulder'] ??
          jointAngles['right_shoulder'] ??
          180.0;
    }
    print(
        'ðŸ¦¾ SHOULDER ANGLE (side: $side): ${shoulderAngle.toStringAsFixed(1)}Â°');

    // (Optional) you can also retrieve knee/hip angles if needed for guards,
    // but those are less sideâ€‘critical. They are already taken from the map
    // using their own logic.

    final double? lastElbowAngle = _bicepLastElbowAngle;
    _bicepLastElbowAngle = elbowAngle;
    final bool isBending =
        lastElbowAngle != null && (lastElbowAngle - elbowAngle) > 1.5;

    // Guards (standing detection, front view, etc.) remain unchanged.
    // They use generic knee/hip angles, which are fine.
    const double standResetAngle = 160.0;
    const double startCurlAngle = 140.0;
    const double extensionPrimeAngle = 135.0;
    const int extensionFramesToPrime = 2;
    const int framesToUnlock = 3;

    // á€™á€á€ºá€á€•á€ºá€›á€•á€ºá€”á€±á€á€²á€· posture á€€á€­á€¯ á€…á€…á€ºá€†á€±á€¸á€–á€­á€¯á€· hip, knee, body angle á€á€½á€±á€€á€­á€¯ á€šá€°á€™á€šá€º
    final double hipAngle = jointAngles['hip'] ??
        jointAngles['left_hip'] ??
        jointAngles['right_hip'] ??
        180.0;
    final double kneeAngle = jointAngles['knee'] ??
        jointAngles['left_knee'] ??
        jointAngles['right_knee'] ??
        180.0;
   

    const double frontViewRatioThreshold = 0.35;
    const double frontViewStandingHip = 150.0;
    const double frontViewStandingKnee = 157.0;

    final double frontViewRatio = jointAngles['front_view_ratio'] ?? 0.0;

    final bool isFrontView = frontViewRatio >= frontViewRatioThreshold;
    const int frontViewFramesToLock = 2;
    if (isFrontView) {
      _bicepFrontViewFrames++;
      if (_bicepFrontViewFrames > 120) {
        _bicepFrontViewFrames = 120;
      }
    } else {
      _bicepFrontViewFrames = 0;
    }

    if (_bicepFrontViewFrames >= frontViewFramesToLock) {
      _bicepCurlStarted = false;
      _bicepCurlBelowStartFrames = 0;
      _bicepReadyFromExtension = false;
      _bicepExtensionFrames = 0;
      _bicepStandingIdleFrames = 0;
      _lastStableAccuracy = 0.0;
      print('Front view detected: 0% until side view is visible');
      return 0.0;
    }

    const int standingIdleFramesToLock = 3;
    final double elbowDeltaAbs =
        lastElbowAngle == null ? 0.0 : (lastElbowAngle - elbowAngle).abs();
    if (isFrontView &&
        hipAngle >= frontViewStandingHip &&
        kneeAngle >= frontViewStandingKnee) {
      if (elbowDeltaAbs <= 1.0) {
        _bicepStandingIdleFrames++;
      } else {
        _bicepStandingIdleFrames = 0;
      }
      if (_bicepStandingIdleFrames >= standingIdleFramesToLock) {
        _bicepCurlStarted = false;
        _bicepCurlBelowStartFrames = 0;
        _bicepReadyFromExtension = false;
        _bicepExtensionFrames = 0;
        _lastStableAccuracy = 0.0;
        print('Front view idle standing lock: 0% until curl motion detected');
        return 0.0;
      }
    } else {
      _bicepStandingIdleFrames = 0;
    }

    if (isFrontView &&
        hipAngle >= frontViewStandingHip &&
        kneeAngle >= frontViewStandingKnee &&
        !isBending) {
      _bicepCurlStarted = false;
      _bicepCurlBelowStartFrames = 0;
      _bicepReadyFromExtension = false;
      _bicepExtensionFrames = 0;
      _lastStableAccuracy = 0.0;
      print('Front view standing lock: 0% until curl motion detected');
      return 0.0;
    }

    if (elbowAngle >= standResetAngle) {
      _bicepCurlStarted = false;
      _bicepCurlBelowStartFrames = 0;
      _bicepReadyFromExtension = false;
      _bicepExtensionFrames = 0;
      _lastStableAccuracy = 0.0;
      print('ðŸš§ STANDING LOCK: 0% until curl descent detected');
      return 0.0;
    }

    if (elbowAngle >= extensionPrimeAngle) {
      _bicepExtensionFrames++;
      if (_bicepExtensionFrames >= extensionFramesToPrime) {
        _bicepReadyFromExtension = true;
      }
    } else {
      _bicepExtensionFrames = 0;
    }

    if (!_bicepReadyFromExtension) {
      _lastStableAccuracy = 0.0;
      print('â¸ Waiting for extension baseline before curl tracking');
      return 0.0;
    }

    if (elbowAngle < startCurlAngle) {
      if (isBending) {
        _bicepCurlBelowStartFrames++;
      } else {
        _bicepCurlBelowStartFrames = 0;
      }
    } else {
      _bicepCurlBelowStartFrames = 0;
    }

    if (!_bicepCurlStarted) {
      if (_bicepCurlBelowStartFrames < framesToUnlock) {
        _lastStableAccuracy = 0.0;
        print(
            'â¸ Waiting for sustained curl (${_bicepCurlBelowStartFrames}/$framesToUnlock frames)');
        return 0.0;
      }
      _bicepCurlStarted = true;
      print('â–¶ï¸ Curl descent detected â€” unlocking accuracy');
    }

    // Accuracy mapping based on elbow angle (sideâ€‘agnostic)
    double accuracy = 0.0;
    if (elbowAngle > 160) {
      accuracy = 0.0;
      print('â¬‡ï¸â¬‡ï¸ ARMS EXTENDED ${elbowAngle.toStringAsFixed(1)}Â° â†’ 0%');
    } else if (elbowAngle > 138) {
      double progress = (160 - elbowAngle) / 30;
      accuracy = 0.2 + (0.3 * progress);
      print(
          'â†˜ï¸ STARTING CURL ${elbowAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle > 126) {
      double progress = (130 - elbowAngle) / 30;
      accuracy = 0.5 + (0.3 * progress);
      print(
          'â†˜ï¸ MID CURL ${elbowAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle > 115) {
      double progress = (100 - elbowAngle) / 20;
      accuracy = 0.8 + (0.15 * progress);
      print(
          'â¬‡ï¸â¬‡ï¸ DEEP CURL ${elbowAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle > 105) {
      double progress = (100 - elbowAngle) / 20;
      accuracy = 0.8 + (0.15 * progress);
      print(
          'â¬‡ï¸â¬‡ï¸ DEEP CURL ${elbowAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle >= 90) {
      double progress = (60 - elbowAngle) / 30;
      accuracy = 0.95 + (0.05 * progress);
      accuracy = accuracy.clamp(0.95, 1.0);
      print(
          'ðŸ† FULL CONTRACTION ${elbowAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else {
      accuracy = 0.9 - ((30 - elbowAngle) * 0.01);
      accuracy = accuracy.clamp(0.7, 0.9);
      print(
          'âš ï¸ OVERâ€‘CONTRACTION ${elbowAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    }

    // Apply shoulder penalty using the sideâ€‘matched shoulder angle
    if (shoulderAngle > 30 && shoulderAngle < 170) {
      final shoulderMovement = (shoulderAngle - 90).abs();
      if (shoulderMovement > 20) {
        accuracy = accuracy * 0.8;
        print('âš ï¸ Excessive shoulder movement penalty: -20%');
      }
    }

    // Warning penalties
    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('âš ï¸ Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    accuracy = accuracy.clamp(0.00, 1.0);
    print(
        'ðŸŽ¯ FINAL BICEP CURL ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');

    return accuracy;
  }

// ===========================================
// SHOULDER PRESS ACCURACY
// ===========================================
  double _calculateShoulderPressAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\nÃ°Å¸Ââ€¹Ã¯Â¸Â === SHOULDER PRESS ACCURACY CALCULATION ===');

    double elbowAngle = 180.0;

    final possibleElbowKeys = [
      'elbow',
      'left_elbow',
      'right_elbow',
      'shoulder_elbow_wrist',
      'left_shoulder_left_elbow_left_wrist',
      'right_shoulder_right_elbow_right_wrist'
    ];

    for (final key in possibleElbowKeys) {
      if (jointAngles.containsKey(key) && jointAngles[key]! > 0) {
        elbowAngle = jointAngles[key]!;
        print(
            'Ã¢Å“â€¦ Found elbow angle from "$key": ${elbowAngle.toStringAsFixed(1)}Ã‚Â°');
        break;
      }
    }

    double shoulderAngle = 180.0;
    final possibleShoulderKeys = [
      'shoulder',
      'left_shoulder',
      'right_shoulder',
      'hip_shoulder_elbow'
    ];

    for (final key in possibleShoulderKeys) {
      if (jointAngles.containsKey(key) && jointAngles[key]! > 0) {
        shoulderAngle = jointAngles[key]!;
        print(
            'Ã¢Å“â€¦ Found shoulder angle from "$key": ${shoulderAngle.toStringAsFixed(1)}Ã‚Â°');
        break;
      }
    }

    print('Ã°Å¸â€™Âª ELBOW ANGLE: ${elbowAngle.toStringAsFixed(1)}Ã‚Â°');
    print('Ã°Å¸Â¦Â¾ SHOULDER ANGLE: ${shoulderAngle.toStringAsFixed(1)}Ã‚Â°');

    if (shoulderAngle < 150) {
      print('Ã¢Å¡Â Ã¯Â¸Â Arms not raised (shoulder angle too low).');
      return 0.0;
    }
    if (elbowAngle > 165 && shoulderAngle < 170) {
      print('Ã¢Å¡Â Ã¯Â¸Â Elbows extended down, not a shoulder press.');
      return 0.0;
    }
    final elbowRaised = jointAngles['elbow_raised'] ?? 0.0;
    if (elbowRaised < 0.5) {
      print('Ã¢Å¡Â Ã¯Â¸Â Elbow not raised above shoulder.');
      return 0.0;
    }

    double accuracy = 0.0;
    if (elbowAngle >= 160) {
      accuracy = 0.8 + ((elbowAngle - 160) * 0.01);
      accuracy = accuracy.clamp(0.8, 0.95);
      print(
          'Ã¢Â¬â€ Ã¯Â¸Â TOP POSITION ${elbowAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle >= 120) {
      double progress = (elbowAngle - 120) / 40;
      accuracy = 0.5 + (0.3 * progress); // 50% to 80%
      print(
          'Ã¢â€ â€”Ã¯Â¸Â MID POSITION ${elbowAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle >= 90) {
      double progress = (elbowAngle - 90) / 30;
      accuracy = 0.2 + (0.3 * progress); // 20% to 50%
      print(
          'Ã¢Â¬â€¡Ã¯Â¸Â BOTTOM POSITION ${elbowAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle >= 60) {
      double progress = (elbowAngle - 60) / 30;
      accuracy = 0.05 + (0.15 * progress); // 5% to 20%
      print(
          'Ã°Å¸â€â€ž DEEP POSITION ${elbowAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else {
      accuracy = 0.05;
      print(
          'Ã¢Å¡Â Ã¯Â¸Â TOO DEEP ${elbowAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ 5% accuracy');
    }

    if (shoulderAngle >= 150) {
      accuracy = accuracy * 1.1;
      accuracy = accuracy.clamp(0.0, 1.0);
      print('Ã¢Å“â€¦ Good shoulder position bonus: +10%');
    } else if (shoulderAngle < 100) {
      accuracy = accuracy * 0.7;
      print('Ã¢Å¡Â Ã¯Â¸Â Shoulders too low penalty: -30%');
    }

    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('Ã¢Å¡Â Ã¯Â¸Â Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    accuracy = accuracy.clamp(0.00, 1.0);
    print(
        'Ã°Å¸Å½Â¯ FINAL SHOULDER PRESS ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');

    return accuracy;
  }

  double _calculateBenchPressAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\n=== BENCH PRESS ACCURACY (SIMPLE) ===');

    double normalizeBenchElbow(double rawAngle) {
      if (rawAngle <= 0.0) return 0.0;
      if (rawAngle < 45.0) {
        return (180.0 - rawAngle).clamp(0.0, 180.0).toDouble();
      }
      return rawAngle.clamp(0.0, 180.0).toDouble();
    }

    final elbowCandidates = <double>[
      normalizeBenchElbow(jointAngles['left_elbow'] ?? 0.0),
      normalizeBenchElbow(jointAngles['right_elbow'] ?? 0.0),
      normalizeBenchElbow(jointAngles['elbow'] ?? 0.0),
      normalizeBenchElbow(
        jointAngles['left_shoulder_left_elbow_left_wrist'] ?? 0.0,
      ),
      normalizeBenchElbow(
        jointAngles['right_shoulder_right_elbow_right_wrist'] ?? 0.0,
      ),
      normalizeBenchElbow(jointAngles['shoulder_elbow_wrist'] ?? 0.0),
    ].where((angle) => angle > 0.0).toList();

    if (elbowCandidates.isEmpty) {
      print('No elbow angle for bench press.');
      return 0.0;
    }

    elbowCandidates.sort();
    final elbowAngle = elbowCandidates[elbowCandidates.length ~/ 2];
    print('Bench elbow angle: ${elbowAngle.toStringAsFixed(1)}°');

    final frontViewRatio = jointAngles['front_view_ratio'] ?? 0.0;
    if (frontViewRatio >= 0.38) {
      print('Bench press front-view lock: 0% (use side view).');
      return 0.0;
    }

    final torsoUprightRatio = jointAngles['torso_upright_ratio'] ?? 0.0;
    if (torsoUprightRatio > 0.0 && torsoUprightRatio >= 1.36) {
      print('Bench press upright lock: 0% until user lies down in side view.');
      return 0.0;
    }

    double accuracy;
    if (elbowAngle >= 165.0) {
      // Fully extended lockout -> highest score.
      accuracy = 0.95;
    } else if (elbowAngle >= 150.0) {
      // 165 -> 150 : 95% -> 75%
      final progress = (165.0 - elbowAngle) / 15.0;
      accuracy = 0.95 - (0.20 * progress);
    } else if (elbowAngle >= 130.0) {
      // 150 -> 130 : 75% -> 55%
      final progress = (150.0 - elbowAngle) / 20.0;
      accuracy = 0.75 - (0.20 * progress);
    } else if (elbowAngle >= 105.0) {
      // 130 -> 105 : 55% -> 30%
      final progress = (130.0 - elbowAngle) / 25.0;
      accuracy = 0.55 - (0.25 * progress);
    } else if (elbowAngle >= 85.0) {
      // 105 -> 85 : 30% -> 12%
      final progress = (105.0 - elbowAngle) / 20.0;
      accuracy = 0.30 - (0.18 * progress);
    } else {
      // Very deep bend near chest -> lowest score.
      accuracy = 0.05;
    }

    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.02, 0.12);
      accuracy = accuracy * (1.0 - penalty);
    }

    accuracy = accuracy.clamp(0.0, 1.0);
    print(
        'FINAL BENCH PRESS ACCURACY (SIMPLE): ${(accuracy * 100).toStringAsFixed(1)}%');
    return accuracy;
  }

  double _calculateLateralRaiseAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    final exerciseLabel =
        (exerciseConfig['name'] as String?) ?? 'Raise Exercise';
    print('\nðŸ™† === $exerciseLabel ACCURACY CALCULATION ===');

    final double frontViewRatio = jointAngles['front_view_ratio'] ?? 0.0;
    if (frontViewRatio < 0.32) {
      print('âš ï¸ Front view not clear enough for $exerciseLabel.');
      return 0.0;
    }

    final shoulderCandidates = <double>[
      if ((jointAngles['left_shoulder'] ?? 0) > 0) jointAngles['left_shoulder']!,
      if ((jointAngles['right_shoulder'] ?? 0) > 0)
        jointAngles['right_shoulder']!,
      if ((jointAngles['shoulder'] ?? 0) > 0) jointAngles['shoulder']!,
      if ((jointAngles['hip_shoulder_elbow'] ?? 0) > 0)
        jointAngles['hip_shoulder_elbow']!,
    ];

    final elbowCandidates = <double>[
      if ((jointAngles['left_elbow'] ?? 0) > 0) jointAngles['left_elbow']!,
      if ((jointAngles['right_elbow'] ?? 0) > 0) jointAngles['right_elbow']!,
      if ((jointAngles['elbow'] ?? 0) > 0) jointAngles['elbow']!,
      if ((jointAngles['shoulder_elbow_wrist'] ?? 0) > 0)
        jointAngles['shoulder_elbow_wrist']!,
    ];

    if (shoulderCandidates.isEmpty) {
      print('âš ï¸ No shoulder angle available for $exerciseLabel.');
      return 0.0;
    }

    final double shoulderAngle =
        shoulderCandidates.reduce((a, b) => a + b) / shoulderCandidates.length;
    final double elbowAngle = elbowCandidates.isEmpty
        ? 180.0
        : elbowCandidates.reduce((a, b) => a + b) / elbowCandidates.length;

    print('ðŸ™† SHOULDER ANGLE: ${shoulderAngle.toStringAsFixed(1)}Â°');
    print('ðŸ’ª ELBOW ANGLE: ${elbowAngle.toStringAsFixed(1)}Â°');

    double accuracy = 0.0;
    if (shoulderAngle < 35.0) {
      final progress = (shoulderAngle / 25.0).clamp(0.0, 1.0);
      accuracy = 0.10 + (0.20 * progress);
      print('â¬‡ï¸ BOTTOM POSITION â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (shoulderAngle < 50.0) {
      final progress = ((shoulderAngle - 25.0) / 15.0).clamp(0.0, 1.0);
      accuracy = 0.30 + (0.15 * progress);
      print('â†—ï¸ STARTING RAISE â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (shoulderAngle < 68.0) {
      final progress = ((shoulderAngle - 40.0) / 20.0).clamp(0.0, 1.0);
      accuracy = 0.45 + (0.15 * progress);
      print('â†—ï¸ MID WAY â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (shoulderAngle < 98.0) {
      final progress = ((shoulderAngle - 60.0) / 20.0).clamp(0.0, 1.0);
      accuracy = 0.60 + (0.25 * progress);
      print('ðŸ“ˆ APPROACHING TARGET â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (shoulderAngle <= 125.0) {
      final progress = ((shoulderAngle - 80.0) / 15.0).clamp(0.0, 1.0);
      accuracy = 0.85 + (0.15 * progress);
      print('ðŸ† TARGET HEIGHT â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (shoulderAngle <= 140.0) {
      final progress = ((shoulderAngle - 95.0) / 15.0).clamp(0.0, 1.0);
      accuracy = 0.90 - (0.20 * progress);
      print('âš ï¸ SLIGHT OVER-EXTENSION â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else {
      accuracy = 0.90;
      print('âš ï¸ Excessive height detected.');
    }

    // if (elbowAngle < 150.0) {
    //   final bendPenalty = ((150.0 - elbowAngle) / 60.0).clamp(0.0, 0.25);
    //   accuracy = accuracy * (1.0 - bendPenalty);
    //   print('âš ï¸ Bent elbows penalty: -${(bendPenalty * 100).toStringAsFixed(1)}%');
    // }

    final double? leftShoulder = jointAngles['left_shoulder'];
    final double? rightShoulder = jointAngles['right_shoulder'];
    if (leftShoulder != null && rightShoulder != null) {
      final symmetryGap = (leftShoulder - rightShoulder).abs();
      if (symmetryGap > 18.0) {
        final symmetryPenalty = min((symmetryGap - 18.0) / 100.0, 0.15);
        accuracy = accuracy * (1.0 - symmetryPenalty);
        print(
            'âš ï¸ Arm symmetry penalty: -${(symmetryPenalty * 100).toStringAsFixed(1)}%');
      }
    }

    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('âš ï¸ Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    accuracy = accuracy.clamp(0.0, 1.0);
    print(
        'ðŸŽ¯ FINAL $exerciseLabel ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');
    return accuracy;
  }

  double _calculateLegExtensionAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\nÃ°Å¸Â¦Âµ === LEG EXTENSION ACCURACY CALCULATION ===');

    // Knee angle Ã¡â‚¬â€ºÃ¡â‚¬Â¾Ã¡â‚¬Â¬Ã¡â‚¬â€“Ã¡â‚¬Â½Ã¡â‚¬Â±Ã¡â‚¬ÂÃ¡â‚¬Â¼Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸
    double kneeAngle = 90.0; // Default Ã¡â‚¬â‚¬Ã¡â‚¬Â½Ã¡â‚¬Â±Ã¡â‚¬Â¸Ã¡â‚¬â€Ã¡â‚¬Â±Ã¡â‚¬ÂÃ¡â‚¬Â»Ã¡â‚¬Â­Ã¡â‚¬â€Ã¡â‚¬Âº

    final possibleKneeKeys = [
      'knee',
      'left_knee',
      'right_knee',
      'hip_knee_ankle',
      'left_hip_left_knee_left_ankle',
      'right_hip_right_knee_right_ankle'
    ];

    for (final key in possibleKneeKeys) {
      if (jointAngles.containsKey(key) && jointAngles[key]! > 0) {
        kneeAngle = jointAngles[key]!;
        print(
            'Ã¢Å“â€¦ Found knee angle from "$key": ${kneeAngle.toStringAsFixed(1)}Ã‚Â°');
        break;
      }
    }

    print('Ã°Å¸Â¦Âµ KNEE ANGLE: ${kneeAngle.toStringAsFixed(1)}Ã‚Â°');

    final double hipAngle = jointAngles['hip'] ??
        jointAngles['left_hip'] ??
        jointAngles['right_hip'] ??
        180.0;

    final double? lastKneeAngle = _legExtensionLastKneeAngle;
    _legExtensionLastKneeAngle = kneeAngle;
    final bool isMoving =
        lastKneeAngle != null && (lastKneeAngle - kneeAngle).abs() > 1.5;

    // Guard against standing (front/side view)
    const double standingKneeAngle = 160.0;
    const double standingHipAngle = 150.0;
    const double frontViewRatioThreshold = 0.35;
    const double frontViewStandingKnee = 150.0;
    const double frontViewStandingHip = 155.0;

    final double frontViewRatio = jointAngles['front_view_ratio'] ?? 0.0;
    final bool isFrontView = frontViewRatio >= frontViewRatioThreshold;

    if ((hipAngle >= standingHipAngle && kneeAngle >= standingKneeAngle) ||
        (isFrontView &&
            hipAngle >= frontViewStandingHip &&
            kneeAngle >= frontViewStandingKnee &&
            !isMoving)) {
      _legExtensionStarted = false;
      _legExtensionMotionFrames = 0;
      _legExtensionReadyFromSeated = false;
      _legExtensionSeatedFrames = 0;
      _lastStableAccuracy = 0.0;
      print('Standing lock: 0% until seated and moving');
      return 0.0;
    }

    // Require a seated baseline before counting
    const double seatedHipAngleMax = 125.0;
    const int seatedFramesToPrime = 2;
    if (hipAngle <= seatedHipAngleMax) {
      _legExtensionSeatedFrames++;
      if (_legExtensionSeatedFrames >= seatedFramesToPrime) {
        _legExtensionReadyFromSeated = true;
      }
    } else {
      _legExtensionSeatedFrames = 0;
      _legExtensionReadyFromSeated = false;
      _legExtensionStarted = false;
      _legExtensionMotionFrames = 0;
      _lastStableAccuracy = 0.0;
      print('Waiting for seated baseline');
      return 0.0;
    }

    // Require motion before unlocking accuracy
    const int motionFramesToUnlock = 3;
    if (!_legExtensionStarted) {
      if (isMoving) {
        _legExtensionMotionFrames++;
      } else {
        _legExtensionMotionFrames = 0;
      }
      if (_legExtensionMotionFrames < motionFramesToUnlock) {
        _lastStableAccuracy = 0.0;
        print('Waiting for leg extension motion');
        return 0.0;
      }
      _legExtensionStarted = true;
    }

    // Leg extension accuracy calculation
    double accuracy = 0.0;
    if (kneeAngle < 90) {
      print('Starting Position (Flexed): 0%');
      return accuracy = 0.0;
    } else if (kneeAngle <= 105) {
      // Ã¡â‚¬Â¡Ã¡â‚¬â€¢Ã¡â‚¬Â¼Ã¡â‚¬Å Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬Â¡Ã¡â‚¬ÂÃ¡â‚¬â‚¬Ã¡â‚¬Â½Ã¡â‚¬Â±Ã¡â‚¬Â¸Ã¡â‚¬â€Ã¡â‚¬Â±Ã¡â‚¬ÂÃ¡â‚¬Â»Ã¡â‚¬Â­Ã¡â‚¬â€Ã¡â‚¬Âº
      accuracy = 0.05; // 15%
      print('Ã°Å¸Â¦Âµ FULL FLEXION Ã¢â€ â€™ 15% accuracy');
    } else if (kneeAngle <= 110) {
      // Ã¡â‚¬Â¡Ã¡â‚¬â€Ã¡â‚¬Å Ã¡â‚¬ÂºÃ¡â‚¬Â¸Ã¡â‚¬â€žÃ¡â‚¬Å¡Ã¡â‚¬ÂºÃ¡â‚¬â€ Ã¡â‚¬â€Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬ÂÃ¡â‚¬Â»Ã¡â‚¬Â­Ã¡â‚¬â€Ã¡â‚¬Âº
      double progress = (kneeAngle - 90) / 20;
      accuracy = 0.15; // + (0.20 * progress); // 15% to 35%
      print(
          'Ã¢â€ â€”Ã¯Â¸Â SLIGHT EXTENSION ${kneeAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle <= 120) {
      // Ã¡â‚¬Å¾Ã¡â‚¬â€žÃ¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬ÂÃ¡â‚¬Â±Ã¡â‚¬Â¬Ã¡â‚¬ÂºÃ¡â‚¬ÂÃ¡â‚¬Â²Ã¡â‚¬Â·Ã¡â‚¬â€ Ã¡â‚¬â€Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬â„¢Ã¡â‚¬Â¾Ã¡â‚¬Â¯
      double progress = (kneeAngle - 110) / 20;
      accuracy = 0.35 + (0.25 * progress); // 35% to 60%
      print(
          'Ã°Å¸Â¦Âµ MODERATE EXTENSION ${kneeAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle <= 135) {
      // Ã¡â‚¬â‚¬Ã¡â‚¬Â±Ã¡â‚¬Â¬Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸Ã¡â‚¬â„¢Ã¡â‚¬Â½Ã¡â‚¬â€Ã¡â‚¬ÂºÃ¡â‚¬ÂÃ¡â‚¬Â²Ã¡â‚¬Â·Ã¡â‚¬â€ Ã¡â‚¬â€Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬â„¢Ã¡â‚¬Â¾Ã¡â‚¬Â¯
      double progress = (kneeAngle - 130) / 20;
      accuracy = 0.60 + (0.20 * progress); // 60% to 80%
      print(
          'Ã¢Â¬â€ Ã¯Â¸Â GOOD EXTENSION ${kneeAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle <= 150) {
      // Ã¡â‚¬â€Ã¡â‚¬â‚¬Ã¡â‚¬ÂºÃ¡â‚¬â€ºÃ¡â‚¬Â¾Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸Ã¡â‚¬â€¦Ã¡â‚¬Â½Ã¡â‚¬Â¬Ã¡â‚¬â€ Ã¡â‚¬â€Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬ÂÃ¡â‚¬Â»Ã¡â‚¬Â­Ã¡â‚¬â€Ã¡â‚¬Âº
      double progress = (kneeAngle - 150) / 20;
      accuracy = 0.80 + (0.15 * progress); // 80% to 95%
      print(
          'Ã¢Â¬â€ Ã¯Â¸ÂÃ¢Â¬â€ Ã¯Â¸Â DEEP EXTENSION ${kneeAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle <= 170) {
      // Ã¡â‚¬Â¡Ã¡â‚¬â€¢Ã¡â‚¬Â¼Ã¡â‚¬Å Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬Â¡Ã¡â‚¬ÂÃ¡â‚¬â€ Ã¡â‚¬â€Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬ÂÃ¡â‚¬Â»Ã¡â‚¬Â­Ã¡â‚¬â€Ã¡â‚¬Âº
      double progress = (kneeAngle - 170) / 10;
      accuracy = 0.95 + (0.05 * progress); // 95% to 100%
      accuracy = accuracy.clamp(0.95, 1.0);
      print(
          'Ã°Å¸Ââ€  FULL EXTENSION ${kneeAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else {
      // Ã¡â‚¬Â¡Ã¡â‚¬Å“Ã¡â‚¬Â½Ã¡â‚¬â€Ã¡â‚¬ÂºÃ¡â‚¬Â¡Ã¡â‚¬â‚¬Ã¡â‚¬Â»Ã¡â‚¬Â½Ã¡â‚¬Â¶Ã¡â‚¬â€ Ã¡â‚¬â€Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬ÂÃ¡â‚¬Â»Ã¡â‚¬Â­Ã¡â‚¬â€Ã¡â‚¬Âº
      accuracy = 0.9 - ((kneeAngle - 180) * 0.01);
      accuracy = accuracy.clamp(0.7, 0.9);
      print(
          'Ã¢Å¡Â Ã¯Â¸Â HYPER-EXTENSION ${kneeAngle.toStringAsFixed(1)}Ã‚Â° Ã¢â€ â€™ ${(accuracy * 100).toStringAsFixed(1)}%');
    }

    // Leg symmetry check
    final leftKnee = jointAngles['left_knee'] ?? 0.0;
    final rightKnee = jointAngles['right_knee'] ?? 0.0;

    if (leftKnee > 0 && rightKnee > 0) {
      final symmetryDiff = (leftKnee - rightKnee).abs();
      if (symmetryDiff > 15) {
        accuracy = accuracy * 0.85; // -15% penalty
        print('Ã¢Å¡Â Ã¯Â¸Â Asymmetric legs penalty: -15%');
      } else if (symmetryDiff < 5) {
        accuracy = accuracy * 1.05; // +5% bonus
        accuracy = accuracy.clamp(0.0, 1.0);
        print('Ã¢Å“â€¦ Perfect leg symmetry bonus: +5%');
      }
    }

    // Warning penalties
    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('Ã¢Å¡Â Ã¯Â¸Â Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    // Ensure minimum accuracy
    accuracy = accuracy.clamp(0.00, 1.0);

    print(
        'Ã°Å¸Å½Â¯ FINAL LEG EXTENSION ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');

    return accuracy;
  }

// ===========================================
// DEFAULT ACCURACY (for unknown exercises)
// ===========================================
  double _calculateDefaultAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\nÃ¢Å¡â„¢Ã¯Â¸Â === DEFAULT ACCURACY CALCULATION ===');

    // Print all available angles for debugging
    print('Ã°Å¸â€œÅ  Available Joint Angles:');
    jointAngles.forEach((key, value) {
      print('   $key: ${value.toStringAsFixed(1)}Ã‚Â°');
    });

    // Try to guess exercise based on angles
    final guessedAccuracy = _guessAccuracyFromAngles(jointAngles);
    print(
        'Ã°Å¸Â¤â€ Guessed accuracy: ${(guessedAccuracy * 100).toStringAsFixed(1)}%');

    // Apply adjustments and return
    return _applyAccuracyAdjustments(guessedAccuracy, warnings, 'default');
  }

// New helper function to guess accuracy
  double _guessAccuracyFromAngles(Map<String, double> jointAngles) {
    // Try to find knee or elbow angles
    double kneeAngle = 180.0;
    double elbowAngle = 180.0;

    for (var entry in jointAngles.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;

      if (key.contains('knee') && value > 0) {
        kneeAngle = value;
        print('   Found knee angle: ${value.toStringAsFixed(1)}Ã‚Â°');
      }
      if (key.contains('elbow') && value > 0) {
        elbowAngle = value;
        print('   Found elbow angle: ${value.toStringAsFixed(1)}Ã‚Â°');
      }
    }

    // If we have knee angle, assume squat-like exercise
    if (kneeAngle < 180 && kneeAngle > 0) {
      return _estimateSquatLikeAccuracy(kneeAngle);
    }

    // If we have elbow angle, assume upper body exercise
    if (elbowAngle < 180 && elbowAngle > 0) {
      return _estimateUpperBodyAccuracy(elbowAngle);
    }

    // Default to 70% if we can't guess
    return 0.7;
  }

  double _estimateSquatLikeAccuracy(double kneeAngle) {
    // Simple estimation based on knee angle
    if (kneeAngle <= 90) return 0.85; // Deep squat
    if (kneeAngle <= 120) return 0.75; // Parallel squat
    if (kneeAngle <= 150) return 0.6; // Half squat
    return 0.3; // Standing
  }

  double _estimateUpperBodyAccuracy(double elbowAngle) {
    // Simple estimation based on elbow angles
    if (elbowAngle <= 90) return 0.85; // Full contraction
    if (elbowAngle <= 120) return 0.75; // Good contraction
    if (elbowAngle <= 150) return 0.6; // Moderate
    return 0.3; // Extended
  }

// ===========================================
// UNIVERSAL ACCURACY CALCULATOR
// ===========================================
  double _calculateUniversalAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    final String? exerciseId =
        (exerciseConfig['id'] ?? exerciseConfig['exerciseId']) as String?;
    final String? exerciseName = exerciseConfig['name'] as String?;

    if (exerciseId == null || exerciseId.isEmpty) {
      print(
          'Ã¢ÂÅ’ CRITICAL: Exercise ID is null or empty! Using default calculation.');
      return _calculateDefaultAccuracy(jointAngles, warnings, exerciseConfig);
    }

    print('\nÃ°Å¸Å½Â¯ === ACCURACY FOR: $exerciseName ===');

    // Exercise-specific calculations
    switch (exerciseId) {
      case 'squat':
        return _calculateSquatAccuracy(jointAngles, warnings, exerciseConfig);
      case 'pushup':
        return _calculatePushupAccuracy(jointAngles, warnings, exerciseConfig);
      case 'bicep_curl':
        return _calculateBicepCurlAccuracy(
            jointAngles, warnings, exerciseConfig);
      case 'bench_press':
        return _calculateBenchPressAccuracy(
            jointAngles, warnings, exerciseConfig);
      case 'lateral_raise':
      case 'front_raise':
        return _calculateLateralRaiseAccuracy(
            jointAngles, warnings, exerciseConfig);
      case 'shoulder_press':
        return _calculateShoulderPressAccuracy(
            jointAngles, warnings, exerciseConfig);
      case 'situp':
        return _calculateSitupAccuracy(jointAngles, warnings, exerciseConfig);
      case 'leg_extension':
        return _calculateLegExtensionAccuracy(
            jointAngles, warnings, exerciseConfig);
      default:
        return _calculateDefaultAccuracy(jointAngles, warnings, exerciseConfig);
    }
  }

// ===========================================
// ACCURACY ADJUSTMENTS HELPER
// ===========================================
// _applyAccuracyAdjustments function Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬â€¢Ã¡â‚¬Â¼Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬â€¢Ã¡â‚¬Â«
  double _applyAccuracyAdjustments(
      double baseScore, List<FormWarning> warnings, String exerciseId) {
    double finalScore = baseScore;

    print('\nÃ°Å¸â€Â§ === APPLYING ADJUSTMENTS FOR $exerciseId ===');
    print('   Base Score: ${(baseScore * 100).toStringAsFixed(1)}%');

    // 1. Warning Penalties - significantly reduced
    double penalty = 0.0;
    if (warnings.isNotEmpty) {
      penalty =
          min(warnings.length * 0.01, 0.05); // Reduced to max 5% penalty only
      finalScore -= penalty;
      print('   Warning Penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    // 2. Remove the clamp or make it very low - Ã¡â‚¬â„¢Ã¡â‚¬Â°Ã¡â‚¬â€ºÃ¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸ 0.4 Ã¡â‚¬â‚¬Ã¡â‚¬â€Ã¡â‚¬Â± 0.1 Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯Ã¡â‚¬â€¢Ã¡â‚¬Â¼Ã¡â‚¬Â±Ã¡â‚¬Â¬Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â¸
    finalScore = finalScore.clamp(0.05, 1.0); // Minimum 10% only

    // 3. Add bonus for good form
    if (warnings.isEmpty && baseScore > 0.6) {
      finalScore = min(finalScore + 0.05, 1.0); // +5% bonus
      print('   Good Form Bonus: +5%');
    }

    // 4. Ensure it's not stuck at 68% - add some randomness
    Random random = Random();
    if (finalScore > 0.65 && finalScore < 0.75) {
      // If stuck between 65-75%, give a small boost
      double boost = random.nextDouble() * 0.05; // 0-5% random boost
      finalScore += boost;
      print('   Stuck range boost: +${(boost * 100).toStringAsFixed(1)}%');
    }

    print('   Final Score: ${(finalScore * 100).toStringAsFixed(1)}%');

    return finalScore.clamp(0.05, 1.0);
  }

  InputImage _convertToInputImage(
    CameraImage image,
    InputImageRotation rotation,
    Size imageSize,
  ) {
    try {
      print('Ã°Å¸â€â€ž Converting CameraImage to InputImage');
      print('Image format: ${image.format.raw}');
      print('Number of planes: ${image.planes.length}');
      print('Image size: $imageSize');
      print('Rotation: $rotation');

      // Check image format
      if (image.format.raw == 35) {
        // YUV_420_888
        print('Ã¢Å“â€¦ Image format is YUV_420_888 (Android standard)');
      }

      // Method 1: Combine all planes for NV21 format
      final WriteBuffer allBytes = WriteBuffer();

      // For YUV_420_888 format (Android camera default)
      // Plane 0: Y (luminance)
      // Plane 1: U (chrominance)
      // Plane 2: V (chrominance)

      if (image.planes.length >= 3) {
        print('Ã°Å¸â€œÅ  Plane sizes:');
        print('  - Plane 0 (Y): ${image.planes[0].bytes.length} bytes');
        print('  - Plane 1 (U): ${image.planes[1].bytes.length} bytes');
        print('  - Plane 2 (V): ${image.planes[2].bytes.length} bytes');

        // For NV21 format, we need Y then VU interleaved
        // But ML Kit expects YUV_420_888 or NV21

        // Try direct approach
        final plane = image.planes[0];

        return InputImage.fromBytes(
          bytes: plane.bytes,
          metadata: InputImageMetadata(
            size: imageSize,
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: plane.bytesPerRow,
          ),
        );
      }

      print('Ã¢Å¡Â Ã¯Â¸Â Unexpected plane count: ${image.planes.length}');

      // Fallback method
      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e, stackTrace) {
      print('Ã¢ÂÅ’ Error in _convertToInputImage: $e');
      print('Stack trace: $stackTrace');

      // Create dummy image for testing
      return _createDummyInputImage(rotation);
    }
  }

  InputImage _createDummyInputImage(InputImageRotation rotation) {
    // Create a simple test image with a colored rectangle
    const int width = 640;
    const int height = 480;

    // Create YUV NV21 format dummy data
    final ySize = width * height;
    final uvSize = (width ~/ 2) * (height ~/ 2);
    final data = Uint8List(ySize + uvSize * 2);

    // Fill Y plane (luminance) - gray background
    for (int i = 0; i < ySize; i++) {
      data[i] = 128; // Gray
    }

    // Fill UV planes (chrominance) - neutral
    for (int i = ySize; i < data.length; i++) {
      data[i] = 128;
    }

    return InputImage.fromBytes(
      bytes: data,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: width,
      ),
    );
  }

  Future<void> dispose() async {
    _throttleTimer?.cancel();
    final poseDetector = _poseDetector;
    _poseDetector = null;
    if (poseDetector != null) {
      await poseDetector.close();
    }

    final resultController = _resultController;
    _resultController = null;
    if (resultController != null && !resultController.isClosed) {
      await resultController.close();
    }
    _servicesReady = false;
  }

  // pose_detection_service.dart Ã¡â‚¬â„¢Ã¡â‚¬Â¾Ã¡â‚¬Â¬ Ã¡â‚¬â€™Ã¡â‚¬Â® function Ã¡â‚¬â‚¬Ã¡â‚¬Â­Ã¡â‚¬Â¯ Ã¡â‚¬â€˜Ã¡â‚¬â€¢Ã¡â‚¬ÂºÃ¡â‚¬â€˜Ã¡â‚¬Å Ã¡â‚¬Â·Ã¡â‚¬ÂºÃ¡â‚¬â€¢Ã¡â‚¬Â«
  void testPoseDetection() async {
    print('Ã°Å¸â€Â Testing Pose Detection...');

    // Create a simple test image
    final testImage = InputImage.fromFilePath(
      'assets/test_images/test_pose.jpg', // Ã¡â‚¬Å¾Ã¡â‚¬â€žÃ¡â‚¬ÂºÃ¡â‚¬Â·Ã¡â‚¬â„¢Ã¡â‚¬Â¾Ã¡â‚¬Â¬Ã¡â‚¬â€ºÃ¡â‚¬Â¾Ã¡â‚¬Â­Ã¡â‚¬â€ºÃ¡â‚¬â€žÃ¡â‚¬Âº
    );

    try {
      final poseDetector = _poseDetector;
      if (poseDetector == null) {
        print('Pose detector is not initialized');
        return;
      }
      final poses = await poseDetector.processImage(testImage);
      print('Test result: Detected ${poses.length} poses');

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final landmarks = pose.landmarks.values
            .where((landmark) => landmark.likelihood > 0.3)
            .length;
        print('Ã¢Å“â€¦ Test successful! Found $landmarks landmarks');
      } else {
        print('Ã¢ÂÅ’ Test failed: No poses detected');
      }
    } catch (e) {
      print('Ã¢ÂÅ’ Test error: $e');
    }
  }
}


