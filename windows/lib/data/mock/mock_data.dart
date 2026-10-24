// lib/data/mock/mock_data.dart
import 'package:isar/isar.dart';
import '../../data/services/isar_service.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/exercise_log.dart' as data;
import '../../data/models/badge_achievement.dart';
import 'dart:math';

class MockData {
  static Future<void> seedMockData() async {
    try {
      final isar = IsarService.instance;
      
      // Check if data exists
      final exerciseCount = await isar.exerciseModels.where().count();
      final logCount = await isar.exerciseLogs.where().count();
      final badgeCount = await isar.badgeAchievements.where().count();
      
      print('Current counts - Exercises: $exerciseCount, Logs: $logCount, Badges: $badgeCount');
      
      if (exerciseCount == 0) {
        await _seedMockExercises(isar);
      }
      
      if (logCount == 0) {
        await _seedMockLogs(isar);
      }
      
      if (badgeCount == 0) {
        await _seedMockBadges(isar);
      }
      
      print('Mock data seeded successfully');
    } catch (e) {
      print('Error seeding mock data: $e');
      print('Stack trace: ${e.toString()}');
    }
  }
  
  static Future<void> _seedMockExercises(Isar isar) async {
    final exercises = [
      ExerciseModel(
        exerciseId: 'squat',
        name: 'Squat',
        type: 'dynamic',
        viewRequired: 'side',
        repLogic: RepLogic(
          primaryJoint: 'knee',
          phase1Eccentric: Phase(
            condition: 'angle < 100',
            description: 'Down',
            threshold: 100.0,
          ),
          phase2Concentric: Phase(
            condition: 'angle > 160',
            description: 'Up',
            threshold: 160.0,
          ),
        ),
        formChecks: [
          FormCheck(
            id: 'back_straight',
            joints: ['shoulder', 'hip', 'knee'],
            minAngle: 160.0,
            maxAngle: 180.0,
            warningMessage: 'Keep your back straight!',
          ),
        ],
        totalReps: Random().nextInt(100),
        averageAccuracy: 70 + Random().nextDouble() * 25,
        lastPerformed: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      ),
      ExerciseModel(
        exerciseId: 'pushup',
        name: 'Push-up',
        type: 'dynamic',
        viewRequired: 'side',
        repLogic: RepLogic(
          primaryJoint: 'elbow',
          phase1Eccentric: Phase(
            condition: 'angle > 160',
            description: 'Down',
            threshold: 160.0,
          ),
          phase2Concentric: Phase(
            condition: 'angle < 90',
            description: 'Up',
            threshold: 90.0,
          ),
        ),
        formChecks: [
          FormCheck(
            id: 'body_straight',
            joints: ['shoulder', 'hip', 'ankle'],
            minAngle: 170.0,
            maxAngle: 190.0,
            warningMessage: 'Keep your body straight!',
          ),
        ],
        totalReps: Random().nextInt(80),
        averageAccuracy: 65 + Random().nextDouble() * 30,
        lastPerformed: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      ),
      ExerciseModel(
        exerciseId: 'bicep_curl',
        name: 'Bicep Curl',
        type: 'dynamic',
        viewRequired: 'front',
        repLogic: RepLogic(
          primaryJoint: 'elbow',
          phase1Eccentric: Phase(
            condition: 'angle > 160',
            description: 'Down',
            threshold: 160.0,
          ),
          phase2Concentric: Phase(
            condition: 'angle < 40',
            description: 'Up',
            threshold: 40.0,
          ),
        ),
        formChecks: [
          FormCheck(
            id: 'elbow_stationary',
            joints: ['shoulder', 'elbow', 'wrist'],
            minAngle: 80.0,
            maxAngle: 100.0,
            warningMessage: 'Keep your elbow stationary!',
          ),
        ],
        totalReps: Random().nextInt(60),
        averageAccuracy: 75 + Random().nextDouble() * 20,
        lastPerformed: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      ),
      ExerciseModel(
        exerciseId: 'shoulder_press',
        name: 'Shoulder Press',
        type: 'dynamic',
        viewRequired: 'side',
        repLogic: RepLogic(
          primaryJoint: 'elbow',
          phase1Eccentric: Phase(
            condition: 'angle < 90',
            description: 'Down',
            threshold: 90.0,
          ),
          phase2Concentric: Phase(
            condition: 'angle > 170',
            description: 'Up',
            threshold: 170.0,
          ),
        ),
        formChecks: [
          FormCheck(
            id: 'back_straight',
            joints: ['shoulder', 'hip', 'knee'],
            minAngle: 170.0,
            maxAngle: 180.0,
            warningMessage: 'Keep your back straight!',
          ),
        ],
        totalReps: Random().nextInt(50),
        averageAccuracy: 68 + Random().nextDouble() * 25,
        lastPerformed: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      ),
      ExerciseModel(
        exerciseId: 'situp',
        name: 'Sit-up',
        type: 'dynamic',
        viewRequired: 'side',
        repLogic: RepLogic(
          primaryJoint: 'hip',
          phase1Eccentric: Phase(
            condition: 'angle > 160',
            description: 'Down',
            threshold: 160.0,
          ),
          phase2Concentric: Phase(
            condition: 'angle < 90',
            description: 'Up',
            threshold: 90.0,
          ),
        ),
        formChecks: [
          FormCheck(
            id: 'neck_straight',
            joints: ['ear', 'shoulder', 'hip'],
            minAngle: 150.0,
            maxAngle: 170.0,
            warningMessage: 'Don\'t strain your neck!',
          ),
        ],
        totalReps: Random().nextInt(40),
        averageAccuracy: 72 + Random().nextDouble() * 23,
        lastPerformed: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      ),
      ExerciseModel(
        exerciseId: 'leg_extension',
        name: 'Leg Extension',
        type: 'dynamic',
        viewRequired: 'side',
        repLogic: RepLogic(
          primaryJoint: 'knee',
          phase1Eccentric: Phase(
            condition: 'angle > 160',
            description: 'Down',
            threshold: 160.0,
          ),
          phase2Concentric: Phase(
            condition: 'angle < 90',
            description: 'Up',
            threshold: 90.0,
          ),
        ),
        formChecks: [
          FormCheck(
            id: 'hip_stationary',
            joints: ['hip', 'knee', 'ankle'],
            minAngle: 80.0,
            maxAngle: 100.0,
            warningMessage: 'Keep your hip stationary!',
          ),
        ],
        totalReps: Random().nextInt(70),
        averageAccuracy: 78 + Random().nextDouble() * 18,
        lastPerformed: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      ),
      ExerciseModel(
        exerciseId: 'wall_sit',
        name: 'Wall Sit',
        type: 'static',
        viewRequired: 'side',
        repLogic: RepLogic(
          countType: 'duration',
          holdCondition: HoldCondition(
            minKneeAngle: 80.0,
            maxKneeAngle: 100.0,
            minBackAngle: 170.0,
            maxBackAngle: 180.0,
          ),
        ),
        formChecks: [
          FormCheck(
            id: 'knee_angle',
            joints: ['hip', 'knee', 'ankle'],
            minAngle: 80.0,
            maxAngle: 100.0,
            warningMessage: 'Maintain 90-degree knee angle!',
          ),
        ],
        totalReps: Random().nextInt(20),
        averageAccuracy: 85 + Random().nextDouble() * 15,
        lastPerformed: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
      ),
    ];
    
    await isar.writeTxn(() async {
      await isar.exerciseModels.putAll(exercises);
    });
    
    print('Seeded ${exercises.length} mock exercises');
  }
  
  static Future<void> _seedMockLogs(Isar isar) async {
  final now = DateTime.now();
  
  final logs = [
    // TODAY'S LOGS - အရေးကြီးဆုံး
    data.ExerciseLog(
      exerciseId: 'squat',
      timestamp: now, // ဒီနေ့
      sessionDuration: 300,
      totalRepetitions: 30,
      averageAccuracy: 85.5,
      maxAccuracy: 95.0,
      minAccuracy: 75.0,
      repDetails: [
        data.RepDetail(repNumber: 1, accuracy: 85.0, durationMs: 4000),
        data.RepDetail(repNumber: 2, accuracy: 87.0, durationMs: 4000),
        data.RepDetail(repNumber: 3, accuracy: 90.0, durationMs: 5000),
      ],
      formWarnings: [],
    ),
    data.ExerciseLog(
      exerciseId: 'pushup',
      timestamp: now.subtract(const Duration(hours: 2)), // ဒီနေ့ နေ့လည်
      sessionDuration: 240,
      totalRepetitions: 25,
      averageAccuracy: 78.0,
      maxAccuracy: 90.0,
      minAccuracy: 65.0,
      repDetails: [
        data.RepDetail(repNumber: 1, accuracy: 80.0, durationMs: 3000),
        data.RepDetail(repNumber: 2, accuracy: 75.0, durationMs: 4000),
      ],
      formWarnings: [],
    ),
    
    // YESTERDAY'S LOGS
    data.ExerciseLog(
      exerciseId: 'squat',
      timestamp: now.subtract(const Duration(days: 1)),
      sessionDuration: 280,
      totalRepetitions: 20,
      averageAccuracy: 82.0,
      maxAccuracy: 88.0,
      minAccuracy: 75.0,
      repDetails: [
        data.RepDetail(repNumber: 1, accuracy: 80.0, durationMs: 5000),
        data.RepDetail(repNumber: 2, accuracy: 84.0, durationMs: 5000),
      ],
      formWarnings: [],
    ),
    
    // OLDER LOGS
    data.ExerciseLog(
      exerciseId: 'bicep_curl',
      timestamp: now.subtract(const Duration(days: 4)),
      sessionDuration: 200,
      totalRepetitions: 35,
      averageAccuracy: 88.0,
      maxAccuracy: 95.0,
      minAccuracy: 80.0,
      repDetails: [
        data.RepDetail(repNumber: 1, accuracy: 85.0, durationMs: 3000),
      ],
      formWarnings: [],
    ),
  ];
  
  await isar.writeTxn(() async {
    await isar.exerciseLogs.putAll(logs);
  });
  
  print('✅ Seeded ${logs.length} mock logs (including today\'s logs)');
}
  
  static Future<void> _seedMockBadges(Isar isar) async {
    final badges = [
      BadgeAchievement(
        badgeId: 'first_workout',
        name: 'First Workout',
        description: 'Complete your first workout',
        iconPath: 'assets/badges/first.png',
        tier: BadgeTier.bronze,
        unlockedAt: DateTime.now().subtract(Duration(days: 4)),
        unlockedFor: 'general',
        progress: 1,
        requirement: 1,
      ),
      BadgeAchievement(
        badgeId: 'streak_3',
        name: '3 Day Streak',
        description: 'Workout for 3 consecutive days',
        iconPath: 'assets/badges/week.png',
        tier: BadgeTier.bronze,
        unlockedAt: DateTime.now(),
        unlockedFor: 'general',
        progress: 2,
        requirement: 3,
      ),
      BadgeAchievement(
        badgeId: 'total_reps_100',
        name: '100 Reps',
        description: 'Complete 100 total repetitions',
        iconPath: 'assets/badges/calories.png',
        tier: BadgeTier.silver,
        unlockedAt: DateTime.now().subtract(Duration(days: 2)),
        unlockedFor: 'general',
        progress: 110,
        requirement: 100,
      ),
      BadgeAchievement(
        badgeId: 'accuracy_90',
        name: 'Accuracy Master',
        description: 'Achieve 90% accuracy in any exercise',
        iconPath: 'assets/badges/accuracy.png',
        tier: BadgeTier.silver,
        unlockedAt: DateTime.now().subtract(Duration(days: 1)),
        unlockedFor: 'general',
        progress: 95,
        requirement: 90,
      ),
      BadgeAchievement(
        badgeId: 'workout_10',
        name: 'Dedicated Trainee',
        description: 'Complete 10 total workouts',
        iconPath: 'assets/badges/complete.png',
        tier: BadgeTier.gold,
        unlockedAt: DateTime.now(),
        unlockedFor: 'general',
        progress: 4,
        requirement: 10,
      ),
      BadgeAchievement(
        badgeId: 'all_exercises',
        name: 'Versatile Athlete',
        description: 'Try all available exercises',
        iconPath: 'assets/badges/complete.png',
        tier: BadgeTier.platinum,
        unlockedAt: DateTime.now(),
        unlockedFor: 'general',
        progress: 3,
        requirement: 7,
      ),
    ];
    
    await isar.writeTxn(() async {
      await isar.badgeAchievements.putAll(badges);
    });
    
    print('Seeded ${badges.length} mock badges');
  }
}