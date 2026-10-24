// lib/domain/use_cases/track_exercise.dart
import 'dart:async';
import '../repositories/exercise_repository.dart';
import '../../data/models/exercise_log.dart';
import '../../data/models/user_activity.dart';
import 'package:flutter/material.dart';

class TrackExerciseUseCase {
  final ExerciseRepository repository;
  
  TrackExerciseUseCase(this.repository);
  
  Future<ExerciseLog> completeExerciseSession({
    required String exerciseId,
    required int totalReps,
    required Duration sessionDuration,
    required double averageAccuracy,
    required double maxAccuracy,
    required double minAccuracy,
    required List<RepDetail> repDetails,
    required List<FormWarning> formWarnings,
    bool isPremiumSession = false,
    String? videoPath,
  }) async {
    final log = ExerciseLog(
      exerciseId: exerciseId,
      timestamp: DateTime.now(),
      sessionDuration: sessionDuration.inSeconds,
      totalRepetitions: totalReps,
      averageAccuracy: averageAccuracy,
      maxAccuracy: maxAccuracy,
      minAccuracy: minAccuracy,
      repDetails: repDetails,
      formWarnings: formWarnings,
      isPremiumSession: isPremiumSession,
      videoPath: videoPath,
    );
    
    await repository.saveExerciseLog(log);
    
    // Update daily activity
    final todayActivity = await repository.getOrCreateDailyActivity();
    todayActivity.addWorkout(
      exerciseId: exerciseId,
      reps: totalReps,
      duration: sessionDuration,
      accuracy: averageAccuracy,
    );
    await repository.updateDailyActivity(todayActivity);
    
    // Update exercise stats
    await repository.updateExerciseStats(exerciseId, totalReps, averageAccuracy);
    
    return log;
  }
  
  Stream<List<ExerciseLog>> getExerciseProgress(
    String exerciseId, {
    DateTimeRange? dateRange,
  }) {
    final range = dateRange ?? DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    
    return repository.watchExerciseLogs(
      exerciseId: exerciseId,
      startDate: range.start,
      endDate: range.end,
    );
  }
  
  Future<Map<String, dynamic>> getSessionSummary(String exerciseId) async {
    final logs = await repository.getExerciseLogsByDateRange(
      DateTime.now().subtract(const Duration(days: 7)),
      DateTime.now(),
      exerciseId: exerciseId,
    );
    
    if (logs.isEmpty) {
      return {
        'totalSessions': 0,
        'totalReps': 0,
        'averageAccuracy': 0.0,
        'bestSession': null,
        'improvement': 0.0,
      };
    }
    
    final totalSessions = logs.length;
    final totalReps = logs.fold(0, (sum, log) => sum + log.totalRepetitions);
    final averageAccuracy = logs.fold(
      0.0,
      (sum, log) => sum + log.averageAccuracy,
    ) / totalSessions;
    
    final bestSession = logs.reduce(
      (a, b) => a.averageAccuracy > b.averageAccuracy ? a : b,
    );
    
    // Calculate improvement (last 3 sessions vs first 3 sessions)
    final sortedLogs = List<ExerciseLog>.from(logs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    double improvement = 0.0;
    if (sortedLogs.length >= 6) {
      final firstThreeAvg = sortedLogs
          .take(3)
          .fold(0.0, (sum, log) => sum + log.averageAccuracy) / 3;
      
      final lastThreeAvg = sortedLogs
          .reversed
          .take(3)
          .fold(0.0, (sum, log) => sum + log.averageAccuracy) / 3;
      
      improvement = lastThreeAvg - firstThreeAvg;
    }
    
    return {
      'totalSessions': totalSessions,
      'totalReps': totalReps,
      'averageAccuracy': averageAccuracy,
      'bestSession': bestSession,
      'improvement': improvement,
      'averageRepsPerSession': totalReps ~/ totalSessions,
    };
  }
}