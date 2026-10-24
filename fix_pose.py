import re

path = r'c:\Users\Han Htoo Aung\healthy_life\lib\data\services\pose_detection_service.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# The broken section: the function declaration was commented out, leaving dangling body code.
# Old broken pattern (lines 82-108 area):
#   // double _smoothAccuracyValue(
#       double newAccuracy, double confidence, Map<String, double> jointAngles) {
#     if (confidence < _minConfidenceForUpdate) {
#     ...
#     return smoothedValue.clamp(0.0, 1.0);
#   }
#
# We need to replace that entire broken block with proper field declarations + proper method.

# Strategy: find the broken comment line + dangling code up to the closing brace
# then replace with clean class fields + proper _smoothAccuracyValue method

OLD_BROKEN = """  // double _smoothAccuracyValue(\r
      double newAccuracy, double confidence, Map<String, double> jointAngles) {\r
    if (confidence < _minConfidenceForUpdate) {\r
      return _lastStableAccuracy;\r
    }\r
\r
    double smoothingAlpha = 0.85; // Faster realtime updates\r
    double smoothedValue = (_lastStableAccuracy * (1.0 - smoothingAlpha)) + (newAccuracy * smoothingAlpha);\r
\r
    if ((smoothedValue - newAccuracy).abs() < 0.02) {\r
      smoothedValue = newAccuracy;\r\n    }\r
\r
    _lastStableAccuracy = smoothedValue;\r
    return smoothedValue.clamp(0.0, 1.0);\r
  }"""

NEW_PROPER = """  // Smoothing: use 35-frame rolling average + fast EMA for realtime accuracy display.
  // accuracy bar only moves when user pose is genuinely correct (confidence gate).
  static const int _accuracyHistorySize = 35;
  List<double> _accuracyRollingBuffer = [];
  double _lastStableAccuracy = 0.0;
  static const double _minConfidenceForUpdate = 0.40;
  static const Duration _transientDetectionGrace = Duration(milliseconds: 550);
  List<List<double>> _jointAngleHistory = [];
  static const int _historySize = 5;
  int _stableFrameCount = 0;

  double _smoothAccuracyValue(
      double newAccuracy, double confidence, Map<String, double> jointAngles) {
    // Gate: only update when pose detection confidence is sufficient.
    // This ensures accuracy only rises when the user is actually in frame
    // and their pose is genuinely readable – not on startup jitter.
    if (confidence < _minConfidenceForUpdate) {
      return _lastStableAccuracy;
    }

    // Rolling 35-frame average to keep a stable, trustworthy baseline.
    _accuracyRollingBuffer.add(newAccuracy);
    if (_accuracyRollingBuffer.length > _accuracyHistorySize) {
      _accuracyRollingBuffer.removeAt(0);
    }

    final double rollingAvg = _accuracyRollingBuffer.isEmpty
        ? newAccuracy
        : _accuracyRollingBuffer.reduce((a, b) => a + b) /
            _accuracyRollingBuffer.length;

    // Fast EMA blend: 80% toward rolling avg + instant snap for large moves.
    // This delivers immediate feedback when form changes significantly,
    // while the rolling avg prevents micro-jitter on the bar.
    const double emaAlpha = 0.82;
    double target = (rollingAvg * 0.6) + (newAccuracy * 0.4);
    double smoothed = (_lastStableAccuracy * (1.0 - emaAlpha)) + (target * emaAlpha);

    // Snap exactly when very close to avoid infinite approach.
    if ((smoothed - target).abs() < 0.015) {
      smoothed = target;
    }

    _lastStableAccuracy = smoothed;
    return smoothed.clamp(0.0, 1.0);
  }"""

if OLD_BROKEN in content:
    content = content.replace(OLD_BROKEN, NEW_PROPER, 1)
    print("✅ Found and replaced broken block (CRLF variant)")
else:
    # Try LF variant
    OLD_BROKEN_LF = OLD_BROKEN.replace('\r\n', '\n').replace('\r', '\n')
    content_lf = content.replace('\r\n', '\n')
    if OLD_BROKEN_LF in content_lf:
        content = content_lf.replace(OLD_BROKEN_LF, NEW_PROPER, 1)
        print("✅ Found and replaced broken block (LF variant)")
    else:
        # Try regex approach as last resort
        pattern = r'  // double _smoothAccuracyValue\([\s\S]*?return smoothedValue\.clamp\(0\.0, 1\.0\);\s*\}'
        match = re.search(pattern, content)
        if match:
            content = content[:match.start()] + NEW_PROPER + content[match.end():]
            print("✅ Found and replaced broken block (regex)")
        else:
            print("❌ Could not find broken block. Dumping lines 80-115:")
            lines = content.split('\n')
            for i, line in enumerate(lines[79:115], start=80):
                print(f"  {i}: {repr(line)}")

# Also remove duplicate field declarations that were left from old code
# (they get defined in NEW_PROPER above, so remove old ones in class body if present)
REMOVE_OLD_FIELDS = [
    r"  static const int _historySize =\s*\n\s*5.*?;\s*\n",  # old _historySize = 5
    r"  static const double _baseSmoothingFactor = 0\.8;\s*\n",
    r"  static const double _stabilityThreshold = 0;.*?\n",
    r"  static const double _minConfidenceForUpdate =\s*\n\s*0\.4;.*?update\s*\n",  # old _minConfidenceForUpdate
    r"  static const int _stabilityRequiredFrames =\s*\n\s*2;.*?update á€œá€¯á€•á€ºá€™á€œá€²\s*\n",
    r"  static const Duration _transientDetectionGrace =\s*\n\s*Duration\(milliseconds: 550\);\s*\n",
    r"  static const double _maxAccuracyStepPerFrame = 0\.1;\s*\n",
    r"  List<List<double>> _jointAngleHistory = \[\];\s*\n",
    r"  int _stableFrameCount = 0;\s*\n",
    r"  double _lastStableAccuracy = 0\.5;\s*\n",  # old value was 0.5, new is 0.0
]

for pattern in REMOVE_OLD_FIELDS:
    new_content = re.sub(pattern, '', content, count=1, flags=re.MULTILINE)
    if new_content != content:
        print(f"  Removed old field matching: {pattern[:40]}...")
        content = new_content

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done writing file.")
