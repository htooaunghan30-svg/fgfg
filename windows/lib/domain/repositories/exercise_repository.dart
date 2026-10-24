// lib/domain/repositories/exercise_repository.dart
import 'dart:async';
import '../../data/models/exercise_model.dart';
import '../../data/models/exercise_log.dart';
import '../../data/models/user_activity.dart';
import 'package:flutter/material.dart';

abstract class ExerciseRepository {
  // Exercise Models
  Future<List<ExerciseModel>> getAllExercises();
  Future<ExerciseModel?> getExerciseById(String id);
  Future<void> saveExercise(ExerciseModel exercise);
  Future<void> updateExerciseStats(String exerciseId, int reps, double accuracy);
  
  // Exercise Logs
  Stream<List<ExerciseLog>> watchExerciseLogs({
    String? exerciseId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> saveExerciseLog(ExerciseLog log);
  Future<List<ExerciseLog>> getExerciseLogsByDateRange(
    DateTime start,
    DateTime end, {
    String? exerciseId,
  });
  Future<ExerciseLog?> getBestSession(String exerciseId);
  
  // User Activity
  Stream<UserActivity?> watchTodayActivity();
  Future<UserActivity> getOrCreateDailyActivity();
  Future<void> updateDailyActivity(UserActivity activity);
  Future<List<UserActivity>> getWeeklyActivities();
  Future<List<UserActivity>> getMonthlyActivities();
  
  // Statistics
  Future<Map<String, dynamic>> getExerciseStatistics(
    String exerciseId,
    DateTimeRange range,
  );
  Future<Map<String, dynamic>> getUserStatistics();
  
  // Maintenance
  Future<void> clearOldLogs(int daysToKeep);
  Future<int> getTotalLogCount();
}