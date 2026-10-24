import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthy_life/data/models/exercise_log.dart';
import 'package:healthy_life/features/gamification/badge_uptime_clock.dart';
import 'package:healthy_life/features/gamification/monthly_badge_debug_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('hf.sec.guard');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'systemUptimeMs') {
        return 10 * 60 * 1000;
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  ExerciseLog makeLog(int id, DateTime timestamp) {
    final log = ExerciseLog(
      exerciseId: 'pushup',
      timestamp: timestamp,
      sessionDuration: 90,
      totalRepetitions: 10,
      averageAccuracy: 0.95,
      maxAccuracy: 0.99,
      minAccuracy: 0.92,
      repDetails: const [],
      formWarnings: const [],
    );
    log.id = id;
    return log;
  }

  test('debugSeedStableTimeline preserves distinct seeded workout days',
      () async {
    final clock = BadgeUptimeClock();
    final logs = [
      makeLog(1, DateTime.utc(2026, 1, 1, 9)),
      makeLog(2, DateTime.utc(2026, 1, 2, 9)),
      makeLog(3, DateTime.utc(2026, 1, 3, 9)),
    ];

    await clock.debugSeedStableTimeline(logs);
    final states = await clock.readStableStatesForLogs(logs);

    expect(states[1]!.stableDayKey, lessThan(states[2]!.stableDayKey));
    expect(states[2]!.stableDayKey, lessThan(states[3]!.stableDayKey));
  });

  test('buildScenarioLogs creates the full gold sandbox workload', () {
    final helper = MonthlyBadgeDebugHelper();
    final logs = helper.buildScenarioLogs(MonthlyBadgeDebugScenario.gold);
    final uniqueWorkoutDays = logs
        .map((log) => DateTime(
            log.timestamp.year, log.timestamp.month, log.timestamp.day))
        .toSet();

    expect(logs.length, 1062);
    expect(uniqueWorkoutDays.length, 102);
  });

  test('buildScenarioLogs creates the bronze sandbox workload', () {
    final helper = MonthlyBadgeDebugHelper();
    final logs = helper.buildScenarioLogs(MonthlyBadgeDebugScenario.bronze);
    final uniqueWorkoutDays = logs
        .map((log) => DateTime(
            log.timestamp.year, log.timestamp.month, log.timestamp.day))
        .toSet();

    expect(logs.length, 342);
    expect(uniqueWorkoutDays.length, 42);
  });
}
