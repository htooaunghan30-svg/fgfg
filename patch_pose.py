import re

with open('lib/data/services/pose_detection_service.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace 1
old1 = '''  double _smoothAccuracyValue(
      double newAccuracy, double confidence, Map<String, double> jointAngles) {'''
new1 = '''  double _smoothAccuracyValue(
      double newAccuracy, double confidence, Map<String, double> jointAngles, {String? exerciseId}) {'''
if old1 in text:
    text = text.replace(old1, new1)
else:
    print("Replace 1 failed")

# Replace 2
old2 = '''    final double blendedTarget =
        (averageAccuracy * 0.7) + (newAccuracy * 0.3);
    final double rawStep =
        (blendedTarget - _lastStableAccuracy) * (_smoothingFactor * confidence);
    final double clampedStep = rawStep.clamp(
      -_maxAccuracyStepPerFrame,
      _maxAccuracyStepPerFrame,
    );'''
new2 = '''    double currentSmoothingFactor = _smoothingFactor;
    double maxStep = _maxAccuracyStepPerFrame;

    final double blendedTarget =
        (averageAccuracy * 0.7) + (newAccuracy * 0.3);
    final double rawStep =
        (blendedTarget - _lastStableAccuracy) * (currentSmoothingFactor * confidence);
    final double clampedStep = rawStep.clamp(
      -maxStep,
      maxStep,
    );'''
if old2 in text:
    text = text.replace(old2, new2)
else:
    print("Replace 2 failed")

# Replace 3
old3 = '''      // Ã¢Å“â€¦ Apply smoothing
      final smoothedAccuracy =
          _smoothAccuracyValue(rawAccuracy, poseConfidence, jointAngles);'''
new3 = '''      // Ã¢Å“â€¦ Apply smoothing
      final String? exerciseId = (exerciseConfig['id'] ?? exerciseConfig['exerciseId']) as String?;
      final smoothedAccuracy =
          _smoothAccuracyValue(rawAccuracy, poseConfidence, jointAngles, exerciseId: exerciseId);'''
if old3 in text:
    text = text.replace(old3, new3)
else:
    print("Replace 3 failed")

with open('lib/data/services/pose_detection_service.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print('Patched successfully')
