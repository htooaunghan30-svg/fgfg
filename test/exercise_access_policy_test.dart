import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_lifenew/features/premium/exercise_access_policy.dart';
import 'package:healthy_lifenew/features/premium/license_models.dart';

void main() {
  test('only squat is available without a premium plan', () {
    expect(ExerciseAccessPolicy.isFreeExercise('squat'), isTrue);
    expect(ExerciseAccessPolicy.isFreeExercise(' SQUAT '), isTrue);
    expect(ExerciseAccessPolicy.requiresPremiumPlan('pushup'), isTrue);
    expect(ExerciseAccessPolicy.requiresPremiumPlan(''), isTrue);
  });

  test('every defined paid plan grants premium exercise access', () {
    for (final plan in LicensePlanCode.values) {
      expect(
        featuresForPlanCode(plan),
        contains(AppFeature.premiumExercises),
      );
    }
    expect(
      featuresForPlanCode(null),
      isNot(contains(AppFeature.premiumExercises)),
    );
  });
}
