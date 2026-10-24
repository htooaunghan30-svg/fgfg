// lib/presentation/providers/camera_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../../data/services/pose_detection_service.dart';
import '../../data/services/exercise_logic_engine.dart';
import '../../domain/use_cases/validate_form.dart';
import '../../core/utils/performance_metrics.dart';
import '../../data/models/exercise_log.dart' show FormWarning;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class CameraProvider with ChangeNotifier {
  // Camera State
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  Size? _cameraPreviewSize;
  
  // Pose Detection
  PoseDetectionService? _poseDetectionService;
  StreamSubscription<PoseDetectionResult>? _detectionSubscription;
  
  // Exercise Logic
  ExerciseLogicEngine? _exerciseLogicEngine;
  StreamSubscription<ExerciseState>? _exerciseStateSubscription;
  
  // Current State
  ExerciseState? _currentExerciseState;
  double _currentAccuracy = 0.0;
  List<FormWarning> _currentWarnings = [];
  Pose? _lastDetectedPose;
  
  // Performance
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();
  
  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;
  bool get isProcessing => _isProcessing;
  Size? get cameraPreviewSize => _cameraPreviewSize;
  ExerciseState? get currentExerciseState => _currentExerciseState;
  double get currentAccuracy => _currentAccuracy;
  List<FormWarning> get currentWarnings => _currentWarnings;
  Pose? get lastDetectedPose => _lastDetectedPose;
  PerformanceMonitor get performanceMonitor => _performanceMonitor;
  
  // Initialize Camera
  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      // Select back camera
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      
      await _cameraController!.initialize();
      
      _cameraPreviewSize = Size(
        _cameraController!.value.previewSize!.height,
        _cameraController!.value.previewSize!.width,
      );
      
      _isCameraInitialized = true;
      notifyListeners();
      
    } catch (e) {
      _isCameraInitialized = false;
      rethrow;
    }
  }
  
  // Start Exercise
  Future<void> startExercise({
    required String exerciseId,
    required Map<String, dynamic> exerciseConfig,
    required ValidateFormUseCase validateFormUseCase,
  }) async {
    if (_poseDetectionService != null) {
      await stopExercise();
    }
    
    // Initialize pose detection
    _poseDetectionService = PoseDetectionService();
    await _poseDetectionService!.initialize();
    
    // Initialize exercise logic
    _exerciseLogicEngine = ExerciseLogicEngine(
      validateForm: validateFormUseCase,
      exerciseId: exerciseId,
      exerciseConfig: exerciseConfig,
    );
    
    // Subscribe to detection results
    _detectionSubscription = _poseDetectionService!.detectionStream.listen(
      _handleDetectionResult,
      onError: (error) {
        debugPrint('Detection error: $error');
      },
    );
    
    // Subscribe to exercise state
    _exerciseStateSubscription = _exerciseLogicEngine!.stateStream.listen(
      _handleExerciseStateChange,
    );
    
    // Start camera stream
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _cameraController!.startImageStream(_processCameraImage);
    }
    
    // Start performance monitoring
    _performanceMonitor.startMonitoring();
  }
  
  void _processCameraImage(CameraImage image) async {
    if (_isProcessing || _poseDetectionService == null) return;
    
    _isProcessing = true;
    final stopwatch = Stopwatch()..start();
    
    try {
      if (_cameraPreviewSize == null) return;
      
      // Process image through pose detection
      await _poseDetectionService!.processCameraImage(
        image,
        InputImageRotation.rotation90deg,
        _cameraPreviewSize!,
        _exerciseLogicEngine?.exerciseId ?? '',
        _exerciseLogicEngine?.exerciseConfig ?? {},
      );
      
      // Record performance
      final processingTime = stopwatch.elapsedMilliseconds.toDouble();
      _performanceMonitor.recordMetric('frame', processingTime);
      
    } catch (e) {
      debugPrint('Error processing camera image: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  void _handleDetectionResult(PoseDetectionResult result) {
    _lastDetectedPose = result.pose;
    _currentAccuracy = result.overallAccuracy;
    _currentWarnings = result.formWarnings;
    
    if (_exerciseLogicEngine != null && result.pose != null) {
      // Pass to exercise logic engine
      _exerciseLogicEngine!.processFrame(
        jointAngles: result.jointAngles,
        formWarnings: result.formWarnings,
        overallAccuracy: result.overallAccuracy,
      );
    }
    
    notifyListeners();
  }
  
  void _handleExerciseStateChange(ExerciseState state) {
    _currentExerciseState = state;
    notifyListeners();
  }
  
  // Stop Exercise
  Future<void> stopExercise() async {
    // Stop camera stream
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
    
    // Cancel subscriptions
    await _detectionSubscription?.cancel();
    await _exerciseStateSubscription?.cancel();
    
    // Dispose services
    await _poseDetectionService?.dispose();
    await _exerciseLogicEngine?.dispose();
    
    // Reset state
    _poseDetectionService = null;
    _exerciseLogicEngine = null;
    _currentExerciseState = null;
    _currentAccuracy = 0.0;
    _currentWarnings.clear();
    _lastDetectedPose = null;
    
    // Stop performance monitoring
    _performanceMonitor.stopMonitoring();
    
    notifyListeners();
  }
  
  // Toggle Camera
  Future<void> toggleCamera() async {
    if (_cameraController == null) return;
    
    final currentLens = _cameraController!.description.lensDirection;
    final cameras = await availableCameras();
    
    CameraDescription? newCamera;
    
    if (currentLens == CameraLensDirection.back) {
      // Switch to front camera
      newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
    } else {
      // Switch to back camera
      newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
    }
    
    await _cameraController!.dispose();
    
    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    
    await _cameraController!.initialize();
    _cameraPreviewSize = Size(
      _cameraController!.value.previewSize!.height,
      _cameraController!.value.previewSize!.width,
    );
    
    notifyListeners();
  }
  
  // Cleanup
  @override
  void dispose() {
    _detectionSubscription?.cancel();
    _exerciseStateSubscription?.cancel();
    _poseDetectionService?.dispose();
    _exerciseLogicEngine?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }
}
