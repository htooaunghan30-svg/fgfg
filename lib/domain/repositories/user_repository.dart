// lib/domain/repositories/user_repository.dart
import '../../data/models/badge_achievement.dart';
import '../../features/iconic/iconic_program.dart';
import '../../features/premium/license_models.dart';
import '../../features/premium/workout_overlay_customization.dart';

abstract class UserRepository {
  // User Preferences
  Future<bool> getIsPremium();
  Future<void> setIsPremium(bool isPremium);
  Future<LicenseActivationResult> activatePremiumLicense(String licenseKey);
  Future<PremiumEntitlement> refreshPremiumEntitlement({
    bool forceServerCheck = false,
  });
  Future<PremiumEntitlement> getPremiumEntitlement({
    bool forceServerCheck = false,
  });
  Future<void> clearPremiumLicense();

  // Settings
  // Voice counting (premium)
  Future<bool> getVoiceCountingEnabled();
  Future<void> setVoiceCountingEnabled(bool enabled);
  Future<String> getVoiceCountingLanguage();
  Future<void> setVoiceCountingLanguage(String languageCode);

  Future<bool> getShowLandmarks();
  Future<void> setShowLandmarks(bool show);

  Future<bool> getAutoRecording();
  Future<void> setAutoRecording(bool auto);

  Future<IconicProgram> getIconicProgram();
  Future<void> setIconicProgram(IconicProgram program);
  Future<String?> getProfessionThemeKey();
  Future<void> setProfessionThemeKey(String key);

  Future<WorkoutOverlayCustomization> getWorkoutOverlayCustomization();
  Future<void> setWorkoutOverlayCustomization(
    WorkoutOverlayCustomization customization,
  );

  Future<String> getSelectedTheme();
  Future<void> setSelectedTheme(String theme);

  Future<String> getAppLanguage();
  Future<void> setAppLanguage(String languageCode);
  Future<bool> getAppLanguageSelected();
  Future<void> setAppLanguageSelected(bool selected);

  // Profile
  Future<String?> getUserName();
  Future<void> setUserName(String? name);
  Future<String?> getProfilePhotoPath();
  Future<void> setProfilePhotoPath(String? path);

  // Legal acceptance / onboarding
  Future<bool> getDisclaimerAccepted();
  Future<void> setDisclaimerAccepted(bool accepted);
  Future<String?> getDisclaimerAcceptedAt();
  Future<void> setDisclaimerAcceptedAt(String? value);

  Future<bool> getTermsAccepted();
  Future<void> setTermsAccepted(bool accepted);
  Future<String?> getTermsAcceptedAt();
  Future<void> setTermsAcceptedAt(String? value);

  Future<bool> getOnboardingComplete();
  Future<void> setOnboardingComplete(bool complete);

  // Achievements
  Stream<List<BadgeAchievement>> watchBadges();
  Future<List<BadgeAchievement>> getAllBadges();
  Future<void> unlockBadge(String badgeId);
  Future<void> updateBadgeProgress(String badgeId, int progress);

  // Workout Preferences
  Future<int> getDailyGoal();
  Future<void> setDailyGoal(int reps);

  Future<List<String>> getFavoriteExercises();
  Future<void> setFavoriteExercises(List<String> exerciseIds);

  // Analytics
  Future<DateTime> getFirstWorkoutDate();
  Future<int> getTotalWorkoutDays();
  Future<int> getCurrentStreak();

  Future<List<BadgeAchievement>> getBadges();
  Future<void> saveBadges(List<BadgeAchievement> badges);

  // Add these methods for statistics
}

