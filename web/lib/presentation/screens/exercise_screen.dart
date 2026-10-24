import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/pose_detection_service.dart';
import '../../data/services/exercise_logic_engine.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/pose_painter.dart';
import '../widgets/accuracy_bar.dart';
import '../widgets/rep_counter.dart';
import '../providers/exercise_provider.dart';
import '../../core/themes/color_scheme.dart';
import '../../data/models/exercise_log.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../data/services/isar_service.dart';
import '../../features/gamification/badge_manager.dart';
import '../../features/iconic/iconic_program.dart';
import '../../features/iconic/zodiac_sign.dart';
import '../../features/iconic/world_festival.dart';
import '../../features/premium/workout_overlay_customization.dart';
import '../../features/premium/voice_coach.dart';
import '../../features/premium/workout_video_export_service.dart';
import '../../features/premium/workout_video_overlay_timeline.dart';
import '../../presentation/providers/user_provider.dart';
import '../../core/localization/app_localizations.dart';
import 'premium_activation_screen.dart';
//import '../../domain/repositories/exercise_repository.dart';
import 'dart:math';

const bool _enableExerciseScreenVerboseLogs = false;

void print(Object? object) {
  if (_enableExerciseScreenVerboseLogs) {
    debugPrint('$object');
  }
}

class ExerciseScreen extends StatefulWidget {
  final String exerciseId;
  final Map<String, dynamic> exerciseConfig;

  const ExerciseScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseConfig,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with WidgetsBindingObserver {
  late PoseDetectionService _poseDetectionService;
  late ExerciseLogicEngine _exerciseLogicEngine;
  late StreamSubscription _detectionSubscription;
  late StreamSubscription _stateSubscription;
  CameraState? _cameraState;
  AnalysisImage? _lastAnalysisImage;
  String? _lastRecordedPath;
  bool _servicesReady = false;
  final VoiceCoach _voiceCoach = VoiceCoach();
  final WorkoutVideoExportService _videoExportService =
      WorkoutVideoExportService();
  WorkoutVideoOverlayTimeline? _recordingTimeline;
  String? _activeRawRecordingPath;

  double _displayAccuracy = 0.0;
  double _targetAccuracy = 0.0;
  Timer? _smoothTimer;
  static const double _uiSmoothingSpeed = 0.1; // 0.05-0.2 ကြား

  static const String _exerciseGuidePrefsKey =
      'exercise_screen_first_time_guide_shown';

  bool _isProcessing = false;
  bool _showLandmarks = false;
  bool _isRecording = false;
  bool _isRecordActionInProgress = false;
  bool _analysisRestartInProgress = false;
  DateTime? _lastFrameProcessedAt;
  Timer? _recordingAutoStopTimer;
  static const Duration _frameIntervalNormal = Duration(milliseconds: 33);
  static const Duration _frameIntervalRecording = Duration(milliseconds: 33);
  static const Duration _maxRecordingDuration = Duration(minutes: 12);
  static const Duration _voiceCountCooldown = Duration(milliseconds: 700);
  DateTime? _lastVoiceCountAt;
  bool? _voiceCountPremiumEnabled;
  bool? _voiceCountingEnabled;
  String? _voiceCountingLanguage;
  bool _isSavingRecording = false;
  String _recordingStatusTitle = '';
  String _recordingStatusSubtitle = '';

  // Exercise state
  ExerciseState _exerciseState = ExerciseState(
    exerciseId: '',
    phase: 'up',
    repetitions: 0,
    currentAccuracy: 0.0,
    activeWarnings: [],
  );

  // UI state
  double _currentAccuracy = 0.0;
  List<FormWarning> _activeWarnings = [];
  Pose? _lastDetectedPose;
  Map<PoseLandmarkType, Offset> _smoothedLandmarkPositions = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Widget build ပြီးမှ စတင်ပါ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupExerciseSession();
      _maybeShowFirstExerciseGuide();
    });
  }

  Future<void> _setupExerciseSession() async {
    print('🚀 Starting exercise session setup...');

    if (!mounted) return;

    try {
      // Services တွေ စတင်မယ်
      print('⚙️ Initializing services...');
      await _initializeServices();

      if (!mounted) return;

      // UI ကို update လုပ်မယ်
      print('🔄 Updating UI...');
      setState(() {
        // ဒီမှာ state update တွေ လုပ်နိုင်တယ်
      });

      print('✅ Exercise session setup complete!');
    } catch (e) {
      print('❌ Error in setup: $e');
      // Error handling လုပ်ပါ
      if (mounted) {
        final l10n = context.l10n;
        _showErrorDialog(
          l10n.t('exercise.error.setup_title'),
          l10n.t(
            'exercise.error.setup_message',
            params: {'error': '$e'},
          ),
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('common.ok')),
          ),
        ],
      ),
    );
  }

  Future<void> _maybeShowFirstExerciseGuide() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_exerciseGuidePrefsKey) == true) {
      return;
    }
    await prefs.setBool(_exerciseGuidePrefsKey, true);
    if (!mounted) return;

    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colors = theme.colorScheme;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.t('exercise.guide.title'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGuideStep(
              number: 1,
              text: l10n.t('exercise.guide.step1'),
              accent: colors.primary,
            ),
            const SizedBox(height: 10),
            _buildGuideStep(
              number: 2,
              text: l10n.t('exercise.guide.step2'),
              accent: colors.primary,
            ),
            const SizedBox(height: 10),
            _buildGuideStep(
              number: 3,
              text: l10n.t('exercise.guide.step3'),
              accent: colors.primary,
              highlight: true,
            ),
            const SizedBox(height: 10),
            _buildGuideStep(
              number: 4,
              text: l10n.t('exercise.guide.step4'),
              accent: colors.primary,
              highlight: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.t('common.close')),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep({
    required int number,
    required String text,
    required Color accent,
    bool highlight = false,
  }) {
    final textColor = highlight ? Colors.red.shade700 : null;
    final fontWeight = highlight ? FontWeight.w700 : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$number',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              height: 1.35,
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ],
    );
  }

  // _initializeCamera();
  // _initializeServices();
  Future<void> _testPoseDetector() async {
    print('🧪 Testing Pose Detector...');

    PoseDetector? testDetector;

    try {
      final options = PoseDetectorOptions(
        mode: PoseDetectionMode.single,
        model: PoseDetectionModel.accurate,
      );

      testDetector = PoseDetector(options: options);
      print('✅ Pose detector created successfully');

      // Test with a simple operation
      // Note: We can't use isAvailable(), so we just test creation
      print('✅ Pose detector test passed');
    } catch (e) {
      print('❌ Pose detector test failed: $e');
      print('Possible reasons:');
      print('1. ML Kit not installed properly');
      print('2. Device not compatible');
      print('3. Missing permissions');

      // Show error to user
      if (mounted) {
        final l10n = context.l10n;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.t('exercise.error.pose_title')),
            content: Text(l10n.t('exercise.error.pose_message')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.t('common.ok')),
              ),
            ],
          ),
        );
      }
    } finally {
      // Always close the detector
      try {
        await testDetector?.close();
      } catch (e) {
        print('Error closing test detector: $e');
      }
    }
  }

  Future<void> _initializeServices() async {
    print('⚙️ Initializing services...');

    try {
      // Initialize pose detection service
      _poseDetectionService = PoseDetectionService();
      await _poseDetectionService.initialize();
      print('✅ Created PoseDetectionService');

      // Test pose detector
      print('🧪 Testing pose detector...');
      await _testPoseDetector();

      print('✅ Pose detector test passed');
      await _configureRecordingBackend();

      // Get exercise provider
      final exerciseProvider = context.read<ExerciseProvider>();
      final userProvider = context.read<UserProvider>();
      await userProvider.refreshPremiumStatus(forceServerCheck: false);
      _showLandmarks = userProvider.showLandmarks;
      try {
        await _voiceCoach.initialize();
        _syncVoiceCoachSettings(userProvider, force: true);
        if (userProvider.voiceCountingEnabled) {
          await _voiceCoach.warmUpCounting();
        }
      } catch (e) {
        debugPrint('Voice counting init skipped: $e');
      }

      // Initialize exercise logic engine
      _exerciseLogicEngine = ExerciseLogicEngine(
        validateForm: exerciseProvider.validateFormUseCase,
        exerciseId: widget.exerciseId,
        exerciseConfig: widget.exerciseConfig,
      );

      print('✅ ExerciseLogicEngine initialized for: ${widget.exerciseId}');

      // Subscribe to detection results
      _detectionSubscription = _poseDetectionService.detectionStream.listen(
        (PoseDetectionResult result) {
          // First, update UI
          _handleDetectionResult(result);

          // Keep the native camera flow aligned with the previous camera
          // pipeline: once a pose exists, forward the frame to the counting
          // engine and let that engine decide whether the frame is usable.
          final isPremium = context.read<UserProvider>().isPremium;
          if (isPremium && result.isPoseDetected && result.pose != null) {
            _exerciseLogicEngine.processFrame(
              jointAngles: result.jointAngles,
              formWarnings: result.formWarnings,
              overallAccuracy: result.overallAccuracy,
            );
          }
        },
        onError: (error) {
          print('❌ Detection stream error: $error');
          _sendSimulatedData();
        },
      );

      print('✅ Subscribed to detection stream');

      // Subscribe to exercise state changes
      _stateSubscription = _exerciseLogicEngine.stateStream.listen(
        _handleExerciseStateChange,
        onError: (error) {
          print('❌ State stream error: $error');
        },
      );

      print('✅ Subscribed to state stream');
      print('🎉 All services initialized successfully');
      _servicesReady = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resumeAnalysisIfNeeded();
      });
    } catch (e) {
      print('❌ Service initialization failed: $e');

      // Fallback to simulated mode
      _startSimulatedMode();
    }
  }

// Helper method for simulated mode
  void _startSimulatedMode() {
    print('🔄 Starting simulated mode...');

    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _sendSimulatedData();
    });
  }

  void _sendSimulatedData() {
    final simulatedAngles = {
      'knee': 120.0 + Random().nextDouble() * 30.0,
      'hip': 90.0 + Random().nextDouble() * 20.0,
      'shoulder': 170.0 + Random().nextDouble() * 10.0,
    };

    final simulatedPoseResult = PoseDetectionResult(
      pose: null,
      jointAngles: simulatedAngles,
      formWarnings: [],
      overallAccuracy: 0.7 + Random().nextDouble() * 0.3,
      isPoseDetected: true,
      timestamp: DateTime.now(),
    );

    _handleDetectionResult(simulatedPoseResult);
  }

// State class ထဲမှာ ဒီ function ကိုထည့်ပါ
  Map<PoseLandmarkType, Offset> _buildSmoothedLandmarkPositions(Pose pose) {
    if (_smoothedLandmarkPositions.isEmpty) {
      return {
        for (final entry in pose.landmarks.entries)
          entry.key: Offset(entry.value.x, entry.value.y),
      };
    }

    final nextPositions = <PoseLandmarkType, Offset>{};
    for (final entry in pose.landmarks.entries) {
      final current = Offset(entry.value.x, entry.value.y);
      final previous = _smoothedLandmarkPositions[entry.key];
      if (previous == null) {
        nextPositions[entry.key] = current;
        continue;
      }

      final distance = (current - previous).distance;
      final smoothingFactor = distance > 42
          ? 0.48
          : distance > 20
              ? 0.34
              : 0.22;

      nextPositions[entry.key] =
          Offset.lerp(previous, current, smoothingFactor) ?? current;
    }

    return nextPositions;
  }

  void _resetDetectionData() {
    print('🔄 Resetting detection data');

    setState(() {
      _displayAccuracy = 0.0;
      _targetAccuracy = 0.0;
      _currentAccuracy = 0.0;
      _activeWarnings.clear();
      _lastDetectedPose = null;
      _smoothedLandmarkPositions = const {};

      // Exercise state ကို reset (reps ကိုတော့ မဖျက်ဘူး)
      _exerciseState = ExerciseState(
        exerciseId: widget.exerciseId,
        phase: 'up',
        repetitions: _exerciseState.repetitions, // Reps ကိုဆက်ထား
        currentAccuracy: 0.0,
        activeWarnings: _activeWarnings,
      );
    });

    // Smoothing timer ကို stop
    _smoothTimer?.cancel();
    _smoothTimer = null;

    // Pose detection service ထဲက smoothing history ကိုလည်း reset လုပ်သင့်ရင်
    // ဒါပေမယ့် service က private variable ဖြစ်နေလို့
    // သင်ကိုယ်တိုင် expose လုပ်ပေးရမယ်
  }

  Future<void> _processAnalysisImage(AnalysisImage image) async {
    if (!mounted || _isProcessing || !_servicesReady) return;

    final now = DateTime.now();
    final interval =
        _isRecording ? _frameIntervalRecording : _frameIntervalNormal;
    if (_lastFrameProcessedAt != null &&
        now.difference(_lastFrameProcessedAt!) < interval) {
      return;
    }
    _lastFrameProcessedAt = now;

    _isProcessing = true;

    try {
      final inputImage = image.toInputImage();
      _lastAnalysisImage = image;

      await _poseDetectionService.processInputImage(
        inputImage,
        widget.exerciseId,
        widget.exerciseConfig,
      );
    } catch (e) {
      print('Error processing analysis image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  // Determine rotation based on device orientation
//     InputImageRotation rotation;
//     switch (_cameraController.value.deviceOrientation) {
//       case DeviceOrientation.portraitUp:
//         rotation = InputImageRotation.rotation90deg;
//         break;
//       case DeviceOrientation.portraitDown:
//         rotation = InputImageRotation.rotation270deg;
//         break;
//       case DeviceOrientation.landscapeLeft:
//         rotation = InputImageRotation.rotation0deg;
//         break;
//       case DeviceOrientation.landscapeRight:
//         rotation = InputImageRotation.rotation180deg;
//         break;
//       default:
//         rotation = InputImageRotation.rotation90deg;
//     }

//     await _poseDetectionService.processCameraImage(
//       image,
//       rotation,
//       _cameraPreviewSize!,
//       widget.exerciseId,
//       widget.exerciseConfig,
//     );

//   } catch (e) {
//     print('Error processing camera image: $e');
//     print('Stack trace: ${e.toString()}');
//   } finally {
//     _isProcessing = false;
//   }
// }

  void _handleDetectionResult(PoseDetectionResult result) {
    if (!mounted) return;

    if (result.formWarnings.isNotEmpty &&
        result.formWarnings
            .any((w) => w.warningId == 'full_body_not_visible') &&
        result.pose == null) {
      _resetDetectionData();

      // UI ကို reset လုပ်မယ်
      setState(() {
        _displayAccuracy = 0.0;
        _targetAccuracy = 0.0;
        _currentAccuracy = 0.0;
        _activeWarnings = result.formWarnings;
        _lastDetectedPose = null;
      });

      // Snackbar နဲ့ သတိပေးမယ်
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Row(
      //       children: [
      //         Icon(Icons.warning, color: Colors.yellow),
      //         SizedBox(width: 10),
      //         Expanded(
      //           child: Text(
      //             'Please step back so your entire body is visible in the frame',
      //             style: TextStyle(fontSize: 14),
      //           ),
      //         ),
      //       ],
      //     ),
      //     backgroundColor: Colors.black87,
      //     duration: Duration(seconds: 3),
      //     behavior: SnackBarBehavior.floating,
      //   ),
      // );

      return; // ဒီ frame ကိုဆက်မလုပ်တော့ဘူး
    }

    _targetAccuracy = result.overallAccuracy;

    if (_isRecording) {
      _smoothTimer?.cancel();
      _smoothTimer = null;
      _displayAccuracy = _targetAccuracy;
    } else if (_smoothTimer == null || !_smoothTimer!.isActive) {
      // Start smooth animation only when not recording to reduce extra UI work.
      _startSmoothAnimation();
    }

    print('Detection result received:');
    print('- Pose detected: ${result.isPoseDetected}');
    print('- Overall accuracy: ${result.overallAccuracy}');
    print('- Joint angles count: ${result.jointAngles.length}');
    print('- Warnings count: ${result.formWarnings.length}');

    if (result.pose != null) {
      final landmarks = result.pose!.landmarks.values
          .where((landmark) => landmark.likelihood > 0.3)
          .length;
      print('- Landmarks with confidence > 0.3: $landmarks');
    }

    setState(() {
      _currentAccuracy = result.overallAccuracy;
      _activeWarnings = result.formWarnings;
      _lastDetectedPose = result.pose;
      _smoothedLandmarkPositions = result.pose != null
          ? _buildSmoothedLandmarkPositions(result.pose!)
          : const {};
    });

    if (_isRecording && _recordingTimeline != null) {
      _recordingTimeline!.record(
        repCount: _exerciseState.repetitions,
        accuracy: result.overallAccuracy,
        phase: _overlayPhaseForExercisePhase(_exerciseState.phase),
      );
    }
  }

// Adaptive smoothing based on difference
  void _startSmoothAnimation() {
    _smoothTimer?.cancel();

    _smoothTimer = Timer.periodic(Duration(milliseconds: 32), (timer) {
      // Slower: 32ms instead of 16ms
      if (!mounted) {
        timer.cancel();
        return;
      }

      final double difference = _targetAccuracy - _displayAccuracy;
      final double absDifference = difference.abs();

      final bool isSitup = widget.exerciseId == 'situp';
      // Faster smoothing for sit-up to follow body movement closely
      double smoothingSpeed = isSitup ? 0.08 : 0.02; // Base

      // Even slower for small differences
      if (absDifference < 0.1) {
        smoothingSpeed = isSitup ? 0.04 : 0.01; // small changes
      }
      // Moderate for medium differences
      else if (absDifference < 0.3) {
        smoothingSpeed = isSitup ? 0.08 : 0.03; // medium changes
      }
      // A bit faster for large differences (but still slow)
      else {
        smoothingSpeed = isSitup ? 0.12 : 0.05; // large changes
      }

      final double change = difference * smoothingSpeed;

      // Stop when very close
      if (absDifference < 0.001) {
        timer.cancel();
        _smoothTimer = null;
        setState(() {
          _displayAccuracy = _targetAccuracy;
        });
      } else {
        setState(() {
          _displayAccuracy += change;
        });
      }
    });
  }

  void _handleExerciseStateChange(ExerciseState state) {
    if (!mounted) return;

    final previousReps = _exerciseState.repetitions;
    final shouldRebuild = _shouldRebuildExerciseState(state);
    final repIncreased = state.repetitions > previousReps;

    final userProvider = context.read<UserProvider>();
    _syncVoiceCoachSettings(userProvider);

    // Premium-only counting feedback
    if (userProvider.isPremium &&
        userProvider.voiceCountingEnabled &&
        repIncreased &&
        _canSpeakNextCount()) {
      _provideHapticFeedback();
      _lastVoiceCountAt = DateTime.now();
      _voiceCoach.speakCount(state.repetitions);
    }

    _exerciseState = state;
    if (shouldRebuild) {
      setState(() {});
    }

    if (_isRecording && _recordingTimeline != null) {
      _recordingTimeline!.record(
        repCount: state.repetitions,
        accuracy: _currentAccuracy,
        phase: _overlayPhaseForExercisePhase(state.phase),
      );
    }
  }

  bool _shouldRebuildExerciseState(ExerciseState nextState) {
    if (_exerciseState.phase != nextState.phase ||
        _exerciseState.repetitions != nextState.repetitions ||
        _exerciseState.isExerciseComplete != nextState.isExerciseComplete) {
      return true;
    }

    final previousHoldSeconds = _exerciseState.holdDuration?.inSeconds;
    final nextHoldSeconds = nextState.holdDuration?.inSeconds;
    if (previousHoldSeconds != nextHoldSeconds) {
      return true;
    }

    final previousWarnings = _exerciseState.activeWarnings;
    final nextWarnings = nextState.activeWarnings;
    if (previousWarnings.length != nextWarnings.length) {
      return true;
    }

    for (var i = 0; i < previousWarnings.length; i++) {
      final previousWarning = previousWarnings[i];
      final nextWarning = nextWarnings[i];
      if (previousWarning.warningId != nextWarning.warningId ||
          previousWarning.message != nextWarning.message) {
        return true;
      }
    }

    return false;
  }

  void _provideHapticFeedback() {
    // Use haptic feedback for rep completion
    HapticFeedback.mediumImpact();
  }

  void _syncVoiceCoachSettings(
    UserProvider userProvider, {
    bool force = false,
  }) {
    if (force || _voiceCountPremiumEnabled != userProvider.isPremium) {
      _voiceCoach.setPremium(userProvider.isPremium);
      _voiceCountPremiumEnabled = userProvider.isPremium;
    }
    if (force || _voiceCountingEnabled != userProvider.voiceCountingEnabled) {
      _voiceCoach.setCountingEnabled(userProvider.voiceCountingEnabled);
      _voiceCountingEnabled = userProvider.voiceCountingEnabled;
    }
    if (force || _voiceCountingLanguage != userProvider.voiceCountingLanguage) {
      _voiceCoach.setCountingLanguage(userProvider.voiceCountingLanguage);
      _voiceCountingLanguage = userProvider.voiceCountingLanguage;
    }
  }

  bool _canSpeakNextCount() {
    final now = DateTime.now();
    final lastVoiceCountAt = _lastVoiceCountAt;
    if (lastVoiceCountAt == null) {
      return true;
    }
    return now.difference(lastVoiceCountAt) >= _voiceCountCooldown;
  }

  Future<void> _toggleLandmarks() async {
    final userProvider = context.read<UserProvider>();
    if (!userProvider.isPremium) {
      final l10n = context.l10n;
      _showPremiumPrompt(
        message: l10n.t('exercise.premium.landmarks'),
      );
      return;
    }

    await userProvider.toggleLandmarks();
    if (!mounted) return;

    setState(() {
      _showLandmarks = userProvider.showLandmarks;
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecordActionInProgress) return;
    final userProvider = context.read<UserProvider>();
    if (!userProvider.isPremium) {
      final l10n = context.l10n;
      _showPremiumPrompt(
        message: l10n.t('exercise.premium.recording'),
      );
      return;
    }

    _isRecordActionInProgress = true;
    try {
      if (!_isRecording) {
        final started = await _startWorkoutRecording();
        if (started) {
          if (mounted) {
            setState(() {
              _isRecording = true;
            });
          } else {
            _isRecording = true;
          }
        }
      } else {
        final savedPath = await _stopWorkoutRecording();
        if (mounted) {
          setState(() {
            _isRecording = false;
          });
        } else {
          _isRecording = false;
        }
        if (savedPath != null && savedPath.isNotEmpty) {
          _lastRecordedPath = savedPath;
        }
      }
    } catch (e) {
      _clearRecordingProcessingStatus();
      print('Error toggling recording: $e');
      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.t(
                'exercise.recording.failed_start',
                params: {'error': '$e'},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isRecordActionInProgress = false;
    }
  }

  Future<void> _configureRecordingBackend() async {
    // Keep raw camera recording so the exported video can be post-processed
    // using the user's selected overlay style after capture.
  }

  Future<bool> _startWorkoutRecording() async {
    return _startNativeVideoRecording();
  }

  Future<String?> _stopWorkoutRecording({
    bool showResultSnackBar = true,
  }) async {
    return _stopNativeVideoRecording(
      showResultSnackBar: showResultSnackBar,
    );
  }

  Future<bool> _startNativeVideoRecording() async {
    final userProvider = context.read<UserProvider>();
    final includeAudio = userProvider.voiceCountingEnabled;
    final hasPermission = await _ensureVideoRecordingPermissions(
      needsAudio: includeAudio,
    );
    if (!hasPermission) {
      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.t('exercise.recording.permission_denied')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    final cameraState = await _ensureVideoCameraState();
    if (cameraState == null) {
      return false;
    }

    await cameraState.enableAudio(includeAudio);
    final captureRequest = await cameraState.startRecording();
    final rawPath = _captureRequestPath(captureRequest);
    if (rawPath == null || rawPath.isEmpty) {
      return false;
    }

    _activeRawRecordingPath = rawPath;
    _recordingTimeline = WorkoutVideoOverlayTimeline.start()
      ..record(
        repCount: _exerciseState.repetitions,
        accuracy: _currentAccuracy,
        phase: _overlayPhaseForExercisePhase(_exerciseState.phase),
      );
    _scheduleRecordingAutoStop();

    HapticFeedback.lightImpact();
    _lastFrameProcessedAt = null;
    await _resumeAnalysisIfNeeded();
    Future<void>.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted || !_isRecording) {
        return;
      }
      _lastFrameProcessedAt = null;
      await _resumeAnalysisIfNeeded();
    });
    return true;
  }

  Future<String?> _stopNativeVideoRecording({
    bool showResultSnackBar = true,
  }) async {
    final initialEstimate = _buildRecordingSaveEstimate();
    _setRecordingProcessingStatus(
      title: 'Finishing recording',
      subtitle: initialEstimate == null
          ? 'Preparing your workout video...'
          : 'Preparing your workout video...\nEstimated time: $initialEstimate',
    );
    _cancelRecordingAutoStop();
    final cameraState = _cameraState;
    if (cameraState is! VideoRecordingCameraState) {
      _clearRecordingProcessingStatus();
      return null;
    }

    String? rawPath = _activeRawRecordingPath;
    try {
      await cameraState.stopRecording(
        onVideo: (captureRequest) {
          rawPath ??= _captureRequestPath(captureRequest);
        },
      );
    } catch (e) {
      rawPath ??= _activeRawRecordingPath;
      if (rawPath == null || rawPath!.isEmpty) {
        _clearRecordingProcessingStatus();
        rethrow;
      }
    }

    _lastFrameProcessedAt = null;
    await _resumeAnalysisIfNeeded();

    if (rawPath == null || rawPath!.isEmpty) {
      _clearRecordingProcessingStatus();
      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.t('exercise.recording.failed_save')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }

    final timeline = _recordingTimeline;
    _activeRawRecordingPath = null;
    _recordingTimeline = null;
    final userProvider = context.read<UserProvider>();
    final zodiacVisual = _zodiacVisualForProgram(userProvider.iconicProgram);
    final festivalVisual =
        _festivalVisualForProgram(userProvider.iconicProgram);
    final overlayCustomization = userProvider.workoutOverlayCustomization;

    // Determine overlay key and title: zodiac, festival, or null.
    final String? overlayKey =
        zodiacVisual?.storageKey ?? festivalVisual?.storageKey;
    final String? overlayTitle =
        zodiacVisual?.title ?? festivalVisual?.themeName;

    WorkoutVideoExportResult? exportResult;
    try {
      final exportEstimate = _buildRecordingSaveEstimate(
        iconicProgram: userProvider.iconicProgram,
        customization: overlayCustomization,
        timeline: timeline,
      );
      _setRecordingProcessingStatus(
        title: 'Saving workout video',
        subtitle: exportEstimate == null
            ? 'Post-processing overlay and saving to your library...'
            : 'Post-processing overlay and saving to your library...\nEstimated time: $exportEstimate',
      );
      exportResult = await _videoExportService.exportVideoWithOverlay(
        rawVideoPath: rawPath!,
        exerciseId: widget.exerciseId,
        customization: overlayCustomization,
        iconicProgram: userProvider.iconicProgram,
        zodiacSignKey: overlayKey,
        worldFestivalTheme: festivalVisual,
        overlayTitle: overlayTitle,
        timeline: timeline ??
            (WorkoutVideoOverlayTimeline.start()
              ..record(
                repCount: _exerciseState.repetitions,
                accuracy: _currentAccuracy,
                phase: _overlayPhaseForExercisePhase(_exerciseState.phase),
              )),
      );
    } catch (e) {
      exportResult = null;
    }

    final appSavedPath = exportResult?.videoPath;
    if (exportResult?.usedRawFallback == true) {
      debugPrint(
        'Workout video overlay export fell back to raw recording. '
        'Reason: ${exportResult?.exportError ?? 'unknown'}',
      );
    }
    _clearRecordingProcessingStatus();
    if (mounted && showResultSnackBar) {
      final l10n = context.l10n;
      final snackMessage = exportResult == null
          ? l10n.t('exercise.recording.failed_save')
          : exportResult.usedRawFallback
              ? 'Saved raw video only. Overlay export failed.'
              : l10n.t(
                  'exercise.recording.saved_app',
                  params: {'path': appSavedPath ?? ''},
                );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return appSavedPath;
  }

  void _setRecordingProcessingStatus({
    required String title,
    required String subtitle,
  }) {
    if (!mounted) return;
    setState(() {
      _isSavingRecording = true;
      _recordingStatusTitle = title;
      _recordingStatusSubtitle = subtitle;
    });
  }

  void _clearRecordingProcessingStatus() {
    if (!mounted) return;
    setState(() {
      _isSavingRecording = false;
      _recordingStatusTitle = '';
      _recordingStatusSubtitle = '';
    });
  }

  String? _buildRecordingSaveEstimate({
    IconicProgram? iconicProgram,
    WorkoutOverlayCustomization? customization,
    WorkoutVideoOverlayTimeline? timeline,
  }) {
    final effectiveTimeline = timeline ?? _recordingTimeline;
    if (effectiveTimeline == null) {
      return null;
    }

    final elapsed = DateTime.now().difference(effectiveTimeline.startedAt);
    final durationSeconds = elapsed.inSeconds.clamp(1, 12 * 60);

    final effectiveProgram =
        iconicProgram ?? context.read<UserProvider>().iconicProgram;
    final effectiveCustomization =
        customization ?? context.read<UserProvider>().workoutOverlayCustomization;

    var multiplier = 0.18;
    var baseSeconds = 5;

    switch (effectiveProgram) {
      case IconicProgram.worldFestival:
        multiplier = 0.28;
        baseSeconds = 7;
        break;
      case IconicProgram.zodiac:
        multiplier = 0.24;
        baseSeconds = 6;
        break;
      case IconicProgram.none:
        multiplier = 0.18;
        baseSeconds = 5;
        break;
    }

    if (effectiveCustomization.customModeEnabled) {
      multiplier += 0.08;
      baseSeconds += 2;
    }

    final estimatedSeconds =
        (baseSeconds + (durationSeconds * multiplier)).round().clamp(5, 90);
    return _formatEstimatedDuration(Duration(seconds: estimatedSeconds));
  }

  String _formatEstimatedDuration(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(1, 90);
    if (totalSeconds < 60) {
      return 'about ${totalSeconds}s';
    }
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (seconds == 0) {
      return 'about ${minutes}m';
    }
    return 'about ${minutes}m ${seconds}s';
  }

  Future<VideoCameraState?> _ensureVideoCameraState() async {
    final currentState = _cameraState;
    if (currentState is VideoCameraState) {
      return currentState;
    }

    if (currentState is PhotoCameraState) {
      currentState.setState(CaptureMode.video);
    }

    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (DateTime.now().isBefore(deadline)) {
      final state = _cameraState;
      if (state is VideoCameraState) {
        return state;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final fallbackState = _cameraState;
    return fallbackState is VideoCameraState ? fallbackState : null;
  }

  Future<void> _restorePhotoCameraState() async {
    final currentState = _cameraState;
    if (currentState is VideoCameraState) {
      currentState.setState(CaptureMode.photo);
    }

    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (DateTime.now().isBefore(deadline)) {
      if (_cameraState is PhotoCameraState) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  ZodiacVisualStyle? _zodiacVisualForProgram(IconicProgram program) {
    switch (program) {
      case IconicProgram.zodiac:
        return zodiacVisualStyleForDate(DateTime.now());
      case IconicProgram.none:
      case IconicProgram.worldFestival:
        return null;
    }
  }

  WorldFestivalVisualStyle? _festivalVisualForProgram(IconicProgram program) {
    switch (program) {
      case IconicProgram.worldFestival:
        return worldFestivalForDate(DateTime.now());
      case IconicProgram.none:
      case IconicProgram.zodiac:
        return null;
    }
  }

  OverlayMovementPhase _overlayPhaseForExercisePhase(String rawPhase) {
    switch (rawPhase.trim().toLowerCase()) {
      case 'up':
        return OverlayMovementPhase.up;
      case 'down':
        return OverlayMovementPhase.down;
      case 'hold':
        return OverlayMovementPhase.hold;
      default:
        return OverlayMovementPhase.idle;
    }
  }

  void _scheduleRecordingAutoStop() {
    _recordingAutoStopTimer?.cancel();
    _recordingAutoStopTimer = Timer(
      _maxRecordingDuration,
      _handleAutoStopRecording,
    );
  }

  void _cancelRecordingAutoStop() {
    _recordingAutoStopTimer?.cancel();
    _recordingAutoStopTimer = null;
  }

  Future<void> _handleAutoStopRecording() async {
    if (!_isRecording || _isRecordActionInProgress) {
      return;
    }

    _isRecordActionInProgress = true;
    try {
      final savedPath = await _stopWorkoutRecording(
        showResultSnackBar: false,
      );
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      } else {
        _isRecording = false;
      }

      if (savedPath != null && savedPath.isNotEmpty) {
        _lastRecordedPath = savedPath;
      }

      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              savedPath != null && savedPath.isNotEmpty
                  ? 'Recording stopped automatically after 12 minutes and was saved.'
                  : l10n.t('exercise.recording.failed_save'),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _clearRecordingProcessingStatus();
      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.t(
                'exercise.recording.failed_start',
                params: {'error': '$e'},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isRecordActionInProgress = false;
    }
  }

  Future<bool> _ensureVideoRecordingPermissions({
    required bool needsAudio,
  }) async {
    if (Platform.isAndroid) {
      final storage = await Permission.storage.request();
      PermissionStatus videos = PermissionStatus.denied;
      try {
        videos = await Permission.videos.request();
      } catch (_) {
        videos = PermissionStatus.denied;
      }
      final hasFilePermission =
          storage.isGranted || videos.isGranted || videos.isLimited;
      if (!needsAudio) {
        return hasFilePermission;
      }
      final microphone = await Permission.microphone.request();
      return microphone.isGranted && hasFilePermission;
    }
    if (Platform.isIOS) {
      final photos = await Permission.photos.request();
      if (!needsAudio) {
        return photos.isGranted;
      }
      final microphone = await Permission.microphone.request();
      return photos.isGranted && microphone.isGranted;
    }
    return false;
  }

  String? _captureRequestPath(CaptureRequest captureRequest) {
    return captureRequest.when(
      single: (single) => single.file?.path,
      multiple: (multiple) {
        for (final value in multiple.fileBySensor.values) {
          if (value?.path != null && value!.path.isNotEmpty) {
            return value.path;
          }
        }
        return null;
      },
    );
  }

  Future<CaptureRequest> _buildVideoCaptureRequest(List<Sensor> sensors) async {
    final tempDirectory = await getTemporaryDirectory();
    final directory = Directory(
      '${tempDirectory.path}${Platform.pathSeparator}hf_native_recordings',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final safeId =
        widget.exerciseId.replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_').trim();
    final baseName = safeId.isEmpty ? 'raw_workout' : 'raw_workout_$safeId';
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (sensors.length == 1) {
      final filePath = '${directory.path}/${baseName}_$timestamp.mp4';
      return SingleCaptureRequest(filePath, sensors.first);
    }

    final fileBySensor = <Sensor, String>{};
    for (final sensor in sensors) {
      final sensorName =
          sensor.position?.toString().split('.').last ?? 'unknown';
      fileBySensor[sensor] =
          '${directory.path}/${baseName}_${sensorName}_$timestamp.mp4';
    }
    return MultipleCaptureRequest(fileBySensor);
  }

  void _handleMediaCaptureEvent(MediaCapture event) {
    if (!mounted) return;

    if (event.status == MediaCaptureStatus.success && event.isVideo) {
      _activeRawRecordingPath ??= _captureRequestPath(event.captureRequest);
      return;
    }

    if (event.status == MediaCaptureStatus.failure && event.isVideo) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.t(
              'exercise.recording.failed_video',
              params: {'error': '${event.exception}'},
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPremiumPrompt({
    String? title,
    required String message,
  }) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? l10n.t('exercise.premium.title')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.t('exercise.premium.not_now')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PremiumActivationScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.t('exercise.premium.upgrade')),
          ),
        ],
      ),
    );
  }

  Future<void> _completeWorkout() async {
    final userProvider = context.read<UserProvider>();
    if (!userProvider.isPremium) {
      final l10n = context.l10n;
      _showPremiumPrompt(
        title: l10n.t('exercise.premium.required_title'),
        message: l10n.t('exercise.premium.required_message'),
      );
      return;
    }

    final log = await _exerciseLogicEngine.completeSession();

    // Show summary first; save only after user taps Save
    _showWorkoutSummary(log);
  }

  Future<void> _saveWorkout(ExerciseLog log) async {
    // Save to database
    await IsarService.saveExerciseLog(log);
    try {
      await BadgeManager().checkAndUpdateBadges(log);
    } catch (e) {
      debugPrint('Badge update failed: $e');
    }
  }

  void _showWorkoutSummary(ExerciseLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => WorkoutSummarySheet(
        log: log,
        onSave: () async {
          Navigator.pop(context);
          await _saveWorkout(log);
        },
      ),
    );
  }

  void _showCameraError() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('exercise.camera.error_title')),
        content: Text(l10n.t('exercise.camera.error_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('common.ok')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poseDetectionService.dispose();
    _exerciseLogicEngine.dispose();
    _detectionSubscription.cancel();
    _stateSubscription.cancel();
    _smoothTimer?.cancel();
    _cancelRecordingAutoStop();
    _voiceCoach.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumeAnalysisIfNeeded();
    }
  }

  Future<void> _resumeAnalysisIfNeeded() async {
    final controller = _cameraState?.analysisController;
    if (controller == null) return;
    if (!controller.enabled && !_analysisRestartInProgress) {
      try {
        _analysisRestartInProgress = true;
        await controller.start();
      } catch (e) {
        // ignore errors, analysis may already be running
        print('Failed to restart analysis: $e');
      } finally {
        _analysisRestartInProgress = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isRecording) {
          return true;
        }
        if (_isRecordActionInProgress) {
          return false;
        }
        _isRecordActionInProgress = true;
        try {
          final savedPath = await _stopWorkoutRecording();
          if (mounted) {
            setState(() {
              _isRecording = false;
            });
          } else {
            _isRecording = false;
          }
          if (savedPath != null && savedPath.isNotEmpty) {
            _lastRecordedPath = savedPath;
          }
        } finally {
          _isRecordActionInProgress = false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CameraAwesomeBuilder.custom(
          sensorConfig: SensorConfig.single(
            sensor: Sensor.position(SensorPosition.front),
            aspectRatio: CameraAspectRatios.ratio_16_9,
          ),
          saveConfig: SaveConfig.video(
            pathBuilder: _buildVideoCaptureRequest,
            videoOptions: VideoOptions(
              enableAudio: false,
              quality: VideoRecordingQuality.hd,
            ),
            mirrorFrontCamera: true,
          ),
          previewFit: CameraPreviewFit.cover,
          imageAnalysisConfig: AnalysisConfig(
            autoStart: true,
            maxFramesPerSecond: 15,
            androidOptions: AndroidAnalysisOptions.nv21(width: 480),
            cupertinoOptions: CupertinoAnalysisOptions.bgra8888(width: 480),
          ),
          onImageForAnalysis: _processAnalysisImage,
          onMediaCaptureEvent: _handleMediaCaptureEvent,
          builder: (state, preview) {
            _cameraState = state;
            if (!_analysisRestartInProgress &&
                state.analysisController != null &&
                !state.analysisController!.enabled) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _resumeAnalysisIfNeeded();
              });
            }
            final isRecording = _isRecording;
            final simplifyRecordingVisuals = isRecording;
            final previewRect = preview.rect;
            final isFrontCamera = !preview.isBackCamera;
            final userProvider = context.read<UserProvider>();
            const WorldFestivalVisualStyle? liveFestivalVisual = null;
            final showLandmarksSetting =
                _showLandmarks || userProvider.showLandmarks;
            final showLandmarks = showLandmarksSetting;
            final selectedTheme = userProvider.selectedTheme;
            final angleTextColor = selectedTheme == 'gold'
                ? AppColorScheme.goldMid
                : selectedTheme == 'pink'
                    ? AppColorScheme.pinkMid
                    : Colors.white;
            final safePadding = MediaQuery.of(context).padding;
            const double repCounterRightOffset = 20;
            const double repCounterSize = 100;

            return Stack(
              children: [
                if (state is PreparingCameraState)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                if (_lastDetectedPose != null && _lastAnalysisImage != null)
                  Positioned.fromRect(
                    rect: previewRect,
                    child: CustomPaint(
                      painter: PosePainter(
                        pose: _lastDetectedPose!,
                        accuracy: _currentAccuracy,
                        landmarkOverrides: _smoothedLandmarkPositions,
                        showLandmarks: showLandmarks,
                        showConnections: showLandmarks,
                        showAngles: !showLandmarks,
                        angleTextColor: angleTextColor,
                        preview: preview,
                        analysisImage: _lastAnalysisImage!,
                        isFrontCamera: isFrontCamera,
                        festivalStyle: liveFestivalVisual,
                      ),
                    ),
                  ),
                if (!isRecording)
                  Positioned.fill(
                    child: SafeArea(
                      child: CameraOverlay(
                        accuracy: _currentAccuracy,
                        repCount: _exerciseState.repetitions,
                        phase: _exerciseState.phase,
                        warnings: _activeWarnings,
                        holdDuration: _exerciseState.holdDuration,
                        onToggleLandmarks: _toggleLandmarks,
                        onToggleRecording: _toggleRecording,
                        onCompleteWorkout: _completeWorkout,
                        showLandmarks: showLandmarksSetting,
                        isRecording: isRecording,
                      ),
                    ),
                  ),
                if (isRecording)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onDoubleTap: _toggleRecording,
                      child: const SizedBox.shrink(),
                    ),
                  ),
                if (isRecording)
                  Positioned(
                    top: 214 + safePadding.top,
                    right: repCounterRightOffset,
                    width: repCounterSize,
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildRecordingWatermark(),
                    ),
                  ),
                Positioned(
                  top: 50 + safePadding.top,
                  left: 20,
                  right: 20,
                  child: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      if (!userProvider.isPremium) {
                        return const SizedBox.shrink();
                      }

                      return AccuracyBar(
                        accuracy: _displayAccuracy,
                        animate: !simplifyRecordingVisuals,
                        simplified: simplifyRecordingVisuals,
                        festivalStyle:
                            simplifyRecordingVisuals ? null : liveFestivalVisual,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 100 + safePadding.top,
                  right: repCounterRightOffset,
                  child: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      if (!userProvider.isPremium) {
                        return const SizedBox.shrink();
                      }

                      // Use a lighter gold that matches the gold theme body/surfaces better.
                      final repCounterColor =
                          userProvider.selectedTheme == 'gold'
                              ? AppColorScheme.goldStart
                              : userProvider.selectedTheme == 'pink'
                                  ? AppColorScheme.pinkStart
                                  : Colors.green;

                      final counterBadgeLevel =
                          RepCounterBadgeLevelResolver.fromBadges(
                        userProvider.badges,
                      );

                      const isStaticExercise = false;

                      if (simplifyRecordingVisuals) {
                        return RepCounter(
                          count: _exerciseState.repetitions,
                          phase: _exerciseState.phase,
                          color: repCounterColor,
                          badgeLevel: counterBadgeLevel,
                          holdDuration: _exerciseState.holdDuration,
                          isStaticExercise: isStaticExercise,
                          festivalStyle: null,
                        );
                      }

                      return AnimatedRepCounter(
                        count: _exerciseState.repetitions,
                        phase: _exerciseState.phase,
                        color: repCounterColor,
                        badgeLevel: counterBadgeLevel,
                        holdDuration: _exerciseState.holdDuration,
                        isStaticExercise: isStaticExercise,
                        festivalStyle: liveFestivalVisual,
                      );
                    },
                  ),
                ),
                if (_isSavingRecording)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.36),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: _buildRecordingProcessingCard(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecordingWatermark() {
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  size: 14,
                  color: Colors.white.withOpacity(0.40),
                ),
                const SizedBox(width: 6),
                Text(
                  'H&F',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.40),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingProcessingCard() {
    final l10n = context.l10n;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.72),
                const Color(0xFF10243B).withOpacity(0.80),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.14),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.24),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 1,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF8DD8FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _recordingStatusTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _recordingStatusSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.t('exercise.recording.preparing_luxury_video'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFE8D7A8).withOpacity(0.92),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 14),
              const _ProcessingDots(),
              const SizedBox(height: 14),
              Text(
                l10n.t('exercise.recording.keep_screen_open'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.58),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessingDots extends StatefulWidget {
  const _ProcessingDots();

  @override
  State<_ProcessingDots> createState() => _ProcessingDotsState();
}

class _ProcessingDotsState extends State<_ProcessingDots> {
  Timer? _timer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 360), (_) {
      if (!mounted) return;
      setState(() {
        _activeIndex = (_activeIndex + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 11 : 8,
          height: isActive ? 11 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFFECCB84)
                : Colors.white.withOpacity(0.32),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFECCB84).withOpacity(0.42),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
        );
      }),
    );
  }
}

class WorkoutSummarySheet extends StatelessWidget {
  final ExerciseLog log;
  final VoidCallback onSave;

  const WorkoutSummarySheet({
    super.key,
    required this.log,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.t('exercise.summary.title'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          _buildStatRow(
            context.l10n.t('exercise.summary.total_reps'),
            '${log.totalRepetitions}',
          ),
          _buildStatRow(
            context.l10n.t('exercise.summary.avg_accuracy'),
            '${(log.averageAccuracy * 100).toStringAsFixed(1)}%',
          ),
          _buildStatRow(
            context.l10n.t('exercise.summary.best_accuracy'),
            '${(log.maxAccuracy * 100).toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.t('exercise.summary.close')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    onSave();
                  },
                  child: Text(context.l10n.t('exercise.summary.view_details')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

extension AnalysisImageMlKit on AnalysisImage {
  InputImage toInputImage() {
    final inputImage = when<InputImage>(
      nv21: (image) {
        return InputImage.fromBytes(
          bytes: image.bytes,
          metadata: InputImageMetadata(
            size: image.size,
            rotation: _toInputImageRotation(image.rotation),
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      },
      bgra8888: (image) {
        return InputImage.fromBytes(
          bytes: image.bytes,
          metadata: InputImageMetadata(
            size: image.size,
            rotation: _toInputImageRotation(image.rotation),
            format: InputImageFormat.bgra8888,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      },
      yuv420: (image) {
        final allBytes = WriteBuffer();
        for (final plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: image.size,
            rotation: _toInputImageRotation(image.rotation),
            format: InputImageFormat.yuv420,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      },
      jpeg: (_) {
        throw UnsupportedError(
            'JPEG analysis format is not supported for ML Kit');
      },
    );

    if (inputImage == null) {
      throw UnsupportedError('Unsupported analysis image format for ML Kit');
    }

    return inputImage;
  }

  InputImageRotation _toInputImageRotation(
      InputAnalysisImageRotation rotation) {
    switch (rotation) {
      case InputAnalysisImageRotation.rotation0deg:
        return InputImageRotation.rotation0deg;
      case InputAnalysisImageRotation.rotation90deg:
        return InputImageRotation.rotation90deg;
      case InputAnalysisImageRotation.rotation180deg:
        return InputImageRotation.rotation180deg;
      case InputAnalysisImageRotation.rotation270deg:
        return InputImageRotation.rotation270deg;
    }
  }
}
