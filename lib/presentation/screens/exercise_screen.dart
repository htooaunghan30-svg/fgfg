import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import '../widgets/rep_counter.dart';
import '../widgets/accuracy_bar.dart';
import '../providers/exercise_provider.dart';
import '../../core/themes/color_scheme.dart';
import '../../data/models/exercise_log.dart';
import '../../domain/use_cases/validate_form.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../data/services/isar_service.dart';
import '../../features/iconic/iconic_program.dart';
import '../../features/iconic/zodiac_sign.dart';
import '../../features/iconic/world_festival.dart';
import '../../features/iconic/profession_hobby_theme.dart';
import '../../features/premium/workout_overlay_customization.dart';
import '../../features/premium/voice_coach.dart';
import '../../features/premium/workout_video_export_service.dart';
import '../../features/premium/workout_video_overlay_timeline.dart';
import '../../features/premium/license_models.dart';
import '../../features/gamification/badge_manager.dart';
import '../../features/iconic/iconic_program.dart';
import '../../features/iconic/profession_hobby_theme.dart';
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

class PendingWorkoutVideoExport {
  final String rawVideoPath;
  final String exerciseId;
  final WorkoutVideoOverlayTimeline timeline;
  final String overlayTitle;
  final IconicProgram iconicProgram;
  final String? zodiacSignKey;
  final WorldFestivalVisualStyle? worldFestivalTheme;

  const PendingWorkoutVideoExport({
    required this.rawVideoPath,
    required this.exerciseId,
    required this.timeline,
    required this.overlayTitle,
    required this.iconicProgram,
    this.zodiacSignKey,
    this.worldFestivalTheme,
  });
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with WidgetsBindingObserver {

  late PoseDetectionService _poseDetectionService;
  late ExerciseLogicEngine _exerciseLogicEngine;
  StreamSubscription? _detectionSubscription;
  StreamSubscription? _stateSubscription;
  CameraState? _cameraState;
  AnalysisImage? _lastAnalysisImage;
  AnalysisImage? _pendingAnalysisImage;
  String? _lastRecordedPath;
  bool _servicesReady = false;
  final VoiceCoach _voiceCoach = VoiceCoach();
  final WorkoutVideoExportService _videoExportService =
      WorkoutVideoExportService();
  WorkoutVideoOverlayTimeline? _recordingTimeline;
  String? _activeRawRecordingPath;

  static const Duration _accuracyBarAnimationDurationNormal =
      Duration(milliseconds: 220);
  static const Duration _accuracyBarAnimationDurationRecording =
      Duration(milliseconds: 140);
  static const double _analysisMaxFps = 19.0;
  static const int _analysisAndroidWidth = 480;
  static const int _analysisIosWidth = 320;
  static const double _shortVideoAspectRatio = 9 / 16;
  static const int _tiktokVideoBitrate = 16000000;
  // Video recording on standard phones uses the 16:9 ratio natively.
  // In portrait, this creates the standard 9:16 Tiktok-style video (e.g., 1080x1920).
  // Combining this with CameraPreviewFit.cover gives a 1:1 hardware-matched 
  // full screen display without the blurry software zooming that was happening before.
  static const CameraAspectRatios _cameraAspectRatio =
      CameraAspectRatios.ratio_4_3;

  static const String _exerciseGuidePrefsKey =
      'exercise_screen_first_time_guide_shown';

  bool _isProcessing = false;
  bool _showLandmarks = false;
  bool _isRecording = false;
  bool _isRecordActionInProgress = false;
  bool _isCameraSwitchInProgress = false;
  bool _analysisRestartInProgress = false;
  bool _cameraCaptureConfigApplied = false;
  double? _minZoomLevel;
  DateTime? _lastFrameProcessedAt;
  Timer? _analysisThrottleTimer;
  Timer? _recordingAutoStopTimer;
  static const Duration _frameIntervalNormal = Duration(milliseconds: 40);
  static const Duration _frameIntervalRecording = Duration(milliseconds: 46);
  static const Duration _maxAdaptiveInterval = Duration(milliseconds: 120);
  static const Duration _maxAdaptiveIntervalRecording =
      Duration(milliseconds: 84);
  static const Duration _uiDetectionRefreshNormal = Duration(milliseconds: 72);
  static const Duration _uiDetectionRefreshRecording =
      Duration(milliseconds: 56);
  static const Duration _uiStateRefreshNormal = Duration(milliseconds: 72);
  static const Duration _uiStateRefreshRecording = Duration(milliseconds: 56);
  static const double _minAccuracyUiDelta = 0.02;
  static const double _landmarkSmoothingAlpha = 0.22;
  static const double _landmarkSnapDistance = 4.0;
  static const double _landmarkMicroJitterDistance = 12.0;
  static const double _landmarkMicroJitterAlpha = 0.11;
  static const double _landmarkLargeMoveDistance = 24.0;
  static const double _landmarkMaxStepPerFrame = 14.0;
  static const double _landmarkMaxStepPerFrameStationary = 8.0;
  static const double _analysisCostEmaAlpha = 0.25;
  static final WorldFestivalVisualStyle _defaultFestival = professionHobbyThemes.first;
  double? _analysisCostMsEma;
  static const Duration _maxRecordingDuration = Duration(minutes: 5);
  static const Duration _voiceCountCooldown = Duration(milliseconds: 700);
  DateTime? _lastVoiceCountAt;
  bool? _voiceCountPremiumEnabled;
  bool? _voiceCountingEnabled;
  String? _voiceCountingLanguage;
  bool _isSavingRecording = false;
  bool _isCompletingWorkout = false;
  bool _isAutoSavingFromRecordingTimeout = false;
  bool _exerciseAccessAuthorized = false;
  String _recordingStatusTitle = '';
  String _recordingStatusSubtitle = '';
  bool _servicesInitialized = false;

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
  DateTime? _lastDetectionUiUpdateAt;
  DateTime? _lastExerciseStateUiUpdateAt;

  // Pre-rendered overlay images to reduce repaint cost during recording
  ImageProvider? _preRenderedRepCounterImage;
  ImageProvider? _preRenderedAccuracyBarImage;
  bool _isGeneratingPreRendered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ✅ Widget build ပြီးမှ စတင်ပါ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_authorizeAndSetupExerciseSession());
    });
  }

  Future<void> _authorizeAndSetupExerciseSession() async {
    final hasAccess = await context
        .read<UserProvider>()
        .ensureExerciseAccess(widget.exerciseId);
    if (!mounted) return;
    if (!hasAccess) {
      await _showPremiumExerciseRequired();
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() => _exerciseAccessAuthorized = true);
    await _setupExerciseSession();
    await _maybeShowFirstExerciseGuide();
  }

  Future<void> _showPremiumExerciseRequired() async {
    final l10n = context.l10n;
    final shouldUpgrade = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.t('exercise.premium.required_title')),
            content: const Text(
              'Squat is available for free. A valid premium license is required for all other exercises.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.t('exercise.premium.not_now')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.t('exercise.premium.upgrade')),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldUpgrade && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumActivationScreen()),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_syncVoiceCoachSettingsFromProvider());
  }

  Future<void> _syncVoiceCoachSettingsFromProvider({
    bool warmUpIfEnabled = false,
  }) async {
    if (!mounted) return;
    final userProvider = context.read<UserProvider>();
    final premiumEnabled = userProvider.isPremium;
    final voiceEnabled = userProvider.voiceCountingEnabled;
    final voiceLanguage = userProvider.voiceCountingLanguage;
    final shouldWarmUp = warmUpIfEnabled &&
        premiumEnabled &&
        voiceEnabled &&
        (_voiceCountingLanguage != voiceLanguage ||
            _voiceCountingEnabled != voiceEnabled ||
            _voiceCountPremiumEnabled != premiumEnabled);

    _voiceCountPremiumEnabled = premiumEnabled;
    _voiceCountingEnabled = voiceEnabled;
    _voiceCountingLanguage = voiceLanguage;
    _voiceCoach.setPremium(premiumEnabled);
    _voiceCoach.setCountingEnabled(voiceEnabled);
    _voiceCoach.setCountingLanguage(voiceLanguage);

    if (shouldWarmUp) {
      await _voiceCoach.warmUpCounting();
    }
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

  Future<void> _initializeServices() async {
    _poseDetectionService = PoseDetectionService();
    _exerciseLogicEngine = ExerciseLogicEngine(
      validateForm: ValidateFormUseCase(),
      exerciseId: widget.exerciseId,
      exerciseConfig: widget.exerciseConfig,
    );

    try {
      await _voiceCoach.initialize();
      await _syncVoiceCoachSettingsFromProvider(warmUpIfEnabled: true);

      // Initial pose detection model check - using accurate as requested
      await _poseDetectionService.initialize();

      _detectionSubscription =
          _poseDetectionService.resultStream.listen(_handleDetectionResult);
      _stateSubscription =
          _exerciseLogicEngine.stateStream.listen(_handleExerciseStateChange);
      _servicesInitialized = true;

      setState(() {
        _servicesReady = true;
      });
    } catch (_) {
      await _poseDetectionService.dispose();
      await _exerciseLogicEngine.dispose();
      rethrow;
    }
  }

  void _handleDetectionResult(PoseDetectionResult result) {
    if (!mounted) return;

    _publishDetectionUi(result);

    _exerciseLogicEngine.processFrame(
      jointAngles: result.jointAngles,
      formWarnings: result.formWarnings,
      overallAccuracy: result.overallAccuracy,
      isRecordingMode: _isRecording,
    );
  }

  Future<bool> _requireFeatureAccess(
    String featureMessage,
    AppFeature feature,
  ) async {
    final userProvider = context.read<UserProvider>();
    final hasAccess = await userProvider.ensureFeatureAccess(feature);
    if (hasAccess || !mounted) {
      return hasAccess;
    }

    final l10n = context.l10n;
    final shouldUpgrade = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.t('exercise.premium.required_title')),
            content: Text(featureMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.t('exercise.premium.not_now')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.t('exercise.premium.upgrade')),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldUpgrade && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PremiumActivationScreen(),
        ),
      );
    }

    return false;
  }

  void _handleExerciseStateChange(ExerciseState state) {
    if (!mounted) return;

    if (state.repetitions > _exerciseState.repetitions) {
      _voiceCoach.speakCount(state.repetitions);
    }

    if (_isRecording && _recordingTimeline != null) {
      _recordingTimeline!.record(
        repCount: state.repetitions,
        accuracy: state.currentAccuracy,
        phase: _overlayPhaseFromExercisePhase(state.phase),
      );
    }

    _publishExerciseStateUi(state);
  }

  void _publishDetectionUi(PoseDetectionResult result) {
    final now = DateTime.now();
    final refreshInterval =
        _isRecording ? _uiDetectionRefreshRecording : _uiDetectionRefreshNormal;
    final lastUpdatedAt = _lastDetectionUiUpdateAt;
    final accuracyDelta = (_currentAccuracy - result.overallAccuracy).abs();
    final poseDetectionChanged =
        (_lastDetectedPose == null) != (result.pose == null);
    final shouldRefresh = lastUpdatedAt == null ||
        now.difference(lastUpdatedAt) >= refreshInterval ||
        result.formWarnings.length != _activeWarnings.length ||
        accuracyDelta >= _minAccuracyUiDelta ||
        poseDetectionChanged;

    if (!shouldRefresh) {
      return;
    }

    _lastDetectionUiUpdateAt = now;
    setState(() {
      _lastDetectedPose = result.pose;
      _smoothedLandmarkPositions = result.pose == null
          ? const {}
          : _smoothLandmarkPositions(result.pose!);
      _currentAccuracy = result.overallAccuracy;
      _activeWarnings = result.formWarnings;
    });
  }

  Map<PoseLandmarkType, Offset> _smoothLandmarkPositions(Pose pose) {
    final nextPositions = <PoseLandmarkType, Offset>{};

    for (final entry in pose.landmarks.entries) {
      final rawOffset = Offset(entry.value.x, entry.value.y);
      final previousOffset = _smoothedLandmarkPositions[entry.key];

      if (previousOffset == null) {
        nextPositions[entry.key] = rawOffset;
        continue;
      }

      final delta = rawOffset - previousOffset;
      final distance = delta.distance;

      if (distance <= _landmarkSnapDistance) {
        nextPositions[entry.key] = previousOffset;
        continue;
      }

      final alpha =
          distance <= _landmarkMicroJitterDistance
              ? _landmarkMicroJitterAlpha
              : (distance >= _landmarkLargeMoveDistance
                  ? 0.34
                  : _landmarkSmoothingAlpha);
      var nextOffset = Offset(
        previousOffset.dx + (delta.dx * alpha),
        previousOffset.dy + (delta.dy * alpha),
      );

      final step = nextOffset - previousOffset;
      final stepDistance = step.distance;
      final maxStep =
          distance <= _landmarkMicroJitterDistance
              ? _landmarkMaxStepPerFrameStationary
              : _landmarkMaxStepPerFrame;
      if (stepDistance > maxStep && stepDistance > 0.0) {
        final scale = maxStep / stepDistance;
        nextOffset = Offset(
          previousOffset.dx + (step.dx * scale),
          previousOffset.dy + (step.dy * scale),
        );
      }

      nextPositions[entry.key] = nextOffset;
    }

    return nextPositions;
  }

  void _publishExerciseStateUi(ExerciseState state) {
    final now = DateTime.now();
    final refreshInterval =
        _isRecording ? _uiStateRefreshRecording : _uiStateRefreshNormal;
    final lastUpdatedAt = _lastExerciseStateUiUpdateAt;
    final accuracyDelta =
        (_exerciseState.currentAccuracy - state.currentAccuracy).abs();
    final shouldRefresh = lastUpdatedAt == null ||
        now.difference(lastUpdatedAt) >= refreshInterval ||
        state.repetitions != _exerciseState.repetitions ||
        state.phase != _exerciseState.phase ||
        accuracyDelta >= _minAccuracyUiDelta;

    if (!shouldRefresh) {
      return;
    }

    _lastExerciseStateUiUpdateAt = now;
    setState(() {
      _exerciseState = state;
    });
  }

  Future<void> _processAnalysisImage(AnalysisImage image) async {
    if (_isProcessing) {
      // Keep only the latest frame so detection stays close to realtime.
      _pendingAnalysisImage = image;
      return;
    }

    final now = DateTime.now();
    final interval = _currentEffectiveFrameInterval;
    if (_lastFrameProcessedAt != null &&
        now.difference(_lastFrameProcessedAt!) < interval) {
      _pendingAnalysisImage = image;
      _schedulePendingAnalysisDrain(
        interval - now.difference(_lastFrameProcessedAt!),
      );
      return;
    }

    _isProcessing = true;
    _lastFrameProcessedAt = now;
    _lastAnalysisImage = image;
    final processStartedAt = DateTime.now();

    try {
      final inputImage = image.toInputImage();
      await _poseDetectionService.processInputImage(
        inputImage: inputImage,
        exerciseId: widget.exerciseId,
        exerciseConfig: widget.exerciseConfig,
      );
    } catch (e) {
      // Ignore frame-level errors to keep the realtime stream smooth.
    } finally {
      final processCostMs =
          DateTime.now().difference(processStartedAt).inMilliseconds.toDouble();
      _analysisCostMsEma = _analysisCostMsEma == null
          ? processCostMs
          : ((_analysisCostMsEma! * (1.0 - _analysisCostEmaAlpha)) +
              (processCostMs * _analysisCostEmaAlpha));
      _isProcessing = false;
      final pending = _pendingAnalysisImage;
      _pendingAnalysisImage = null;
      if (pending != null) {
        _pendingAnalysisImage = pending;
        _schedulePendingAnalysisDrain(
          _isRecording
              ? const Duration(milliseconds: 1)
              : Duration.zero,
        );
      }
    }
  }

  Duration get _currentEffectiveFrameInterval {
    final base = _isRecording ? _frameIntervalRecording : _frameIntervalNormal;
    final ema = _analysisCostMsEma;
    if (ema == null || ema <= 0) {
      return base;
    }
    final adaptiveMultiplier = _isRecording ? 0.78 : 0.95;
    final adaptiveMs = (ema * adaptiveMultiplier).round();
    final adaptiveDuration = Duration(milliseconds: adaptiveMs);
    if (adaptiveDuration < base) {
      return base;
    }
    final maxAdaptiveInterval =
        _isRecording ? _maxAdaptiveIntervalRecording : _maxAdaptiveInterval;
    if (adaptiveDuration > maxAdaptiveInterval) {
      return maxAdaptiveInterval;
    }
    return adaptiveDuration;
  }

  void _schedulePendingAnalysisDrain(Duration delay) {
    if (_analysisThrottleTimer != null || !mounted) {
      return;
    }
    final safeDelay = delay.isNegative ? Duration.zero : delay;
    _analysisThrottleTimer = Timer(safeDelay, () {
      _analysisThrottleTimer = null;
      final pending = _pendingAnalysisImage;
      if (pending == null || _isProcessing) {
        return;
      }
      _pendingAnalysisImage = null;
      unawaited(_processAnalysisImage(pending));
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecordActionInProgress) return;
    if (!_isRecording &&
        !await _requireFeatureAccess(
          context.l10n.t('exercise.premium.recording'),
          AppFeature.luxuryOverlayStudio,
        )) {
      return;
    }
    setState(() => _isRecordActionInProgress = true);

    try {
      if (_isRecording) {
        await _stopRecording();
      } else {
        await _startRecording();
      }
    } finally {
      if (mounted) {
        setState(() => _isRecordActionInProgress = false);
      }
    }
  }

  Future<void> _startRecording() async {
    final currentState = _cameraState;
    if (currentState == null) {
      return;
    }

    _analysisThrottleTimer?.cancel();
    _analysisThrottleTimer = null;
    _lastFrameProcessedAt = null;
    _lastDetectionUiUpdateAt = null;
    _lastExerciseStateUiUpdateAt = null;

    _recordingTimeline = WorkoutVideoOverlayTimeline.start();
    _recordingTimeline!.record(
      repCount: _exerciseState.repetitions,
      accuracy: _exerciseState.currentAccuracy,
      phase: _overlayPhaseFromExercisePhase(_exerciseState.phase),
    );

    bool started = false;
    final action = currentState.when(
      onVideoMode: (videoState) async {
        final request = await videoState.startRecording();
        _activeRawRecordingPath = request.path;
        started = true;
      },
      onVideoRecordingMode: (_) {
        started = true;
      },
    );
    if (action is Future) {
      await action;
    }

    if (started) {
      if (mounted) {
        setState(() => _isRecording = true);
        _scheduleRecordingAutoStop();
        // Generate pre-rendered static overlays once per recording session.
        unawaited(_generatePreRenderedOverlays());
      }
    } else {
      _recordingAutoStopTimer?.cancel();
      _pendingAnalysisImage = null;
      _lastFrameProcessedAt = null;
    }
  }

  void _scheduleRecordingAutoStop() {
    _recordingAutoStopTimer?.cancel();
    _recordingAutoStopTimer = Timer(_maxRecordingDuration, () {
      unawaited(_handleRecordingAutoStop());
    });
  }

  Future<void> _handleRecordingAutoStop() async {
    if (!mounted ||
        !_isRecording ||
        _isRecordActionInProgress ||
        _isSavingRecording ||
        _isCompletingWorkout ||
        _isAutoSavingFromRecordingTimeout) {
      return;
    }

    _isAutoSavingFromRecordingTimeout = true;
    try {
      await _stopRecording(autoFinalizeWorkout: true);
    } finally {
      _isAutoSavingFromRecordingTimeout = false;
    }
  }

  Future<void> _switchCameraSensor() async {
    if (_isCameraSwitchInProgress) return;
    final currentState = _cameraState;
    if (currentState == null) return;

    setState(() => _isCameraSwitchInProgress = true);
    try {
      _cameraCaptureConfigApplied = false;
      final minZoom = 0.0;
      _minZoomLevel = minZoom;
      await currentState.switchCameraSensor(
        aspectRatio: _cameraAspectRatio,
        zoom: minZoom,
      );
      // Reset transient frame caches so the new camera starts with fresh pose
      // frames and avoids one-frame stale overlay from the previous sensor.
      _pendingAnalysisImage = null;
      _lastAnalysisImage = null;
      _lastDetectedPose = null;
      _smoothedLandmarkPositions = const {};
      _lastFrameProcessedAt = null;
    } catch (_) {
      // Keep the workout flow stable if a specific device rejects camera swap.
    } finally {
      if (mounted) {
        setState(() => _isCameraSwitchInProgress = false);
      }
    }
  }

  Future<void> _ensureNormalCameraCaptureConfig(CameraState cameraState) async {
    if (_cameraCaptureConfigApplied || cameraState is PreparingCameraState) {
      return;
    }

    _cameraCaptureConfigApplied = true;
    try {
      final minZoom = 0.0;
      _minZoomLevel = minZoom;
      await cameraState.sensorConfig.setAspectRatio(_cameraAspectRatio);
      await cameraState.sensorConfig.setZoom(minZoom);
      // Let camera handle brightness automatically (don't set manual brightness)
      unawaited(CamerawesomePlugin.startAutoFocus());
    } catch (_) {
      _cameraCaptureConfigApplied = false;
    }
  }

  /// Render the static parts of the HUD to images once at recording start.
  /// Inserts an offstage OverlayEntry, captures RepaintBoundaries to PNG bytes
  /// and stores MemoryImage providers for lightweight runtime compositing.
  Future<void> _generatePreRenderedOverlays() async {
    if (_isGeneratingPreRendered) return;
    if (!mounted) return;
    _isGeneratingPreRendered = true;

    try {
      if (_preRenderedRepCounterImage != null && _preRenderedAccuracyBarImage != null) {
        return;
      }

      final overlayState = Overlay.of(context);
      if (overlayState == null) return;

      final repKey = GlobalKey();
      final accKey = GlobalKey();

      final userProvider = context.read<UserProvider>();
      final now = DateTime.now();
      final dateFestivalVisual = worldFestivalForDate(now);
      final selectedProfessionVisual = professionThemeByKey(userProvider.professionThemeKey);
      final isProfessionProgram = userProvider.iconicProgram == IconicProgram.professionHobby;
      final isFestivalProgram = userProvider.iconicProgram == IconicProgram.worldFestival;
      final WorldFestivalVisualStyle? liveFestivalVisual = isProfessionProgram ? selectedProfessionVisual : isFestivalProgram ? dateFestivalVisual : null;
      final hudFestival = liveFestivalVisual ?? _defaultFestival;
      final hudDesign = _FestivalHudDesign.resolve(hudFestival);
      final hudPhaseColor = _phaseAccentForFestival(hudFestival, _exerciseState.phase);

      final repSize = 108.0;
      final accWidth = (MediaQuery.of(context).size.width - 40).clamp(0.0, double.infinity);
      final accHeight = 28.0;

      final entry = OverlayEntry(
        builder: (ctx) => Offstage(
          offstage: true,
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                Center(
                  child: RepaintBoundary(
                    key: repKey,
                    child: SizedBox(
                      width: repSize,
                      height: repSize,
                      child: Center(
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipPath(
                                  clipper: _FestivalCounterClipper(hudDesign.counterFamily),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.lerp(hudFestival.primaryStart, Colors.black, 0.08)!
                                              .withOpacity(0.98),
                                          Color.lerp(hudFestival.primaryEnd, Colors.black, 0.24)!
                                              .withOpacity(0.98),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: hudDesign.edgeColor.withOpacity(0.92),
                                        width: 1.7,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: hudFestival.glowColor.withOpacity(0.26),
                                          blurRadius: 13,
                                          spreadRadius: 0.6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: hudDesign.innerEdgeColor.withOpacity(0.36),
                                        width: 1.0,
                                      ),
                                      gradient: RadialGradient(
                                        center: const Alignment(-0.16, -0.36),
                                        radius: 0.94,
                                        colors: [
                                          Colors.white.withOpacity(0.14),
                                          Color.lerp(hudFestival.primaryStart, Colors.black, 0.50)!
                                              .withOpacity(0.94),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                top: 8,
                                child: _FestivalCounterGem(
                                  color: hudDesign.edgeColor.withOpacity(0.80),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: _FestivalCounterGem(
                                  color: hudPhaseColor.withOpacity(0.86),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: RepaintBoundary(
                    key: accKey,
                    child: SizedBox(
                      width: accWidth,
                      height: accHeight,
                      child: Container(
                        height: accHeight,
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color.lerp(hudFestival.primaryStart, Colors.black, 0.22)!
                                  .withOpacity(0.95),
                              Color.lerp(hudFestival.primaryEnd, Colors.black, 0.18)!
                                  .withOpacity(0.96),
                            ],
                          ),
                          border: Border.all(
                            color: hudDesign.edgeColor.withOpacity(0.88),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: hudFestival.glowColor.withOpacity(0.18),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.black.withOpacity(0.20),
                                border: Border.all(
                                  color: hudDesign.innerEdgeColor.withOpacity(0.20),
                                  width: 0.8,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Row(
                                  children: List.generate(7, (index) {
                                    final opacity = 0.03 + ((index % 2) * 0.03);
                                    return Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 1.2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(999),
                                          color: Colors.white.withOpacity(opacity),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            Positioned(
                              left: accWidth * 0.80,
                              top: 3,
                              bottom: 3,
                              child: Container(
                                width: 2.2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: hudFestival.thresholdLineColor.withOpacity(0.72),
                                  boxShadow: [
                                    BoxShadow(
                                      color: hudFestival.glowColor.withOpacity(0.22),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: 0.16,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: LinearGradient(
                                        colors: hudFestival.accuracyBarGradient
                                            .map((c) => c.withOpacity(0.44))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      overlayState.insert(entry);

      // Wait a frame for layout/painting to complete
      await Future.delayed(const Duration(milliseconds: 80));

      // Capture rep counter image
      try {
        final repBoundary = repKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (repBoundary != null) {
          final ui.Image img = await repBoundary.toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio);
          final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List();
          if (bytes != null && mounted) {
            setState(() {
              _preRenderedRepCounterImage = MemoryImage(bytes);
            });
          }
        }
      } catch (_) {
        // ignore capture errors
      }

      // Capture accuracy bar image
      try {
        final accBoundary = accKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (accBoundary != null) {
          final ui.Image img = await accBoundary.toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio);
          final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List();
          if (bytes != null && mounted) {
            setState(() {
              _preRenderedAccuracyBarImage = MemoryImage(bytes);
            });
          }
        }
      } catch (_) {
        // ignore capture errors
      }

      entry.remove();
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPreRendered = false;
        });
      } else {
        _isGeneratingPreRendered = false;
      }
    }
  }

  Size _cameraFrameSize(Size availableSize) {
    if (availableSize.isEmpty) {
      return Size.zero;
    }

    final width = availableSize.width;
    final targetHeight = width / _shortVideoAspectRatio;
    final height = min(availableSize.height, targetHeight);
    return Size(width, height);
  }

  Future<void> _stopRecording({bool autoFinalizeWorkout = false}) async {
    _recordingAutoStopTimer?.cancel();
    String? rawPath = _activeRawRecordingPath;
    final currentState = _cameraState;
    final action = currentState?.when(
      onVideoRecordingMode: (recordingState) async {
        await recordingState.stopRecording(
          onVideo: (request) {
            rawPath = request.path ?? rawPath;
          },
        );
      },
    );
    if (action is Future) {
      await action;
    }
    _analysisThrottleTimer?.cancel();
    _analysisThrottleTimer = null;
    _lastFrameProcessedAt = null;

    final String? finalRawPath = rawPath ?? _activeRawRecordingPath ?? _lastRecordedPath;
    _activeRawRecordingPath = finalRawPath;
    if (mounted) {
      setState(() => _isRecording = false);
    }
    _lastDetectionUiUpdateAt = null;
    _lastExerciseStateUiUpdateAt = null;

    final timeline = _recordingTimeline;
    final readyForExport =
        finalRawPath != null && finalRawPath.isNotEmpty && timeline != null;
    if (readyForExport && mounted) {
      if (autoFinalizeWorkout) {
        _activeRawRecordingPath = finalRawPath;
        _recordingTimeline = timeline;
        final userProvider = context.read<UserProvider>();
        await _exportRecordingWithSelectedEffects(userProvider);
        await _completeWorkoutAfterRecordingSaved();
        return;
      }

      final userProvider = context.read<UserProvider>();
      final now = DateTime.now();
      final zodiac = zodiacVisualStyleForDate(now);
      final dateFestivalVisual = worldFestivalForDate(now);
      final selectedProfessionVisual =
          professionThemeByKey(userProvider.professionThemeKey);
      final isProfessionProgram =
          userProvider.iconicProgram == IconicProgram.professionHobby;
      final isFestivalProgram =
          userProvider.iconicProgram == IconicProgram.worldFestival;
      final isZodiacProgram =
          userProvider.iconicProgram == IconicProgram.zodiac;
      final WorldFestivalVisualStyle? exportFestivalTheme = isProfessionProgram
          ? selectedProfessionVisual
          : isFestivalProgram
              ? dateFestivalVisual
              : null;
      final String? exportZodiacKey = isZodiacProgram ? zodiac.storageKey : null;
      final exerciseTitle =
          (widget.exerciseConfig['name'] as String?)?.trim().isNotEmpty == true
              ? widget.exerciseConfig['name'] as String
              : widget.exerciseId.replaceAll('_', ' ').toUpperCase();
      final exportOverlayTitle =
          isProfessionProgram ? selectedProfessionVisual.label : exerciseTitle;

      _activeRawRecordingPath = null;
      _recordingTimeline = null;

      Navigator.of(context).pop(
        PendingWorkoutVideoExport(
          rawVideoPath: finalRawPath,
          exerciseId: widget.exerciseId,
          timeline: timeline,
          overlayTitle: exportOverlayTitle,
          iconicProgram: userProvider.iconicProgram,
          zodiacSignKey: exportZodiacKey,
          worldFestivalTheme: exportFestivalTheme,
        ),
      );
      return;
    }

    await _completeWorkout();
  }

  OverlayMovementPhase _overlayPhaseFromExercisePhase(String phase) {
    switch (phase) {
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

  Future<void> _exportRecordingWithSelectedEffects(UserProvider userProvider) async {
    final rawPath = _activeRawRecordingPath;
    final timeline = _recordingTimeline;
    if (rawPath == null || rawPath.isEmpty || timeline == null) {
      _recordingTimeline = null;
      return;
    }

    final now = DateTime.now();
    final zodiac = zodiacVisualStyleForDate(now);
    final dateFestivalVisual = worldFestivalForDate(now);
    final selectedProfessionVisual =
        professionThemeByKey(userProvider.professionThemeKey);
    final isProfessionProgram =
        userProvider.iconicProgram == IconicProgram.professionHobby;
    final isFestivalProgram =
        userProvider.iconicProgram == IconicProgram.worldFestival;
    final isLuxuryStudioProgram =
        userProvider.iconicProgram == IconicProgram.luxuryStudio;
    final isZodiacProgram =
        userProvider.iconicProgram == IconicProgram.zodiac;
    final WorldFestivalVisualStyle? exportFestivalTheme = isProfessionProgram
        ? selectedProfessionVisual
        : isFestivalProgram
            ? dateFestivalVisual
            : null;
    final String? exportZodiacKey = isZodiacProgram ? zodiac.storageKey : null;
    final exerciseTitle =
        (widget.exerciseConfig['name'] as String?)?.trim().isNotEmpty == true
            ? widget.exerciseConfig['name'] as String
            : widget.exerciseId.replaceAll('_', ' ').toUpperCase();
    final exportOverlayTitle =
        isProfessionProgram ? selectedProfessionVisual.label : exerciseTitle;

    if (mounted) {
      setState(() {
        _isSavingRecording = true;
        _recordingStatusTitle =
            context.l10n.t('exercise.recording.exporting_video');
        _recordingStatusSubtitle =
            context.l10n.t('exercise.recording.applying_overlay_effects');
      });
    }

    try {
      final exportResult = await _videoExportService.exportVideoWithOverlay(
        rawVideoPath: rawPath,
        exerciseId: widget.exerciseId,
        timeline: timeline,
        customization: userProvider.workoutOverlayCustomization,
        iconicProgram: userProvider.iconicProgram,
        zodiacSignKey: exportZodiacKey,
        worldFestivalTheme: exportFestivalTheme,
        overlayTitle: exportOverlayTitle,
      );

      _lastRecordedPath = exportResult.videoPath;
      if (mounted && exportResult.usedRawFallback) {
        final fallbackReason = exportResult.exportError?.trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              fallbackReason == null || fallbackReason.isEmpty
                  ? context.l10n.t('exercise.recording.saved_raw_fallback')
                  : context.l10n.t(
                      'exercise.recording.saved_without_overlay',
                      params: {'error': fallbackReason},
                    ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.t(
                'exercise.recording.failed_video',
                params: {'error': '$e'},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _activeRawRecordingPath = null;
      _recordingTimeline = null;
      if (mounted) {
        setState(() {
          _isSavingRecording = false;
          _recordingStatusTitle = '';
          _recordingStatusSubtitle = '';
        });
      }
    }
  }

  void _handleMediaCaptureEvent(MediaCapture capture) {
    if (!capture.isVideo) {
      return;
    }

    final path = capture.captureRequest.path;
    if (path == null || path.isEmpty) {
      return;
    }

    if (capture.status == MediaCaptureStatus.capturing) {
      _activeRawRecordingPath = path;
      return;
    }

    if (capture.status == MediaCaptureStatus.success) {
      _lastRecordedPath = path;
      _activeRawRecordingPath = path;
    }
  }

  Future<void> _completeWorkout() async {
    if (!mounted || !_servicesReady || _isCompletingWorkout) {
      return;
    }

    if (_isSavingRecording || _isRecordActionInProgress) {
      return;
    }

    if (_isRecording) {
      await _stopRecording();
      return;
    }

    await _completeWorkoutAfterRecordingSaved();
  }

  Future<void> _completeWorkoutAfterRecordingSaved() async {
    if (!mounted || !_servicesReady || _isCompletingWorkout) {
      return;
    }

    setState(() {
      _isCompletingWorkout = true;
    });

    try {
      final log = await _exerciseLogicEngine.completeSession();
      await IsarService.saveExerciseLog(log);
      await BadgeManager().checkAndUpdateBadges(log);

      if (!mounted) {
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return WorkoutSummarySheet(
            log: log,
            onSave: () {
              Navigator.of(sheetContext).pop();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showErrorDialog(
        context.l10n.t('exercise.error.setup_title'),
        context.l10n.t(
          'exercise.error.setup_message',
          params: {'error': '$e'},
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompletingWorkout = false;
        });
      }
    }
  }

  Future<void> _toggleLandmarks() async {
    if (!_showLandmarks &&
        !await _requireFeatureAccess(
          context.l10n.t('exercise.premium.landmarks'),
          AppFeature.professionHobby,
        )) {
      return;
    }

    setState(() {
      _showLandmarks = !_showLandmarks;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _analysisThrottleTimer?.cancel();
    _recordingAutoStopTimer?.cancel();
    _detectionSubscription?.cancel();
    _stateSubscription?.cancel();
    if (_servicesInitialized) {
      unawaited(_poseDetectionService.dispose());
      unawaited(_exerciseLogicEngine.dispose());
    }
    unawaited(_voiceCoach.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_exerciseAccessAuthorized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final userProvider = Provider.of<UserProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    final safePadding = mediaQuery.padding;
    const double controlsDockBaseHeight = 116;
    final double controlsDockHeight = controlsDockBaseHeight + safePadding.bottom;
    
    final selectedTheme = userProvider.selectedTheme;
    final angleTextColor = selectedTheme == 'gold'
        ? AppColorScheme.goldMid
        : selectedTheme == 'pink'
            ? AppColorScheme.pinkMid
            : Colors.white;

    final now = DateTime.now();
    final dateFestivalVisual = worldFestivalForDate(now);
    final selectedProfessionVisual =
        professionThemeByKey(userProvider.professionThemeKey);
    final isProfessionProgram =
        userProvider.iconicProgram == IconicProgram.professionHobby;
    final isFestivalProgram =
        userProvider.iconicProgram == IconicProgram.worldFestival;
    final isLuxuryStudioProgram =
        userProvider.iconicProgram == IconicProgram.luxuryStudio;
    final liveFestivalVisual = isProfessionProgram ? selectedProfessionVisual : isFestivalProgram ? dateFestivalVisual : null;
    // Keep world_festival title ribbon as export-only art direction.
    // Live camera HUD should not render the world_festival title bar.
    final WorldFestivalVisualStyle? hudVisual =
        isProfessionProgram ? selectedProfessionVisual : null;
    final String? hudThemeKey =
        isProfessionProgram ? userProvider.professionThemeKey : null;
    final precisionState = _currentAccuracy >= 0.82
        ? 'OPTIMAL'
        : _currentAccuracy >= 0.68
            ? 'STABLE'
            : 'CALIBRATING';
    
    final bool showLandmarksSetting = _showLandmarks || userProvider.showLandmarks;
    final isRecording = _isRecording;
    const double repCounterRightOffset = 20;
    const double repCounterSize = 100;
    final double luxuryRepCounterWidgetSize = isLuxuryStudioProgram ? 122 : 108;
    final double luxuryAccuracyBarWidth = isLuxuryStudioProgram
        ? min(mediaQuery.size.width - 72, 312).toDouble()
        : (mediaQuery.size.width - 40).toDouble();

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
          
          // ၁. Camera Preview ရဲ့ Aspect Ratio ကို အတိအကျယူပါ
          // We use ratio_16_9 for the camera sensor, which is 9:16 in portrait mode.
          const double cameraRatio = 2 / 3;
          
          return Stack(
            children: [
              // --- Base Camera Layer ---
              Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: CameraAwesomeBuilder.custom(
                    sensorConfig: SensorConfig.single(
                      sensor: Sensor.position(SensorPosition.back),
                      aspectRatio: _cameraAspectRatio,
                      zoom: _minZoomLevel ?? 0.0,
                    ),
                    imageAnalysisConfig: AnalysisConfig(
                      autoStart: true,
                      maxFramesPerSecond: _analysisMaxFps,
                      androidOptions: const AndroidAnalysisOptions.nv21(
                        width: _analysisAndroidWidth,
                      ),
                      cupertinoOptions: const CupertinoAnalysisOptions.bgra8888(
                        width: _analysisIosWidth,
                      ),
                    ),
                    // fitWidth prevents double scaling - ၁:၁ pixel mapping without crop
                    previewFit: CameraPreviewFit.cover,
                    previewAlignment: Alignment.center,
                    previewPadding: EdgeInsets.zero,
                    saveConfig: SaveConfig.video(
                      videoOptions: VideoOptions(
                        enableAudio: true,
                        quality: VideoRecordingQuality.fhd,
                        android: AndroidVideoOptions(
                          bitrate: _tiktokVideoBitrate,
                          fallbackStrategy: QualityFallbackStrategy.higher,
                        ),
                        ios: CupertinoVideoOptions(
                          fileType: CupertinoFileType.mpeg4,
                          codec: CupertinoCodecType.h264,
                          fps: 30,
                        ),
                      ),
                    ),
                    onMediaCaptureEvent: _handleMediaCaptureEvent,
                    onImageForAnalysis: _processAnalysisImage,
                        builder: (cameraState, preview) {
                           // Update state outside of the build phase gently
                           if (_cameraState?.runtimeType != cameraState.runtimeType) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() => _cameraState = cameraState);
                                }
                              });
                           } else {
                              _cameraState = cameraState;
                           }
                           unawaited(_ensureNormalCameraCaptureConfig(cameraState));
                           
                           final isFrontCamera = cameraState.sensorConfig.sensors.isNotEmpty &&
                                 cameraState.sensorConfig.sensors.first.position == SensorPosition.front;
                           
                           // The PosePainter MUST be built inside the camera's scaled scope
                           // so that pose detections geometrically match the camera image exactly.
                           return Stack(
                             fit: StackFit.expand,
                             children: [
                               if (_lastDetectedPose != null && _lastAnalysisImage != null)
                                 Positioned.fromRect(
                                   rect: preview.rect,
                                   child: RepaintBoundary(
                                     child: CustomPaint(
                                        painter: PosePainter(
                                          pose: _lastDetectedPose!,
                                          accuracy: _currentAccuracy,
                                          landmarkOverrides: _smoothedLandmarkPositions,
                                          showLandmarks: showLandmarksSetting,
                                          showConnections: showLandmarksSetting,
                                          showAngles: !showLandmarksSetting,
                                          angleTextColor: angleTextColor,
                                          preview: preview,
                                          analysisImage: _lastAnalysisImage!,
                                          isFrontCamera: isFrontCamera,
                                          festivalStyle: _isRecording ? liveFestivalVisual : null,
                                        ),
                                     ),
                                   ),
                                 ),
],
                             );
                          },
),
                      ),
                    ),
                  ),

               // --- UI Overlays (Unscaled) ---
              if (_cameraState is PreparingCameraState)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: controlsDockHeight,
                child: SafeArea(
                  bottom: false,
                  child: CameraOverlay(
                    accuracy: _currentAccuracy,
                    repCount: _exerciseState.repetitions,
                    phase: _exerciseState.phase,
                    warnings: _activeWarnings,
                    holdDuration: _exerciseState.holdDuration,
                    onToggleLandmarks: () {
                      unawaited(_toggleLandmarks());
                    },
                    onToggleRecording: () {
                      unawaited(_toggleRecording());
                    },
                    onCompleteWorkout: _completeWorkout,
                    showLandmarks: showLandmarksSetting,
                    isRecording: isRecording,
                    showBottomControls: false,
                  ),
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
                top: 12 + safePadding.top,
                left: 20,
                right: 20,
                child: IgnorePointer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 36),
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: luxuryAccuracyBarWidth,
                          child: _buildSimpleAccuracyBar(
                            _currentAccuracy,
                            visualStyle: hudVisual,
                            themeKey: hudThemeKey,
                            precisionState: precisionState,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 8 + safePadding.top,
                right: 14,
                child: SafeArea(
                  child: IgnorePointer(
                    ignoring: _isCameraSwitchInProgress,
                    child: GestureDetector(
                      onTap: _switchCameraSensor,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0B0D).withOpacity(0.90),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _isCameraSwitchInProgress
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.88),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.flip_camera_ios_rounded,
                                color: Colors.white.withOpacity(0.90),
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 94 + safePadding.top,
                right: repCounterRightOffset,
                child: IgnorePointer(
                  child: _buildSimpleRepCounter(
                    _exerciseState.repetitions,
                    visualStyle: hudVisual,
                    themeKey: hudThemeKey,
                    size: luxuryRepCounterWidgetSize,
                  ),
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

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: controlsDockHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.98),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.10),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.36),
                        blurRadius: 22,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: CameraOverlay(
                      accuracy: _currentAccuracy,
                      repCount: _exerciseState.repetitions,
                      phase: _exerciseState.phase,
                      warnings: _activeWarnings,
                      holdDuration: _exerciseState.holdDuration,
                      onToggleLandmarks: () {
                        unawaited(_toggleLandmarks());
                      },
                      onToggleRecording: () {
                        unawaited(_toggleRecording());
                      },
                      onCompleteWorkout: _completeWorkout,
                      showLandmarks: showLandmarksSetting,
                      isRecording: isRecording,
                      showTopHud: false,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSimpleRepCounter(
    int count, {
    required WorldFestivalVisualStyle? visualStyle,
    required String? themeKey,
    required double size,
  }) {
    final _ = (visualStyle, themeKey);
    return RepaintBoundary(
      child: RepCounter(
        count: count,
        phase: _exerciseState.phase,
        size: size,
        badgeLevel: RepCounterBadgeLevel.none,
        usePreRenderedBackground:
            _isRecording && _preRenderedRepCounterImage != null,
        preRenderedBackground:
            _isRecording ? _preRenderedRepCounterImage : null,
      ),
    );
  }

  Widget _buildSimpleAccuracyBar(
    double accuracy, {
    required WorldFestivalVisualStyle? visualStyle,
    required String? themeKey,
    required String precisionState,
  }) {
    final _ = (visualStyle, themeKey, precisionState);
    return RepaintBoundary(
      child: AccuracyBar(
        accuracy: accuracy.clamp(0.0, 1.0).toDouble(),
        animate: true,
        simplified: true,
        usePreRenderedBackground:
            _isRecording && _preRenderedAccuracyBarImage != null,
        preRenderedBackground:
            _isRecording ? _preRenderedAccuracyBarImage : null,
      ),
    );
  }

  Widget _buildFestivalTitleRibbon({
    required WorldFestivalVisualStyle festival,
    required _FestivalHudDesign design,
    required String precisionState,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: _FestivalRibbonClipper(design.bannerFamily),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    festival.primaryStart.withOpacity(0.85),
                    festival.primaryEnd.withOpacity(0.90),
                  ],
                ),
                border: Border.all(
                  color: design.edgeColor.withOpacity(0.40),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          festival.accent1,
                          festival.accent2,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: festival.glowColor.withOpacity(0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      festival.bannerIcon,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          festival.label.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.98),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            shadows: [
                              Shadow(
                                color: festival.glowColor.withOpacity(0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          festival.themeName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: festival.accent1.withOpacity(0.95),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withOpacity(0.12),
                      border: Border.all(
                        color: design.innerEdgeColor.withOpacity(0.50),
                      ),
                    ),
                    child: Text(
                      precisionState,
                      style: TextStyle(
                        color: festival.accent2,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _phaseAccentForFestival(WorldFestivalVisualStyle festival, String phase) {
    switch (phase.toLowerCase()) {
      case 'down':
        return festival.phaseDownColor;
      case 'hold':
        return festival.phaseHoldColor;
      case 'up':
      default:
        return festival.phaseUpColor;
    }
  }

  Widget _buildRecordingWatermark() {
    return const SizedBox.shrink();
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

enum _FestivalShapeFamily {
  crown,
  crystal,
  ribbon,
  lotus,
  wave,
  marquee,
  comet,
  temple,
}

class _FestivalHudDesign {
  final _FestivalShapeFamily bannerFamily;
  final _FestivalShapeFamily counterFamily;
  final Color edgeColor;
  final Color innerEdgeColor;

  const _FestivalHudDesign({
    required this.bannerFamily,
    required this.counterFamily,
    required this.edgeColor,
    required this.innerEdgeColor,
  });

  static _FestivalHudDesign resolve(WorldFestivalVisualStyle festival) {
    final key = festival.storageKey.toLowerCase();
    final bannerFamily = _resolveBannerFamily(key);
    final counterFamily = _resolveCounterFamily(key);
    return _FestivalHudDesign(
      bannerFamily: bannerFamily,
      counterFamily: counterFamily,
      edgeColor: Color.lerp(festival.accent1, Colors.white, 0.18)!,
      innerEdgeColor: Color.lerp(festival.accent2, Colors.white, 0.24)!,
    );
  }

  static _FestivalShapeFamily _resolveBannerFamily(String key) {
    if (key == 'profession_electrical_engineer') {
      return _FestivalShapeFamily.comet;
    }
    if (key == 'profession_mechanical_engineer') {
      return _FestivalShapeFamily.ribbon;
    }
    if (key == 'profession_civil_engineer') {
      return _FestivalShapeFamily.temple;
    }
    if (key == 'profession_doctor') {
      return _FestivalShapeFamily.crystal;
    }
    if (key == 'profession_nurse') {
      return _FestivalShapeFamily.wave;
    }
    if (key == 'profession_pharmacist') {
      return _FestivalShapeFamily.marquee;
    }
    if (key == 'profession_software_developer') {
      return _FestivalShapeFamily.comet;
    }
    if (key == 'profession_data_scientist') {
      return _FestivalShapeFamily.crown;
    }
    if (key == 'profession_human_resource') {
      return _FestivalShapeFamily.ribbon;
    }
    if (key == 'profession_marketing_specialist') {
      return _FestivalShapeFamily.comet;
    }
    if (key == 'profession_fashion_designer') {
      return _FestivalShapeFamily.wave;
    }
    if (key == 'profession_beautician') {
      return _FestivalShapeFamily.lotus;
    }
    if (key == 'profession_musician') {
      return _FestivalShapeFamily.wave;
    }
    if (key == 'profession_writer') {
      return _FestivalShapeFamily.marquee;
    }
    if (key == 'profession_game_streamer') {
      return _FestivalShapeFamily.comet;
    }
    if (key == 'profession_social_media_influencer') {
      return _FestivalShapeFamily.lotus;
    }
    if (key == 'profession_manager') {
      return _FestivalShapeFamily.ribbon;
    }
    if (key == 'profession_director') {
      return _FestivalShapeFamily.marquee;
    }
    if (key == 'profession_cgd') {
      return _FestivalShapeFamily.comet;
    }
    if (key == 'profession_it_engineer') {
      return _FestivalShapeFamily.crystal;
    }
    if (_containsAny(key, const ['snow', 'ice', 'winter', 'harbin', 'sapporo'])) {
      return _FestivalShapeFamily.crystal;
    }
    if (_containsAny(key, const ['carnival', 'holi', 'dance', 'tomatina', 'day_of_the_dead'])) {
      return _FestivalShapeFamily.lotus;
    }
    if (_containsAny(key, const ['marathon', 'running', 'crossfit', 'tour', 'boat'])) {
      return _FestivalShapeFamily.ribbon;
    }
    if (_containsAny(key, const ['film', 'oscars', 'cannes', 'fringe', 'comic', 'sundance'])) {
      return _FestivalShapeFamily.marquee;
    }
    if (_containsAny(key, const ['fashion', 'gala', 'nyfw', 'lfw', 'mfw', 'pfw'])) {
      return _FestivalShapeFamily.crown;
    }
    if (_containsAny(key, const ['earth', 'environment', 'yoga', 'happiness', 'hanami', 'lantern'])) {
      return _FestivalShapeFamily.wave;
    }
    if (_containsAny(key, const ['gp', 'daytona', 'wimbledon', 'open', 'super_bowl'])) {
      return _FestivalShapeFamily.comet;
    }
    if (_containsAny(key, const ['eid', 'easter', 'diwali', 'hanukkah', 'christmas', 'purim', 'vaisakhi'])) {
      return _FestivalShapeFamily.temple;
    }
    return _fallbackFamily(key, const [
      _FestivalShapeFamily.crown,
      _FestivalShapeFamily.crystal,
      _FestivalShapeFamily.ribbon,
      _FestivalShapeFamily.lotus,
      _FestivalShapeFamily.wave,
      _FestivalShapeFamily.marquee,
      _FestivalShapeFamily.comet,
      _FestivalShapeFamily.temple,
    ]);
  }

  static _FestivalShapeFamily _resolveCounterFamily(String key) {
    if (key == 'profession_electrical_engineer') {
      return _FestivalShapeFamily.crown;
    }
    if (key == 'profession_mechanical_engineer') {
      return _FestivalShapeFamily.ribbon;
    }
    if (key == 'profession_civil_engineer') {
      return _FestivalShapeFamily.temple;
    }
    if (key == 'profession_doctor') {
      return _FestivalShapeFamily.crown;
    }
    if (key == 'profession_nurse') {
      return _FestivalShapeFamily.lotus;
    }
    if (key == 'profession_pharmacist') {
      return _FestivalShapeFamily.crystal;
    }
    if (key == 'profession_software_developer') {
      return _FestivalShapeFamily.marquee;
    }
    if (key == 'profession_data_scientist') {
      return _FestivalShapeFamily.comet;
    }
    if (key == 'profession_human_resource') {
      return _FestivalShapeFamily.ribbon;
    }
    if (key == 'profession_marketing_specialist') {
      return _FestivalShapeFamily.crown;
    }
    if (key == 'profession_fashion_designer') {
      return _FestivalShapeFamily.lotus;
    }
    if (key == 'profession_beautician') {
      return _FestivalShapeFamily.wave;
    }
    if (key == 'profession_musician') {
      return _FestivalShapeFamily.crown;
    }
    if (key == 'profession_writer') {
      return _FestivalShapeFamily.crystal;
    }
    if (key == 'profession_game_streamer') {
      return _FestivalShapeFamily.ribbon;
    }
    if (key == 'profession_social_media_influencer') {
      return _FestivalShapeFamily.lotus;
    }
    if (key == 'profession_manager') {
      return _FestivalShapeFamily.crown;
    }
    if (key == 'profession_director') {
      return _FestivalShapeFamily.crown;
    }
    if (key == 'profession_cgd') {
      return _FestivalShapeFamily.marquee;
    }
    if (key == 'profession_it_engineer') {
      return _FestivalShapeFamily.comet;
    }
    if (_containsAny(key, const ['new_year', 'eve', 'met_gala', 'eurovision', 'coachella'])) {
      return _FestivalShapeFamily.crown;
    }
    if (_containsAny(key, const ['snow', 'ice', 'lantern', 'white_nights'])) {
      return _FestivalShapeFamily.crystal;
    }
    if (_containsAny(key, const ['marathon', 'running', 'boat', 'tour'])) {
      return _FestivalShapeFamily.ribbon;
    }
    if (_containsAny(key, const ['carnival', 'holi', 'hanami', 'dance', 'tomatina'])) {
      return _FestivalShapeFamily.lotus;
    }
    if (_containsAny(key, const ['earth', 'environment', 'yoga', 'happiness', 'sxsw', 'vivid'])) {
      return _FestivalShapeFamily.wave;
    }
    if (_containsAny(key, const ['film', 'oscars', 'cannes', 'fringe', 'comic'])) {
      return _FestivalShapeFamily.marquee;
    }
    if (_containsAny(key, const ['gp', 'daytona', 'super_bowl', 'wimbledon', 'open'])) {
      return _FestivalShapeFamily.comet;
    }
    if (_containsAny(key, const ['eid', 'easter', 'diwali', 'hanukkah', 'christmas', 'purim'])) {
      return _FestivalShapeFamily.temple;
    }
    return _fallbackFamily(key, const [
      _FestivalShapeFamily.crystal,
      _FestivalShapeFamily.lotus,
      _FestivalShapeFamily.ribbon,
      _FestivalShapeFamily.wave,
      _FestivalShapeFamily.marquee,
      _FestivalShapeFamily.comet,
      _FestivalShapeFamily.crown,
      _FestivalShapeFamily.temple,
    ]);
  }

  static bool _containsAny(String key, List<String> tokens) {
    for (final token in tokens) {
      if (key.contains(token)) {
        return true;
      }
    }
    return false;
  }

  static _FestivalShapeFamily _fallbackFamily(
    String key,
    List<_FestivalShapeFamily> families,
  ) {
    var hash = 0;
    for (final code in key.codeUnits) {
      hash = ((hash * 31) + code) & 0x7fffffff;
    }
    return families[hash % families.length];
  }
}

class _FestivalRibbonClipper extends CustomClipper<Path> {
  final _FestivalShapeFamily family;

  const _FestivalRibbonClipper(this.family);

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final path = Path();
    const edge = 10.0;

    switch (family) {
      case _FestivalShapeFamily.crown:
        path
          ..moveTo(edge, height)
          ..lineTo(0, height * 0.62)
          ..lineTo(width * 0.14, height * 0.58)
          ..lineTo(width * 0.24, height * 0.16)
          ..lineTo(width * 0.50, 0)
          ..lineTo(width * 0.76, height * 0.16)
          ..lineTo(width * 0.86, height * 0.58)
          ..lineTo(width, height * 0.62)
          ..lineTo(width - edge, height);
        break;
      case _FestivalShapeFamily.crystal:
        path
          ..moveTo(12, 0)
          ..lineTo(width - 12, 0)
          ..lineTo(width, height * 0.5)
          ..lineTo(width - 12, height)
          ..lineTo(12, height)
          ..lineTo(0, height * 0.5);
        break;
      case _FestivalShapeFamily.ribbon:
        path
          ..moveTo(16, 0)
          ..lineTo(width - 16, 0)
          ..lineTo(width, height * 0.5)
          ..lineTo(width - 16, height)
          ..lineTo(16, height)
          ..lineTo(0, height * 0.5);
        break;
      case _FestivalShapeFamily.lotus:
        path
          ..moveTo(0, height * 0.75)
          ..quadraticBezierTo(width * 0.08, 0, width * 0.22, height * 0.25)
          ..quadraticBezierTo(width * 0.36, height * 0.03, width * 0.5, 0)
          ..quadraticBezierTo(width * 0.64, height * 0.03, width * 0.78, height * 0.25)
          ..quadraticBezierTo(width * 0.92, 0, width, height * 0.75)
          ..lineTo(width, height)
          ..lineTo(0, height);
        break;
      case _FestivalShapeFamily.wave:
        path
          ..moveTo(0, height * 0.70)
          ..quadraticBezierTo(width * 0.15, height * 0.45, width * 0.32, height * 0.62)
          ..quadraticBezierTo(width * 0.50, height * 0.80, width * 0.68, height * 0.56)
          ..quadraticBezierTo(width * 0.86, height * 0.34, width, height * 0.58)
          ..lineTo(width, height)
          ..lineTo(0, height);
        break;
      case _FestivalShapeFamily.marquee:
        path
          ..moveTo(10, 0)
          ..lineTo(width - 10, 0)
          ..lineTo(width, 10)
          ..lineTo(width, height - 10)
          ..lineTo(width - 10, height)
          ..lineTo(10, height)
          ..lineTo(0, height - 10)
          ..lineTo(0, 10);
        break;
      case _FestivalShapeFamily.comet:
        path
          ..moveTo(0, 0)
          ..lineTo(width * 0.9, 0)
          ..lineTo(width, height * 0.5)
          ..lineTo(width * 0.9, height)
          ..lineTo(0, height)
          ..quadraticBezierTo(width * 0.06, height * 0.5, 0, 0);
        break;
      case _FestivalShapeFamily.temple:
        path
          ..moveTo(width * 0.08, height)
          ..lineTo(width * 0.08, height * 0.36)
          ..lineTo(width * 0.24, height * 0.36)
          ..lineTo(width * 0.5, 0)
          ..lineTo(width * 0.76, height * 0.36)
          ..lineTo(width * 0.92, height * 0.36)
          ..lineTo(width * 0.92, height)
          ..close();
        break;
    }

    return path..close();
  }

  @override
  bool shouldReclip(covariant _FestivalRibbonClipper oldClipper) {
    return oldClipper.family != family;
  }
}

class _FestivalCounterClipper extends CustomClipper<Path> {
  final _FestivalShapeFamily family;

  const _FestivalCounterClipper(this.family);

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);
    final radius = width < height ? width / 2 : height / 2;

    switch (family) {
      case _FestivalShapeFamily.crown:
        return Path()
          ..moveTo(center.dx, 0)
          ..lineTo(width * 0.82, height * 0.18)
          ..lineTo(width, center.dy)
          ..lineTo(width * 0.82, height * 0.82)
          ..lineTo(center.dx, height)
          ..lineTo(width * 0.18, height * 0.82)
          ..lineTo(0, center.dy)
          ..lineTo(width * 0.18, height * 0.18)
          ..close();
      case _FestivalShapeFamily.crystal:
        return Path()
          ..moveTo(width * 0.22, 0)
          ..lineTo(width * 0.78, 0)
          ..lineTo(width, center.dy)
          ..lineTo(width * 0.78, height)
          ..lineTo(width * 0.22, height)
          ..lineTo(0, center.dy)
          ..close();
      case _FestivalShapeFamily.ribbon:
        return Path()
          ..moveTo(width * 0.14, 0)
          ..lineTo(width * 0.86, 0)
          ..lineTo(width, height * 0.14)
          ..lineTo(width, height * 0.86)
          ..lineTo(width * 0.86, height)
          ..lineTo(width * 0.14, height)
          ..lineTo(0, height * 0.86)
          ..lineTo(0, height * 0.14)
          ..close();
      case _FestivalShapeFamily.lotus:
        return Path()
          ..moveTo(center.dx, 0)
          ..quadraticBezierTo(width * 0.82, height * 0.08, width, center.dy)
          ..quadraticBezierTo(width * 0.82, height * 0.92, center.dx, height)
          ..quadraticBezierTo(width * 0.18, height * 0.92, 0, center.dy)
          ..quadraticBezierTo(width * 0.18, height * 0.08, center.dx, 0)
          ..close();
      case _FestivalShapeFamily.wave:
        return _buildWavyPath(center, radius, 8, 0.12);
      case _FestivalShapeFamily.marquee:
        return Path()
          ..moveTo(center.dx, 0)
          ..lineTo(width, height * 0.28)
          ..lineTo(width * 0.88, height)
          ..lineTo(width * 0.12, height)
          ..lineTo(0, height * 0.28)
          ..close();
      case _FestivalShapeFamily.comet:
        return Path()
          ..moveTo(width * 0.12, 0)
          ..lineTo(width * 0.84, 0)
          ..quadraticBezierTo(width, height * 0.36, width * 0.92, height * 0.76)
          ..quadraticBezierTo(width * 0.66, height, width * 0.24, height)
          ..quadraticBezierTo(0, height * 0.74, 0, height * 0.36)
          ..quadraticBezierTo(width * 0.04, height * 0.16, width * 0.12, 0)
          ..close();
      case _FestivalShapeFamily.temple:
        return Path()
          ..moveTo(width * 0.2, 0)
          ..lineTo(width * 0.8, 0)
          ..lineTo(width, height * 0.3)
          ..lineTo(width * 0.88, height)
          ..lineTo(width * 0.12, height)
          ..lineTo(0, height * 0.3)
          ..close();
    }
  }

  Path _buildWavyPath(
    Offset center,
    double radius,
    int segments,
    double waveStrength,
  ) {
    final path = Path();
    for (var i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * pi;
      final wave = 1 + (waveStrength * sin(angle * 3));
      final x = center.dx + cos(angle) * radius * wave;
      final y = center.dy + sin(angle) * radius * wave;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant _FestivalCounterClipper oldClipper) {
    return oldClipper.family != family;
  }
}

class _FestivalCounterGem extends StatelessWidget {
  final Color color;

  const _FestivalCounterGem({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.60),
            blurRadius: 6,
            spreadRadius: 0.6,
          ),
        ],
      ),
    );
  }
}

class _SignalTicks extends StatelessWidget {
  final Color color;
  final int tickCount;

  const _SignalTicks({
    required this.color,
    required this.tickCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(tickCount, (index) {
        final strength = ((index % 4) + 1) / 4;
        return Container(
          width: 1.2,
          height: 3.2 + (3.5 * strength),
          color: color.withOpacity(0.45 + (0.4 * strength)),
        );
      }),
    );
  }
}

class _ElectricalPulseRail extends StatefulWidget {
  final Color color;

  const _ElectricalPulseRail({required this.color});

  @override
  State<_ElectricalPulseRail> createState() => _ElectricalPulseRailState();
}

class _ElectricalPulseRailState extends State<_ElectricalPulseRail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final x = (_controller.value * 1.28) - 0.22;
        return Align(
          alignment: Alignment(x.clamp(-1.0, 1.0), 0),
          child: Container(
            width: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  widget.color.withOpacity(0.36),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CivilTrussMarks extends StatelessWidget {
  final Color color;

  const _CivilTrussMarks({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CivilTrussPainter(color: color),
    );
  }
}

class _CivilTrussPainter extends CustomPainter {
  final Color color;

  const _CivilTrussPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;
    for (int i = 1; i <= 3; i++) {
      final y = (height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(width, y), paint);
    }
    for (int i = 1; i <= 3; i++) {
      final x = (width / 4) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
    }
    canvas.drawLine(Offset(0, 0), Offset(width, height), paint);
    canvas.drawLine(Offset(width, 0), Offset(0, height), paint);
  }

  @override
  bool shouldRepaint(covariant _CivilTrussPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _CivilBubbleLevelIndicator extends StatelessWidget {
  final double progress;
  final Color color;

  const _CivilBubbleLevelIndicator({
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = ((progress * 2) - 1).clamp(-1.0, 1.0).toDouble();
    return Align(
      alignment: Alignment(alignment, 0),
      child: Container(
        width: 8,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.92),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.42),
              blurRadius: 6,
            ),
          ],
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

