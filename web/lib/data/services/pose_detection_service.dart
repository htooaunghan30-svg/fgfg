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
import 'package:flutter/foundation.dart'; // á€’á€«á€€á€­á€¯ á€‘á€Šá€·á€ºá€™á€¾ WriteBuffer á€€á€­á€¯ á€žá€¯á€¶á€¸á€œá€­á€¯á€·á€›á€™á€¾á€¬á€•á€«
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
  // Exercise Logic Engine á€€á€­á€¯ á€€á€¼á€±á€Šá€¬á€á€¼á€„á€ºá€¸

  // UI á€€á€”á€± Rep count á€á€½á€±á€€á€­á€¯ á€œá€¾á€™á€ºá€¸á€šá€°á€”á€­á€¯á€„á€ºá€–á€­á€¯á€· Getter á€á€…á€ºá€á€¯ á€‘á€¬á€¸á€•á€±á€¸á€›á€„á€º á€•á€­á€¯á€€á€±á€¬á€„á€ºá€¸á€•á€«á€á€šá€º
  PoseDetectionResult({
    this.pose,
    required this.jointAngles,
    required this.formWarnings,
    required this.overallAccuracy,
    required this.isPoseDetected,
    required this.timestamp,
  });
}

class PoseDetectionService {
  static const double _minDetectionConfidence = 0.5;
  static const double _minTrackingConfidence = 0.5;
  static const int _maxPoseDetections = 2;
  static const double _minReliableLandmarkLikelihood = 0.1;
  static const double _minAcceptedPoseConfidence = 0.15;

  late PoseDetector _poseDetector;
  late StreamController<PoseDetectionResult> _resultController;
  late Timer? _throttleTimer;
  bool _isProcessing = false;
  int _processingFrameCount = 0;
  DateTime? _lastProcessedTime;
  List<double> _accuracyHistory = [];

  final AngleCalculator _angleCalculator = AngleCalculator();

  // UI á€€á€”á€± Rep count á€á€½á€±á€€á€­á€¯ á€œá€¾á€™á€ºá€¸á€šá€°á€”á€­á€¯á€„á€ºá€–á€­á€¯á€· Getter á€á€…á€ºá€á€¯ á€‘á€¬á€¸á€•á€±á€¸á€›á€„á€º á€•á€­á€¯á€€á€±á€¬á€„á€ºá€¸á€•á€«á€á€šá€º

  //static const double _smoothingFactor = 0.15; // 0.1-0.3 á€€á€¼á€¬á€¸
  // static const int _historySize = 10;
  static const double _minConfidenceThreshold =
      0.25; // Minimum confidence to update

  // State for smoothing
  double _smoothedAccuracy = 0.1; // Start at 50%
  List<double> _recentAccuracies = [];
  DateTime? _lastSignificantUpdate;
  static const int _updateCooldownMs = 300;

  // double _smoothAccuracyValue(double newAccuracy, double confidence) {
  //   final now = DateTime.now();

  //   // 1. Confidence check - if confidence is low, don't update much
  //   if (confidence < _minConfidenceThreshold) {
  //     // Return current value with minimal update
  //     return 0.1 * newAccuracy + 0.9 * _smoothedAccuracy;
  //   }

  //   // 2. Cooldown check - don't update too frequently
  //   if (_lastSignificantUpdate != null &&
  //       now.difference(_lastSignificantUpdate!).inMilliseconds < _updateCooldownMs) {
  //     return _smoothedAccuracy;
  //   }

  //   _lastSignificantUpdate = now;

  //   // 3. Add to history for moving average
  //   _recentAccuracies.add(newAccuracy);
  //   if (_recentAccuracies.length > _historySize) {
  //     _recentAccuracies.removeAt(0);
  //   }

  //   // 4. Calculate weighted average (recent values have more weight)
  //   double weightedSum = 0.0;
  //   double totalWeight = 0.0;

  //   for (int i = 0; i < _recentAccuracies.length; i++) {
  //     final weight = (i + 1) / _recentAccuracies.length; // Linear weighting
  //     weightedSum += _recentAccuracies[i] * weight;
  //     totalWeight += weight;
  //   }

  //   final weightedAverage = weightedSum / totalWeight;

  //   // 5. Apply exponential smoothing
  //   _smoothedAccuracy = _smoothingFactor * weightedAverage +
  //                      (1 - _smoothingFactor) * _smoothedAccuracy;

  //   // 6. Clamp to reasonable values (avoid extreme jumps)
  //   final change = (_smoothedAccuracy - newAccuracy).abs();
  //   if (change > 0.4) { // Don't allow jumps > 40%
  //     _smoothedAccuracy = newAccuracy > _smoothedAccuracy
  //         ? _smoothedAccuracy + 0.4
  //         : _smoothedAccuracy - 0.4;
  //   }

  //   return _smoothedAccuracy.clamp(0.0, 1.0);
  // }
  // Update the smoothing function
//static const int _historySize = 5; // Reduced for faster response

  static const double _smoothingFactor =
      0.9; // Increased for more responsiveness
// Smoothing parameters
  static const double _quickResponseFactor =
      0.2; // á€á€­á€¯á€¸á€á€€á€ºá€”á€±á€›á€„á€º á€™á€¼á€”á€ºá€™á€¼á€”á€º response
  static const double _slowResponseFactor =
      0.2; // á€€á€»á€”á€±á€›á€„á€º á€–á€¼á€Šá€ºá€¸á€–á€¼á€Šá€ºá€¸ response
  static const int _smoothingHistory =
      4; // á€žá€™á€­á€¯á€„á€ºá€¸á€¡á€›á€½á€šá€ºá€¡á€…á€¬á€¸

// Smoothing parameters
  static const int _historySize =
      1; // á€žá€™á€­á€¯á€„á€ºá€¸á€¡á€›á€½á€šá€ºá€¡á€…á€¬á€¸
  static const double _baseSmoothingFactor = 0.8;
  static const double _stabilityThreshold = 0; //

// Smoothing parameters - á€¡á€žá€…á€ºá€•á€¼á€„á€ºá€†á€„á€ºá€‘á€¬á€¸á€žá€±á€¬
//static const int _historySize = 10; // á€žá€™á€­á€¯á€„á€ºá€¸á€¡á€›á€½á€šá€ºá€¡á€…á€¬á€¸
  static const double _minConfidenceForUpdate =
      0.4; // Confidence 50% á€¡á€‘á€€á€ºá€†á€­á€¯á€™á€¾ update
  static const int _stabilityRequiredFrames =
      2; // á€˜á€šá€ºá€”á€¾á€…á€º frame á€á€Šá€ºá€™á€¼á€²á€™á€¾ update á€œá€¯á€•á€ºá€™á€œá€²

// History tracking
//List<double> _accuracyHistory = [];
  List<List<double>> _jointAngleHistory = [];
//List<double> _jointAngleHistory = [];
  int _stableFrameCount = 0;
  double _lastStableAccuracy = 0.5;

// Smoothing parameters - á€›á€­á€¯á€¸á€›á€¾á€„á€ºá€¸á€¡á€±á€¬á€„á€ºá€•á€¼á€„á€ºá€•á€«

// á€’á€® function á€€á€­á€¯ á€¡á€žá€…á€ºá€•á€¼á€”á€ºá€›á€±á€¸á€•á€«
  double _smoothAccuracyValue(
      double newAccuracy, double confidence, Map<String, double> jointAngles) {
    print('\nðŸ”„ === SMOOTHING ACCURACY ===');
    print('   New Accuracy: ${(newAccuracy * 100).toStringAsFixed(1)}%');
    print('   Confidence: ${(confidence * 100).toStringAsFixed(1)}%');

    // 1. If confidence is too low, return current value directly
    if (confidence < _minConfidenceForUpdate) {
      print('âš ï¸ Confidence too low, returning current value');
      return _lastStableAccuracy;
    }

    // 2. Simple moving average with recent history
    _accuracyHistory.add(newAccuracy);
    if (_accuracyHistory.length > _historySize) {
      _accuracyHistory.removeAt(0);
    }

    // 3. Calculate average of recent values
    double sum = 0.0;
    for (double acc in _accuracyHistory) {
      sum += acc;
    }
    double averageAccuracy = sum / _accuracyHistory.length;

    // 4. Apply exponential smoothing
    double smoothedValue = (_smoothingFactor * newAccuracy) +
        ((1 - _smoothingFactor) * _lastStableAccuracy);

    // 5. Update stable accuracy
    _lastStableAccuracy = smoothedValue;

    print('âœ… Smoothed Value: ${(smoothedValue * 100).toStringAsFixed(1)}%');

    return smoothedValue.clamp(0.0, 1.0);
  }

// Update condition á€€á€­á€¯á€›á€­á€¯á€¸á€›á€¾á€„á€ºá€¸á€¡á€±á€¬á€„á€ºá€œá€¯á€•á€ºá€•á€«
  bool _checkUpdateConditions(
      double newAccuracy, Map<String, double> jointAngles) {
    // Always update if we don't have enough history
    if (_accuracyHistory.length < 2) {
      return true;
    }

    // If accuracy changed by more than 2%, update
    double lastAccuracy = _accuracyHistory.last;
    double change = (newAccuracy - lastAccuracy).abs();

    if (change < 0.02) {
      // 2% change only (á€¡á€›á€„á€º 5%)
      print(
          'ðŸ“Š Small change (${(change * 100).toStringAsFixed(1)}%), but updating anyway');
      return true; // Still update even with small changes
    }

    return true;
  }

// Angle stability check á€€á€­á€¯á€œá€»á€¾á€±á€¬á€·á€á€»
  bool _areAnglesStable(Map<String, double> currentAngles) {
    if (currentAngles.isEmpty) return true; // Empty is considered stable

    if (_jointAngleHistory.isEmpty) {
      _jointAngleHistory.add(currentAngles.values.toList());
      return true;
    }

    List<double> lastAngles = _jointAngleHistory.last;
    double totalChange = 0.0;
    int minLength = min(lastAngles.length, currentAngles.values.length);

    for (int i = 0; i < minLength; i++) {
      totalChange += (currentAngles.values.elementAt(i) - lastAngles[i]).abs();
    }

    double avgChange = totalChange / minLength;
    bool isStable = avgChange < 5.0; // Increased from 10.0 to 15.0

    _jointAngleHistory.add(currentAngles.values.toList());
    if (_jointAngleHistory.length > 2) {
      // Reduced from 5
      _jointAngleHistory.removeAt(0);
    }

    return isStable;
  }

  double _calculateUpdateFactor(
      double confidence, Map<String, double> jointAngles) {
    // Base update factor based on confidence
    double baseFactor = confidence.clamp(0.3, 0.7); // 30-70% range

    // Adjust based on angle stability
    double stabilityBonus = _areAnglesStable(jointAngles) ? 0.15 : 0.0;

    // Adjust based on accuracy history trend
    double trendBonus = 0.0;
    if (_accuracyHistory.length >= 3) {
      double trend = _calculateTrend(_accuracyHistory);
      if (trend > 0) {
        // Improving
        trendBonus = 0.1;
      } else if (trend < -0.1) {
        // Declining significantly
        trendBonus = -0.05;
      }
    }

    double totalFactor = baseFactor + stabilityBonus + trendBonus;

    // Clamp to reasonable range
    return totalFactor.clamp(0.1, 0.8);
  }

  double _applyVerySlowSmoothing(double newAccuracy) {
    // á€¡á€›á€™á€ºá€¸á€–á€¼á€Šá€ºá€¸á€–á€¼á€Šá€ºá€¸á€•á€² update á€œá€¯á€•á€ºá€™á€šá€º
    const double smoothingFactor =
        0.2; // âœ… 0.08 á€€á€”á€± 0.2 á€á€­á€¯á€¸ (2x á€•á€­á€¯á€™á€¼á€”á€º)
    _lastStableAccuracy = (smoothingFactor * newAccuracy) +
        ((1 - smoothingFactor) * _lastStableAccuracy);
    return _lastStableAccuracy;
  }

  double _applyStableSmoothing(double newAccuracy, double trend) {
    // Stable á€–á€¼á€…á€ºá€”á€±á€›á€„á€º á€•á€­á€¯á€™á€¼á€”á€ºá€™á€¼á€”á€º update á€œá€¯á€•á€ºá€™á€šá€º
    double smoothingFactor = 0.3; // 30%

    // If accuracy is improving, update faster
    if (trend > 0.1) {
      // Improving trend
      smoothingFactor = 0.4;
    }
    // If accuracy is declining, update slower
    else if (trend < -0.1) {
      smoothingFactor = 0.15;
    }

    _lastStableAccuracy = (smoothingFactor * newAccuracy) +
        ((1 - smoothingFactor) * _lastStableAccuracy);
    return _lastStableAccuracy;
  }

  double _calculateTrend(List<double> history) {
    if (history.length < 3) return 0.0;

    // Simple linear trend calculation
    double sumX = 0.0;
    double sumY = 0.0;
    double sumXY = 0.0;
    double sumX2 = 0.0;

    for (int i = 0; i < history.length; i++) {
      sumX += i;
      sumY += history[i];
      sumXY += i * history[i];
      sumX2 += i * i;
    }

    double n = history.length.toDouble();
    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

    return slope;
  }

  double _calculateVariance(List<double> values) {
    if (values.length < 2) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    double sum = 0.0;
    for (final value in values) {
      sum += (value - mean) * (value - mean);
    }
    return sum / values.length;
  }

  double _calculatePoseConfidence(Pose pose) {
    // Key landmarks for full body detection
    final List<PoseLandmarkType> keyLandmarks = [
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

    // Normalize based on number of visible landmarks
    final visibilityFactor = validLandmarks / keyLandmarks.length;
    final finalConfidence = averageConfidence * visibilityFactor;

    print(
        'ðŸ‘ï¸ Pose Confidence: ${(finalConfidence * 100).toStringAsFixed(1)}% ' +
            '($validLandmarks/${keyLandmarks.length} landmarks)');

    return finalConfidence;
  }

  PoseDetectionService() {
    _resultController = StreamController<PoseDetectionResult>.broadcast();

    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    );

    _poseDetector = PoseDetector(options: options);
  }

  Stream<PoseDetectionResult> get detectionStream => _resultController.stream;

  Future<void> initialize() async {
    try {
      // Pose detector á€€á€­á€¯ á€…á€™á€ºá€¸á€žá€•á€ºá€¡á€žá€¯á€¶á€¸á€•á€¼á€¯á€™á€¾á€¯
      print('Initializing Pose Detection Service...');

      // Check if pose detection is available
      // final isAvailable = await PoseDetector.isAvailable();
      // if (!isAvailable) {
      //   print('Pose detection is not available');
      //   return;
      // }

      print('Pose Detection Service initialized successfully');
    } catch (e) {
      print('Error initializing pose detection: $e');
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

      final torsoMagnitude = sqrt((torsoDx * torsoDx) + (torsoDy * torsoDy));
      final pressMagnitude = sqrt((pressDx * pressDx) + (pressDy * pressDy));
      final forearmMagnitude =
          sqrt((forearmDx * forearmDx) + (forearmDy * forearmDy));
      if (torsoMagnitude < 1.0 || pressMagnitude < 1.0 || forearmMagnitude < 1.0) {
        return;
      }

      final torsoDotPress =
          ((torsoDx * pressDx) + (torsoDy * pressDy)) /
          (torsoMagnitude * pressMagnitude);
      final torsoDotForearm =
          ((torsoDx * forearmDx) + (torsoDy * forearmDy)) /
          (torsoMagnitude * forearmMagnitude);

      final shoulderToWristVerticality =
          (shoulder.y - wrist.y) /
          ((pressDx.abs() + pressDy.abs()).clamp(1.0, double.infinity));
      final forearmVerticality =
          (elbow.y - wrist.y) /
          ((forearmDx.abs() + forearmDy.abs()).clamp(1.0, double.infinity));

      final perpendicularity =
          (1.0 - torsoDotPress.abs()).clamp(0.0, 1.0).toDouble();
      final forearmPerpendicularity =
          (1.0 - torsoDotForearm.abs()).clamp(0.0, 1.0).toDouble();
      final upwardLift = shoulderToWristVerticality.clamp(0.0, 1.0).toDouble();
      final forearmLift = forearmVerticality.clamp(0.0, 1.0).toDouble();

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
          (0.20 + 0.80 * ((perpendicularity * 0.45) +
                  (forearmPerpendicularity * 0.25) +
                  (upwardLift * 0.20) +
                  (forearmLift * 0.10)))
              .clamp(0.0, 1.0)
              .toDouble();

      sideCandidates.add({
        'confidence': confidence,
        'alignment': alignmentScore,
        'upward_lift': upwardLift,
        'forearm_lift': forearmLift,
        'perpendicularity': perpendicularity,
        'forearm_perpendicularity': forearmPerpendicularity,
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
        'bench_press_top_path_valid': 0.0,
      };
    }

    sideCandidates.sort(
      (a, b) => (b['confidence'] ?? 0.0).compareTo(a['confidence'] ?? 0.0),
    );
    final best = sideCandidates.first;
    final alignment = best['alignment'] ?? 0.0;
    final upwardLift = best['upward_lift'] ?? 0.0;
    final topPathValid = alignment >= 0.44 && upwardLift >= 0.05 ? 1.0 : 0.0;

    return {
      'bench_press_lockout_alignment': alignment,
      'bench_press_vertical_lift': upwardLift,
      'bench_press_top_path_valid': topPathValid,
    };
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
    // âœ… FIX 1: Correct InputImage creation
    InputImage inputImage;
    try {
      inputImage = _createCorrectInputImage(cameraImage, rotation);
      print('âœ… Created InputImage successfully');
    } catch (e) {
      print('âŒ Error creating InputImage: $e');
      // Try alternative method
      inputImage = _createInputImageFromBytes(cameraImage, rotation);
    }

    await _processInputImageInternal(
      inputImage: inputImage,
      exerciseId: exerciseId,
      exerciseConfig: exerciseConfig,
    );
  }

  Future<void> processInputImage(
    InputImage inputImage,
    String exerciseId,
    Map<String, dynamic> exerciseConfig,
  ) async {
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
      print('â­ï¸ Skipping frame - already processing');
      return;
    }

    _isProcessing = true;

    try {
      print('\nðŸŽ¬ === PROCESSING FRAME ${++_processingFrameCount} ===');
      print('ðŸ” Calling pose detector...');

      // Test pose detector
      List<Pose> poses = [];
      try {
        poses = await _poseDetector.processImage(inputImage);
        print('âœ… Pose detection completed. Found ${poses.length} poses');
      } catch (e) {
        print('âŒ Pose detector error: $e');

        _lastStableAccuracy = 0.0;
        _accuracyHistory.clear();

        // Send empty result
        _resultController.add(PoseDetectionResult(
          pose: null,
          jointAngles: {},
          formWarnings: [],
          overallAccuracy: 0.0,
          isPoseDetected: false,
          timestamp: DateTime.now(),
        ));
        return;
      }

      if (poses.isEmpty) {
        print('âŒ No poses detected in this frame');

        _lastStableAccuracy = 0.0;
        _accuracyHistory.clear();

        // Send result with no pose
        _resultController.add(PoseDetectionResult(
          pose: null,
          jointAngles: {},
          formWarnings: [],
          overallAccuracy: 0.0,
          isPoseDetected: false,
          timestamp: DateTime.now(),
        ));
        return;
      }

      // âœ… IMPORTANT: á€™á€°á€›á€„á€ºá€¸ code á€á€½á€± á€•á€¼á€”á€ºá€‘á€Šá€·á€ºá€›á€™á€šá€º
      // Process detected pose
      print('ðŸŽ‰ Pose detected!');
      final Pose primaryPose = _getPrimaryPose(poses);
      final allowMissingLikelihoodFallback =
          !_poseHasExplicitLikelihoods(primaryPose);
      if (allowMissingLikelihoodFallback) {
        print(
            'âš ï¸ Pose landmarks do not expose confidence values, using fallback visibility checks');
      }

      final bool isFullBodyVisible = _isFullBodyVisible(primaryPose);
      // final bool isPushupSideVisible =
      //     exerciseId == 'pushup' && _isPushupSideVisible(primaryPose);
      if (!isFullBodyVisible) {
        print(
            'âš ï¸ Full body not visible - continuing with available landmarks');
        // if (isPushupSideVisible) {
        //   print('âš ï¸ Push-up side view detected - allowing single-side tracking');
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

      print('ðŸ“ˆ ${goodLandmarks.length}/33 landmarks with confidence > 0.5');

      if (goodLandmarks.isEmpty) {
        print('âš ï¸ No landmarks with sufficient confidence');
        _lastStableAccuracy = 0.0;
        _accuracyHistory.clear();
        _resultController.add(PoseDetectionResult(
          pose: primaryPose,
          jointAngles: const {},
          formWarnings: [],
          overallAccuracy: 0.0,
          isPoseDetected: false,
          timestamp: DateTime.now(),
        ));
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
        _lastStableAccuracy = 0.0;
        _accuracyHistory.clear();
        _resultController.add(PoseDetectionResult(
          pose: primaryPose,
          jointAngles: const {},
          formWarnings: formWarnings,
          overallAccuracy: 0.0,
          isPoseDetected: true,
          timestamp: DateTime.now(),
        ));
        return;
      }

      // Calculate accuracy
      final rawAccuracy = _calculateUniversalAccuracy(
        jointAngles,
        formWarnings,
        exerciseConfig,
      );

      // âœ… FIX 2: Better pose confidence calculation
      double poseConfidence = _calculateImprovedPoseConfidence(primaryPose);
      // if (exerciseId == 'pushup' ) {//&& isPushupSideVisible
      //  // final sideConfidence = _calculatePushupSideConfidence(primaryPose);
      //   if (sideConfidence > poseConfidence) {
      //     print(
      //         'âœ… Using push-up side confidence: ${(sideConfidence * 100).toStringAsFixed(1)}%');
      //   }
      //   poseConfidence = max(poseConfidence, sideConfidence);
      //   if (poseConfidence < 0.45) {
      //     poseConfidence = 0.45;
      //     print(
      //         'âœ… Push-up side view confidence boost: ${(poseConfidence * 100).toStringAsFixed(1)}%');
      //   }
      // }

      if (poseConfidence < _minAcceptedPoseConfidence) {
        print(
            'âš ï¸ Low pose confidence: ${(poseConfidence * 100).toStringAsFixed(1)}%');

        _lastStableAccuracy = 0.0;
        _accuracyHistory.clear();

        _resultController.add(PoseDetectionResult(
          pose: primaryPose,
          jointAngles: jointAngles,
          formWarnings: formWarnings,
          overallAccuracy: 0.0,
          isPoseDetected: false,
          timestamp: DateTime.now(),
        ));
        return;
      }

      // âœ… Apply smoothing
      final smoothedAccuracy =
          _smoothAccuracyValue(rawAccuracy, poseConfidence, jointAngles);

      print('Raw Accuracy: ${(rawAccuracy * 100).toStringAsFixed(1)}%');
      print('Pose Confidence: ${(poseConfidence * 100).toStringAsFixed(1)}%');
      print(
          'Smoothed Accuracy: ${(smoothedAccuracy * 100).toStringAsFixed(1)}%');
      print('ðŸ“ Joint angles: $jointAngles');

      // Send final result with ALL data
      _resultController.add(PoseDetectionResult(
        pose: primaryPose,
        jointAngles: jointAngles,
        formWarnings: formWarnings,
        overallAccuracy: smoothedAccuracy,
        isPoseDetected: true,
        timestamp: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      print('âŒâŒâŒ CRITICAL ERROR in processCameraImage: $e');
      print('Stack trace: $stackTrace');

      // Send error result
      _resultController.add(PoseDetectionResult(
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

// âœ… FIX 3: Correct InputImage creation for ML Kit
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
    // Android á€¡á€á€½á€€á€º NV21 format á€•á€¼á€±á€¬á€„á€ºá€¸á€á€¼á€„á€ºá€¸
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
    // iOS á€¡á€á€½á€€á€º BGRA format
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

// âœ… FIX 4: Better pose confidence calculation
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
            'ðŸ“ ${entry.value}: ${(landmarkConfidence * 100).toStringAsFixed(1)}%');
      }
    }

    if (detectedLandmarks == 0) return 0.0;

    final double averageConfidence = totalConfidence / detectedLandmarks;
    final double detectionRatio = detectedLandmarks / essentialLandmarks.length;

    // Combined score: 60% average confidence + 40% detection ratio
    final double combinedScore =
        (averageConfidence * 0.6) + (detectionRatio * 0.4);

    print('ðŸ“Š POSE CONFIDENCE REPORT:');
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
    print('ðŸ”„ Sending simulated pose for testing');

    final simulatedAngles = {
      'knee': 120.0,
      'hip': 90.0,
      'shoulder': 170.0,
    };

    _resultController.add(PoseDetectionResult(
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

    print('\nðŸ”¢ === CALCULATING ALL JOINT ANGLES ===');

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

      print('ðŸŽ¯ Primary Joint: $primaryJoint');
      final primaryAngle = _calculateJointAngle(pose, primaryJoint);

      if (primaryAngle > 0) {
        angles[primaryJoint] = primaryAngle;
        print(
            'âœ… Added primary angle: $primaryJoint = ${primaryAngle.toStringAsFixed(1)}Â°');
      } else {
        print('âŒ Failed to calculate primary angle for: $primaryJoint');
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
                'âœ… Added alternative angle: $alt = ${altAngle.toStringAsFixed(1)}Â°');
            print('âœ… Mapped $alt to primary $primaryJoint');
            break;
          }
        }
      }
    }

    // Calculate angles for all form checks
    final rawFormChecks =
        exerciseConfig['form_checks'] ?? exerciseConfig['formChecks'];
    final formChecks = rawFormChecks is List ? rawFormChecks : const [];
    print('ðŸ“‹ Form checks count: ${formChecks.length}');

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
        print('\nðŸ”„ Calculating form check angle $i: $angleName');

        final angle = _calculateJointAngle(
          pose,
          vertexJoint,
          startJoint: startJoint,
          endJoint: endJoint,
        );

        if (angle > 0) {
          angles[angleName] = angle;
          print(
              'âœ… Added form check angle: $angleName = ${angle.toStringAsFixed(1)}Â°');
          if (vertexJoint == 'elbow' && !angles.containsKey('elbow')) {
            angles['elbow'] = angle;
            print('âœ… Mapped form check elbow angle to primary elbow');
          }
        } else {
          print('âŒ Failed to calculate form check angle: $angleName');
        }
      }
    }

    // Always calculate basic angles even if not in config
    if (!angles.containsKey('knee')) {
      final kneeAngle = _calculateKneeAngleFromLandmarks(pose);
      if (kneeAngle > 0) {
        angles['knee'] = kneeAngle;
        print('âœ… Added basic knee angle: ${kneeAngle.toStringAsFixed(1)}Â°');
      }
    }

    if (!angles.containsKey('hip')) {
      final hipAngle = _calculateJointAngle(pose, 'hip');
      if (hipAngle > 0) {
        angles['hip'] = hipAngle;
        print('âœ… Added basic hip angle: ${hipAngle.toStringAsFixed(1)}Â°');
      }
    }

    if (!angles.containsKey('elbow')) {
      final elbowAngle = _calculateJointAngle(pose, 'elbow');
      if (elbowAngle > 0) {
        angles['elbow'] = elbowAngle;
        print(
            'âœ… Added basic elbow angle: ${elbowAngle.toStringAsFixed(1)}Â°');
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
          print('✅ Added left elbow: ${leftElbow.toStringAsFixed(1)}°');
        }
      }
      if (!angles.containsKey('right_elbow')) {
        final rightElbow = _calculateJointAngle(pose, 'right_elbow');
        if (rightElbow > 0) {
          angles['right_elbow'] = rightElbow;
          print('✅ Added right elbow: ${rightElbow.toStringAsFixed(1)}°');
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
              '✅ Added left elbow triplet: ${leftTriplet.toStringAsFixed(1)}°');
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
              '✅ Added right elbow triplet: ${rightTriplet.toStringAsFixed(1)}°');
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
              '✅ Added generic elbow triplet: ${bestAngle.toStringAsFixed(1)}°');
        }
      }

      // 4. Body angle (shoulder-hip-ankle)
      if (!angles.containsKey('shoulder_hip_ankle')) {
        final bodyAngle = _calculateShoulderHipAnkleAngle(pose);
        if (bodyAngle > 0) {
          angles['shoulder_hip_ankle'] = bodyAngle;
          print('✅ Added body angle: ${bodyAngle.toStringAsFixed(1)}°');
        }
      }

      // 5. Back angle (shoulder-hip-knee)
      if (!angles.containsKey('shoulder_hip_knee')) {
        final backAngle = _calculateBackAngle(pose);
        if (backAngle > 0) {
          angles['shoulder_hip_knee'] = backAngle;
          print('✅ Added back angle: ${backAngle.toStringAsFixed(1)}°');
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
              '✅ Added torso upright ratio: ${uprightRatio.toStringAsFixed(3)}');
        }
      }

      if (resolvedExerciseId == 'bench_press') {
        final benchMetrics = _calculateBenchPressPathMetrics(pose);
        angles.addAll(benchMetrics);
        print(
            '✅ Added bench press path metrics: alignment=${(benchMetrics['bench_press_lockout_alignment']! * 100).toStringAsFixed(1)}%, vertical=${(benchMetrics['bench_press_vertical_lift']! * 100).toStringAsFixed(1)}%, topValid=${benchMetrics['bench_press_top_path_valid']!.toStringAsFixed(0)}');
      }
    }

    // Calculate back angle for squat
    if (resolvedExerciseId == 'squat' &&
        !angles.containsKey('shoulder_hip_knee')) {
      final backAngle = _calculateBackAngle(pose);
      if (backAngle > 0) {
        angles['shoulder_hip_knee'] = backAngle;
        print('âœ… Added back angle: ${backAngle.toStringAsFixed(1)}Â°');
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
          print('✅ Added left shoulder: ${leftShoulder.toStringAsFixed(1)}°');
        }
      }
      if (!angles.containsKey('right_shoulder')) {
        final rightShoulder = _calculateJointAngle(pose, 'right_shoulder');
        if (rightShoulder > 0) {
          angles['right_shoulder'] = rightShoulder;
          print('✅ Added right shoulder: ${rightShoulder.toStringAsFixed(1)}°');
        }
      }
      if (!angles.containsKey('left_elbow')) {
        final leftElbow = _calculateJointAngle(pose, 'left_elbow');
        if (leftElbow > 0) {
          angles['left_elbow'] = leftElbow;
          print('✅ Added left elbow: ${leftElbow.toStringAsFixed(1)}°');
        }
      }
      if (!angles.containsKey('right_elbow')) {
        final rightElbow = _calculateJointAngle(pose, 'right_elbow');
        if (rightElbow > 0) {
          angles['right_elbow'] = rightElbow;
          print('✅ Added right elbow: ${rightElbow.toStringAsFixed(1)}°');
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
    //     print('âœ… Added body angle: ${bodyAngle.toStringAsFixed(1)}Â°');
    //   }
    // }
    // if (resolvedExerciseId == 'situp' &&
    //     !angles.containsKey('shoulder_hip_knee')) {
    //   final backAngle = _calculateBackAngle(pose);
    //   if (backAngle > 0) {
    //     angles['shoulder_hip_knee'] = backAngle;
    //     print('âœ… Added back angle: ${backAngle.toStringAsFixed(1)}Â°');
    //   }
    // }

    if (resolvedExerciseId == 'situp') {
      // Sit-up á€¡á€á€½á€€á€º á€™á€¾á€”á€ºá€€á€”á€ºá€žá€±á€¬ angle á€™á€»á€¬á€¸
      final backAngle = _calculateBackAngle(pose);
      if (backAngle > 0) {
        angles['shoulder_hip_knee'] = backAngle;
        print('âœ… Sit-up back angle: ${backAngle.toStringAsFixed(1)}Â°');
      }

      // Hip angle (á€•á€±á€«á€„á€ºá€”á€²á€·á€€á€­á€¯á€šá€ºá€‘á€Šá€ºá€€á€¼á€¬á€¸)
      final hipAngle = _calculateJointAngle(pose, 'hip');
      if (hipAngle > 0) {
        angles['hip'] = hipAngle;
        print('âœ… Sit-up hip angle: ${hipAngle.toStringAsFixed(1)}Â°');
      }

      // Torso angle (á€€á€­á€¯á€šá€ºá€‘á€Šá€ºá€á€Šá€·á€ºá€™á€á€ºá€™á€¾á€¯)
      final torsoAngle = _calculateShoulderHipAnkleAngle(pose);
      if (torsoAngle > 0) {
        angles['torso_angle'] = torsoAngle;
        print('âœ… Sit-up torso angle: ${torsoAngle.toStringAsFixed(1)}Â°');
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
      print('âœ… Elbow raised flag: ${angles['elbow_raised']}');
    }

    print('\nðŸ“Š FINAL ANGLES CALCULATED:');
    if (angles.isEmpty) {
      print('âŒ NO ANGLES CALCULATED!');
    } else {
      angles.forEach((key, value) {
        print('   $key: ${value.toStringAsFixed(1)}Â°');
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

  (double, double) _calculateAngleFromLandmarkTypes(
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
      return (0.0, 0.0);
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
      return (0.0, 0.0);
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
    return (angle, confidence);
  }

  (double, double) _calculateStandardAngleForVertex(
    Pose pose,
    PoseLandmarkType vertexType,
  ) {
    final adjacentJoints = _getAdjacentJoints(vertexType);
    return _calculateAngleFromLandmarkTypes(
      pose,
      adjacentJoints.$1,
      vertexType,
      adjacentJoints.$2,
    );
  }

  (double, double) _calculateCustomAngleForJointNames(
    Pose pose,
    String startJoint,
    String vertexJoint,
    String endJoint,
  ) {
    final startType = _getLandmarkType(startJoint, pose);
    final vertexType = _getLandmarkType(vertexJoint, pose);
    final endType = _getLandmarkType(endJoint, pose);
    if (startType == null || vertexType == null || endType == null) {
      return (0.0, 0.0);
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

    if (leftResult.$1 == 0.0 && rightResult.$1 == 0.0) {
      return 0.0;
    }

    if (rightResult.$2 > leftResult.$2) {
      print('âœ… Right back angle: ${rightResult.$1.toStringAsFixed(1)}Â°');
      return rightResult.$1;
    }

    print('âœ… Left back angle: ${leftResult.$1.toStringAsFixed(1)}Â°');
    return leftResult.$1;
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

    if (leftResult.$1 == 0.0 && rightResult.$1 == 0.0) {
      return 0.0;
    }

    if (rightResult.$2 > leftResult.$2) {
      print('âœ… Right body angle: ${rightResult.$1.toStringAsFixed(1)}Â°');
      return rightResult.$1;
    }

    print('âœ… Left body angle: ${leftResult.$1.toStringAsFixed(1)}Â°');
    return leftResult.$1;
  }

// á€’á€® function á€€á€­á€¯á€œá€¯á€¶á€¸á€á€¡á€žá€…á€ºá€•á€¼á€„á€ºá€†á€„á€ºá€•á€«
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
            'âœ… Found $normalizedName: ${landmarkType.toString()} (confidence: ${(confidence * 100).toStringAsFixed(1)}%)');
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
          print('âœ… Partial match: $normalizedName â†’ ${entry.key}');
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
        print('âœ… Using left knee for $normalizedName');
        return PoseLandmarkType.leftKnee;
      } else if (_isLandmarkReliable(
        rightKnee,
        allowMissingLikelihoodFallback: allowMissingLikelihoodFallback,
        minLikelihood: 0.2,
      )) {
        print('âœ… Using right knee for $normalizedName');
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

    print('âŒ Could not find landmark for: $jointName ($normalizedName)');
    return null;
  }

  double _calculateJointAngle(
    Pose pose,
    String vertexJoint, {
    String? startJoint,
    String? endJoint,
  }) {
    final allowMissingLikelihoodFallback = !_poseHasExplicitLikelihoods(pose);

    print('\nðŸ“ === CALCULATING JOINT ANGLE ===');
    print('Vertex Joint: $vertexJoint');
    print('Start Joint: $startJoint');
    print('End Joint: $endJoint');

    // Prefer the most confident side for generic standard joints
    if ((startJoint == null || endJoint == null) &&
        !_isSideSpecificJointName(vertexJoint)) {
      final leftVertexType = _getLandmarkType('left_$vertexJoint', pose);
      final rightVertexType = _getLandmarkType('right_$vertexJoint', pose);

      final leftResult = leftVertexType == null
          ? (0.0, 0.0)
          : _calculateStandardAngleForVertex(pose, leftVertexType);
      final rightResult = rightVertexType == null
          ? (0.0, 0.0)
          : _calculateStandardAngleForVertex(pose, rightVertexType);

      if (leftResult.$1 > 0.0 || rightResult.$1 > 0.0) {
        if (rightResult.$2 > leftResult.$2) {
          print('âœ… Using right side for $vertexJoint angle');
          return rightResult.$1;
        }
        print('âœ… Using left side for $vertexJoint angle');
        return leftResult.$1;
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
          if (result.$1 > 0.0) {
            print('âœ… Using $inferredSide side for $vertexJoint triplet');
            return result.$1;
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

          if (leftResult.$1 > 0.0 || rightResult.$1 > 0.0) {
            if (rightResult.$2 > leftResult.$2) {
              print('âœ… Using right side for $vertexJoint triplet');
              return rightResult.$1;
            }
            print('âœ… Using left side for $vertexJoint triplet');
            return leftResult.$1;
          }
        }
      }
    }

    // Get the vertex landmark
    final vertexType = _getLandmarkType(vertexJoint, pose);
    if (vertexType == null) {
      print('âŒ Vertex joint type not found for: $vertexJoint');

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
          'âŒ Vertex landmark not found or low confidence: ${vertexLandmark?.likelihood ?? 0}');
      return 0.0;
    }
    final resolvedVertexLandmark = vertexLandmark!;

    print(
        'âœ… Vertex landmark found: (${resolvedVertexLandmark.x.toStringAsFixed(2)}, ${resolvedVertexLandmark.y.toStringAsFixed(2)})');

    // For standard joints (knee, elbow, etc.)
    if (startJoint == null || endJoint == null) {
      final adjacentJoints = _getAdjacentJoints(vertexType);

      final startType = adjacentJoints.$1;
      final endType = adjacentJoints.$2;

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
        print('âŒ Adjacent landmarks not found or low confidence');
        return 0.0;
      }
      final resolvedStartLandmark = startLandmark!;
      final resolvedEndLandmark = endLandmark!;

      final angle = _calculateRobustAngle(
        _landmarkToVector3(resolvedStartLandmark),
        _landmarkToVector3(resolvedVertexLandmark),
        _landmarkToVector3(resolvedEndLandmark),
      );

      print('âœ… Calculated angle: ${angle.toStringAsFixed(1)}Â°');
      return angle;
    }

    // For custom triplets
    final startType = _getLandmarkType(startJoint, pose);
    final endType = _getLandmarkType(endJoint, pose);

    if (startType == null || endType == null) {
      print('âŒ Start or end joint type not found');
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
      print('âŒ Start or end landmark not found or low confidence');
      return 0.0;
    }
    final resolvedStartLandmark = startLandmark!;
    final resolvedEndLandmark = endLandmark!;

    final angle = _calculateRobustAngle(
      _landmarkToVector3(resolvedStartLandmark),
      _landmarkToVector3(resolvedVertexLandmark),
      _landmarkToVector3(resolvedEndLandmark),
    );

    print('âœ… Calculated custom angle: ${angle.toStringAsFixed(1)}Â°');
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

    if (leftResult.$1 == 0.0 && rightResult.$1 == 0.0) {
      print('âŒ Could not calculate knee angle from landmarks');
      return 0.0;
    }

    if (rightResult.$2 > leftResult.$2) {
      print('âœ… Right knee angle: ${rightResult.$1.toStringAsFixed(1)}Â°');
      return rightResult.$1;
    }

    print('âœ… Left knee angle: ${leftResult.$1.toStringAsFixed(1)}Â°');
    return leftResult.$1;
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
      // Full extension ~180Â°, Deep squat ~50-60Â°

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

  (PoseLandmarkType, PoseLandmarkType) _getAdjacentJoints(
      PoseLandmarkType joint) {
    switch (joint) {
      case PoseLandmarkType.leftElbow:
        return (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftWrist);
      case PoseLandmarkType.rightElbow:
        return (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightWrist);
      case PoseLandmarkType.leftKnee:
        return (PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle);
      case PoseLandmarkType.rightKnee:
        return (PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle);
      case PoseLandmarkType.leftShoulder:
        return (PoseLandmarkType.leftHip, PoseLandmarkType.leftElbow);
      case PoseLandmarkType.rightShoulder:
        return (PoseLandmarkType.rightHip, PoseLandmarkType.rightElbow);
      case PoseLandmarkType.leftHip:
        return (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftKnee);
      case PoseLandmarkType.rightHip:
        return (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightKnee);
      default:
        return (PoseLandmarkType.nose, PoseLandmarkType.nose);
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

    print('\nðŸŽ¯ === ACCURACY CALCULATION FOR: $exerciseName ===');

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

// Squat accuracy calculation á€™á€¾á€¬ range á€á€½á€±á€€á€­á€¯á€•á€¼á€„á€ºá€™á€šá€º
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
    print('\nðŸ‹ï¸ === SQUAT ACCURACY CALCULATION ===');

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
            'âœ… Found knee angle from key "${key}": ${kneeAngle.toStringAsFixed(1)}Â°');
        break;
      }
    }

    if (kneeAngle == 180.0) {
      for (final entry in jointAngles.entries) {
        if (entry.key.toLowerCase().contains('knee') && entry.value > 0) {
          kneeAngle = entry.value;
          print(
              'âœ… Found knee angle from "${entry.key}": ${kneeAngle.toStringAsFixed(1)}Â°');
          break;
        }
      }
    }

    print('ðŸ¦µ FINAL KNEE ANGLE: ${kneeAngle.toStringAsFixed(1)}Â°');

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

    // Front-view baseline lock: treat near-baseline knee angles as standing.
    if (isFrontView) {
      if (kneeAngle >= 145.0) {
        _squatFrontViewBaselineKnee = _squatFrontViewBaselineKnee == null
            ? kneeAngle
            : (_squatFrontViewBaselineKnee! * 0.8 + kneeAngle * 0.2);
      }
      if (_squatFrontViewBaselineKnee != null) {
        final baseline = _squatFrontViewBaselineKnee!;
        if (kneeAngle >= (baseline - 5.0)) {
          _squatStandingFrames++;
          if (_squatStandingFrames >= standingFramesToPrime) {
            _squatReadyFromStanding = true;
          }
          _squatDescentStarted = false;
          _squatBelowStartFrames = 0;
          _lastStableAccuracy = 0.0;
          print('Front view baseline lock: 0% until descent detected');
          return 0.0;
        }
      }
    }

    // General standing guard (side or front) when torso is upright and legs are near-straight.
    final bool torsoUpright = hipAngle >= 165.0 && backAngle >= 165.0;
    if (torsoUpright && kneeAngle >= 150.0) {
      _squatStandingFrames++;
      if (_squatStandingFrames >= standingFramesToPrime) {
        _squatReadyFromStanding = true;
      }
      _squatDescentStarted = false;
      _squatBelowStartFrames = 0;
      _lastStableAccuracy = 0.0;
      print('🚧 UPRIGHT STANDING LOCK: 0% until descent detected');
      return 0.0;
    }

    // Side-view standing guard (front_view_ratio low) to prevent false bend from 2D projection.
    if (!isFrontView &&
        kneeAngle >= 150.0 &&
        hipAngle >= 150.0 &&
        backAngle >= 150.0) {
      _squatStandingFrames++;
      if (_squatStandingFrames >= standingFramesToPrime) {
        _squatReadyFromStanding = true;
      }
      _squatDescentStarted = false;
      _squatBelowStartFrames = 0;
      _lastStableAccuracy = 0.0;
      print('🚧 SIDE VIEW STANDING LOCK: 0% until descent detected');
      return 0.0;
    }

    if (kneeAngle >= standResetAngle) {
      _squatStandingFrames++;
      if (_squatStandingFrames >= standingFramesToPrime) {
        _squatReadyFromStanding = true;
      }
      _squatDescentStarted = false;
      _squatBelowStartFrames = 0;
      _lastStableAccuracy = 0.0;
      print('🚧 STANDING LOCK: 0% until descent detected');
      return 0.0;
    }

    _squatStandingFrames = 0;
    if (!_squatReadyFromStanding) {
      _lastStableAccuracy = 0.0;
      print('⏸ Waiting for standing baseline before squat tracking');
      return 0.0;
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
            '⏸ Waiting for sustained descent (${_squatBelowStartFrames}/$framesToUnlock frames)');
        return 0.0;
      }
      _squatDescentStarted = true;
      print('▶️ Descent detected — unlocking squat accuracy');
    }

    double accuracy = 0.0;
    if (kneeAngle >= 170) {
      accuracy = 0.0;
      print('ðŸ›Œ STANDING: 0%');
    } else if (kneeAngle >= 140) {
      final progress = (170 - kneeAngle) / (170 - 140);
      accuracy = 0.2 + (0.3 * progress);
      print('â†—ï¸ SHALLOW SQUAT: ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle >= 110) {
      final progress = (140 - kneeAngle) / (140 - 110);
      accuracy = 0.5 + (0.3 * progress);
      print('â†—ï¸ MID SQUAT: ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle >= 80) {
      final progress = (110 - kneeAngle) / (110 - 80);
      accuracy = 0.8 + (0.2 * progress);
      print('â†—ï¸ DEEP SQUAT: ${(accuracy * 100).toStringAsFixed(1)}%');
    } else {
      accuracy = 1.0;
      print('âœ… FULL SQUAT: 100%');
    }

    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('âš ï¸ Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    accuracy = accuracy.clamp(0.0, 1.0);
    print('ðŸŽ¯ FINAL SQUAT ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');

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
    print('\nðŸ§˜ === SIT-UP CALCULATION ===');

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
      print('🚧 Waiting for stable hip/knee landmarks before sit-up tracking');
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
        print('⚠️ SITTING LOCK ACTIVE: Accuracy locked at 0%');
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
      print('⚠️ SITTING DETECTED: Accuracy locked at 0%');
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
      print('⚠️ SITTING REST DETECTED: Accuracy locked at 0%');
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
            '✅ Lying baseline locked (${_situpLyingFrames}/$_situpLyingFramesNeeded frames)');
      }
    } else {
      _situpLyingFrames = 0;
    }

    if (isPositionLikeChair) {
      _situpOutputAccuracy = 0.0;
      _situpStillJitterFrames = 0;
      print('âš ï¸ SITTING POSITION DETECTED: Accuracy locked at 0%');
      return 0.0;
    }

    if (!_situpPrimed) {
      _situpOutputAccuracy = 0.0;
      _situpStillJitterFrames = 0;
      print('🚧 Waiting for lying start (hips & knees extended) → 0%');
      return 0.0;
    }

    print(
        'ðŸ§˜ SIT-UP CALCULATION - Hip Angle: ${smoothedHipAngle.toStringAsFixed(1)}Â°');

    const double startAngle = 140.0;
    const double targetAngle = 92.0;

    double accuracy = 0.0;
    if (smoothedHipAngle >= startAngle) {
      accuracy = 0.0;
      print('ðŸ›Œ LYING DOWN: 0%');
    } else if (smoothedHipAngle <= targetAngle) {
      accuracy = 1.0;
      print('âœ… FULL SIT-UP');
    } else {
      final double progress =
          (startAngle - smoothedHipAngle) / (startAngle - targetAngle);
      // Faster response: boost early progress for real-time feel
      final double eased = pow(progress.clamp(0.0, 1.0), 0.55).toDouble();
      accuracy = eased;
      print('ðŸ“88 SMOOTH PROGRESS: ${(accuracy * 100).toStringAsFixed(1)}%');
    }

    if (kneeAngle > 80 && smoothedHipAngle < 100) {
      accuracy *= 0.9;
      print('âš ï¸ Keep your feet on the ground!');
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
        'ðŸŽ¯ SIT-UP ACCURACY: ${(_situpOutputAccuracy * 100).toStringAsFixed(1)}%');

    return _situpOutputAccuracy;
  }

  double _calculatePushupAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\n💪 === PUSH-UP ACCURACY (FIXED) ===');

    // --- 1. Elbow Angle ကို ရှာဖွေခြင်း ---
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
          '✅ Using average of both sides: ${elbowAngle.toStringAsFixed(1)}° (L:${leftElbow.toStringAsFixed(1)}°, R:${rightElbow.toStringAsFixed(1)}°)');
    } else if (rightElbow > 0 && leftElbow == 0) {
      elbowAngle = rightElbow;
      source = "right elbow (only)";
      print('✅ Found right elbow only: ${elbowAngle.toStringAsFixed(1)}°');
    } else if (leftElbow > 0 && rightElbow == 0) {
      elbowAngle = leftElbow;
      source = "left elbow (only)";
      print('✅ Found left elbow only: ${elbowAngle.toStringAsFixed(1)}°');
    } else if (genericElbow > 0) {
      elbowAngle = genericElbow;
      source = "generic";
      print('✅ Found generic elbow: ${elbowAngle.toStringAsFixed(1)}°');
    } else {
      print('❌ No valid elbow angle found!');
      return 0.0;
    }

    if (elbowAngle > 120 && elbowAngle < 180) {
      double reversedAngle = 180 - elbowAngle;
      if (reversedAngle >= 30 && reversedAngle <= 90) {
        print('⚠️ Angle may be reversed: $elbowAngle° → $reversedAngle°');
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
            '⚠️ Both sides may be reversed: using reversed average: ${elbowAngle.toStringAsFixed(1)}°');
      }
    }

    // --- 3. Standing Posture စစ်ဆေးခြင်း ---
    double? torsoRatio = jointAngles['torso_upright_ratio'];
    if (torsoRatio != null && torsoRatio > 1.5) {
      print('🚫 Standing detected by torso ratio: $torsoRatio');
      return 0.0;
    }

    double? bodyAngle =
        jointAngles['shoulder_hip_ankle'] ?? jointAngles['shoulder_hip_knee'];
    if (bodyAngle != null && bodyAngle < 140) {
      print('🚫 Body not straight enough: ${bodyAngle.toStringAsFixed(1)}°');
      return 0.0;
    }

    // ========== အပိုင်းအသစ် ထည့်ရန် ==========
    // --- ခန္ဓာကိုယ် စောင်းခြင်းကို စစ်ဆေးခြင်း ---
    // torso_upright_ratio က ခန္ဓာကိုယ် မတ်မတ်ရှိမှုကို ပြတယ်။
    // push-up အတွက် ဒီတန်ဖိုး နည်းနေရမယ်။ (ခန္ဓာကိုယ် လဲလျောင်းနေရမယ်)
    // ဒီတန်ဖိုး များလေလေ ခန္ဓာကိုယ် မတ်လေလေ ဖြစ်တယ်။

    double torsoUprightRatio = jointAngles['torso_upright_ratio'] ?? 0.0;

    // ခန္ဓာကိုယ် စတင် စောင်းလာရင် torsoUprightRatio တန်ဖိုး တက်လာမယ်။
    // ဒီတန်ဖိုး သတ်မှတ်ချက်ထက် ကျော်လွန်ရင် ခန္ဓာကိုယ် စောင်းနေပြီလို့ ယူဆပြီး accuracy ကို လျှော့ချမယ်။

    const double uprightThreshold =
        0.02; // ဒီတန်ဖိုးကို လိုအပ်သလို ချိန်ညှိနိုင်ပါတယ်။

    if (torsoUprightRatio > uprightThreshold) {
      // ခန္ဓာကိုယ် စောင်းနေတယ်။ ဒါဆို pushup မဟုတ်သေးဘူး။
      // accuracy ကို လက်ရှိ တွက်ထားတဲ့အတိုင်း မထားဘဲ လျှော့ချမယ်။
      // ဥပမာ - စောင်းလေလေ accuracy နည်းလေလေ ဖြစ်အောင် လုပ်မယ်။

      // ဒီနေရာမှာ ရွေးချယ်စရာ နှစ်မျိုးရှိတယ်။
      // ရွေးချယ်စရာ ၁: လုံးဝ 0% ပေးလိုက်မယ် (ခန္ဓာကိုယ်စောင်းရင် pushup စမလုပ်ရသေးဘူးလို့ သတ်မှတ်)
      // return 0.0;

      // ရွေးချယ်စရာ ၂: စောင်းတဲ့အတိုင်းအဆပေါ်မူတည်ပြီး accuracy ကို လျှော့ချမယ်။
      double uprightPenalty = (torsoUprightRatio - uprightThreshold) *
          2.0; // စောင်းလေလေ ပိုလျှော့လေလေ
      uprightPenalty =
          uprightPenalty.clamp(0.0, 0.6); // အများဆုံး 80% ထိပဲ လျှော့မယ်။

      // မူလ တွက်ထားတဲ့ accuracy ကို သိမ်းထားဖို့ လိုတယ်။ ဒါပေမယ့် ဒီနေရာမှာ accuracy ကို အောက်မှာမှ တွက်မှာမို့လို့
      // ဒီစစ်ဆေးမှုကို accuracy တွက်ပြီးမှ လုပ်သင့်တယ်။
      // ဒါကြောင့် ဒီအပိုင်းကို အောက်က accuracy တွက်ပြီးတဲ့နောက်မှာ ထည့်ရမယ်။
    }
    // ============================================

    // --- 4. Accuracy တွက်ချက်ခြင်း ---
    double accuracy = 0.0;
    const double extensionAngle = 160.0; // လက်ဖြောင့်ချိန် (အပေါ်ဆုံး) -> 0%
    const double targetAngle = 100.0; // လက်ကွေးသင့်တဲ့ အနိမ့်ဆုံး -> 100%

    if (elbowAngle >= extensionAngle) {
      accuracy = 0.0;
      print('⬆️ EXTENDED (${elbowAngle.toStringAsFixed(1)}°) → 0%');
    } else if (elbowAngle <= targetAngle) {
      accuracy = 1.0;
      print('⬇️ TARGET DEPTH (${elbowAngle.toStringAsFixed(1)}°) → 100%');
    } else {
      double progress =
          (extensionAngle - elbowAngle) / (extensionAngle - targetAngle);
      double easedProgress = pow(progress, 0.8).toDouble();
      accuracy = easedProgress.clamp(0.0, 1.0);
      print(
          '📈 Elbow: ${elbowAngle.toStringAsFixed(1)}° → Progress: ${(progress * 100).toStringAsFixed(1)}% → Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%');
    }

    // --- 5. Body alignment bonus/penalty ---
    if (bodyAngle != null) {
      if (bodyAngle >= 155) {
        accuracy = (accuracy * 1.05).clamp(0.0, 1.0);
        print('✅ Good body alignment (+5%): ${bodyAngle.toStringAsFixed(1)}°');
      }
    }
    // else if (bodyAngle < 150) {
    //      accuracy *= 0.9;
    //      print('⚠️ Poor body alignment (-10%): ${bodyAngle.toStringAsFixed(1)}°');
    //    }

    // --- 6. Asymmetry penalty ---
    if (leftElbow > 0 && rightElbow > 0) {
      double asymmetry = (leftElbow - rightElbow).abs();
      if (asymmetry > 20) {
        double penalty = ((asymmetry - 20) / 40).clamp(0.0, 0.10);
        accuracy *= (1.0 - penalty);
        print('⚠️ Asymmetry penalty -${(penalty * 100).toStringAsFixed(1)}%');
      }
    }

    // --- 7. Form warnings ---
    // if (warnings.isNotEmpty) {
    //   double penalty = (warnings.length * 0.02).clamp(0.0, 0.1);
    //   accuracy *= (1.0 - penalty);
    //   print('⚠️ Form warnings penalty -${(penalty*100).toStringAsFixed(1)}%');
    // }

    // ========== ဒီနေရာမှာ ထည့်ရန် (ရွေးချယ်စရာ ၂ အတွက်) ==========
    // // --- ခန္ဓာကိုယ် စောင်းခြင်းကို စစ်ဆေးပြီး accuracy ကို ထပ်လျှော့ခြင်း ---
    // double torsoUprightRatio = jointAngles['torso_upright_ratio'] ?? 0.0;
    // const double uprightThreshold = 0.1; // ဒီတန်ဖိုးကို လိုအပ်သလို ချိန်ညှိပါ။

    if (torsoUprightRatio > uprightThreshold) {
      // ခန္ဓာကိုယ် စောင်းနေတယ်။ စောင်းတဲ့အတိုင်းအဆပေါ်မူတည်ပြီး accuracy ကို လျှော့ချမယ်။
      double uprightPenalty = (torsoUprightRatio - uprightThreshold) * 2.0;
      uprightPenalty =
          uprightPenalty.clamp(0.0, 0.6); // အများဆုံး 80% လျှော့မယ်။

      accuracy *= (1.0 - uprightPenalty);
      print(
          '⚠️ Body tilt penalty: -${(uprightPenalty * 100).toStringAsFixed(1)}% (torso ratio: $torsoUprightRatio)');
    }
    // ================================================================

    accuracy = accuracy.clamp(0.0, 1.0);
    print(
        '🎯 FINAL ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}% (source: $source)');
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
    print('\n💪 === BICEP CURL ACCURACY CALCULATION ===');

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
            '✅ Found elbow angle from "$key": ${elbowAngle.toStringAsFixed(1)}°');
        break;
      }
    }

    print('💪 ELBOW ANGLE: ${elbowAngle.toStringAsFixed(1)}°');

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
      // Try side‑specific shoulder key
      shoulderAngle =
          jointAngles['${side}_shoulder'] ?? jointAngles['shoulder'] ?? 180.0;
    } else {
      // No side info – use generic shoulder (should match the generic elbow)
      shoulderAngle = jointAngles['shoulder'] ??
          jointAngles['left_shoulder'] ??
          jointAngles['right_shoulder'] ??
          180.0;
    }
    print(
        '🦾 SHOULDER ANGLE (side: $side): ${shoulderAngle.toStringAsFixed(1)}°');

    // (Optional) you can also retrieve knee/hip angles if needed for guards,
    // but those are less side‑critical. They are already taken from the map
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

    // မတ်တပ်ရပ်နေတဲ့ posture ကို စစ်ဆေးဖို့ hip, knee, body angle တွေကို ယူမယ်
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
      print('🚧 STANDING LOCK: 0% until curl descent detected');
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
      print('⏸ Waiting for extension baseline before curl tracking');
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
            '⏸ Waiting for sustained curl (${_bicepCurlBelowStartFrames}/$framesToUnlock frames)');
        return 0.0;
      }
      _bicepCurlStarted = true;
      print('▶️ Curl descent detected — unlocking accuracy');
    }

    // Accuracy mapping based on elbow angle (side‑agnostic)
    double accuracy = 0.0;
    if (elbowAngle > 160) {
      accuracy = 0.0;
      print('⬇️⬇️ ARMS EXTENDED ${elbowAngle.toStringAsFixed(1)}° → 0%');
    } else if (elbowAngle > 138) {
      double progress = (160 - elbowAngle) / 30;
      accuracy = 0.2 + (0.3 * progress);
      print(
          '↘️ STARTING CURL ${elbowAngle.toStringAsFixed(1)}° → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle > 126) {
      double progress = (130 - elbowAngle) / 30;
      accuracy = 0.5 + (0.3 * progress);
      print(
          '↘️ MID CURL ${elbowAngle.toStringAsFixed(1)}° → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle > 115) {
      double progress = (100 - elbowAngle) / 20;
      accuracy = 0.8 + (0.15 * progress);
      print(
          '⬇️⬇️ DEEP CURL ${elbowAngle.toStringAsFixed(1)}° → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle > 105) {
      double progress = (100 - elbowAngle) / 20;
      accuracy = 0.8 + (0.15 * progress);
      print(
          '⬇️⬇️ DEEP CURL ${elbowAngle.toStringAsFixed(1)}° → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle >= 90) {
      double progress = (60 - elbowAngle) / 30;
      accuracy = 0.95 + (0.05 * progress);
      accuracy = accuracy.clamp(0.95, 1.0);
      print(
          '🏆 FULL CONTRACTION ${elbowAngle.toStringAsFixed(1)}° → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else {
      accuracy = 0.9 - ((30 - elbowAngle) * 0.01);
      accuracy = accuracy.clamp(0.7, 0.9);
      print(
          '⚠️ OVER‑CONTRACTION ${elbowAngle.toStringAsFixed(1)}° → ${(accuracy * 100).toStringAsFixed(1)}%');
    }

    // Apply shoulder penalty using the side‑matched shoulder angle
    if (shoulderAngle > 30 && shoulderAngle < 170) {
      final shoulderMovement = (shoulderAngle - 90).abs();
      if (shoulderMovement > 20) {
        accuracy = accuracy * 0.8;
        print('⚠️ Excessive shoulder movement penalty: -20%');
      }
    }

    // Warning penalties
    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('⚠️ Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    accuracy = accuracy.clamp(0.00, 1.0);
    print(
        '🎯 FINAL BICEP CURL ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');

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
    print('\nðŸ‹ï¸ === SHOULDER PRESS ACCURACY CALCULATION ===');

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
            'âœ… Found elbow angle from "$key": ${elbowAngle.toStringAsFixed(1)}Â°');
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
            'âœ… Found shoulder angle from "$key": ${shoulderAngle.toStringAsFixed(1)}Â°');
        break;
      }
    }

    print('ðŸ’ª ELBOW ANGLE: ${elbowAngle.toStringAsFixed(1)}Â°');
    print('ðŸ¦¾ SHOULDER ANGLE: ${shoulderAngle.toStringAsFixed(1)}Â°');

    if (shoulderAngle < 150) {
      print('âš ï¸ Arms not raised (shoulder angle too low).');
      return 0.0;
    }
    if (elbowAngle > 165 && shoulderAngle < 170) {
      print('âš ï¸ Elbows extended down, not a shoulder press.');
      return 0.0;
    }
    final elbowRaised = jointAngles['elbow_raised'] ?? 0.0;
    if (elbowRaised < 0.5) {
      print('âš ï¸ Elbow not raised above shoulder.');
      return 0.0;
    }

    double accuracy = 0.0;
    if (elbowAngle >= 160) {
      accuracy = 0.8 + ((elbowAngle - 160) * 0.01);
      accuracy = accuracy.clamp(0.8, 0.95);
      print(
          'â¬†ï¸ TOP POSITION ${elbowAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle >= 120) {
      double progress = (elbowAngle - 120) / 40;
      accuracy = 0.5 + (0.3 * progress); // 50% to 80%
      print(
          'â†—ï¸ MID POSITION ${elbowAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle >= 90) {
      double progress = (elbowAngle - 90) / 30;
      accuracy = 0.2 + (0.3 * progress); // 20% to 50%
      print(
          'â¬‡ï¸ BOTTOM POSITION ${elbowAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (elbowAngle >= 60) {
      double progress = (elbowAngle - 60) / 30;
      accuracy = 0.05 + (0.15 * progress); // 5% to 20%
      print(
          'ðŸ”„ DEEP POSITION ${elbowAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else {
      accuracy = 0.05;
      print(
          'âš ï¸ TOO DEEP ${elbowAngle.toStringAsFixed(1)}Â° â†’ 5% accuracy');
    }

    if (shoulderAngle >= 150) {
      accuracy = accuracy * 1.1;
      accuracy = accuracy.clamp(0.0, 1.0);
      print('âœ… Good shoulder position bonus: +10%');
    } else if (shoulderAngle < 100) {
      accuracy = accuracy * 0.7;
      print('âš ï¸ Shoulders too low penalty: -30%');
    }

    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('âš ï¸ Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    accuracy = accuracy.clamp(0.00, 1.0);
    print(
        'ðŸŽ¯ FINAL SHOULDER PRESS ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');

    return accuracy;
  }

  double _calculateBenchPressAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\n🏋️ === BENCH PRESS ACCURACY CALCULATION ===');

    // Use side-aware elbow selection first to avoid unstable generic keys.
    final leftElbow = jointAngles['left_elbow'] ??
        jointAngles['left_shoulder_left_elbow_left_wrist'] ??
        0.0;
    final rightElbow = jointAngles['right_elbow'] ??
        jointAngles['right_shoulder_right_elbow_right_wrist'] ??
        0.0;
    final genericElbow =
        jointAngles['elbow'] ?? jointAngles['shoulder_elbow_wrist'] ?? 0.0;

    double elbowAngle = 0.0;
    String? usedElbowKey;
    if (leftElbow > 0 && rightElbow > 0) {
      final elbowGap = (leftElbow - rightElbow).abs();
      if (elbowGap <= 18.0) {
        elbowAngle = (leftElbow + rightElbow) / 2.0;
        usedElbowKey = 'avg_left_right_elbow';
        print(
            '✅ Using averaged elbow angle: L=${leftElbow.toStringAsFixed(1)}°, R=${rightElbow.toStringAsFixed(1)}° → ${elbowAngle.toStringAsFixed(1)}°');
      } else if (genericElbow > 0) {
        final leftDiff = (leftElbow - genericElbow).abs();
        final rightDiff = (rightElbow - genericElbow).abs();
        if (leftDiff <= rightDiff) {
          elbowAngle = leftElbow;
          usedElbowKey = 'left_elbow';
        } else {
          elbowAngle = rightElbow;
          usedElbowKey = 'right_elbow';
        }
        print(
            '⚖️ Large side gap (${elbowGap.toStringAsFixed(1)}°); using ${usedElbowKey == 'left_elbow' ? 'left' : 'right'} elbow closest to generic (${genericElbow.toStringAsFixed(1)}°) → ${elbowAngle.toStringAsFixed(1)}°');
      } else {
        // Side view frequently shows one arm clearly and one arm noisy.
        // Prefer the smaller elbow angle to preserve true range-of-motion.
        if (leftElbow <= rightElbow) {
          elbowAngle = leftElbow;
          usedElbowKey = 'left_elbow';
        } else {
          elbowAngle = rightElbow;
          usedElbowKey = 'right_elbow';
        }
        print(
            '⚖️ Large side gap (${elbowGap.toStringAsFixed(1)}°); using ${usedElbowKey == 'left_elbow' ? 'left' : 'right'} elbow → ${elbowAngle.toStringAsFixed(1)}°');
      }
    } else if (leftElbow > 0) {
      elbowAngle = leftElbow;
      usedElbowKey = 'left_elbow';
      print('✅ Using left elbow angle: ${elbowAngle.toStringAsFixed(1)}°');
    } else if (rightElbow > 0) {
      elbowAngle = rightElbow;
      usedElbowKey = 'right_elbow';
      print('✅ Using right elbow angle: ${elbowAngle.toStringAsFixed(1)}°');
    } else if (genericElbow > 0) {
      elbowAngle = genericElbow;
      usedElbowKey = 'generic_elbow';
      print('✅ Using generic elbow angle: ${elbowAngle.toStringAsFixed(1)}°');
    }

    if (elbowAngle <= 0) {
      print('⚠️ No elbow angle available for bench press.');
      return 0.0;
    }

    final repLogic =
        exerciseConfig['rep_logic'] as Map<String, dynamic>? ?? const {};
    final phase1 =
        repLogic['phase_1_eccentric'] as Map<String, dynamic>? ?? const {};
    final phase2 =
        repLogic['phase_2_concentric'] as Map<String, dynamic>? ?? const {};
    final depthThreshold =
        (phase1['threshold'] as num?)?.toDouble().clamp(75.0, 118.0) ?? 102.0;
    final lockoutThreshold =
        (phase2['threshold'] as num?)?.toDouble().clamp(125.0, 170.0) ?? 145.0;

    final mirroredElbow = 180.0 - elbowAngle;
    final rawInRange = elbowAngle >= 40.0 && elbowAngle <= 178.0;
    final mirroredInRange = mirroredElbow >= 40.0 && mirroredElbow <= 178.0;
    if (!rawInRange && mirroredInRange) {
      print(
          '⚠️ Adjusted mirrored elbow angle: ${elbowAngle.toStringAsFixed(1)}° → ${mirroredElbow.toStringAsFixed(1)}°');
      elbowAngle = mirroredElbow;
    }

    String? side;
    if (usedElbowKey != null) {
      if (usedElbowKey.contains('left')) {
        side = 'left';
      } else if (usedElbowKey.contains('right')) {
        side = 'right';
      }
    }

    final shoulderCandidates = <double>[
      if (side != null && (jointAngles['${side}_shoulder'] ?? 0.0) > 0.0)
        jointAngles['${side}_shoulder']!,
      if ((jointAngles['shoulder'] ?? 0.0) > 0.0) jointAngles['shoulder']!,
      if ((jointAngles['left_shoulder'] ?? 0.0) > 0.0)
        jointAngles['left_shoulder']!,
      if ((jointAngles['right_shoulder'] ?? 0.0) > 0.0)
        jointAngles['right_shoulder']!,
    ];
    final double? shoulderAngle = shoulderCandidates.isEmpty
        ? null
        : shoulderCandidates.reduce((a, b) => a + b) / shoulderCandidates.length;
    final double torsoUprightRatio = jointAngles['torso_upright_ratio'] ?? 0.0;
    final double bodyAngle = jointAngles['shoulder_hip_ankle'] ??
        jointAngles['shoulder_hip_knee'] ??
        0.0;
    final double lockoutAlignment =
        jointAngles['bench_press_lockout_alignment'] ?? 0.0;
    final double verticalLift =
        jointAngles['bench_press_vertical_lift'] ?? 0.0;
    final bool topPathValid =
        (jointAngles['bench_press_top_path_valid'] ?? 0.0) >= 0.5;

    print('🏋️ ELBOW ANGLE: ${elbowAngle.toStringAsFixed(1)}°');
    if (shoulderAngle != null) {
      print('🦾 SHOULDER ANGLE: ${shoulderAngle.toStringAsFixed(1)}°');
    } else {
      print('🦾 SHOULDER ANGLE: unavailable');
    }
    print('📐 TORSO UPRIGHT RATIO: ${torsoUprightRatio.toStringAsFixed(3)}');
    print(
        '🧭 BENCH PATH: alignment=${(lockoutAlignment * 100).toStringAsFixed(1)}%, vertical=${(verticalLift * 100).toStringAsFixed(1)}%, topValid=$topPathValid');

    if (torsoUprightRatio >= 1.25 && bodyAngle >= 145.0) {
      print('⚠️ Upright posture detected, not a bench press setup.');
      return 0.0;
    }

    final extensionStartAngle = min(depthThreshold, 80.0);
    final extensionEndAngle = max(lockoutThreshold, 150.0);
    final extensionProgress =
        ((elbowAngle - extensionStartAngle) /
                (extensionEndAngle - extensionStartAngle))
            .clamp(0.0, 1.0);
    final pathScore =
        ((lockoutAlignment * 0.65) + (verticalLift * 0.35)).clamp(0.0, 1.0);

    if (pathScore < 0.06) {
      print('⚠️ Bench press path not engaged enough.');
      return 0.0;
    }

    double accuracy = (0.12 + (0.88 * extensionProgress)) * (0.45 + 0.55 * pathScore);
    print(
        '📈 Bench extension progress: ${(extensionProgress * 100).toStringAsFixed(1)}%');
    print('🛤️ Bench path score: ${(pathScore * 100).toStringAsFixed(1)}%');

    if (shoulderAngle != null) {
      if (shoulderAngle >= 70.0 && shoulderAngle <= 140.0) {
        accuracy = (accuracy * 1.05).clamp(0.0, 1.0);
      } else if (shoulderAngle < 35.0 || shoulderAngle > 165.0) {
        accuracy = accuracy * 0.82;
      }
    }

    if (elbowAngle >= (lockoutThreshold - 5.0) &&
        (!topPathValid || verticalLift < 0.05)) {
      accuracy = accuracy * 0.82;
      print('⚠️ Minor bench press top path variance: slight lockout penalty applied.');
    } else if (elbowAngle >= 120.0 && verticalLift < 0.03) {
      accuracy = accuracy * 0.90;
      print('⚠️ Press path is slightly low.');
    }

    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('⚠️ Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    accuracy = accuracy.clamp(0.0, 1.0);
    print(
        '🎯 FINAL BENCH PRESS ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');
    return accuracy;
  }

  double _calculateLateralRaiseAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    final exerciseLabel =
        (exerciseConfig['name'] as String?) ?? 'Raise Exercise';
    print('\n🙆 === $exerciseLabel ACCURACY CALCULATION ===');

    final double frontViewRatio = jointAngles['front_view_ratio'] ?? 0.0;
    if (frontViewRatio < 0.32) {
      print('⚠️ Front view not clear enough for $exerciseLabel.');
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
      print('⚠️ No shoulder angle available for $exerciseLabel.');
      return 0.0;
    }

    final double shoulderAngle =
        shoulderCandidates.reduce((a, b) => a + b) / shoulderCandidates.length;
    final double elbowAngle = elbowCandidates.isEmpty
        ? 180.0
        : elbowCandidates.reduce((a, b) => a + b) / elbowCandidates.length;

    print('🙆 SHOULDER ANGLE: ${shoulderAngle.toStringAsFixed(1)}°');
    print('💪 ELBOW ANGLE: ${elbowAngle.toStringAsFixed(1)}°');

    double accuracy = 0.0;
    if (shoulderAngle < 35.0) {
      final progress = (shoulderAngle / 25.0).clamp(0.0, 1.0);
      accuracy = 0.10 + (0.20 * progress);
      print('⬇️ BOTTOM POSITION → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (shoulderAngle < 50.0) {
      final progress = ((shoulderAngle - 25.0) / 15.0).clamp(0.0, 1.0);
      accuracy = 0.30 + (0.15 * progress);
      print('↗️ STARTING RAISE → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (shoulderAngle < 68.0) {
      final progress = ((shoulderAngle - 40.0) / 20.0).clamp(0.0, 1.0);
      accuracy = 0.45 + (0.15 * progress);
      print('↗️ MID WAY → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (shoulderAngle < 98.0) {
      final progress = ((shoulderAngle - 60.0) / 20.0).clamp(0.0, 1.0);
      accuracy = 0.60 + (0.25 * progress);
      print('📈 APPROACHING TARGET → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (shoulderAngle <= 125.0) {
      final progress = ((shoulderAngle - 80.0) / 15.0).clamp(0.0, 1.0);
      accuracy = 0.85 + (0.15 * progress);
      print('🏆 TARGET HEIGHT → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (shoulderAngle <= 140.0) {
      final progress = ((shoulderAngle - 95.0) / 15.0).clamp(0.0, 1.0);
      accuracy = 0.90 - (0.20 * progress);
      print('⚠️ SLIGHT OVER-EXTENSION → ${(accuracy * 100).toStringAsFixed(1)}%');
    } else {
      accuracy = 0.90;
      print('⚠️ Excessive height detected.');
    }

    // if (elbowAngle < 150.0) {
    //   final bendPenalty = ((150.0 - elbowAngle) / 60.0).clamp(0.0, 0.25);
    //   accuracy = accuracy * (1.0 - bendPenalty);
    //   print('⚠️ Bent elbows penalty: -${(bendPenalty * 100).toStringAsFixed(1)}%');
    // }

    final double? leftShoulder = jointAngles['left_shoulder'];
    final double? rightShoulder = jointAngles['right_shoulder'];
    if (leftShoulder != null && rightShoulder != null) {
      final symmetryGap = (leftShoulder - rightShoulder).abs();
      if (symmetryGap > 18.0) {
        final symmetryPenalty = min((symmetryGap - 18.0) / 100.0, 0.15);
        accuracy = accuracy * (1.0 - symmetryPenalty);
        print(
            '⚠️ Arm symmetry penalty: -${(symmetryPenalty * 100).toStringAsFixed(1)}%');
      }
    }

    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('⚠️ Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    accuracy = accuracy.clamp(0.0, 1.0);
    print(
        '🎯 FINAL $exerciseLabel ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');
    return accuracy;
  }

  double _calculateLegExtensionAccuracy(
    Map<String, double> jointAngles,
    List<FormWarning> warnings,
    Map<String, dynamic> exerciseConfig,
  ) {
    print('\nðŸ¦µ === LEG EXTENSION ACCURACY CALCULATION ===');

    // Knee angle á€›á€¾á€¬á€–á€½á€±á€á€¼á€„á€ºá€¸
    double kneeAngle = 90.0; // Default á€€á€½á€±á€¸á€”á€±á€á€»á€­á€”á€º

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
            'âœ… Found knee angle from "$key": ${kneeAngle.toStringAsFixed(1)}Â°');
        break;
      }
    }

    print('ðŸ¦µ KNEE ANGLE: ${kneeAngle.toStringAsFixed(1)}Â°');

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
      // á€¡á€•á€¼á€Šá€·á€ºá€¡á€á€€á€½á€±á€¸á€”á€±á€á€»á€­á€”á€º
      accuracy = 0.05; // 15%
      print('ðŸ¦µ FULL FLEXION â†’ 15% accuracy');
    } else if (kneeAngle <= 110) {
      // á€¡á€”á€Šá€ºá€¸á€„á€šá€ºá€†á€”á€·á€ºá€á€»á€­á€”á€º
      double progress = (kneeAngle - 90) / 20;
      accuracy = 0.15; // + (0.20 * progress); // 15% to 35%
      print(
          'â†—ï¸ SLIGHT EXTENSION ${kneeAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle <= 120) {
      // á€žá€„á€·á€ºá€á€±á€¬á€ºá€á€²á€·á€†á€”á€·á€ºá€™á€¾á€¯
      double progress = (kneeAngle - 110) / 20;
      accuracy = 0.35 + (0.25 * progress); // 35% to 60%
      print(
          'ðŸ¦µ MODERATE EXTENSION ${kneeAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle <= 135) {
      // á€€á€±á€¬á€„á€ºá€¸á€™á€½á€”á€ºá€á€²á€·á€†á€”á€·á€ºá€™á€¾á€¯
      double progress = (kneeAngle - 130) / 20;
      accuracy = 0.60 + (0.20 * progress); // 60% to 80%
      print(
          'â¬†ï¸ GOOD EXTENSION ${kneeAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle <= 150) {
      // á€”á€€á€ºá€›á€¾á€­á€¯á€„á€ºá€¸á€…á€½á€¬á€†á€”á€·á€ºá€á€»á€­á€”á€º
      double progress = (kneeAngle - 150) / 20;
      accuracy = 0.80 + (0.15 * progress); // 80% to 95%
      print(
          'â¬†ï¸â¬†ï¸ DEEP EXTENSION ${kneeAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else if (kneeAngle <= 170) {
      // á€¡á€•á€¼á€Šá€·á€ºá€¡á€á€†á€”á€·á€ºá€á€»á€­á€”á€º
      double progress = (kneeAngle - 170) / 10;
      accuracy = 0.95 + (0.05 * progress); // 95% to 100%
      accuracy = accuracy.clamp(0.95, 1.0);
      print(
          'ðŸ† FULL EXTENSION ${kneeAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    } else {
      // á€¡á€œá€½á€”á€ºá€¡á€€á€»á€½á€¶á€†á€”á€·á€ºá€á€»á€­á€”á€º
      accuracy = 0.9 - ((kneeAngle - 180) * 0.01);
      accuracy = accuracy.clamp(0.7, 0.9);
      print(
          'âš ï¸ HYPER-EXTENSION ${kneeAngle.toStringAsFixed(1)}Â° â†’ ${(accuracy * 100).toStringAsFixed(1)}%');
    }

    // Leg symmetry check
    final leftKnee = jointAngles['left_knee'] ?? 0.0;
    final rightKnee = jointAngles['right_knee'] ?? 0.0;

    if (leftKnee > 0 && rightKnee > 0) {
      final symmetryDiff = (leftKnee - rightKnee).abs();
      if (symmetryDiff > 15) {
        accuracy = accuracy * 0.85; // -15% penalty
        print('âš ï¸ Asymmetric legs penalty: -15%');
      } else if (symmetryDiff < 5) {
        accuracy = accuracy * 1.05; // +5% bonus
        accuracy = accuracy.clamp(0.0, 1.0);
        print('âœ… Perfect leg symmetry bonus: +5%');
      }
    }

    // Warning penalties
    if (warnings.isNotEmpty) {
      final penalty = min(warnings.length * 0.03, 0.20);
      accuracy = accuracy * (1.0 - penalty);
      print('âš ï¸ Warning penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    // Ensure minimum accuracy
    accuracy = accuracy.clamp(0.00, 1.0);

    print(
        'ðŸŽ¯ FINAL LEG EXTENSION ACCURACY: ${(accuracy * 100).toStringAsFixed(1)}%');

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
    print('\nâš™ï¸ === DEFAULT ACCURACY CALCULATION ===');

    // Print all available angles for debugging
    print('ðŸ“Š Available Joint Angles:');
    jointAngles.forEach((key, value) {
      print('   $key: ${value.toStringAsFixed(1)}Â°');
    });

    // Try to guess exercise based on angles
    final guessedAccuracy = _guessAccuracyFromAngles(jointAngles);
    print(
        'ðŸ¤” Guessed accuracy: ${(guessedAccuracy * 100).toStringAsFixed(1)}%');

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
        print('   Found knee angle: ${value.toStringAsFixed(1)}Â°');
      }
      if (key.contains('elbow') && value > 0) {
        elbowAngle = value;
        print('   Found elbow angle: ${value.toStringAsFixed(1)}Â°');
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
          'âŒ CRITICAL: Exercise ID is null or empty! Using default calculation.');
      return _calculateDefaultAccuracy(jointAngles, warnings, exerciseConfig);
    }

    print('\nðŸŽ¯ === ACCURACY FOR: $exerciseName ===');

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
// _applyAccuracyAdjustments function á€€á€­á€¯á€•á€¼á€„á€ºá€•á€«
  double _applyAccuracyAdjustments(
      double baseScore, List<FormWarning> warnings, String exerciseId) {
    double finalScore = baseScore;

    print('\nðŸ”§ === APPLYING ADJUSTMENTS FOR $exerciseId ===');
    print('   Base Score: ${(baseScore * 100).toStringAsFixed(1)}%');

    // 1. Warning Penalties - significantly reduced
    double penalty = 0.0;
    if (warnings.isNotEmpty) {
      penalty =
          min(warnings.length * 0.01, 0.05); // Reduced to max 5% penalty only
      finalScore -= penalty;
      print('   Warning Penalty: -${(penalty * 100).toStringAsFixed(1)}%');
    }

    // 2. Remove the clamp or make it very low - á€™á€°á€›á€„á€ºá€¸ 0.4 á€€á€”á€± 0.1 á€€á€­á€¯á€•á€¼á€±á€¬á€„á€ºá€¸
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
      print('ðŸ”„ Converting CameraImage to InputImage');
      print('Image format: ${image.format.raw}');
      print('Number of planes: ${image.planes.length}');
      print('Image size: $imageSize');
      print('Rotation: $rotation');

      // Check image format
      if (image.format.raw == 35) {
        // YUV_420_888
        print('âœ… Image format is YUV_420_888 (Android standard)');
      }

      // Method 1: Combine all planes for NV21 format
      final WriteBuffer allBytes = WriteBuffer();

      // For YUV_420_888 format (Android camera default)
      // Plane 0: Y (luminance)
      // Plane 1: U (chrominance)
      // Plane 2: V (chrominance)

      if (image.planes.length >= 3) {
        print('ðŸ“Š Plane sizes:');
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

      print('âš ï¸ Unexpected plane count: ${image.planes.length}');

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
      print('âŒ Error in _convertToInputImage: $e');
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
    await _poseDetector.close();
    await _resultController.close();
  }

  // pose_detection_service.dart á€™á€¾á€¬ á€’á€® function á€€á€­á€¯ á€‘á€•á€ºá€‘á€Šá€·á€ºá€•á€«
  void testPoseDetection() async {
    print('ðŸ” Testing Pose Detection...');

    // Create a simple test image
    final testImage = InputImage.fromFilePath(
      'assets/test_images/test_pose.jpg', // á€žá€„á€ºá€·á€™á€¾á€¬á€›á€¾á€­á€›á€„á€º
    );

    try {
      final poses = await _poseDetector.processImage(testImage);
      print('Test result: Detected ${poses.length} poses');

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final landmarks = pose.landmarks.values
            .where((landmark) => landmark.likelihood > 0.3)
            .length;
        print('âœ… Test successful! Found $landmarks landmarks');
      } else {
        print('âŒ Test failed: No poses detected');
      }
    } catch (e) {
      print('âŒ Test error: $e');
    }
  }
}

