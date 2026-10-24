import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthy_life/data/models/exercise_log.dart';
import 'package:healthy_life/presentation/services/trusted_progress_service.dart';

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

  ExerciseLog makeLog(
    int id,
    DateTime timestamp, {
    int reps = 12,
    String exerciseId = 'situp',
  }) {
    final log = ExerciseLog(
      exerciseId: exerciseId,
      timestamp: timestamp,
      sessionDuration: 60,
      totalRepetitions: reps,
      averageAccuracy: 0.9,
      maxAccuracy: 0.95,
      minAccuracy: 0.8,
      repDetails: const [],
      formWarnings: const [],
    );
    log.id = id;
    return log;
  }

  test('weekly summary ignores future-clamped days beyond trusted today',
      () async {
    final service = TrustedProgressService();
    final trustedNow = DateTime(2026, 3, 10, 18);
    final logs = [
      makeLog(1, DateTime.utc(2026, 3, 10, 12)),
      makeLog(2, DateTime.utc(2030, 1, 1, 12)),
    ];

    final summary = await service.buildWeeklySummary(
      logs,
      trustedNow: trustedNow,
    );

    expect(summary.activities.length, 1);
    expect(summary.activities.first.totalRepetitions, 12);
    expect(summary.currentStreak, 1);
  });

  test('recent workouts use trusted ordering instead of raw spoofed dates',
      () async {
    final service = TrustedProgressService();
    final trustedNow = DateTime(2026, 3, 10, 18);
    final logs = [
      makeLog(1, DateTime.utc(2026, 3, 10, 12)),
      makeLog(2, DateTime.utc(2030, 1, 1, 12)),
      makeLog(3, DateTime.utc(2026, 3, 9, 12)),
    ];

    final recent = await service.buildRecentWorkouts(
      logs,
      trustedNow: trustedNow,
    );

    expect(recent.workouts.length, 3);
    expect(
      recent.workouts.first.trustedTimestamp.isBefore(
        DateTime.utc(2030, 1, 1, 12).toLocal(),
      ),
      isTrue,
    );
    expect(recent.workouts.last.log.id, 3);
  });
}
