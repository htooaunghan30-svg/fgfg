// lib/domain/use_cases/calculate_metrics.dart
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../../core/utils/angle_calculator.dart';
import '../../core/utils/calorie_estimator.dart';
import '../../data/models/exercise_log.dart';

class CalculateMetricsUseCase {
  final AngleCalculator _angleCalculator = AngleCalculator();
  
  Map<String, double> calculateJointAngles({
    required Map<String, Vector3> jointPositions,
    required String exerciseId,
  }) {
    final Map<String, double> angles = {};
    
    // Get joint pairs based on exercise
    final jointPairs = _getJointPairsForExercise(exerciseId);
    
    for (final pair in jointPairs) {
      final start = jointPositions[pair.start];
      final middle = jointPositions[pair.middle];
      final end = jointPositions[pair.end];
      
      if (start != null && middle != null && end != null) {
        final angle = _angleCalculator.calculateAngle(start, middle, end);
        angles['${pair.start}_${pair.middle}_${pair.end}'] = angle;
      }
    }
    
    return angles;
  }
  
  double calculateRepQuality({
    required double peakAngle,
    required double troughAngle,
    required double targetPeak,
    required double targetTrough,
    required Duration repDuration,
    required List<FormWarning> warnings,
  }) {
    // Angle accuracy (50% weight)
    final angleError = (
      (peakAngle - targetPeak).abs() +
      (troughAngle - targetTrough).abs()
    ) / (targetPeak + targetTrough);
    final angleScore = 1.0 - angleError.clamp(0.0, 1.0);
    
    // Duration score (20% weight) - ideal rep duration between 1-3 seconds
    final idealDuration = const Duration(seconds: 2);
    final durationError = (repDuration.inMilliseconds - idealDuration.inMilliseconds).abs() /
        idealDuration.inMilliseconds;
    final durationScore = 1.0 - durationError.clamp(0.0, 1.0);
    
    // Form score (30% weight)
    final formScore = warnings.isEmpty ? 1.0 : 0.5;
    
    // Weighted average
    return (angleScore * 0.5) + (durationScore * 0.2) + (formScore * 0.3);
  }
  
  double estimateCaloriesBurned({
    required String exerciseId,
    required int reps,
    required Duration duration,
    double userWeight = 70.0, // Default 70kg
  }) {
    return ExerciseCalorieEstimator.estimateFromWorkout(
      exerciseId: exerciseId,
      reps: reps,
      duration: duration,
      userWeightKg: userWeight,
    );
  }
  
  double calculateVelocityProfile(List<double> anglesOverTime, List<Duration> timestamps) {
    if (anglesOverTime.length < 2) return 0.0;
    
    // Calculate angular velocities
    final List<double> velocities = [];
    for (int i = 1; i < anglesOverTime.length; i++) {
      final deltaAngle = anglesOverTime[i] - anglesOverTime[i - 1];
      final deltaTime = timestamps[i].inMilliseconds - timestamps[i - 1].inMilliseconds;
      
      if (deltaTime > 0) {
        velocities.add(deltaAngle / (deltaTime / 1000)); // degrees per second
      }
    }
    
    if (velocities.isEmpty) return 0.0;
    
    // Calculate consistency of velocity (lower variance = more consistent)
    final mean = velocities.reduce((a, b) => a + b) / velocities.length;
    final variance = velocities
        .map((v) => (v - mean) * (v - mean))
        .reduce((a, b) => a + b) / velocities.length;
    
    //return 1.0 - (variance.sqrt() / mean.abs()).clamp(0.0, 1.0);
    return 1.0 - (sqrt(variance) / mean.abs()).clamp(0.0, 1.0);
  }
  
  List<JointPair> _getJointPairsForExercise(String exerciseId) {
    // Define joint pairs for each exercise
    switch (exerciseId) {
      case 'squat':
        return [
          JointPair('hip', 'knee', 'ankle'),
          JointPair('shoulder', 'hip', 'knee'),
        ];
      case 'pushup':
        return [
          JointPair('shoulder', 'elbow', 'wrist'),
          JointPair('shoulder', 'hip', 'ankle'),
        ];
      case 'bicep_curl':
        return [
          JointPair('shoulder', 'elbow', 'wrist'),
        ];
      case 'shoulder_press':
        return [
          JointPair('shoulder', 'elbow', 'wrist'),
        ];
      case 'situp':
        return [
          JointPair('shoulder', 'hip', 'knee'),
          JointPair('ear', 'shoulder', 'hip'),
        ];
      case 'leg_extension':
        return [
          JointPair('hip', 'knee', 'ankle'),
          JointPair('shoulder', 'hip', 'knee'),
        ];
      case 'wall_sit':
        return [
          JointPair('hip', 'knee', 'ankle'),
        ];
      default:
        return [];
    }
  }
}

class JointPair {
  final String start;
  final String middle;
  final String end;
  
  JointPair(this.start, this.middle, this.end);
}
