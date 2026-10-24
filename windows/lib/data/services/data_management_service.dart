import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/badge_achievement.dart';
import '../models/exercise_log.dart';
import '../models/exercise_model.dart';
import '../models/user_activity.dart';
import '../../features/premium/premium_license_service.dart';
import 'isar_service.dart';

class DataManagementService {
  static Future<File> exportUserDataToJson() async {
    final isar = IsarService.instance;
    final prefs = await SharedPreferences.getInstance();

    final exercises = await isar.exerciseModels.where().findAll();
    final logs = await isar.exerciseLogs.where().findAll();
    final activities = await isar.userActivitys.where().findAll();
    final badges = await isar.badgeAchievements.where().findAll();

    exercises.sort((a, b) => a.exerciseId.compareTo(b.exerciseId));
    logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    activities.sort((a, b) => a.date.compareTo(b.date));
    badges.sort((a, b) => a.badgeId.compareTo(b.badgeId));

    final exportPayload = <String, dynamic>{
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'preferences': _serializePreferences(prefs),
      'exerciseModels': exercises
          .map(
            (exercise) => <String, dynamic>{
              'exerciseId': exercise.exerciseId,
              'name': exercise.name,
              'type': exercise.type,
              'viewRequired': exercise.viewRequired,
              'totalReps': exercise.totalReps,
              'averageAccuracy': exercise.averageAccuracy,
              'lastPerformed': exercise.lastPerformed.toIso8601String(),
            },
          )
          .toList(),
      'exerciseLogs': logs
          .map(
            (log) => <String, dynamic>{
              'id': log.id,
              'exerciseId': log.exerciseId,
              'timestamp': log.timestamp.toIso8601String(),
              'sessionDurationSeconds': log.sessionDuration,
              'totalRepetitions': log.totalRepetitions,
              'averageAccuracy': log.averageAccuracy,
              'maxAccuracy': log.maxAccuracy,
              'minAccuracy': log.minAccuracy,
              'isPremiumSession': log.isPremiumSession,
              'videoPath': log.videoPath,
              'repDetails': log.repDetails
                  .map(
                    (detail) => <String, dynamic>{
                      'repNumber': detail.repNumber,
                      'accuracy': detail.accuracy,
                      'durationMs': detail.durationMs,
                      'formPerfect': detail.formPerfect,
                      'jointAngles': detail.jointAngles
                          .map(
                            (angle) => <String, dynamic>{
                              'jointName': angle.jointName,
                              'angle': angle.angle,
                              'timestamp': angle.timestamp?.toIso8601String(),
                            },
                          )
                          .toList(),
                    },
                  )
                  .toList(),
              'formWarnings': log.formWarnings
                  .map(
                    (warning) => <String, dynamic>{
                      'warningId': warning.warningId,
                      'message': warning.message,
                      'timestamp': warning.timestamp?.toIso8601String(),
                      'jointPosition': warning.jointPosition,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'userActivities':
          activities.map((activity) => activity.toJson()).toList(),
      'badges': badges
          .map(
            (badge) => <String, dynamic>{
              'badgeId': badge.badgeId,
              'name': badge.name,
              'description': badge.description,
              'iconPath': badge.iconPath,
              'tier': badge.tier.name,
              'unlockedAt': badge.unlockedAt.toIso8601String(),
              'unlockedFor': badge.unlockedFor,
              'progress': badge.progress,
              'requirement': badge.requirement,
              'isUnlocked': badge.isUnlocked,
            },
          )
          .toList(),
    };

    Directory exportDir;
    if (Platform.isAndroid) {
      final rootDir = Directory('/storage/emulated/0');
      if (await rootDir.exists()) {
        exportDir = Directory(
          '${rootDir.path}${Platform.pathSeparator}HealthyLifeExports',
        );
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        exportDir = Directory(
          '${appDir.path}${Platform.pathSeparator}exports',
        );
      }
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      exportDir = Directory('${appDir.path}${Platform.pathSeparator}exports');
    }
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final file = File(
      '${exportDir.path}${Platform.pathSeparator}${_buildFileName()}',
    );
    final jsonText = const JsonEncoder.withIndent('  ').convert(exportPayload);
    await file.writeAsString(jsonText);

    return file;
  }

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

  static Map<String, dynamic> _serializePreferences(SharedPreferences prefs) {
    final map = <String, dynamic>{};

    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value is String ||
          value is bool ||
          value is int ||
          value is double ||
          value is List<String>) {
        map[key] = value;
      } else {
        map[key] = value?.toString();
      }
    }

    return map;
  }

  static String _buildFileName() {
    final now = DateTime.now();
    final yyyy = now.year.toString().padLeft(4, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return 'healthy_life_export_$yyyy$mm${dd}_$hh$min$ss.json';
  }
}
