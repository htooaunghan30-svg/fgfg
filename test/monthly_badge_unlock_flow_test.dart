import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthy_life/data/services/isar_service.dart';
import 'package:healthy_life/features/gamification/monthly_badge_debug_helper.dart';

class _TestPathProviderPlatform extends PathProviderPlatform {
  _TestPathProviderPlatform(this.basePath);

  final String basePath;

  @override
  Future<String?> getApplicationDocumentsPath() async => basePath;

  @override
  Future<String?> getTemporaryPath() async => basePath;

  @override
  Future<String?> getApplicationSupportPath() async => basePath;

  @override
  Future<String?> getLibraryPath() async => basePath;

  @override
  Future<String?> getExternalStoragePath() async => basePath;

  @override
  Future<List<String>?> getExternalCachePaths() async => <String>[basePath];

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => <String>[basePath];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('hf.sec.guard');

  setUpAll(() async {
    final tempRoot = await Directory.systemTemp.createTemp('badge_test_');
    PathProviderPlatform.instance =
        _TestPathProviderPlatform(tempRoot.path);

    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'systemUptimeMs') {
        return 10 * 60 * 1000;
      }
      return null;
    });

    await IsarService.initialize();
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('bronze scenario unlocks first workout, prep, and bronze only',
      () async {
    final helper = MonthlyBadgeDebugHelper();
    final result = await helper.seedScenario(MonthlyBadgeDebugScenario.bronze);

    final firstWorkout = result.badge('first_workout');
    final prep = result.badge('prep_phase_15_v2');
    final bronze = result.badge('month_1_bronze');
    final silver = result.badge('month_2_silver');
    final gold = result.badge('month_3_gold');

    expect(result.seededLogCount, 342);
    expect(firstWorkout, isNotNull);
    expect(firstWorkout!.isUnlocked, isTrue);

    expect(prep, isNotNull);
    expect(prep!.progress, 15);
    expect(prep.requirement, 15);
    expect(prep.isUnlocked, isTrue);

    expect(bronze, isNotNull);
    expect(bronze!.progress, 30);
    expect(bronze.requirement, 30);
    expect(bronze.isUnlocked, isTrue);

    expect(silver, isNotNull);
    expect(silver!.isUnlocked, isFalse);

    expect(gold, isNotNull);
    expect(gold!.isUnlocked, isFalse);
  });

  test('silver scenario unlocks first workout, prep, bronze, and silver only',
      () async {
    final helper = MonthlyBadgeDebugHelper();
    final result = await helper.seedScenario(MonthlyBadgeDebugScenario.silver);

    final firstWorkout = result.badge('first_workout');
    final prep = result.badge('prep_phase_15_v2');
    final bronze = result.badge('month_1_bronze');
    final silver = result.badge('month_2_silver');
    final gold = result.badge('month_3_gold');

    expect(firstWorkout, isNotNull);
    expect(firstWorkout!.isUnlocked, isTrue);

    expect(prep, isNotNull);
    expect(prep!.progress, 15);
    expect(prep.isUnlocked, isTrue);

    expect(bronze, isNotNull);
    expect(bronze!.progress, 30);
    expect(bronze.isUnlocked, isTrue);

    expect(silver, isNotNull);
    expect(silver!.progress, 30);
    expect(silver.requirement, 30);
    expect(silver.isUnlocked, isTrue);

    expect(gold, isNotNull);
    expect(gold!.isUnlocked, isFalse);
  });

  test('gold scenario unlocks first workout, prep, bronze, silver, and gold',
      () async {
    final helper = MonthlyBadgeDebugHelper();
    final result = await helper.seedScenario(MonthlyBadgeDebugScenario.gold);

    final firstWorkout = result.badge('first_workout');
    final prep = result.badge('prep_phase_15_v2');
    final bronze = result.badge('month_1_bronze');
    final silver = result.badge('month_2_silver');
    final gold = result.badge('month_3_gold');

    expect(firstWorkout, isNotNull);
    expect(firstWorkout!.isUnlocked, isTrue);

    expect(prep, isNotNull);
    expect(prep!.progress, 15);
    expect(prep.isUnlocked, isTrue);

    expect(bronze, isNotNull);
    expect(bronze!.progress, 30);
    expect(bronze.isUnlocked, isTrue);

    expect(silver, isNotNull);
    expect(silver!.progress, 30);
    expect(silver.isUnlocked, isTrue);

    expect(gold, isNotNull);
    expect(gold!.progress, 30);
    expect(gold.requirement, 30);
    expect(gold.isUnlocked, isTrue);
  });
}
