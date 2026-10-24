import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/badge_achievement.dart';
import '../models/exercise_log.dart';
import '../models/exercise_model.dart';
import '../models/user_activity.dart';
import '../../features/premium/premium_license_service.dart';
import 'isar_service.dart';

class DataManagementService {
  static Future<void> clearUserData() async {
    final isar = IsarService.instance;
    final exercises = await isar.exerciseModels.where().findAll();

    for (final exercise in exercises) {
      exercise.totalReps = 0;
      exercise.averageAccuracy = 0.0;
    }

    await isar.writeTxn(() async {
      await isar.exerciseLogs.clear();
      await isar.userActivitys.clear();
      await isar.badgeAchievements.clear();
      await isar.exerciseModels.putAll(exercises);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await PremiumLicenseService().clearAllSensitiveData();
  }
}
