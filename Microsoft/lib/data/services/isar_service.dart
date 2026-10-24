import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/exercise_model.dart';
import '../models/exercise_log.dart';
import '../models/user_activity.dart';
import '../models/badge_achievement.dart';
import 'package:flutter/material.dart'; // ဒါကို ထည့်ပေးပါ
import '../../core/constants/exercise_config.dart'; // သင့် path အတိုင်းချိန်ညှိပါ

class IsarService {
  static late Isar _isar;
  @Index() // ဒီ Index ပါမှ Between ကို သုံးလို့ရမှာပါ
  late DateTime timestamp;
  
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        ExerciseModelSchema,
        ExerciseLogSchema,
        UserActivitySchema,
        BadgeAchievementSchema,
      ],
      directory: dir.path,
      name: 'fitness_app',
      inspector: true, // Enable for debugging
    );
    
    await _seedInitialData();
  }
  
  static Future<void> _seedInitialData() async {
    // Check if exercises already exist
    final existingExercises = await _isar.exerciseModels.count();
    if (existingExercises == 0) {
      await _isar.writeTxn(() async {
        final exercises = _buildExerciseModelsFromConfig();
        
        await _isar.exerciseModels.putAll(exercises);
        
        // Seed initial badges
        final badges = [
          BadgeAchievement(
            badgeId: 'first_workout',
            name: 'First Steps',
            description: 'Complete your first workout',
            iconPath: 'assets/badges/first.png',
            tier: BadgeTier.bronze,
            unlockedAt: DateTime.now(),
            unlockedFor: 'general',
            progress: 0,
            requirement: 1,
          ),
          // Add more badges...
        ];
        
        await _isar.badgeAchievements.putAll(badges);
      });
    } else {
      // Keep existing users in sync when new exercises are added to config.
      await _syncMissingExercisesFromConfig();
    }
  }

  static Future<void> _syncMissingExercisesFromConfig() async {
    final existing = await _isar.exerciseModels.where().findAll();
    final existingIds = existing
        .map((exercise) => _normalizeExerciseId(exercise.exerciseId))
        .toSet();

    final missingConfigs = ExerciseConfig.getAllExercises().where((config) {
      final id = (config['id'] as String?) ?? '';
      if (id.isEmpty) return false;
      return !existingIds.contains(_normalizeExerciseId(id));
    }).toList();

    if (missingConfigs.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final missingExercises = missingConfigs
        .map((config) => _buildExerciseModelFromConfig(config, now))
        .toList();

    await _isar.writeTxn(() async {
      await _isar.exerciseModels.putAll(missingExercises);
    });

    await _rebuildExerciseStatsForIds(
      missingExercises.map((exercise) => exercise.exerciseId).toList(),
    );
  }

  static List<ExerciseModel> _buildExerciseModelsFromConfig() {
    final now = DateTime.now();
    return ExerciseConfig.getAllExercises()
        .map((config) => _buildExerciseModelFromConfig(config, now))
        .toList();
  }

  static ExerciseModel _buildExerciseModelFromConfig(
    Map<String, dynamic> config,
    DateTime now,
  ) {
    return ExerciseModel(
      exerciseId: (config['id'] as String? ?? '').trim(),
      name: (config['name'] as String? ?? 'Unknown').trim(),
      type: (config['type'] as String? ?? 'dynamic').trim(),
      viewRequired: (config['view_required'] as String? ?? 'side').trim(),
      repLogic:
          _parseRepLogicFromConfig(config['rep_logic'] as Map<String, dynamic>?),
      formChecks:
          _parseFormChecksFromConfig(config['form_checks'] as List<dynamic>?),
      totalReps: 0,
      averageAccuracy: 0.0,
      lastPerformed: now,
    );
  }

  static RepLogic _parseRepLogicFromConfig(Map<String, dynamic>? repLogicConfig) {
    if (repLogicConfig == null) {
      return RepLogic(primaryJoint: 'knee');
    }

    final phase1 = (repLogicConfig['phase_1_eccentric'] ??
            repLogicConfig['phase_1_concentric'])
        as Map<String, dynamic>?;
    final phase2 = (repLogicConfig['phase_2_concentric'] ??
            repLogicConfig['phase_2_eccentric'])
        as Map<String, dynamic>?;
    final holdCondition =
        repLogicConfig['hold_condition'] as Map<String, dynamic>?;

    return RepLogic(
      primaryJoint: repLogicConfig['primary_joint'] as String? ?? 'knee',
      phase1Eccentric: phase1 == null
          ? null
          : Phase(
              condition: phase1['condition'] as String? ?? '',
              description: phase1['description'] as String? ?? '',
              threshold: (phase1['threshold'] as num?)?.toDouble() ?? 0.0,
            ),
      phase2Concentric: phase2 == null
          ? null
          : Phase(
              condition: phase2['condition'] as String? ?? '',
              description: phase2['description'] as String? ?? '',
              threshold: (phase2['threshold'] as num?)?.toDouble() ?? 0.0,
            ),
      holdCondition: holdCondition == null
          ? null
          : HoldCondition(
              minKneeAngle:
                  ((holdCondition['knee_angle'] as Map<String, dynamic>?)?['min']
                          as num?)
                      ?.toDouble(),
              maxKneeAngle:
                  ((holdCondition['knee_angle'] as Map<String, dynamic>?)?['max']
                          as num?)
                      ?.toDouble(),
              minBackAngle:
                  ((holdCondition['back_angle'] as Map<String, dynamic>?)?['min']
                          as num?)
                      ?.toDouble(),
              maxBackAngle:
                  ((holdCondition['back_angle'] as Map<String, dynamic>?)?['max']
                          as num?)
                      ?.toDouble(),
            ),
      countType: repLogicConfig['count_type'] as String?,
    );
  }

  static List<FormCheck> _parseFormChecksFromConfig(
    List<dynamic>? formChecksConfig,
  ) {
    if (formChecksConfig == null) return [];

    return formChecksConfig
        .whereType<Map<String, dynamic>>()
        .map(
          (check) => FormCheck(
            id: (check['id'] as String?) ?? '',
            joints: (check['joints'] as List<dynamic>? ?? const [])
                .whereType<String>()
                .toList(),
            checkType: check['check_type'] as String?,
            targetJoint: check['target_joint'] as String?,
            jointsPair: (check['joints_pair'] as List<dynamic>? ?? const [])
                .whereType<String>()
                .toList(),
            tolerance: (check['tolerance'] as num?)?.toDouble(),
            minAngle: (check['min_angle'] as num?)?.toDouble() ?? 0.0,
            maxAngle: (check['max_angle'] as num?)?.toDouble() ?? 180.0,
            warningMessage: (check['warning_message'] as String?) ?? '',
          ),
        )
        .toList();
  }

  static Future<void> _rebuildExerciseStatsForIds(
    List<String> exerciseIds,
  ) async {
    if (exerciseIds.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      for (final exerciseId in exerciseIds) {
        final exercise = await _isar.exerciseModels
            .filter()
            .exerciseIdEqualTo(exerciseId)
            .findFirst();
        if (exercise == null) {
          continue;
        }

        final logs = await _isar.exerciseLogs
            .filter()
            .exerciseIdEqualTo(exerciseId)
            .findAll();

        if (logs.isEmpty) {
          exercise.totalReps = 0;
          exercise.averageAccuracy = 0.0;
          await _isar.exerciseModels.put(exercise);
          continue;
        }

        final totalReps =
            logs.fold<int>(0, (sum, log) => sum + log.totalRepetitions);
        final weightedAccuracySum = logs.fold<double>(
          0.0,
          (sum, log) => sum + (log.averageAccuracy * log.totalRepetitions),
        );
        final latestTimestamp = logs
            .map((log) => log.timestamp)
            .reduce((a, b) => a.isAfter(b) ? a : b);

        exercise.totalReps = totalReps;
        exercise.averageAccuracy =
            totalReps > 0 ? (weightedAccuracySum / totalReps) : 0.0;
        exercise.lastPerformed = latestTimestamp;

        await _isar.exerciseModels.put(exercise);
      }
    });
  }

  static String _normalizeExerciseId(String id) {
    return id.toLowerCase().replaceAll('-', '_').trim();
  }
  
  // Exercise Log CRUD Operations
  static Stream<List<ExerciseLog>> watchExerciseLogs({
    String? exerciseId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // QueryBuilder ကို တိုက်ရိုက် filter ထဲမှာ မဆောက်ဘဲ
    // isar instance ကနေ တိုက်ရိုက် query ဆောက်တဲ့ ပုံစံပါ
    final query = _isar.exerciseLogs.filter();
    
    QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition> finalQuery;

    if (exerciseId != null) {
      finalQuery = query.exerciseIdEqualTo(exerciseId);
    } else {
      finalQuery = query as QueryBuilder<ExerciseLog, ExerciseLog, QAfterFilterCondition>;
    }

    // နောက်ထပ် logic တွေ ထပ်ထည့်ချင်ရင် finalQuery ကို သုံးပါ
    return finalQuery.build().watch(fireImmediately: true);
  }
  
  static Future<void> saveExerciseLog(ExerciseLog log) async {
    final sanitizedLog = _sanitizeExerciseLog(log);
    await _isar.writeTxn(() async {
      await _isar.exerciseLogs.put(sanitizedLog);

      // Keep UserActivity (weekly/monthly summaries + streak inputs) in sync
      // when logs are saved directly via IsarService (e.g., ExerciseScreen).
      final dayDate = DateTime(
        sanitizedLog.timestamp.year,
        sanitizedLog.timestamp.month,
        sanitizedLog.timestamp.day,
      );
      var activity = await _isar.userActivitys
          .filter()
          .dateEqualTo(dayDate)
          .findFirst();
      activity ??= UserActivity(date: dayDate);
      activity.addWorkout(
        exerciseId: sanitizedLog.exerciseId,
        reps: sanitizedLog.totalRepetitions,
        duration: Duration(seconds: sanitizedLog.sessionDuration),
        accuracy: sanitizedLog.averageAccuracy,
      );
      await _isar.userActivitys.put(activity);
       
      // Update exercise stats
      final exercise = await _isar.exerciseModels
          .where()
          .exerciseIdEqualTo(sanitizedLog.exerciseId)
          .findFirst();
      
      if (exercise != null) {
        // Recalculate stats from all logs for correctness
        final allLogs = await _isar.exerciseLogs
            .where()
            .exerciseIdEqualTo(sanitizedLog.exerciseId)
            .findAll();

        final totalReps = allLogs.fold(
          0,
          (sum, entry) => sum + entry.totalRepetitions,
        );

        final weightedAccuracySum = allLogs.fold(
          0.0,
          (sum, entry) =>
              sum + (entry.averageAccuracy * entry.totalRepetitions),
        );

        exercise.totalReps = totalReps;
        exercise.averageAccuracy =
            totalReps > 0 ? (weightedAccuracySum / totalReps) : 0.0;
        exercise.lastPerformed = sanitizedLog.timestamp;
        
        await _isar.exerciseModels.put(exercise);
      }
    });
  }

  static ExerciseLog _sanitizeExerciseLog(ExerciseLog log) {
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
      final sanitizedPositions = warning.jointPosition
          ?.where((value) => value.isFinite)
          .toList();
      return FormWarning(
        warningId: warning.warningId.trim(),
        message: warning.message.trim(),
        timestamp: warning.timestamp,
        jointPosition: sanitizedPositions,
      );
    }).toList();

    return log;
  }

  static int _clampInt(int value, {int min = 0, int max = 1000000}) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static double _clampUnit(double value) {
    if (!value.isFinite) return 0.0;
    if (value < 0.0) return 0.0;
    if (value > 1.0) return 1.0;
    return value;
  }
  
  // Get statistics for charts
  static Future<Map<String, dynamic>> getExerciseStatistics(
    String exerciseId, 
    DateTimeRange range,
  
  ) async {
    final logs = await _isar.exerciseLogs
    .filter()
    .exerciseIdEqualTo(exerciseId)
    .timestampGreaterThan(range.start)
    .and()
    .timestampLessThan(range.end)
    .findAll();
 
    
    if (logs.isEmpty) {
      return {
        'totalReps': 0,
        'averageAccuracy': 0.0,
        'bestSession': null,
        'trend': 0.0,
        'dailyAverage': 0,
      };
    }
    
    // Calculate statistics
    final totalReps = logs.fold(0, (sum, log) => sum + log.totalRepetitions);
    final totalRepsForAccuracy =
        logs.fold(0, (sum, log) => sum + log.totalRepetitions);
    final weightedAccuracySum = logs.fold(
      0.0,
      (sum, log) => sum + (log.averageAccuracy * log.totalRepetitions),
    );
    final averageAccuracy = totalRepsForAccuracy > 0
        ? (weightedAccuracySum / totalRepsForAccuracy)
        : 0.0;
    
    final bestSession = logs.reduce(
      (a, b) => a.averageAccuracy > b.averageAccuracy ? a : b,
    );
    
    // Calculate trend (improvement over time)
    final sortedLogs = List<ExerciseLog>.from(logs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    final firstWeekAverage = sortedLogs
        .take(7)
        .fold(0.0, (sum, log) => sum + log.averageAccuracy) / 7;
    
    final lastWeekAverage = sortedLogs
        .reversed
        .take(7)
        .fold(0.0, (sum, log) => sum + log.averageAccuracy) / 7;
    
    final trend = lastWeekAverage - firstWeekAverage;
    
    return {
      'totalReps': totalReps,
      'averageAccuracy': averageAccuracy,
      'bestSession': bestSession,
      'trend': trend,
      'dailyAverage': totalReps ~/ logs.length,
    };
  }
  
  // Batch operations for performance
  static Future<void> batchInsertLogs(List<ExerciseLog> logs) async {
    await _isar.writeTxn(() async {
      await _isar.exerciseLogs.putAll(logs);
    });
  }
  
  // Clear all data (for testing/reset)
  static Future<void> clearAllData() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
    await _seedInitialData();
  }
  
  // Get instance for direct access if needed
  static Isar get instance => _isar;
}
