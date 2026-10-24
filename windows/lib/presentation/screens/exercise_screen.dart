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
import '../../domain/use_cases/validate_form.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../data/services/isar_service.dart';
import '../../features/gamification/badge_manager.dart';
import '../../features/iconic/iconic_program.dart';
import '../../features/iconic/zodiac_sign.dart';
import '../../features/iconic/world_festival.dart';
import '../../features/iconic/profession_hobby_theme.dart';
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
  AnalysisImage? _pendingAnalysisImage;
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
  bool _smoothAnimationUsesRecordingMode = false;
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

  Future<void> _initializeServices() async {
    _poseDetectionService = PoseDetectionService();
    _exerciseLogicEngine = ExerciseLogicEngine(
      validateForm: ValidateFormUseCase(),
      exerciseId: widget.exerciseId,
      exerciseConfig: widget.exerciseConfig,
    );

    // Initial pose detection model check - using accurate as requested
    await _poseDetectionService.initialize();

    _detectionSubscription = _poseDetectionService.resultStream.listen(_handleDetectionResult);
    _stateSubscription = _exerciseLogicEngine.stateStream.listen(_handleExerciseStateChange);

    setState(() {
      _servicesReady = true;
    });
  }

  void _handleDetectionResult(PoseDetectionResult result) {
    if (!mounted) return;

    // Performance optimization: Removed high-frequency print statements.

    setState(() {
      _lastDetectedPose = result.pose;
      _currentAccuracy = result.overallAccuracy;
      _activeWarnings = result.formWarnings;
      
      // Update smoothing for UI
      _targetAccuracy = result.overallAccuracy;
      if (_smoothTimer == null) {
        _startSmoothAnimation();
      }
    });

    _exerciseLogicEngine.processFrame(
      jointAngles: result.jointAngles,
      formWarnings: result.formWarnings,
      overallAccuracy: result.overallAccuracy,
    );
  }

  void _startSmoothAnimation() {
    _smoothTimer?.cancel();
    _smoothTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final diff = _targetAccuracy - _displayAccuracy;
      if (diff.abs() < 0.005) {
        setState(() {
          _displayAccuracy = _targetAccuracy;
        });
        timer.cancel();
        _smoothTimer = null;
        return;
      }

      setState(() {
        _displayAccuracy += diff * _uiSmoothingSpeed;
      });
    });
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
    final interval = _isRecording ? _frameIntervalRecording : _frameIntervalNormal;
    if (_lastFrameProcessedAt != null && 
        now.difference(_lastFrameProcessedAt!) < interval) {
      return;
    }

    _isProcessing = true;
    _lastFrameProcessedAt = now;
    _lastAnalysisImage = image;

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
      _isProcessing = false;
      final pending = _pendingAnalysisImage;
      _pendingAnalysisImage = null;
      if (pending != null) {
        unawaited(_processAnalysisImage(pending));
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecordActionInProgress) return;
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

    if (mounted && started) {
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
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

    _activeRawRecordingPath = rawPath ?? _activeRawRecordingPath ?? _lastRecordedPath;
    if (mounted) {
      setState(() => _isRecording = false);
    }
    final userProvider = context.read<UserProvider>();
    await _exportRecordingWithSelectedEffects(userProvider);
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

    if (mounted) {
      setState(() {
        _isSavingRecording = true;
        _recordingStatusTitle = 'Exporting video';
        _recordingStatusSubtitle = 'Applying your selected overlay effects...';
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
        overlayTitle: exerciseTitle,
      );

      _lastRecordedPath = exportResult.videoPath;
      if (mounted && exportResult.usedRawFallback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Video saved. Overlay export fell back to raw recording.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video export failed: $e'),
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
    // Show summary and handle navigation
  }

  void _toggleLandmarks() {
    setState(() {
      _showLandmarks = !_showLandmarks;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detectionSubscription.cancel();
    _stateSubscription.cancel();
    _smoothTimer?.cancel();
    _recordingAutoStopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final l10n = context.l10n;
    
    // Performance optimization: Force simplified visuals for real-time live preview.
    const bool simplifyRecordingVisuals = true;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraAwesomeBuilder.custom(
        saveConfig: SaveConfig.video(),
        onMediaCaptureEvent: _handleMediaCaptureEvent,
        onImageForAnalysis: _processAnalysisImage,
        builder: (cameraState, preview) {
          _cameraState = cameraState;
          final isFrontCamera =
              cameraState.sensorConfig.sensors.isNotEmpty &&
                  cameraState.sensorConfig.sensors.first.position ==
                      SensorPosition.front;
          final previewRect = preview.rect;
          
          final liveFestivalVisual = worldFestivalForDate(DateTime.now());

          final bool showLandmarksSetting =
              _showLandmarks || userProvider.showLandmarks;
          final showLandmarks = showLandmarksSetting;
          final isRecording = _isRecording;
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
              if (cameraState is PreparingCameraState)
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
