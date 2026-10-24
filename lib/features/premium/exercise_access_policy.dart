/// Defines the small free tier and the exercises protected by a license.
abstract final class ExerciseAccessPolicy {
  static const String freeExerciseId = 'squat';

  static bool isFreeExercise(String exerciseId) =>
      exerciseId.trim().toLowerCase() == freeExerciseId;

  static bool requiresPremiumPlan(String exerciseId) =>
      !isFreeExercise(exerciseId);
}
