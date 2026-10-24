// lib/data/repositories/exercise_repository_impl.dart
import 'dart:async';
import 'package:isar/isar.dart'; // isar package ကို import လုပ်ဖို့ မမေ့ပါနဲ့
import '../../data/services/isar_service.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/exercise_log.dart';
import '../../data/models/user_activity.dart';
import '../../core/constants/exercise_config.dart';
import '../../features/gamification/badge_manager.dart';
import '../repositories/exercise_repository.dart';
import 'package:flutter/material.dart';
import 'dart:math';

//part 'user_activity.g.dart'; // ဒါမျိုး ပါရပါမယ်
class ExerciseRepositoryImpl implements ExerciseRepository {
  @override
// lib/data/repositories/exercise_repository_impl.dart
// getAllExercises method ကို ပြင်ဆင်ပါ

  @override
  Future<List<ExerciseModel>> getAllExercises() async {
    try {
      final isar = IsarService.instance;

      // Check if database has exercises
      final count = await isar.exerciseModels.count();

      if (count == 0) {
        print('No exercises found in database, seeding...');
        await _seedExercisesFromConfig();
      } else {
        await _syncMissingExercisesFromConfig();
      }

      // Get all exercises
      final exercises = await isar.exerciseModels.where().findAll();

      // Sort by name
      exercises.sort((a, b) => a.name.compareTo(b.name));

      print('Loaded ${exercises.length} exercises from database');

      // Log exercise details
      for (final exercise in exercises.take(3)) {
        print('Exercise: ${exercise.exerciseId} - ${exercise.name}');
      }

      return exercises;
    } catch (e) {
      print('Error getting exercises: $e');
      return [];
    }
  }

  Future<void> _syncMissingExercisesFromConfig() async {
    try {
      final isar = IsarService.instance;
      final existingExercises = await isar.exerciseModels.where().findAll();
      final existingIds = existingExercises.map((e) => e.exerciseId).toSet();
      final missingConfigs = ExerciseConfig.getAllExercises()
          .where((config) => !existingIds.contains(config['id']))
          .toList();

      if (missingConfigs.isEmpty) {
        return;
      }

      final missingExercises = missingConfigs.map((config) {
        return ExerciseModel(
          exerciseId: config['id'] as String? ?? 'unknown',
          name: config['name'] as String? ?? 'Unknown',
          type: config['type'] as String? ?? 'dynamic',
          viewRequired: config['view_required'] as String? ?? 'side',
          repLogic:
              _parseRepLogic(config['rep_logic'] as Map<String, dynamic>?),
          formChecks: _parseFormChecks(config['form_checks'] as List<dynamic>?),
          totalReps: 0,
          averageAccuracy: 0.0,
          lastPerformed: DateTime.now(),
        );
      }).toList();

      await isar.writeTxn(() async {
        await isar.exerciseModels.putAll(missingExercises);
      });

      print('Synced ${missingExercises.length} missing exercises from config');
    } catch (e) {
      print('Error syncing missing exercises: $e');
    }
  }

// Add method to calculate total reps
// lib/data/repositories/exercise_repository_impl.dart
// getTotalReps method ကို ပြင်ဆင်ပါ

  Future<int> getTotalReps() async {
    try {
      final isar = IsarService.instance;
      final logs = await isar.exerciseLogs.where().findAll();
      final total = logs.fold(0, (sum, log) => sum + log.totalRepetitions);
      return total;
    } catch (e) {
      print('Error calculating total reps: $e');
      return 0;
    }
  }

  final Map<String, List<ExerciseLog>> _exerciseLogs = {};
// Add this method for getting exercise logs
  List<ExerciseLog> getExerciseLogs(String exerciseId) {
    final logs = _exerciseLogs[exerciseId] ?? [];
    return logs;
  }

// Initialize method ထည့်ပါ
  Future<void> initialize() async {
    await getAllExercises();
  }

  Future<void> _seedExercisesFromConfig() async {
    try {
      final isar = IsarService.instance;
      final allExercises = ExerciseConfig.getAllExercises();

      print('Seeding ${allExercises.length} exercises from config...');

      final exerciseModels = allExercises.map((config) {
        print('Processing exercise: ${config['id']} - ${config['name']}');

        return ExerciseModel(
          exerciseId: config['id'] as String? ?? 'unknown',
          name: config['name'] as String? ?? 'Unknown',
          type: config['type'] as String? ?? 'dynamic',
          viewRequired: config['view_required'] as String? ?? 'side',
          repLogic:
              _parseRepLogic(config['rep_logic'] as Map<String, dynamic>?),
          formChecks: _parseFormChecks(config['form_checks'] as List<dynamic>?),
          totalReps: 0,
          averageAccuracy: 0.0,
          lastPerformed:
              DateTime.now().subtract(Duration(days: Random().nextInt(30))),
        );
      }).toList();

      print('Created ${exerciseModels.length} exercise models');

      await isar.writeTxn(() async {
        await isar.exerciseModels.putAll(exerciseModels);
      });

      print(
          'Successfully seeded ${exerciseModels.length} exercises to database');
    } catch (e) {
      print('Error seeding exercises: $e');
      print('Stack trace: ${e.toString()}');
    }
  }

  RepLogic _parseRepLogic(Map<String, dynamic>? repLogic) {
    if (repLogic == null) return RepLogic();

    final phase1Map =
        (repLogic['phase_1_eccentric'] ?? repLogic['phase_1_concentric'])
            as Map<String, dynamic>?;
    final phase2Map =
        (repLogic['phase_2_concentric'] ?? repLogic['phase_2_eccentric'])
            as Map<String, dynamic>?;

    return RepLogic(
      primaryJoint: repLogic['primary_joint'] as String? ?? 'knee',
      phase1Eccentric: phase1Map != null
          ? Phase(
              condition: phase1Map['condition'] as String? ?? '',
              description: phase1Map['description'] as String? ?? '',
              threshold: (phase1Map['threshold'] as num?)?.toDouble() ??
                  0.0,
            )
          : null,
      phase2Concentric: phase2Map != null
          ? Phase(
              condition: phase2Map['condition'] as String? ?? '',
              description: phase2Map['description'] as String? ?? '',
              threshold: (phase2Map['threshold'] as num?)?.toDouble() ??
                  0.0,
            )
          : null,
      holdCondition: repLogic['hold_condition'] != null
          ? HoldCondition(
              minKneeAngle: ((repLogic['hold_condition']
                      as Map<String, dynamic>)['knee_angle']?['min'] as num?)
                  ?.toDouble(),
              maxKneeAngle: ((repLogic['hold_condition']
                      as Map<String, dynamic>)['knee_angle']?['max'] as num?)
                  ?.toDouble(),
              minBackAngle: ((repLogic['hold_condition']
                      as Map<String, dynamic>)['back_angle']?['min'] as num?)
                  ?.toDouble(),
              maxBackAngle: ((repLogic['hold_condition']
                      as Map<String, dynamic>)['back_angle']?['max'] as num?)
                  ?.toDouble(),
            )
          : null,
      countType: repLogic['count_type'] as String?,
    );
  }

  List<FormCheck> _parseFormChecks(List<dynamic>? formChecks) {
    if (formChecks == null) return [];

    print('Parsing ${formChecks.length} form checks');

    return formChecks.map((check) {
      try {
        if (check is! Map<String, dynamic>) {
          print('Warning: Form check is not a Map: $check');
          return FormCheck(
            id: 'unknown',
            joints: [],
            minAngle: 0.0,
            maxAngle: 180.0,
            warningMessage: '',
          );
        }

        return FormCheck(
          id: (check['id'] as String?) ?? 'unknown',
          joints: ((check['joints'] as List<dynamic>?) ?? [])
              .whereType<String>()
              .toList(),
          checkType: check['check_type'] as String?,
          targetJoint: check['target_joint'] as String?,
          jointsPair: ((check['joints_pair'] as List<dynamic>?) ?? [])
              .whereType<String>()
              .toList(),
          tolerance: (check['tolerance'] as num?)?.toDouble(),
          minAngle: (check['min_angle'] as num?)?.toDouble() ?? 0.0,
          maxAngle: (check['max_angle'] as num?)?.toDouble() ?? 180.0,
          warningMessage: (check['warning_message'] as String?) ?? '',
        );
      } catch (e) {
        print('Error parsing form check $check: $e');
        return FormCheck(
          id: 'error',
          joints: [],
          minAngle: 0.0,
          maxAngle: 180.0,
          warningMessage: '',
        );
      }
    }).toList();
  }

  @override
  Future<ExerciseModel?> getExerciseById(String id) async {
    final isar = IsarService.instance;
    // exerciseId က index မဟုတ်ရင် filter() သုံးရပါမယ်
    return await isar.exerciseModels.filter().exerciseIdEqualTo(id).findFirst();
  }

  @override
  Future<void> saveExercise(ExerciseModel exercise) async {
    final isar = IsarService.instance;
    _sanitizeExerciseModel(exercise);
    await isar.writeTxn(() async {
      await isar.exerciseModels.put(exercise);
    });
  }

  @override
  Future<void> updateExerciseStats(
      String exerciseId, int reps, double accuracy) async {
    final exercise = await getExerciseById(exerciseId);
    if (exercise != null) {
      final safeReps = _clampInt(reps, max: 1000000);
      final safeAccuracy = _clampUnit(accuracy);
      if (safeReps <= 0) {
        return;
      }
      final prevTotalReps = exercise.totalReps;
      final newTotalReps = prevTotalReps + safeReps;
      final weightedSum = (exercise.averageAccuracy * prevTotalReps) +
          (safeAccuracy * safeReps);
      exercise.totalReps = newTotalReps;
      exercise.averageAccuracy =
          newTotalReps > 0 ? (weightedSum / newTotalReps) : 0.0;
      exercise.lastPerformed = DateTime.now();
      await saveExercise(exercise);
    }
  }

  @override
  Stream<List<ExerciseLog>> watchExerciseLogs({
    String? exerciseId, // Comma ထည့်ပေးလိုက်ပါပြီ
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final isar = IsarService.instance;
    // QueryBuilder<ExerciseLog, ExerciseLog, QAfterWhereClause> query = isar.exerciseLogs.where();

    // where() အစား filter() ကို ပြောင်းသုံးထားပါတယ် (Safe Side)
    // return isar.exerciseLogs
    //     .filter()
    //     .optional(exerciseId != null, (q) => q.exerciseIdEqualTo(exerciseId!))
    //     .optional(startDate != null, (q) => q.timestampGreaterThan(startDate!))
    //     .optional(endDate != null, (q) => q.timestampLessThan(endDate!))
    //     .sortByTimestampDesc()
    //     .watch(fireImmediately: true);

    if (exerciseId != null) {
      // Filter by exercise ID
      return isar.exerciseLogs
          .where()
          .filter()
          .exerciseIdEqualTo(exerciseId)
          .watch(fireImmediately: true);
    } else {
      // All logs
      return isar.exerciseLogs.where().watch(fireImmediately: true);
    }
  }

  @override
  Future<void> saveExerciseLog(ExerciseLog log) async {
    final isar = IsarService.instance;
    final sanitizedLog = _sanitizeExerciseLog(log);
    await isar.writeTxn(() async {
      await isar.exerciseLogs.put(sanitizedLog);
    });
    try {
      await BadgeManager().checkAndUpdateBadges(sanitizedLog);
    } catch (e) {
      debugPrint('Badge update failed after saving log: $e');
    }
  }

  @override
  Future<List<ExerciseLog>> getExerciseLogsByDateRange(
    DateTime start,
    DateTime end, {
    String? exerciseId,
  }) async {
    final isar = IsarService.instance;

    // var သုံးပြီး filter() နဲ့ စပါမယ်
    var query = isar.exerciseLogs.filter().timestampBetween(start, end);

    if (exerciseId != null) {
      query = query.exerciseIdEqualTo(exerciseId);
    }

    return await query.sortByTimestampDesc().findAll();
  }

  @override
  Future<ExerciseLog?> getBestSession(String exerciseId) async {
    final isar = IsarService.instance;
    final logs = await isar.exerciseLogs
        .filter() // where() -> filter()
        .exerciseIdEqualTo(exerciseId)
        .sortByAverageAccuracyDesc()
        .findAll();

    return logs.isNotEmpty ? logs.first : null;
  }

  @override
  Stream<UserActivity?> watchTodayActivity() {
    final isar = IsarService.instance;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // date က index မဟုတ်ရင် filter() သုံးရပါမယ်
    return isar.userActivitys
        .filter()
        .dateEqualTo(todayDate)
        .watch(fireImmediately: true)
        .map((activities) => activities.isNotEmpty ? activities.first : null);
  }

  @override
  Future<UserActivity> getOrCreateDailyActivity() async {
    final isar = IsarService.instance;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // where() -> filter()
    var activity =
        await isar.userActivitys.filter().dateEqualTo(todayDate).findFirst();

    if (activity == null) {
      activity = UserActivity(date: todayDate);
      await isar.writeTxn(() async {
        await isar.userActivitys.put(activity!);
      });
    }

    return activity;
  }

  @override
  Future<void> updateDailyActivity(UserActivity activity) async {
    final isar = IsarService.instance;
    _sanitizeUserActivity(activity);
    await isar.writeTxn(() async {
      await isar.userActivitys.put(activity);
    });
  }

  @override
  Future<List<UserActivity>> getWeeklyActivities() async {
    final isar = IsarService.instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 6));

    return await isar.userActivitys
        .filter() // where() -> filter()
        .dateBetween(weekStart, today)
        .sortByDate()
        .findAll();
  }

  @override
  Future<List<UserActivity>> getMonthlyActivities() async {
    final isar = IsarService.instance;
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    return await isar.userActivitys
        .filter() // where() -> filter()
        .dateGreaterThan(monthAgo)
        .sortByDateDesc()
        .findAll();
  }

  @override
  Future<Map<String, dynamic>> getExerciseStatistics(
    String exerciseId,
    DateTimeRange range,
  ) async {
    final logs = await getExerciseLogsByDateRange(
      range.start,
      range.end,
      exerciseId: exerciseId,
    );

    if (logs.isEmpty) {
      return {
        'totalReps': 0,
        'averageAccuracy': 0.0,
        'bestSession': null,
        'trend': 0.0,
        'dailyAverage': 0,
      };
    }

    final totalReps = logs.fold(0, (sum, log) => sum + log.totalRepetitions);
    final averageAccuracy = logs.fold(
          0.0,
          (sum, log) => sum + log.averageAccuracy,
        ) /
        logs.length;

    final bestSession = logs.reduce(
      (a, b) => a.averageAccuracy > b.averageAccuracy ? a : b,
    );

    // Calculate trend
    final sortedLogs = List<ExerciseLog>.from(logs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    double trend = 0.0;
    if (sortedLogs.length >= 2) {
      final firstAccuracy = sortedLogs.first.averageAccuracy;
      final lastAccuracy = sortedLogs.last.averageAccuracy;
      trend = lastAccuracy - firstAccuracy;
    }

    return {
      'totalReps': totalReps,
      'averageAccuracy': averageAccuracy,
      'bestSession': bestSession,
      'trend': trend,
      'dailyAverage': totalReps ~/ logs.length,
    };
  }

  @override
  Future<Map<String, dynamic>> getUserStatistics() async {
    final isar = IsarService.instance;
    final totalLogs = await isar.exerciseLogs.count();
    final totalActivities = await isar.userActivitys.count();

    return {
      'totalWorkouts': totalLogs,
      'totalActivityDays': totalActivities,
      'averageDailyReps': await _calculateAverageDailyReps(),
      'currentStreak': await _calculateCurrentStreak(),
    };
  }

  Future<int> _calculateAverageDailyReps() async {
    final isar = IsarService.instance;
    final activities = await isar.userActivitys.where().findAll();

    if (activities.isEmpty) return 0;

    final totalReps =
        activities.fold(0, (sum, activity) => sum + activity.totalRepetitions);
    return totalReps ~/ activities.length;
  }

  Future<int> _calculateCurrentStreak() async {
    final isar = IsarService.instance;
    final activities = await isar.userActivitys
        .where() // where() -> filter()
        .sortByDateDesc()
        .findAll();

    if (activities.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final activity in activities) {
      final activityDate = activity.date;

      if (activityDate.year == currentDate.year &&
          activityDate.month == currentDate.month &&
          activityDate.day == currentDate.day) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Future<void> clearOldLogs(int daysToKeep) async {
    final isar = IsarService.instance;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    await isar.writeTxn(() async {
      await isar.exerciseLogs
          .filter() // where() -> filter()
          .timestampLessThan(cutoffDate)
          .deleteAll();
    });
  }

  @override
  Future<int> getTotalLogCount() async {
    final isar = IsarService.instance;
    return await isar.exerciseLogs.count();
  }

  ExerciseLog _sanitizeExerciseLog(ExerciseLog log) {
    log.totalRepetitions = _clampInt(log.totalRepetitions, max: 1000000);
    log.sessionDuration = _clampInt(log.sessionDuration, max: 86400);
    log.averageAccuracy = _clampUnit(log.averageAccuracy);
    log.maxAccuracy = _clampUnit(log.maxAccuracy);
    log.minAccuracy = _clampUnit(log.minAccuracy);
    if (log.minAccuracy > log.maxAccuracy) {
      final tmp = log.minAccuracy;
      log.minAccuracy = log.maxAccuracy;
      log.maxAccuracy = tmp;
    }

    log.repDetails = log.repDetails.map((rep) {
      final sanitizedAngles = rep.jointAngles
          .where((angle) => angle.angle.isFinite)
          .map(
            (angle) => JointAngle(
              jointName: angle.jointName,
              angle: angle.angle,
              timestamp: angle.timestamp,
            ),
          )
          .toList();

      return rep.copyWith(
        repNumber: _clampInt(rep.repNumber, max: 1000000),
        accuracy: _clampUnit(rep.accuracy),
        durationMs: _clampInt(rep.durationMs, max: 3600000),
        jointAngles: sanitizedAngles,
      );
    }).toList();

    log.formWarnings = log.formWarnings.map((warning) {
      final sanitizedPositions =
          warning.jointPosition?.where((value) => value.isFinite).toList();
      return FormWarning(
        warningId: warning.warningId.trim(),
        message: warning.message.trim(),
        timestamp: warning.timestamp,
        jointPosition: sanitizedPositions,
      );
    }).toList();

    return log;
  }

  void _sanitizeExerciseModel(ExerciseModel exercise) {
    exercise.totalReps = _clampInt(exercise.totalReps, max: 1000000);
    exercise.averageAccuracy = _clampUnit(exercise.averageAccuracy);
  }

  void _sanitizeUserActivity(UserActivity activity) {
    activity.totalWorkouts = _clampInt(activity.totalWorkouts, max: 1000000);
    activity.totalRepetitions =
        _clampInt(activity.totalRepetitions, max: 10000000);
    activity.totalDuration = _clampInt(activity.totalDuration, max: 86400);
    activity.averageAccuracy = _clampUnit(activity.averageAccuracy);
    activity.estimatedCalories =
        _clampNonNegativeDouble(activity.estimatedCalories);
  }

  int _clampInt(int value, {int min = 0, int max = 1000000}) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  double _clampUnit(double value) {
    if (!value.isFinite) return 0.0;
    if (value < 0.0) return 0.0;
    if (value > 1.0) return 1.0;
    return value;
  }

  double _clampNonNegativeDouble(double value) {
    if (!value.isFinite || value < 0.0) return 0.0;
    return value;
  }
}
// // lib/data/repositories/exercise_repository_impl.dart
// import 'dart:async';
// import 'package:isar/isar.dart';
// import '../../data/services/isar_service.dart';
// import '../../data/models/exercise_model.dart';
// import '../../data/models/exercise_log.dart';
// import '../../data/models/user_activity.dart';
// import '../../core/constants/exercise_config.dart';
// import '../repositories/exercise_repository.dart';
// import 'package:flutter/material.dart';
// import 'dart:math';

// class ExerciseRepositoryImpl implements ExerciseRepository {

//   Isar get _isar => IsarService.instance;

//   @override
//   Future<List<ExerciseModel>> getAllExercises() async {
//     try {
//       final isar = IsarService.instance;

//       final exercises = await isar.collection<ExerciseModel>().where().findAll();

//       print('Found ${exercises.length} exercises in database');

//       if (exercises.isEmpty) {
//         print('Database is empty, seeding exercises...');
//         await _seedExercisesFromConfig();

//         final newExercises = await isar.collection<ExerciseModel>().where().findAll();
//         print('After seeding: ${newExercises.length} exercises');

//         for (final exercise in newExercises) {
//           print('Exercise: ${exercise.exerciseId} - ${exercise.name}');
//         }

//         return newExercises;
//       }

//       return exercises;
//     } catch (e) {
//       print('Error getting exercises: $e');
//       return [];
//     }
//   }

//   Future<void> _seedExercisesFromConfig() async {
//     try {
//       final isar = IsarService.instance;
//       final allExercises = ExerciseConfig.getAllExercises();

//       print('Seeding ${allExercises.length} exercises from config...');

//       final exerciseModels = allExercises.map((config) {
//         print('Processing exercise: ${config['id']} - ${config['name']}');

//         return ExerciseModel(
//           exerciseId: config['id'] as String? ?? 'unknown',
//           name: config['name'] as String? ?? 'Unknown',
//           type: config['type'] as String? ?? 'dynamic',
//           viewRequired: config['view_required'] as String? ?? 'side',
//           repLogic: _parseRepLogic(config['rep_logic'] as Map<String, dynamic>?),
//           formChecks: _parseFormChecks(config['form_checks'] as List<dynamic>?),
//           totalReps: 0,
//           averageAccuracy: 0.0,
//           lastPerformed: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
//         );
//       }).toList();

//       print('Created ${exerciseModels.length} exercise models');

//       await isar.writeTxn(() async {
//         await isar.collection<ExerciseModel>().putAll(exerciseModels);
//       });

//       print('Successfully seeded ${exerciseModels.length} exercises to database');

//     } catch (e) {
//       print('Error seeding exercises: $e');
//       print('Stack trace: ${e.toString()}');
//     }
//   }

//   RepLogic _parseRepLogic(Map<String, dynamic>? repLogic) {
//     if (repLogic == null) return RepLogic();

//     return RepLogic(
//       primaryJoint: repLogic['primary_joint'] as String? ?? 'knee',
//       phase1Eccentric: repLogic['phase_1_eccentric'] != null
//           ? Phase(
//               condition: (repLogic['phase_1_eccentric'] as Map<String, dynamic>)['condition'] as String? ?? '',
//               description: (repLogic['phase_1_eccentric'] as Map<String, dynamic>)['description'] as String? ?? '',
//               threshold: ((repLogic['phase_1_eccentric'] as Map<String, dynamic>)['threshold'] as num?)?.toDouble() ?? 0.0,
//             )
//           : null,
//       phase2Concentric: repLogic['phase_2_concentric'] != null
//           ? Phase(
//               condition: (repLogic['phase_2_concentric'] as Map<String, dynamic>)['condition'] as String? ?? '',
//               description: (repLogic['phase_2_concentric'] as Map<String, dynamic>)['description'] as String? ?? '',
//               threshold: ((repLogic['phase_2_concentric'] as Map<String, dynamic>)['threshold'] as num?)?.toDouble() ?? 0.0,
//             )
//           : null,
//       holdCondition: repLogic['hold_condition'] != null
//           ? HoldCondition(
//               minKneeAngle: ((repLogic['hold_condition'] as Map<String, dynamic>)['knee_angle']?['min'] as num?)?.toDouble(),
//               maxKneeAngle: ((repLogic['hold_condition'] as Map<String, dynamic>)['knee_angle']?['max'] as num?)?.toDouble(),
//               minBackAngle: ((repLogic['hold_condition'] as Map<String, dynamic>)['back_angle']?['min'] as num?)?.toDouble(),
//               maxBackAngle: ((repLogic['hold_condition'] as Map<String, dynamic>)['back_angle']?['max'] as num?)?.toDouble(),
//             )
//           : null,
//       countType: repLogic['count_type'] as String?,
//     );
//   }

//   List<FormCheck> _parseFormChecks(List<dynamic>? formChecks) {
//     if (formChecks == null) return [];

//     print('Parsing ${formChecks.length} form checks');

//     return formChecks.map((check) {
//       try {
//         if (check is! Map<String, dynamic>) {
//           print('Warning: Form check is not a Map: $check');
//           return FormCheck(
//             id: 'unknown',
//             joints: [],
//             minAngle: 0.0,
//             maxAngle: 180.0,
//             warningMessage: '',
//           );
//         }

//         return FormCheck(
//           id: (check['id'] as String?) ?? 'unknown',
//           joints: ((check['joints'] as List<dynamic>?) ?? [])
//               .whereType<String>()
//               .toList(),
//           checkType: check['check_type'] as String?,
//           targetJoint: check['target_joint'] as String?,
//           jointsPair: ((check['joints_pair'] as List<dynamic>?) ?? [])
//               .whereType<String>()
//               .toList(),
//           tolerance: (check['tolerance'] as num?)?.toDouble(),
//           minAngle: (check['min_angle'] as num?)?.toDouble() ?? 0.0,
//           maxAngle: (check['max_angle'] as num?)?.toDouble() ?? 180.0,
//           warningMessage: (check['warning_message'] as String?) ?? '',
//         );
//       } catch (e) {
//         print('Error parsing form check $check: $e');
//         return FormCheck(
//           id: 'error',
//           joints: [],
//           minAngle: 0.0,
//           maxAngle: 180.0,
//           warningMessage: '',
//         );
//       }
//     }).toList();
//   }

//   @override
//   Future<ExerciseModel?> getExerciseById(String id) async {
//     final isar = IsarService.instance;
//     return await isar.collection<ExerciseModel>()
//         .where()
//         .filter((exercise) => exercise.exerciseId == id)
//         .findFirst();
//   }

//   @override
//   Future<void> saveExercise(ExerciseModel exercise) async {
//     final isar = IsarService.instance;
//     await isar.writeTxn(() async {
//       await isar.collection<ExerciseModel>().put(exercise);
//     });
//   }

//   @override
//   Future<void> updateExerciseStats(String exerciseId, int reps, double accuracy) async {
//     final isar = IsarService.instance;
//     final exercise = await getExerciseById(exerciseId);
//     if (exercise != null) {
//       exercise.totalReps += reps;
//       exercise.averageAccuracy = (exercise.averageAccuracy + accuracy) / 2;
//       exercise.lastPerformed = DateTime.now();
//       await saveExercise(exercise);
//     }
//   }

//   @override
//   Stream<List<ExerciseLog>> watchExerciseLogs({
//     String? exerciseId,
//     DateTime? startDate,
//     DateTime? endDate,
//   }) {
//     final isar = IsarService.instance;

//     var query = isar.collection<ExerciseLog>().where();

//     if (exerciseId != null) {
//       query = query.filter((log) => log.exerciseId == exerciseId);
//     }

//     if (startDate != null) {
//       query = query.filter((log) => log.timestamp.isAfter(startDate));
//     }

//     if (endDate != null) {
//       query = query.filter((log) => log.timestamp.isBefore(endDate));
//     }

//     return query
//         .sortByTimestampDesc()
//         .watch(fireImmediately: true);
//   }

//   @override
//   Future<void> saveExerciseLog(ExerciseLog log) async {
//     final isar = IsarService.instance;
//     await isar.writeTxn(() async {
//       await isar.collection<ExerciseLog>().put(log);
//     });
//   }

//   @override
//   Future<List<ExerciseLog>> getExerciseLogsByDateRange(
//     DateTime start,
//     DateTime end, {
//     String? exerciseId,
//   }) async {
//     final isar = IsarService.instance;

//     var query = isar.collection<ExerciseLog>()
//         .where()
//         .filter((log) => log.timestamp.isAfter(start) && log.timestamp.isBefore(end));

//     if (exerciseId != null) {
//       query = query.filter((log) => log.exerciseId == exerciseId);
//     }

//     return await query.sortByTimestampDesc().findAll();
//   }

//   @override
//   Future<ExerciseLog?> getBestSession(String exerciseId) async {
//     final isar = IsarService.instance;
//     final logs = await isar.collection<ExerciseLog>()
//         .where()
//         .filter((log) => log.exerciseId == exerciseId)
//         .sortByAverageAccuracyDesc()
//         .findAll();

//     return logs.isNotEmpty ? logs.first : null;
//   }

//   @override
//   Stream<UserActivity?> watchTodayActivity() {
//     final isar = IsarService.instance;
//     final today = DateTime.now();
//     final todayDate = DateTime(today.year, today.month, today.day);

//     return isar.collection<UserActivity>()
//         .where()
//         .filter((activity) => activity.date == todayDate)
//         .watch(fireImmediately: true)
//         .map((activities) => activities.isNotEmpty ? activities.first : null);
//   }

//   @override
//   Future<UserActivity> getOrCreateDailyActivity() async {
//     final isar = IsarService.instance;
//     final today = DateTime.now();
//     final todayDate = DateTime(today.year, today.month, today.day);

//     var activity = await isar.collection<UserActivity>()
//         .where()
//         .filter((activity) => activity.date == todayDate)
//         .findFirst();

//     if (activity == null) {
//       activity = UserActivity(date: todayDate);
//       await isar.writeTxn(() async {
//         await isar.collection<UserActivity>().put(activity!);
//       });
//     }

//     return activity;
//   }

//   @override
//   Future<void> updateDailyActivity(UserActivity activity) async {
//     final isar = IsarService.instance;
//     await isar.writeTxn(() async {
//       await isar.collection<UserActivity>().put(activity);
//     });
//   }

//   @override
//   Future<List<UserActivity>> getWeeklyActivities() async {
//     final isar = IsarService.instance;
//     final now = DateTime.now();
//     final weekAgo = now.subtract(const Duration(days: 7));

//     return await isar.collection<UserActivity>()
//         .where()
//         .filter((activity) => activity.date.isAfter(weekAgo))
//         .sortByDateDesc()
//         .findAll();
//   }

//   @override
//   Future<List<UserActivity>> getMonthlyActivities() async {
//     final isar = IsarService.instance;
//     final now = DateTime.now();
//     final monthAgo = now.subtract(const Duration(days: 30));

//     return await isar.collection<UserActivity>()
//         .where()
//         .filter((activity) => activity.date.isAfter(monthAgo))
//         .sortByDateDesc()
//         .findAll();
//   }

//   @override
//   Future<Map<String, dynamic>> getExerciseStatistics(
//     String exerciseId,
//     DateTimeRange range,
//   ) async {
//     final logs = await getExerciseLogsByDateRange(
//       range.start,
//       range.end,
//       exerciseId: exerciseId,
//     );

//     if (logs.isEmpty) {
//       return {
//         'totalReps': 0,
//         'averageAccuracy': 0.0,
//         'bestSession': null,
//         'trend': 0.0,
//         'dailyAverage': 0,
//       };
//     }

//     final totalReps = logs.fold(0, (sum, log) => sum + log.totalRepetitions);
//     final averageAccuracy = logs.fold(
//       0.0,
//       (sum, log) => sum + log.averageAccuracy,
//     ) / logs.length;

//     final bestSession = logs.reduce(
//       (a, b) => a.averageAccuracy > b.averageAccuracy ? a : b,
//     );

//     final sortedLogs = List<ExerciseLog>.from(logs)
//       ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

//     double trend = 0.0;
//     if (sortedLogs.length >= 2) {
//       final firstAccuracy = sortedLogs.first.averageAccuracy;
//       final lastAccuracy = sortedLogs.last.averageAccuracy;
//       trend = lastAccuracy - firstAccuracy;
//     }

//     return {
//       'totalReps': totalReps,
//       'averageAccuracy': averageAccuracy,
//       'bestSession': bestSession,
//       'trend': trend,
//       'dailyAverage': totalReps ~/ logs.length,
//     };
//   }

//   @override
//   Future<Map<String, dynamic>> getUserStatistics() async {
//     final isar = IsarService.instance;
//     final totalLogs = await isar.collection<ExerciseLog>().count();
//     final totalActivities = await isar.collection<UserActivity>().count();

//     return {
//       'totalWorkouts': totalLogs,
//       'totalActivityDays': totalActivities,
//       'averageDailyReps': await _calculateAverageDailyReps(),
//       'currentStreak': await _calculateCurrentStreak(),
//     };
//   }

//   Future<int> _calculateAverageDailyReps() async {
//     final isar = IsarService.instance;
//     final activities = await isar.collection<UserActivity>().where().findAll();

//     if (activities.isEmpty) return 0;

//     final totalReps = activities.fold(0, (sum, activity) => sum + activity.totalRepetitions);
//     return totalReps ~/ activities.length;
//   }

//   Future<int> _calculateCurrentStreak() async {
//     final isar = IsarService.instance;
//     final activities = await isar.collection<UserActivity>()
//         .where()
//         .sortByDateDesc()
//         .findAll();

//     if (activities.isEmpty) return 0;

//     int streak = 0;
//     DateTime currentDate = DateTime.now();

//     for (final activity in activities) {
//       final activityDate = activity.date;

//       if (activityDate.year == currentDate.year &&
//           activityDate.month == currentDate.month &&
//           activityDate.day == currentDate.day) {
//         streak++;
//         currentDate = currentDate.subtract(const Duration(days: 1));
//       } else {
//         break;
//       }
//     }

//     return streak;
//   }

//   @override
//   Future<void> clearOldLogs(int daysToKeep) async {
//     final isar = IsarService.instance;
//     final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

//     await isar.writeTxn(() async {
//       await isar.collection<ExerciseLog>()
//           .where()
//           .filter((log) => log.timestamp.isBefore(cutoffDate))
//           .deleteAll();
//     });
//   }

//   @override
//   Future<int> getTotalLogCount() async {
//     final isar = IsarService.instance;
//     return await isar.collection<ExerciseLog>().count();
//   }
// }
