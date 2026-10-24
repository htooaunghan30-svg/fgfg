import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../../data/models/badge_achievement.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/exercise_log.dart';
import '../../data/models/user_activity.dart';
import '../../data/services/isar_service.dart';
import 'badge_manager.dart';
import 'badge_uptime_clock.dart';

enum MonthlyBadgeDebugScenario {
  bronze,
  silver,
  gold,
}

extension MonthlyBadgeDebugScenarioX on MonthlyBadgeDebugScenario {
  String get label {
    switch (this) {
      case MonthlyBadgeDebugScenario.bronze:
        return 'Bronze';
      case MonthlyBadgeDebugScenario.silver:
        return 'Silver';
      case MonthlyBadgeDebugScenario.gold:
        return 'Gold';
    }
  }

  int get completedMonthlyPhases {
    switch (this) {
      case MonthlyBadgeDebugScenario.bronze:
        return 1;
      case MonthlyBadgeDebugScenario.silver:
        return 2;
      case MonthlyBadgeDebugScenario.gold:
        return 3;
    }
  }
}

class MonthlyBadgeDebugResult {
  static const List<String> orderedBadgeIds = [
    'first_workout',
    'prep_phase_15_v2',
    'month_1_bronze',
    'month_2_silver',
    'month_3_gold',
  ];

  final MonthlyBadgeDebugScenario scenario;
  final int seededLogCount;
  final Map<String, BadgeAchievement> badgesById;

  const MonthlyBadgeDebugResult({
    required this.scenario,
    required this.seededLogCount,
    required this.badgesById,
  });

  BadgeAchievement? badge(String badgeId) => badgesById[badgeId];

  String get summary {
    final prep = badge('prep_phase_15_v2');
    final bronze = badge('month_1_bronze');
    final silver = badge('month_2_silver');
    final gold = badge('month_3_gold');
    return 'Seeded $seededLogCount logs. '
        'Prep ${_badgeState(prep)}, '
        'Bronze ${_badgeState(bronze)}, '
        'Silver ${_badgeState(silver)}, '
        'Gold ${_badgeState(gold)}.';
  }

  static String _badgeState(BadgeAchievement? badge) {
    if (badge == null) {
      return 'missing';
    }
    return '${badge.progress}/${badge.requirement}'
        '${badge.isUnlocked ? ' unlocked' : ''}';
  }
}

class MonthlyBadgeDebugHelper {
  static final DateTime _startDate = DateTime.utc(2026, 1, 1, 9);
  static const String _upperExerciseId = 'pushup';
  static const String _coreExerciseId = 'situp';
  static const String _lowerExerciseId = 'squat';

  static const List<_MonthlyWorkoutSpec> _monthlyWorkoutSpecs = [
    _MonthlyWorkoutSpec(
      upperReps: 18,
      upperSets: 3,
      coreReps: 24,
      coreSets: 3,
      lowerReps: 30,
      lowerSets: 3,
    ),
    _MonthlyWorkoutSpec(
      upperReps: 24,
      upperSets: 4,
      coreReps: 32,
      coreSets: 4,
      lowerReps: 40,
      lowerSets: 4,
    ),
    _MonthlyWorkoutSpec(
      upperReps: 30,
      upperSets: 4,
      coreReps: 40,
      coreSets: 4,
      lowerReps: 50,
      lowerSets: 4,
    ),
  ];

  final BadgeUptimeClock _uptimeClock;

  MonthlyBadgeDebugHelper({
    BadgeUptimeClock? uptimeClock,
  }) : _uptimeClock = uptimeClock ?? BadgeUptimeClock();

  Future<MonthlyBadgeDebugResult> seedScenario(
    MonthlyBadgeDebugScenario scenario,
  ) async {
    if (!kDebugMode) {
      throw StateError(
          'MonthlyBadgeDebugHelper is only available in debug mode.');
    }

    final isar = IsarService.instance;
    await _resetSandbox(isar);

    final logs = buildScenarioLogs(scenario);
    for (final log in logs) {
      await IsarService.saveExerciseLog(log);
    }

    await _uptimeClock.debugSeedStableTimeline(logs);
    await BadgeManager().checkAndUpdateBadges(logs.last);

    final badges = await isar.badgeAchievements.where().findAll();
    badges.sort((a, b) => a.badgeId.compareTo(b.badgeId));

    return MonthlyBadgeDebugResult(
      scenario: scenario,
      seededLogCount: logs.length,
      badgesById: {for (final badge in badges) badge.badgeId: badge},
    );
  }

  @visibleForTesting
  List<ExerciseLog> buildScenarioLogs(MonthlyBadgeDebugScenario scenario) {
    final logs = <ExerciseLog>[];
    var dayOffset = 0;

    _addWorkoutDay(
      logs,
      _startDate.add(Duration(days: dayOffset)),
      upperReps: 8,
      upperSets: 1,
      coreReps: 10,
      coreSets: 1,
      lowerReps: 12,
      lowerSets: 1,
    );
    dayOffset += 1;

    for (var prepDay = 1; prepDay <= 15; prepDay++) {
      final plan = _prepWorkoutSpec(prepDay);
      if (plan != null) {
        _addWorkoutDay(
          logs,
          _startDate.add(Duration(days: dayOffset)),
          upperReps: plan.upperReps,
          upperSets: plan.upperSets,
          coreReps: plan.coreReps,
          coreSets: plan.coreSets,
          lowerReps: plan.lowerReps,
          lowerSets: plan.lowerSets,
        );
      }
      dayOffset += 1;
    }

    for (var phaseIndex = 0;
        phaseIndex < scenario.completedMonthlyPhases;
        phaseIndex++) {
      final plan = _monthlyWorkoutSpecs[phaseIndex];
      var activeDays = 0;
      var phaseDayIndex = 1;

      while (activeDays < 30) {
        final cycleDay = ((phaseDayIndex - 1) % 7) + 1;
        if (cycleDay <= 5) {
          _addWorkoutDay(
            logs,
            _startDate.add(Duration(days: dayOffset)),
            upperReps: plan.upperReps,
            upperSets: plan.upperSets,
            coreReps: plan.coreReps,
            coreSets: plan.coreSets,
            lowerReps: plan.lowerReps,
            lowerSets: plan.lowerSets,
          );
          activeDays += 1;
        }
        phaseDayIndex += 1;
        dayOffset += 1;
      }
    }

    return logs;
  }

  Future<void> _resetSandbox(Isar isar) async {
    final exercises = await isar.exerciseModels.where().findAll();
    final baseline = DateTime.now().toUtc();

    for (final exercise in exercises) {
      exercise.totalReps = 0;
      exercise.averageAccuracy = 0.0;
      exercise.lastPerformed = baseline;
    }

    await isar.writeTxn(() async {
      await isar.exerciseLogs.clear();
      await isar.userActivitys.clear();
      await isar.badgeAchievements.clear();
      await isar.exerciseModels.putAll(exercises);
    });

    await _uptimeClock.clearPersistedState();
  }

  void _addWorkoutDay(
    List<ExerciseLog> logs,
    DateTime day, {
    required int upperReps,
    required int upperSets,
    required int coreReps,
    required int coreSets,
    required int lowerReps,
    required int lowerSets,
  }) {
    _addCategoryLogs(
      logs,
      day,
      exerciseId: _upperExerciseId,
      totalReps: upperReps,
      sets: upperSets,
      offsetMinutes: 0,
    );
    _addCategoryLogs(
      logs,
      day,
      exerciseId: _coreExerciseId,
      totalReps: coreReps,
      sets: coreSets,
      offsetMinutes: 30,
    );
    _addCategoryLogs(
      logs,
      day,
      exerciseId: _lowerExerciseId,
      totalReps: lowerReps,
      sets: lowerSets,
      offsetMinutes: 60,
    );
  }

  void _addCategoryLogs(
    List<ExerciseLog> logs,
    DateTime day, {
    required String exerciseId,
    required int totalReps,
    required int sets,
    required int offsetMinutes,
  }) {
    final perSetReps = _splitRepetitions(totalReps, sets);
    for (var i = 0; i < perSetReps.length; i++) {
      logs.add(
        ExerciseLog(
          exerciseId: exerciseId,
          timestamp: day.add(Duration(minutes: offsetMinutes + (i * 5))),
          sessionDuration: 90,
          totalRepetitions: perSetReps[i],
          averageAccuracy: 0.96,
          maxAccuracy: 0.99,
          minAccuracy: 0.93,
          repDetails: const [],
          formWarnings: const [],
        ),
      );
    }
  }

  List<int> _splitRepetitions(int totalReps, int sets) {
    final base = totalReps ~/ sets;
    final remainder = totalReps % sets;
    return List<int>.generate(
      sets,
      (index) => base + (index < remainder ? 1 : 0),
      growable: false,
    );
  }

  _MonthlyWorkoutSpec? _prepWorkoutSpec(int prepDay) {
    switch (prepDay) {
      case 1:
      case 2:
      case 3:
        return const _MonthlyWorkoutSpec(
          upperReps: 8,
          upperSets: 2,
          coreReps: 10,
          coreSets: 2,
          lowerReps: 12,
          lowerSets: 2,
        );
      case 4:
      case 5:
        return const _MonthlyWorkoutSpec(
          upperReps: 10,
          upperSets: 2,
          coreReps: 12,
          coreSets: 2,
          lowerReps: 15,
          lowerSets: 2,
        );
      case 8:
      case 9:
      case 10:
      case 11:
      case 12:
        return const _MonthlyWorkoutSpec(
          upperReps: 12,
          upperSets: 2,
          coreReps: 15,
          coreSets: 2,
          lowerReps: 18,
          lowerSets: 2,
        );
      case 15:
        return const _MonthlyWorkoutSpec(
          upperReps: 12,
          upperSets: 3,
          coreReps: 15,
          coreSets: 3,
          lowerReps: 18,
          lowerSets: 3,
        );
      default:
        return null;
    }
  }
}

class _MonthlyWorkoutSpec {
  final int upperReps;
  final int upperSets;
  final int coreReps;
  final int coreSets;
  final int lowerReps;
  final int lowerSets;

  const _MonthlyWorkoutSpec({
    required this.upperReps,
    required this.upperSets,
    required this.coreReps,
    required this.coreSets,
    required this.lowerReps,
    required this.lowerSets,
  });
}
