import 'package:isar/isar.dart';

import '../../data/models/badge_achievement.dart';
import '../../data/models/exercise_log.dart';
import '../../data/services/isar_service.dart';
import 'badge_uptime_clock.dart';

class BadgeManager {
  static final BadgeManager _instance = BadgeManager._internal();
  factory BadgeManager() => _instance;
  BadgeManager._internal();

  static const String _firstWorkoutBadgeId = 'first_workout';
  static const String _prepBadgeId = 'prep_phase_15_v2';
  final BadgeUptimeClock _uptimeClock = BadgeUptimeClock();

  final _PrepPhaseDefinition _prepPhase = const _PrepPhaseDefinition(
    id: _prepBadgeId,
    name: 'The Foundation Kickstart',
    durationDays: 15,
    cycleRule: '5_days_active_2_days_rest',
    dayRules: {
      1: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 8, sets: 2),
          _WorkoutCategory.core: _DailyTarget(reps: 10, sets: 2),
          _WorkoutCategory.lower: _DailyTarget(reps: 12, sets: 2),
        },
      ),
      2: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 8, sets: 2),
          _WorkoutCategory.core: _DailyTarget(reps: 10, sets: 2),
          _WorkoutCategory.lower: _DailyTarget(reps: 12, sets: 2),
        },
      ),
      3: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 8, sets: 2),
          _WorkoutCategory.core: _DailyTarget(reps: 10, sets: 2),
          _WorkoutCategory.lower: _DailyTarget(reps: 12, sets: 2),
        },
      ),
      4: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 10, sets: 2),
          _WorkoutCategory.core: _DailyTarget(reps: 12, sets: 2),
          _WorkoutCategory.lower: _DailyTarget(reps: 15, sets: 2),
        },
      ),
      5: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 10, sets: 2),
          _WorkoutCategory.core: _DailyTarget(reps: 12, sets: 2),
          _WorkoutCategory.lower: _DailyTarget(reps: 15, sets: 2),
        },
      ),
      6: _PrepDayRule.rest(),
      7: _PrepDayRule.rest(),
      8: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 12, sets: 2),
          _WorkoutCategory.core: _DailyTarget(reps: 15, sets: 2),
          _WorkoutCategory.lower: _DailyTarget(reps: 18, sets: 2),
        },
      ),
      9: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 12, sets: 2),
          _WorkoutCategory.core: _DailyTarget(reps: 15, sets: 2),
          _WorkoutCategory.lower: _DailyTarget(reps: 18, sets: 2),
        },
      ),
      10: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 12, sets: 2),
          _WorkoutCategory.core: _DailyTarget(reps: 15, sets: 2),
          _WorkoutCategory.lower: _DailyTarget(reps: 18, sets: 2),
        },
      ),
      11: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 12, sets: 2),
          _WorkoutCategory.core: _DailyTarget(reps: 15, sets: 2),
          _WorkoutCategory.lower: _DailyTarget(reps: 18, sets: 2),
        },
      ),
      12: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 12, sets: 2),
          _WorkoutCategory.core: _DailyTarget(reps: 15, sets: 2),
          _WorkoutCategory.lower: _DailyTarget(reps: 18, sets: 2),
        },
      ),
      13: _PrepDayRule.rest(),
      14: _PrepDayRule.rest(),
      15: _PrepDayRule.workout(
        targets: {
          _WorkoutCategory.upper: _DailyTarget(reps: 12, sets: 3),
          _WorkoutCategory.core: _DailyTarget(reps: 15, sets: 3),
          _WorkoutCategory.lower: _DailyTarget(reps: 18, sets: 3),
        },
      ),
    },
  );

  final List<_ProgramBadgeDefinition> _programBadges = const [
    _ProgramBadgeDefinition(
      id: 'month_1_bronze',
      name: 'Bronze Foundation',
      description:
          '30 qualified active days. Daily: Upper 18 reps + 3 sets (combined across upper exercises), Core 24 reps + 3 sets, Lower 30 reps + 3 sets (combined across lower exercises).',
      tier: BadgeTier.bronze,
      requiredDays: 30,
      cycleRule: '5_days_active_2_days_rest',
      dailyLogic: {
        _WorkoutCategory.upper: _DailyTarget(reps: 18, sets: 3),
        _WorkoutCategory.core: _DailyTarget(reps: 24, sets: 3),
        _WorkoutCategory.lower: _DailyTarget(reps: 30, sets: 3),
      },
    ),
    _ProgramBadgeDefinition(
      id: 'month_2_silver',
      name: 'Silver Warrior',
      description:
          '30 qualified active days. Daily: Upper 24 reps + 4 sets, Core 32 reps + 4 sets, Lower 40 reps + 4 sets.',
      tier: BadgeTier.silver,
      requiredDays: 30,
      cycleRule: '5_days_active_2_days_rest',
      dailyLogic: {
        _WorkoutCategory.upper: _DailyTarget(reps: 24, sets: 4),
        _WorkoutCategory.core: _DailyTarget(reps: 32, sets: 4),
        _WorkoutCategory.lower: _DailyTarget(reps: 40, sets: 4),
      },
    ),
    _ProgramBadgeDefinition(
      id: 'month_3_gold',
      name: 'Gold Master',
      description:
          '30 qualified active days. Daily: Upper 30 reps + 4 sets, Core 40 reps + 4 sets, Lower 50 reps + 4 sets.',
      tier: BadgeTier.gold,
      requiredDays: 30,
      cycleRule: '5_days_active_2_days_rest',
      dailyLogic: {
        _WorkoutCategory.upper: _DailyTarget(reps: 30, sets: 4),
        _WorkoutCategory.core: _DailyTarget(reps: 40, sets: 4),
        _WorkoutCategory.lower: _DailyTarget(reps: 50, sets: 4),
      },
    ),
  ];

  Future<void> initialize() async {
    await _ensureProgramBadges();
    final isar = IsarService.instance;
    final logs = await isar.exerciseLogs.where().findAll();
    if (logs.isEmpty) {
      return;
    }
    logs.sort((a, b) {
      final byTimestamp = a.timestamp.compareTo(b.timestamp);
      if (byTimestamp != 0) {
        return byTimestamp;
      }
      return a.id.compareTo(b.id);
    });
    await checkAndUpdateBadges(logs.last);
  }

  Future<void> checkAndUpdateBadges(ExerciseLog newLog) async {
    final isar = IsarService.instance;

    await _ensureProgramBadges(isar: isar);
    await _uptimeClock.ensureDayKeyForLog(newLog);

    final logs = await isar.exerciseLogs.where().findAll();
    logs.sort((a, b) {
      final byTimestamp = a.timestamp.compareTo(b.timestamp);
      if (byTimestamp != 0) {
        return byTimestamp;
      }
      return a.id.compareTo(b.id);
    });

    await _uptimeClock.backfillMissingDayKeys(logs);
    final stableLogStates = await _uptimeClock.readStableStatesForLogs(logs);
    final progressData = _buildDailyProgress(logs, stableLogStates);
    final dailyProgress = progressData.dailyProgressByDayKey;
    final displayDateByDayKey = progressData.displayDateByDayKey;

    final snapshot = _calculateProgramProgress(dailyProgress);
    final hasFirstWorkoutQualifiedDay =
        _hasFirstWorkoutQualifiedDay(dailyProgress);
    final firstQualifiedDayKey = _firstQualifiedDayKey(dailyProgress);

    await isar.writeTxn(() async {
      final existing = await isar.badgeAchievements.where().findAll();
      final existingById = {for (final badge in existing) badge.badgeId: badge};

      final firstWorkoutBadge = existingById[_firstWorkoutBadgeId] ??
          _createFirstWorkoutBadgeAchievement();
      final firstWorkoutWasUnlocked = firstWorkoutBadge.isUnlocked;
      firstWorkoutBadge.progress = hasFirstWorkoutQualifiedDay ? 1 : 0;
      firstWorkoutBadge.requirement = 1;
      firstWorkoutBadge.name = 'First Steps';
      firstWorkoutBadge.description =
          'Complete one day: Upper 8 (push-up/shoulder press/bicep curl/lateral raise/front raise), Core 10 (sit-up), Lower 12 (squat/leg extension).';
      firstWorkoutBadge.tier = BadgeTier.bronze;
      firstWorkoutBadge.iconPath = 'assets/badges/first.png';
      firstWorkoutBadge.unlockedFor = 'general';
      final firstWorkoutUnlockDate = _resolveUnlockDate(
        dayKeyByBadgeId: {
          _firstWorkoutBadgeId: firstQualifiedDayKey,
        },
        displayDateByDayKey: displayDateByDayKey,
        badgeId: _firstWorkoutBadgeId,
      );
      if (firstWorkoutBadge.isUnlocked &&
          (!firstWorkoutWasUnlocked ||
              _shouldRefreshUnlockDate(
                current: firstWorkoutBadge.unlockedAt,
                resolved: firstWorkoutUnlockDate,
              ))) {
        firstWorkoutBadge.unlockedAt = firstWorkoutUnlockDate!;
      }
      await isar.badgeAchievements.put(firstWorkoutBadge);

      final prepBadge = existingById[_prepPhase.id] ??
          _createPrepBadgeAchievement(_prepPhase);
      final prepWasUnlocked = prepBadge.isUnlocked;

      prepBadge.progress = (snapshot.progressByBadgeId[_prepPhase.id] ?? 0)
          .clamp(0, _prepPhase.durationDays)
          .toInt();
      prepBadge.requirement = _prepPhase.durationDays;
      prepBadge.name = _prepPhase.name;
      prepBadge.description =
          '15-day prep phase (${_prepPhase.cycleRule}) before Bronze.';
      prepBadge.tier = BadgeTier.bronze;
      prepBadge.iconPath = 'assets/badges/${_prepPhase.id}.png';
      prepBadge.unlockedFor = 'program_prep';

      final prepUnlockDate = _resolveUnlockDate(
        dayKeyByBadgeId: snapshot.unlockDayKeyByBadgeId,
        displayDateByDayKey: displayDateByDayKey,
        badgeId: _prepPhase.id,
      );
      if (prepBadge.isUnlocked &&
          (!prepWasUnlocked ||
              _shouldRefreshUnlockDate(
                current: prepBadge.unlockedAt,
                resolved: prepUnlockDate,
              ))) {
        prepBadge.unlockedAt = prepUnlockDate!;
      }

      await isar.badgeAchievements.put(prepBadge);

      for (final definition in _programBadges) {
        final badge =
            existingById[definition.id] ?? _createBadgeAchievement(definition);
        final wasUnlocked = badge.isUnlocked;

        final progress = (snapshot.progressByBadgeId[definition.id] ?? 0)
            .clamp(0, definition.requiredDays)
            .toInt();
        badge.progress = progress;
        badge.requirement = definition.requiredDays;
        badge.name = definition.name;
        badge.description = definition.description;
        badge.tier = definition.tier;
        badge.iconPath = 'assets/badges/${definition.id}.png';
        badge.unlockedFor = 'program_monthly';

        final unlockDate = _resolveUnlockDate(
          dayKeyByBadgeId: snapshot.unlockDayKeyByBadgeId,
          displayDateByDayKey: displayDateByDayKey,
          badgeId: definition.id,
        );
        if (badge.isUnlocked &&
            (!wasUnlocked ||
                _shouldRefreshUnlockDate(
                  current: badge.unlockedAt,
                  resolved: unlockDate,
                ))) {
          badge.unlockedAt = unlockDate!;
        }

        await isar.badgeAchievements.put(badge);
      }
    });
  }

  Future<List<BadgeAchievement>> getUnlockedBadges() async {
    final isar = IsarService.instance;
    final badges = await isar.badgeAchievements.where().findAll();
    return badges.where((badge) => badge.isUnlocked).toList();
  }

  Future<List<BadgeAchievement>> getInProgressBadges() async {
    final isar = IsarService.instance;
    final badges = await isar.badgeAchievements.where().findAll();
    return badges.where((badge) => !badge.isUnlocked).toList();
  }

  Future<Map<BadgeTier, List<BadgeAchievement>>> getBadgesByTier() async {
    final badges =
        await IsarService.instance.badgeAchievements.where().findAll();

    final Map<BadgeTier, List<BadgeAchievement>> badgesByTier = {
      BadgeTier.bronze: [],
      BadgeTier.silver: [],
      BadgeTier.gold: [],
      BadgeTier.platinum: [],
    };

    for (final badge in badges) {
      badgesByTier[badge.tier]!.add(badge);
    }

    return badgesByTier;
  }

  Future<void> _ensureProgramBadges({Isar? isar}) async {
    final db = isar ?? IsarService.instance;
    final existingBadges = await db.badgeAchievements.where().findAll();
    final existingIds = existingBadges.map((badge) => badge.badgeId).toSet();

    final missingBadges = <BadgeAchievement>[];

    if (!existingIds.contains(_firstWorkoutBadgeId)) {
      missingBadges.add(_createFirstWorkoutBadgeAchievement());
    }

    if (!existingIds.contains(_prepPhase.id)) {
      missingBadges.add(_createPrepBadgeAchievement(_prepPhase));
    }

    missingBadges.addAll(
      _programBadges
          .where((definition) => !existingIds.contains(definition.id))
          .map(_createBadgeAchievement),
    );

    if (missingBadges.isEmpty) {
      return;
    }

    await db.writeTxn(() async {
      await db.badgeAchievements.putAll(missingBadges);
    });
  }

  BadgeAchievement _createBadgeAchievement(_ProgramBadgeDefinition definition) {
    return BadgeAchievement(
      badgeId: definition.id,
      name: definition.name,
      description: definition.description,
      iconPath: 'assets/badges/${definition.id}.png',
      tier: definition.tier,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
      unlockedFor: 'program_monthly',
      progress: 0,
      requirement: definition.requiredDays,
    );
  }

  BadgeAchievement _createPrepBadgeAchievement(
      _PrepPhaseDefinition definition) {
    return BadgeAchievement(
      badgeId: definition.id,
      name: definition.name,
      description: '15-day prep phase (${definition.cycleRule}).',
      iconPath: 'assets/badges/${definition.id}.png',
      tier: BadgeTier.bronze,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
      unlockedFor: 'program_prep',
      progress: 0,
      requirement: definition.durationDays,
    );
  }

  BadgeAchievement _createFirstWorkoutBadgeAchievement() {
    return BadgeAchievement(
      badgeId: _firstWorkoutBadgeId,
      name: 'First Steps',
      description:
          'Complete one day: Upper 8 (push-up/shoulder press/bicep curl/lateral raise/front raise), Core 10, Lower 12 (from saved workout logs).',
      iconPath: 'assets/badges/first.png',
      tier: BadgeTier.bronze,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
      unlockedFor: 'general',
      progress: 0,
      requirement: 1,
    );
  }

  _DailyProgressBuild _buildDailyProgress(
    List<ExerciseLog> logs,
    Map<int, BadgeStableLogState> stableLogStatesByLogId,
  ) {
    final dailyByDayKey = <int, Map<_WorkoutCategory, _DailyProgress>>{};
    final displayDateByDayKey = <int, DateTime>{};

    for (final log in logs) {
      final category = _resolveCategory(log.exerciseId);
      if (category == null || log.totalRepetitions <= 0) {
        continue;
      }
      final stableState = stableLogStatesByLogId[log.id];
      if (stableState == null) {
        continue;
      }
      final dayKey = stableState.stableDayKey;

      final existingDate = displayDateByDayKey[dayKey];
      if (existingDate == null ||
          stableState.trustedLocalTimestamp.isBefore(existingDate)) {
        displayDateByDayKey[dayKey] = stableState.trustedLocalTimestamp;
      }

      final categoryMap = dailyByDayKey.putIfAbsent(dayKey, () => {});
      final progress = categoryMap.putIfAbsent(
        category,
        () => _DailyProgress(),
      );

      progress.reps += log.totalRepetitions;
      progress.sets += 1;
    }

    return _DailyProgressBuild(
      dailyProgressByDayKey: dailyByDayKey,
      displayDateByDayKey: displayDateByDayKey,
    );
  }

  bool _hasFirstWorkoutQualifiedDay(
    Map<int, Map<_WorkoutCategory, _DailyProgress>> dailyProgress,
  ) {
    const upperTargetReps = 8;
    const coreTargetReps = 10;
    const lowerTargetReps = 12;

    for (final entry in dailyProgress.entries) {
      final categoryProgress = entry.value;
      final upperReps = categoryProgress[_WorkoutCategory.upper]?.reps ?? 0;
      final coreReps = categoryProgress[_WorkoutCategory.core]?.reps ?? 0;
      final lowerReps = categoryProgress[_WorkoutCategory.lower]?.reps ?? 0;

      if (upperReps >= upperTargetReps &&
          coreReps >= coreTargetReps &&
          lowerReps >= lowerTargetReps) {
        return true;
      }
    }

    return false;
  }

  int? _firstQualifiedDayKey(
    Map<int, Map<_WorkoutCategory, _DailyProgress>> dailyProgress,
  ) {
    const upperTargetReps = 8;
    const coreTargetReps = 10;
    const lowerTargetReps = 12;

    final dayKeys = dailyProgress.keys.toList()..sort();
    for (final dayKey in dayKeys) {
      final categoryProgress = dailyProgress[dayKey] ?? {};
      final upperReps = categoryProgress[_WorkoutCategory.upper]?.reps ?? 0;
      final coreReps = categoryProgress[_WorkoutCategory.core]?.reps ?? 0;
      final lowerReps = categoryProgress[_WorkoutCategory.lower]?.reps ?? 0;

      if (upperReps >= upperTargetReps &&
          coreReps >= coreTargetReps &&
          lowerReps >= lowerTargetReps) {
        return dayKey;
      }
    }
    return null;
  }

  DateTime? _resolveUnlockDate({
    required Map<String, int?> dayKeyByBadgeId,
    required Map<int, DateTime> displayDateByDayKey,
    required String badgeId,
  }) {
    final dayKey = dayKeyByBadgeId[badgeId];
    if (dayKey == null) {
      return null;
    }
    return displayDateByDayKey[dayKey];
  }

  bool _shouldRefreshUnlockDate({
    required DateTime current,
    required DateTime? resolved,
  }) {
    if (resolved == null) {
      return false;
    }
    return current.toUtc().millisecondsSinceEpoch !=
        resolved.toUtc().millisecondsSinceEpoch;
  }

  _ProgressSnapshot _calculateProgramProgress(
    Map<int, Map<_WorkoutCategory, _DailyProgress>> dailyProgress,
  ) {
    final progressByBadgeId = <String, int>{
      _prepPhase.id: 0,
      for (final definition in _programBadges) definition.id: 0,
    };
    final unlockDayKeyByBadgeId = <String, int>{};

    final firstStepsDayKey = _firstQualifiedDayKey(dailyProgress);
    final prepStartDayKey =
        firstStepsDayKey == null ? null : (firstStepsDayKey + 1);

    final prepResult = _calculatePrepPhaseProgress(
      dailyProgress,
      startDayKey: prepStartDayKey,
    );
    progressByBadgeId[_prepPhase.id] = prepResult.progress;
    if (prepResult.isCompleted && prepResult.completionDayKey != null) {
      unlockDayKeyByBadgeId[_prepPhase.id] = prepResult.completionDayKey!;
    } else {
      return _ProgressSnapshot(
        progressByBadgeId: progressByBadgeId,
        unlockDayKeyByBadgeId: unlockDayKeyByBadgeId,
      );
    }

    var phaseStartDayKey = prepResult.completionDayKey! + 1;

    for (final definition in _programBadges) {
      final phase = _calculateCycledMonthlyProgress(
        definition: definition,
        dailyProgress: dailyProgress,
        phaseStartDayKey: phaseStartDayKey,
      );

      progressByBadgeId[definition.id] = phase.progress;
      if (!phase.isCompleted || phase.completionDayKey == null) {
        break;
      }

      unlockDayKeyByBadgeId[definition.id] = phase.completionDayKey!;
      phaseStartDayKey = phase.completionDayKey! + 1;
    }

    return _ProgressSnapshot(
      progressByBadgeId: progressByBadgeId,
      unlockDayKeyByBadgeId: unlockDayKeyByBadgeId,
    );
  }

  _PhaseProgress _calculateCycledMonthlyProgress({
    required _ProgramBadgeDefinition definition,
    required Map<int, Map<_WorkoutCategory, _DailyProgress>> dailyProgress,
    required int phaseStartDayKey,
  }) {
    if (dailyProgress.isEmpty) {
      return const _PhaseProgress(progress: 0);
    }

    var phaseStart = phaseStartDayKey;
    final latestTrackedDayKey = _maxDayKey(dailyProgress.keys.toList());
    if (latestTrackedDayKey == null || latestTrackedDayKey < phaseStart) {
      return const _PhaseProgress(progress: 0);
    }

    final loggedDayKeys = dailyProgress.keys.toSet();

    var progress = 0;
    int? completionDayKey;
    var currentDayKey = phaseStart;
    int? lastLoggedDayKey;

    while (currentDayKey <= latestTrackedDayKey) {
      if (loggedDayKeys.contains(currentDayKey)) {
        if (lastLoggedDayKey != null &&
            (currentDayKey - lastLoggedDayKey) > 15) {
          progress = 0;
          completionDayKey = null;
          phaseStart = currentDayKey;
        }
      }

      final dayIndex = (currentDayKey - phaseStart) + 1;
      final cycleDay = ((dayIndex - 1) % 7) + 1;
      final isRestDay = cycleDay > 5;

      if (!isRestDay) {
        final categoryProgress = dailyProgress[currentDayKey] ?? {};
        if (_meetsDailyTarget(definition, categoryProgress)) {
          progress += 1;
          if (progress >= definition.requiredDays) {
            completionDayKey = currentDayKey;
            break;
          }
        }
      }

      if (loggedDayKeys.contains(currentDayKey)) {
        lastLoggedDayKey = currentDayKey;
      }

      currentDayKey += 1;
    }

    return _PhaseProgress(
      progress: progress.clamp(0, definition.requiredDays).toInt(),
      completionDayKey: completionDayKey,
    );
  }

  _PrepPhaseProgress _calculatePrepPhaseProgress(
      Map<int, Map<_WorkoutCategory, _DailyProgress>> dailyProgress,
      {int? startDayKey}) {
    final workoutDayKeys = dailyProgress.keys.toList()..sort();
    if (workoutDayKeys.isEmpty) {
      return const _PrepPhaseProgress(progress: 0);
    }

    final earliestDayKey = startDayKey ?? workoutDayKeys.first;
    final latestDayKey = workoutDayKeys.last;

    if (earliestDayKey > latestDayKey) {
      return const _PrepPhaseProgress(progress: 0);
    }

    // Prep progress reflects the current run.
    // If a required active day is missed, the run resets and starts over at
    // the next tracked day.
    var runStartDayKey = earliestDayKey;
    var progress = 0;

    for (var dayKey = earliestDayKey; dayKey <= latestDayKey; dayKey++) {
      final dayNumber = (dayKey - runStartDayKey) + 1;
      final rule = _prepPhase.dayRules[dayNumber];
      if (rule == null) {
        runStartDayKey = dayKey;
        progress = 0;
        continue;
      }

      final categoryProgress = dailyProgress[dayKey] ?? {};
      final isPassed = rule.isRestDay
          ? true
          : _meetsPrepWorkoutTarget(rule.targets, categoryProgress);

      if (!isPassed) {
        runStartDayKey = dayKey + 1;
        progress = 0;
        continue;
      }

      progress++;
      if (progress >= _prepPhase.durationDays) {
        return _PrepPhaseProgress(
          progress: _prepPhase.durationDays,
          completionDayKey: dayKey,
        );
      }
    }

    return _PrepPhaseProgress(
      progress: progress.clamp(0, _prepPhase.durationDays).toInt(),
    );
  }

  bool _meetsPrepWorkoutTarget(
    Map<_WorkoutCategory, _DailyTarget> targets,
    Map<_WorkoutCategory, _DailyProgress> categoryProgress,
  ) {
    for (final entry in targets.entries) {
      final progress = categoryProgress[entry.key];
      final target = entry.value;

      if (progress == null) {
        return false;
      }

      if (progress.reps < target.reps || progress.sets < target.sets) {
        return false;
      }
    }

    return true;
  }

  bool _meetsDailyTarget(
    _ProgramBadgeDefinition definition,
    Map<_WorkoutCategory, _DailyProgress> categoryProgress,
  ) {
    for (final entry in definition.dailyLogic.entries) {
      final progress = categoryProgress[entry.key];
      final target = entry.value;

      if (progress == null) {
        return false;
      }

      // Cap by daily limit so extra reps/sets never create extra badge credit.
      final cappedReps =
          progress.reps > target.reps ? target.reps : progress.reps;
      final cappedSets =
          progress.sets > target.sets ? target.sets : progress.sets;

      if (cappedReps < target.reps || cappedSets < target.sets) {
        return false;
      }
    }

    return true;
  }

  int? _maxDayKey(List<int> dayKeys) {
    if (dayKeys.isEmpty) {
      return null;
    }
    var max = dayKeys.first;
    for (final dayKey in dayKeys) {
      if (dayKey > max) {
        max = dayKey;
      }
    }
    return max;
  }

  _WorkoutCategory? _resolveCategory(String exerciseId) {
    final normalized = exerciseId.toLowerCase().replaceAll('-', '_').trim();

    switch (normalized) {
      case 'pushup':
      case 'push_up':
      case 'bicep_curl':
      case 'bicepcurl':
      case 'shoulder_press':
      case 'shoulderpress':
      case 'lateral_raise':
      case 'lateralraise':
      case 'front_raise':
      case 'frontraise':
        return _WorkoutCategory.upper;
      case 'situp':
      case 'sit_up':
        return _WorkoutCategory.core;
      case 'squat':
      case 'leg_extension':
      case 'legextension':
        return _WorkoutCategory.lower;
      default:
        return null;
    }
  }
}

enum _WorkoutCategory {
  upper,
  core,
  lower,
}

class _DailyTarget {
  final int reps;
  final int sets;

  const _DailyTarget({
    required this.reps,
    required this.sets,
  });
}

class _DailyProgress {
  int reps = 0;
  int sets = 0;
}

class _ProgramBadgeDefinition {
  final String id;
  final String name;
  final String description;
  final BadgeTier tier;
  final int requiredDays;
  final String cycleRule;
  final Map<_WorkoutCategory, _DailyTarget> dailyLogic;

  const _ProgramBadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.requiredDays,
    required this.cycleRule,
    required this.dailyLogic,
  });
}

class _ProgressSnapshot {
  final Map<String, int> progressByBadgeId;
  final Map<String, int> unlockDayKeyByBadgeId;

  const _ProgressSnapshot({
    required this.progressByBadgeId,
    required this.unlockDayKeyByBadgeId,
  });
}

class _PrepPhaseDefinition {
  final String id;
  final String name;
  final int durationDays;
  final String cycleRule;
  final Map<int, _PrepDayRule> dayRules;

  const _PrepPhaseDefinition({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.cycleRule,
    required this.dayRules,
  });
}

class _PrepDayRule {
  final bool isRestDay;
  final Map<_WorkoutCategory, _DailyTarget> targets;

  const _PrepDayRule.workout({
    required this.targets,
  }) : isRestDay = false;

  const _PrepDayRule.rest()
      : isRestDay = true,
        targets = const {};
}

class _PrepPhaseProgress {
  final int progress;
  final int? completionDayKey;

  bool get isCompleted => progress >= 15;

  const _PrepPhaseProgress({
    required this.progress,
    this.completionDayKey,
  });
}

class _PhaseProgress {
  final int progress;
  final int? completionDayKey;

  bool get isCompleted => completionDayKey != null;

  const _PhaseProgress({
    required this.progress,
    this.completionDayKey,
  });
}

class _DailyProgressBuild {
  final Map<int, Map<_WorkoutCategory, _DailyProgress>> dailyProgressByDayKey;
  final Map<int, DateTime> displayDateByDayKey;

  const _DailyProgressBuild({
    required this.dailyProgressByDayKey,
    required this.displayDateByDayKey,
  });
}
