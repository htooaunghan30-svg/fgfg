import '../../data/models/exercise_log.dart';
import '../../data/models/user_activity.dart';
import '../../features/gamification/badge_uptime_clock.dart';

class TrustedRecentWorkout {
  final ExerciseLog log;
  final DateTime trustedTimestamp;

  const TrustedRecentWorkout({
    required this.log,
    required this.trustedTimestamp,
  });
}

class TrustedRecentWorkoutsSnapshot {
  final List<TrustedRecentWorkout> workouts;
  final DateTime trustedNow;

  const TrustedRecentWorkoutsSnapshot({
    required this.workouts,
    required this.trustedNow,
  });

  bool get isEmpty => workouts.isEmpty;
}

class TrustedWeeklySummarySnapshot {
  final List<UserActivity> activities;
  final int currentStreak;

  const TrustedWeeklySummarySnapshot({
    required this.activities,
    required this.currentStreak,
  });

  bool get isEmpty => activities.isEmpty;
}

class TrustedProgressService {
  final BadgeUptimeClock _clock;

  TrustedProgressService({
    BadgeUptimeClock? clock,
  }) : _clock = clock ?? BadgeUptimeClock();

  Future<TrustedWeeklySummarySnapshot> buildWeeklySummary(
    List<ExerciseLog> logs, {
    DateTime? trustedNow,
  }) async {
    if (logs.isEmpty) {
      return const TrustedWeeklySummarySnapshot(
        activities: [],
        currentStreak: 0,
      );
    }

    final normalizedLogs = [...logs]..sort((a, b) {
        final byTimestamp = a.timestamp.compareTo(b.timestamp);
        if (byTimestamp != 0) {
          return byTimestamp;
        }
        return a.id.compareTo(b.id);
      });

    await _clock.backfillMissingDayKeys(normalizedLogs);
    final stableStates = await _clock.readStableStatesForLogs(normalizedLogs);
    final resolvedNow = trustedNow ?? await _clock.readTrustedNow();
    final today = _startOfDay(resolvedNow);
    final weekStart = today.subtract(const Duration(days: 6));

    final activitiesByDay = <DateTime, UserActivity>{};
    final workoutDays = <DateTime>{};

    for (final log in normalizedLogs) {
      final trustedTimestamp =
          stableStates[log.id]?.trustedLocalTimestamp ?? log.timestamp;
      final trustedDay = _startOfDay(trustedTimestamp);
      workoutDays.add(trustedDay);

      if (trustedDay.isBefore(weekStart) || trustedDay.isAfter(today)) {
        continue;
      }

      final activity = activitiesByDay.putIfAbsent(
        trustedDay,
        () => UserActivity(date: trustedDay),
      );
      activity.addWorkout(
        exerciseId: log.exerciseId,
        reps: log.totalRepetitions,
        duration: Duration(seconds: log.sessionDuration),
        accuracy: log.averageAccuracy,
      );
    }

    final activities = activitiesByDay.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return TrustedWeeklySummarySnapshot(
      activities: activities,
      currentStreak: _calculateCurrentStreak(workoutDays, today),
    );
  }

  Future<TrustedRecentWorkoutsSnapshot> buildRecentWorkouts(
    List<ExerciseLog> logs, {
    int limit = 5,
    DateTime? trustedNow,
  }) async {
    final displayLogs = _preferCompletedLogs(logs);
    if (displayLogs.isEmpty) {
      return TrustedRecentWorkoutsSnapshot(
        workouts: const [],
        trustedNow: trustedNow ?? await _clock.readTrustedNow(),
      );
    }

    final normalizedLogs = [...displayLogs]..sort((a, b) {
        final byTimestamp = a.timestamp.compareTo(b.timestamp);
        if (byTimestamp != 0) {
          return byTimestamp;
        }
        return a.id.compareTo(b.id);
      });

    await _clock.backfillMissingDayKeys(normalizedLogs);
    final stableStates = await _clock.readStableStatesForLogs(normalizedLogs);
    final recentWorkouts = normalizedLogs
        .map(
          (log) => TrustedRecentWorkout(
            log: log,
            trustedTimestamp:
                stableStates[log.id]?.trustedLocalTimestamp ?? log.timestamp,
          ),
        )
        .toList()
      ..sort((a, b) {
        final byTimestamp = b.trustedTimestamp.compareTo(a.trustedTimestamp);
        if (byTimestamp != 0) {
          return byTimestamp;
        }
        return b.log.id.compareTo(a.log.id);
      });

    return TrustedRecentWorkoutsSnapshot(
      workouts: recentWorkouts.length <= limit
          ? recentWorkouts
          : recentWorkouts.take(limit).toList(),
      trustedNow: trustedNow ?? await _clock.readTrustedNow(),
    );
  }

  List<ExerciseLog> _preferCompletedLogs(List<ExerciseLog> logs) {
    final filtered = logs
        .where((log) => log.totalRepetitions > 0 || log.repDetails.isNotEmpty)
        .toList();
    return filtered.isNotEmpty ? filtered : logs;
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  int _calculateCurrentStreak(Set<DateTime> workoutDays, DateTime today) {
    final eligibleDays =
        workoutDays.where((day) => !day.isAfter(today)).toSet();
    if (eligibleDays.isEmpty) {
      return 0;
    }

    final sortedDays = eligibleDays.toList()..sort((a, b) => b.compareTo(a));

    final yesterday = today.subtract(const Duration(days: 1));
    final latestDay = sortedDays.first;
    if (latestDay != today && latestDay != yesterday) {
      return 0;
    }

    var streak = 0;
    var checkDay = latestDay == yesterday ? yesterday : today;

    for (final day in sortedDays) {
      if (day == checkDay) {
        streak += 1;
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else if (day.isBefore(checkDay)) {
        break;
      }
    }

    return streak;
  }
}
