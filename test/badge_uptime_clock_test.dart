import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthy_life/data/models/exercise_log.dart';
import 'package:healthy_life/features/gamification/badge_uptime_clock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('hf.sec.guard');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'systemUptimeMs') {
        return 10 * 60 * 1000; // 10 minutes
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
      exerciseId: 'situp',
      timestamp: timestamp,
      sessionDuration: 60,
      totalRepetitions: 12,
      averageAccuracy: 0.9,
      maxAccuracy: 0.95,
      minAccuracy: 0.8,
      repDetails: const [],
      formWarnings: const [],
    );
    log.id = id;
    return log;
  }

  test('clamps future timestamps using uptime drift guard', () async {
    final clock = BadgeUptimeClock();
    final now = DateTime.utc(2026, 3, 10, 12, 0);
    final farFuture = DateTime.utc(2030, 1, 1, 12, 0);

    final log1 = makeLog(1, now);
    final log2 = makeLog(2, farFuture);

    await clock.ensureDayKeyForLog(log1);
    await clock.ensureDayKeyForLog(log2);

    final dayKeys = await clock.readStableDayKeysForLogs([log1, log2]);
    final dayKey1 = dayKeys[1]!;
    final dayKey2 = dayKeys[2]!;

    expect(dayKey2 - dayKey1, lessThanOrEqualTo(2));
  });

  test('does not move day key backwards on time rollback', () async {
    final clock = BadgeUptimeClock();
    final now = DateTime.utc(2026, 3, 10, 12, 0);
    final past = DateTime.utc(2026, 2, 1, 12, 0);

    final log1 = makeLog(1, now);
    final log2 = makeLog(2, past);

    await clock.ensureDayKeyForLog(log1);
    await clock.ensureDayKeyForLog(log2);

    final dayKeys = await clock.readStableDayKeysForLogs([log1, log2]);
    final dayKey1 = dayKeys[1]!;
    final dayKey2 = dayKeys[2]!;

    expect(dayKey2, greaterThanOrEqualTo(dayKey1));
  });

  test('returns trusted display dates instead of raw spoofed future dates',
      () async {
    final clock = BadgeUptimeClock();
    final now = DateTime.utc(2026, 3, 10, 12, 0);
    final farFuture = DateTime.utc(2030, 1, 1, 12, 0);

    final log1 = makeLog(1, now);
    final log2 = makeLog(2, farFuture);

    await clock.ensureDayKeyForLog(log1);
    await clock.ensureDayKeyForLog(log2);

    final stableStates = await clock.readStableStatesForLogs([log1, log2]);
    final trustedDate1 = stableStates[1]!.trustedLocalTimestamp;
    final trustedDate2 = stableStates[2]!.trustedLocalTimestamp;

    expect(
      trustedDate2.difference(trustedDate1).inDays,
      lessThanOrEqualTo(2),
    );
    expect(trustedDate2.isBefore(farFuture.toLocal()), isTrue);
  });

  test('backfillMissingDayKeys follows workout timestamps for legacy logs',
      () async {
    final clock = BadgeUptimeClock();
    final laterLog = makeLog(1, DateTime.utc(2026, 3, 12, 12, 0));
    final earlierLog = makeLog(2, DateTime.utc(2026, 3, 10, 12, 0));

    await clock.backfillMissingDayKeys([laterLog, earlierLog]);

    final dayKeys = await clock.readDayKeysForLogs([laterLog, earlierLog]);
    expect(dayKeys[2], lessThan(dayKeys[1]!));
  });
}
