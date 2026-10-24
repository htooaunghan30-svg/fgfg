// lib/data/models/user_activity.dart
import 'package:isar/isar.dart';
import '../../core/utils/calorie_estimator.dart';

part 'user_activity.g.dart';

@Collection()
class UserActivity {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime date; // Date only (time set to 00:00:00)
  
  late int totalWorkouts = 0;
  late int totalRepetitions = 0;
  late int totalDuration = 0;         // Duration.zero;
  late double averageAccuracy = 0.0;
  // Exercise-specific counts
  late int squatCount = 0;
  late int pushupCount = 0;
  late int bicepCurlCount = 0;
  late int shoulderPressCount = 0;
  late int situpCount = 0;
  late int legExtensionCount = 0;
  late int wallSitCount = 0;
  
  // Streaks
  late int currentStreak = 0;
  late int bestStreak = 0;
  
  // Calories estimation (very rough)
  late double estimatedCalories = 0.0;
  
  // Premium features usage
  late int voiceCoachUses = 0;
  late int videoRecordings = 0;
  late int analyticsViews = 0;
  
  UserActivity({
    required this.date,
  });
  
  // Helper methods
  void addWorkout({
    required String exerciseId,
    required int reps,
    required Duration duration,
    required double accuracy,
  }) {
    final normalizedExerciseId =
        exerciseId.toLowerCase().replaceAll('-', '_').trim();

    totalWorkouts++;
    totalRepetitions += reps;
    totalDuration += duration.inSeconds;
    
    // Update moving average
    averageAccuracy = ((averageAccuracy * (totalWorkouts - 1)) + accuracy) / totalWorkouts;
    
    // Update exercise-specific counts
    switch (normalizedExerciseId) {
      case 'squat':
        squatCount += reps;
        break;
      case 'pushup':
      case 'push_up':
        pushupCount += reps;
        break;
      case 'bicep_curl':
      case 'bicepcurl':
        bicepCurlCount += reps;
        break;
      case 'shoulder_press':
      case 'shoulderpress':
        shoulderPressCount += reps;
        break;
      case 'situp':
      case 'sit_up':
        situpCount += reps;
        break;
      case 'leg_extension':
      case 'legextension':
        legExtensionCount += reps;
        break;
      case 'wall_sit':
        wallSitCount += 1; // Count as 1 workout for static
        break;
    }
    
    // Estimate calories (very rough estimation)
    estimatedCalories += _estimateCalories(normalizedExerciseId, reps, duration);
  }
  
  double _estimateCalories(String exerciseId, int reps, Duration duration) {
    return ExerciseCalorieEstimator.estimateFromWorkout(
      exerciseId: exerciseId,
      reps: reps,
      duration: duration,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalWorkouts': totalWorkouts,
      'totalRepetitions': totalRepetitions,
      'totalDuration': totalDuration,
      'averageAccuracy': averageAccuracy,
      'squatCount': squatCount,
      'pushupCount': pushupCount,
      'bicepCurlCount': bicepCurlCount,
      'shoulderPressCount': shoulderPressCount,
      'situpCount': situpCount,
      'legExtensionCount': legExtensionCount,
      'wallSitCount': wallSitCount,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'estimatedCalories': estimatedCalories,
      'voiceCoachUses': voiceCoachUses,
      'videoRecordings': videoRecordings,
      'analyticsViews': analyticsViews,
    };
  }
  
  factory UserActivity.fromJson(Map<String, dynamic> json) {
    final activity = UserActivity(
      date: DateTime.parse(json['date']),
    );
    
    activity.totalWorkouts = json['totalWorkouts'] ?? 0;
    activity.totalRepetitions = json['totalRepetitions'] ?? 0;
    activity.totalDuration = json['totalDurationSeconds'] ?? 0;
    //activity.totalDuration = Duration(seconds: json['totalDuration'] ?? 0);
    activity.averageAccuracy = json['averageAccuracy'] ?? 0.0;
    activity.squatCount = json['squatCount'] ?? 0;
    activity.pushupCount = json['pushupCount'] ?? 0;
    activity.bicepCurlCount = json['bicepCurlCount'] ?? 0;
    activity.shoulderPressCount = json['shoulderPressCount'] ?? 0;
    activity.situpCount = json['situpCount'] ?? 0;
    activity.legExtensionCount = json['legExtensionCount'] ?? 0;
    activity.wallSitCount = json['wallSitCount'] ?? 0;
    activity.currentStreak = json['currentStreak'] ?? 0;
    activity.bestStreak = json['bestStreak'] ?? 0;
    activity.estimatedCalories = json['estimatedCalories'] ?? 0.0;
    activity.voiceCoachUses = json['voiceCoachUses'] ?? 0;
    activity.videoRecordings = json['videoRecordings'] ?? 0;
    activity.analyticsViews = json['analyticsViews'] ?? 0;
    
    return activity;
  }
}
