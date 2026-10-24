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
        // Seed exercise configurations from JSON
        final exercises = [
          // Add all 7 exercises from JSON configuration
          ExerciseModel(
            exerciseId: 'squat',
            name: 'Squat',
            type: 'dynamic',
            viewRequired: 'side',
            repLogic: RepLogic(
              primaryJoint: 'knee',
              phase1Eccentric: Phase(
                condition: 'angle < 100',
                description: 'Squat Down (Depth)',
                threshold: 100,
              ),
              phase2Concentric: Phase(
                condition: 'angle > 160',
                description: 'Stand Up',
                threshold: 160,
              ),
            ),
            formChecks: [
            ],
            lastPerformed: DateTime.now(),
          ),
           ExerciseModel(
            exerciseId: 'pushup',
            name: 'Push-up',
            type: 'dynamic',
            viewRequired: 'side',
            repLogic: RepLogic(
              primaryJoint: 'elbow',
              phase1Eccentric: Phase(
                condition: 'angle < 90',
                description: 'Lower Body',
                threshold: 90,
              ),
              phase2Concentric: Phase(
                condition: 'angle > 160',
                description: 'Push Up',
                threshold: 160,
              ),
            ),
            formChecks: [
              FormCheck(
                id: 'body_plank',
                joints: ['shoulder', 'hip', 'ankle'],
                minAngle: 160,
                maxAngle: 180,
                warningMessage: '',
              ),
            ],
            lastPerformed: DateTime.now(),
          ),
          
          // Bicep Curl exercise
          ExerciseModel(
            exerciseId: 'bicep_curl',
            name: 'Bicep Curl',
            type: 'dynamic',
            viewRequired: 'side',
            repLogic: RepLogic(
              primaryJoint: 'elbow',
              phase1Eccentric: Phase(
                condition: 'angle < 50',
                description: 'Curl Up',
                threshold: 50,
              ),
              phase2Concentric: Phase(
                condition: 'angle > 160',
                description: 'Lower Arm',
                threshold: 160,
              ),
            ),
            formChecks: [
              FormCheck(
                id: 'elbow_stability',
                joints: ['shoulder', 'elbow', 'wrist'],
                checkType: 'static_joint_position',
                targetJoint: 'elbow',
                warningMessage: '',
              ),
            ],
            lastPerformed: DateTime.now(),
          ),
          
          // Shoulder Press exercise
          ExerciseModel(
            exerciseId: 'shoulder_press',
            name: 'Shoulder Press',
            type: 'dynamic',
            viewRequired: 'front',
            repLogic: RepLogic(
              primaryJoint: 'elbow',
              phase1Eccentric: Phase(
                condition: 'angle > 160',
                description: 'Push Up (Extension)',
                threshold: 160,
              ),
              phase2Concentric: Phase(
                condition: 'angle < 90',
                description: 'Lower Down',
                threshold: 90,
              ),
            ),
            formChecks: [
              FormCheck(
                id: 'arm_symmetry',
                checkType: 'symmetry',
                jointsPair: ['left_elbow', 'right_elbow'],
                tolerance: 15,
                warningMessage: '',
              ),
            ],
            lastPerformed: DateTime.now(),
          ),
          
          // Sit-up exercise
          ExerciseModel(
            exerciseId: 'situp',
            name: 'Sit-up',
            type: 'dynamic',
            viewRequired: 'side',
            repLogic: RepLogic(
              primaryJoint: 'hip',
              phase1Eccentric: Phase(
                condition: 'angle < 60',
                description: 'Sit Up',
                threshold: 60,
              ),
              phase2Concentric: Phase(
                condition: 'angle > 150',
                description: 'Lay Down',
                threshold: 150,
              ),
            ),
            formChecks: [
              FormCheck(
                id: 'neck_strain',
                joints: ['ear', 'shoulder', 'hip'],
                minAngle: 150,
                maxAngle: 180,
                warningMessage: '',
              ),
            ],
            lastPerformed: DateTime.now(),
          ),
          
          // Leg Extension exercise
          ExerciseModel(
            exerciseId: 'leg_extension',
            name: 'Leg Extension',
            type: 'dynamic',
            viewRequired: 'side',
            repLogic: RepLogic(
              primaryJoint: 'knee',
              phase1Eccentric: Phase(
                condition: 'angle > 160',
                description: 'Extend Leg',
                threshold: 160,
              ),
              phase2Concentric: Phase(
                condition: 'angle < 100',
                description: 'Lower Leg',
                threshold: 100,
              ),
            ),
            formChecks: [
              FormCheck(
                id: 'upper_body_stability',
                joints: ['shoulder', 'hip', 'knee'],
                minAngle: 80,
                maxAngle: 110,
                warningMessage: '',
              ),
            ],
            lastPerformed: DateTime.now(),
          ),
          
          // Wall Sit exercise
          ExerciseModel(
            exerciseId: 'wall_sit',
            name: 'Wall Sit',
            type: 'static',
            viewRequired: 'side',
            repLogic: RepLogic(
              countType: 'duration',
              holdCondition: HoldCondition(
                minKneeAngle: 80,
                maxKneeAngle: 100,
                minBackAngle: 170,
                maxBackAngle: 180,
              ),
            ),
            formChecks: [
              FormCheck(
                id: 'knee_angle_check',
                joints: ['hip', 'knee', 'ankle'],
                minAngle: 80,
                maxAngle: 100,
                warningMessage: '',
              ),
            ],
            lastPerformed: DateTime.now(),
          ),
        
        ];
        
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
    }
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
    await _isar.writeTxn(() async {
      await _isar.exerciseLogs.put(log);

      // Keep UserActivity (weekly/monthly summaries + streak inputs) in sync
      // when logs are saved directly via IsarService (e.g., ExerciseScreen).
      final dayDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      var activity = await _isar.userActivitys
          .filter()
          .dateEqualTo(dayDate)
          .findFirst();
      activity ??= UserActivity(date: dayDate);
      activity.addWorkout(
        exerciseId: log.exerciseId,
        reps: log.totalRepetitions,
        duration: Duration(seconds: log.sessionDuration),
        accuracy: log.averageAccuracy,
      );
      await _isar.userActivitys.put(activity);
       
      // Update exercise stats
      final exercise = await _isar.exerciseModels
          .where()
          .exerciseIdEqualTo(log.exerciseId)
          .findFirst();
      
      if (exercise != null) {
        // Recalculate stats from all logs for correctness
        final allLogs = await _isar.exerciseLogs
            .where()
            .exerciseIdEqualTo(log.exerciseId)
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
        exercise.lastPerformed = log.timestamp;
        
        await _isar.exerciseModels.put(exercise);
      }
    });
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
