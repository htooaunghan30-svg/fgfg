// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'H&F';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '2025.1.0';
  
  // Performance settings
  static const int targetFps = 22;
  static const int poseDetectionThrottleMs = 45; // 20 FPS
  static const double minDetectionConfidence = 0.35;
  static const double minTrackingConfidence = 0.35;
  
  // Exercise defaults
  static const double defaultAngleTolerance = 15.0;
  static const Duration minRepDuration = Duration(milliseconds: 400);
  static const Duration maxRepDuration = Duration(seconds: 10);
  static const Duration noiseBufferDuration = Duration(milliseconds: 400);
  
  // Database
  static const String databaseName = 'fitness_app';
  static const int databaseVersion = 1;
  
  // Premium features
  static const List<String> premiumFeatures = [
    'voice_coach',
    'video_recording',
    'advanced_analytics',
    'skeletal_overlay',
    'custom_workouts',
  ];
  
  // Achievement tiers
  static const Map<String, int> badgeRequirements = {
    'beginner': 10,
    'intermediate': 50,
    'advanced': 100,
    'expert': 500,
    'master': 1000,
  };
  
  // Camera settings
  static const List<double> cameraAspectRatios = [16/9, 4/3, 1/1];
  static const String defaultResolution = 'high';
  
  // UI Constants
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
}
