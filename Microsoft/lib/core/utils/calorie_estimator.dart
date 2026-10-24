import 'dart:math';

class ExerciseCalorieEstimator {
  static const double defaultWeightKg = 70.0;

  static const Map<String, _CalorieProfile> _profiles = {
    // MET values based on common compendium ranges for moderate effort.
    'squat': _CalorieProfile(
      met: 5.0,
      defaultSecPerRep: 2.2,
      minSecPerRep: 1.2,
      maxSecPerRep: 4.0,
    ),
    'pushup': _CalorieProfile(
      met: 8.0,
      defaultSecPerRep: 2.0,
      minSecPerRep: 1.0,
      maxSecPerRep: 3.5,
    ),
    'bicep_curl': _CalorieProfile(
      met: 3.5,
      defaultSecPerRep: 2.6,
      minSecPerRep: 1.4,
      maxSecPerRep: 4.5,
    ),
    'shoulder_press': _CalorieProfile(
      met: 4.5,
      defaultSecPerRep: 2.6,
      minSecPerRep: 1.4,
      maxSecPerRep: 4.5,
    ),
    'situp': _CalorieProfile(
      met: 4.0,
      defaultSecPerRep: 2.4,
      minSecPerRep: 1.2,
      maxSecPerRep: 4.5,
    ),
    'leg_extension': _CalorieProfile(
      met: 3.5,
      defaultSecPerRep: 2.8,
      minSecPerRep: 1.4,
      maxSecPerRep: 5.0,
    ),
  };

  static String normalizeExerciseId(String exerciseId) {
    switch (exerciseId.toLowerCase().replaceAll('-', '_').trim()) {
      case 'push_up':
        return 'pushup';
      case 'sit_up':
        return 'situp';
      case 'bicepcurl':
        return 'bicep_curl';
      case 'shoulderpress':
        return 'shoulder_press';
      case 'legextension':
        return 'leg_extension';
      default:
        return exerciseId.toLowerCase().replaceAll('-', '_').trim();
    }
  }

  static double estimateFromLog({
    required String exerciseId,
    required int totalRepetitions,
    required int sessionDurationSeconds,
    required List<int> repDurationsMs,
    double userWeightKg = defaultWeightKg,
  }) {
    final normalizedId = normalizeExerciseId(exerciseId);
    final profile = _profiles[normalizedId] ?? _defaultProfile;
    final reps = max(totalRepetitions, 0);

    final repActiveSeconds = repDurationsMs
            .where((ms) => ms > 0)
            .fold<int>(0, (sum, ms) => sum + ms) /
        1000.0;

    final effectiveSeconds = profile.isStatic
        ? _resolveStaticSeconds(
            reps: reps,
            sessionDurationSeconds: sessionDurationSeconds,
            repActiveSeconds: repActiveSeconds,
            profile: profile,
          )
        : _resolveDynamicSeconds(
            reps: reps,
            sessionDurationSeconds: sessionDurationSeconds,
            repActiveSeconds: repActiveSeconds,
            profile: profile,
          );

    final durationHours = effectiveSeconds / 3600.0;
    final calories = profile.met * userWeightKg * durationHours;
    return calories.isFinite ? max(0.0, calories) : 0.0;
  }

  static double estimateFromWorkout({
    required String exerciseId,
    required int reps,
    required Duration duration,
    double userWeightKg = defaultWeightKg,
  }) {
    return estimateFromLog(
      exerciseId: exerciseId,
      totalRepetitions: reps,
      sessionDurationSeconds: duration.inSeconds,
      repDurationsMs: const <int>[],
      userWeightKg: userWeightKg,
    );
  }

  static double _resolveDynamicSeconds({
    required int reps,
    required int sessionDurationSeconds,
    required double repActiveSeconds,
    required _CalorieProfile profile,
  }) {
    if (reps <= 0 && repActiveSeconds <= 0) {
      return 0.0;
    }

    final minByReps = reps * profile.minSecPerRep;
    final defaultByReps = reps * profile.defaultSecPerRep;
    final maxByReps = reps * profile.maxSecPerRep;

    var activeSeconds = repActiveSeconds > 0 ? repActiveSeconds : defaultByReps;
    if (reps > 0) {
      activeSeconds = activeSeconds.clamp(minByReps, maxByReps);
    }

    if (sessionDurationSeconds > 0) {
      final sessionSeconds = sessionDurationSeconds.toDouble();
      activeSeconds = min(activeSeconds, sessionSeconds);
    }

    return max(0.0, activeSeconds);
  }

  static double _resolveStaticSeconds({
    required int reps,
    required int sessionDurationSeconds,
    required double repActiveSeconds,
    required _CalorieProfile profile,
  }) {
    var activeSeconds = repActiveSeconds;

    if (activeSeconds <= 0 && sessionDurationSeconds > 0) {
      activeSeconds = sessionDurationSeconds.toDouble();
    }

    if (activeSeconds <= 0 && reps > 0) {
      activeSeconds = reps * profile.defaultSecPerRep;
    }

    if (sessionDurationSeconds > 0) {
      activeSeconds = min(activeSeconds, sessionDurationSeconds.toDouble());
    }

    return max(0.0, activeSeconds);
  }

  static const _CalorieProfile _defaultProfile = _CalorieProfile(
    met: 3.5,
    defaultSecPerRep: 2.5,
    minSecPerRep: 1.2,
    maxSecPerRep: 4.5,
  );
}

class _CalorieProfile {
  final double met;
  final bool isStatic;
  final double defaultSecPerRep;
  final double minSecPerRep;
  final double maxSecPerRep;

  const _CalorieProfile({
    required this.met,
    required this.defaultSecPerRep,
    required this.minSecPerRep,
    required this.maxSecPerRep,
    this.isStatic = false,
  });
}
