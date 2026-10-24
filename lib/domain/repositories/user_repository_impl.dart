// lib/data/repositories/user_repository_impl.dart

import 'dart:async';
import 'package:isar/isar.dart'; // Isar core package
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/isar_service.dart';

// Models တွေကို မဖြစ်မနေ Import လုပ်ရပါမယ်။
// ဒါမှသာ isar.userActivities တို့ findFirst တို့ကို သုံးလို့ရမှာပါ။
import '../../data/models/badge_achievement.dart';
import '../../data/models/user_activity.dart'; // Import this
import '../../data/models/exercise_log.dart'; // Import this
import '../../features/iconic/iconic_program.dart';
import '../../features/iconic/profession_hobby_theme.dart';
import '../../features/premium/license_models.dart';
import '../../features/premium/premium_license_service.dart';
import '../../features/premium/workout_overlay_customization.dart';

import '../repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  static const String _premiumKey = 'is_premium';
  static const String _voiceCountingEnabledKey = 'voice_counting_enabled';
  static const String _voiceCountingLanguageKey = 'voice_counting_language';
  static const String _showLandmarksKey = 'show_landmarks';
  static const String _autoRecordingKey = 'auto_recording';
  static const String _iconicProgramKey = 'iconic_program';
  static const String _professionThemeKey = 'profession_theme_key';
  static const String _workoutOverlayCustomizationKey =
      'workout_overlay_customization';
  static const String _selectedThemeKey = 'selected_theme';
  static const String _appLanguageKey = 'app_language';
  static const String _appLanguageSelectedKey = 'app_language_selected';
  static const String _userNameKey = 'user_name';
  static const String _profilePhotoPathKey = 'profile_photo_path';
  static const String _disclaimerAcceptedKey = 'disclaimer_accepted';
  static const String _disclaimerAcceptedAtKey = 'disclaimer_accepted_at';
  static const String _termsAcceptedKey = 'terms_accepted';
  static const String _termsAcceptedAtKey = 'terms_accepted_at';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _dailyGoalKey = 'daily_goal';
  static const String _favoriteExercisesKey = 'favorite_exercises';

  // Nullable အဖြစ်ပြောင်းလိုက်တာက error ကင်းဖို့ ပိုစိတ်ချရပါတယ်
  SharedPreferences? _prefs;
  final Isar _isar = IsarService.instance;
  final PremiumLicenseService _premiumLicenseService = PremiumLicenseService();

  @override
  Future<List<BadgeAchievement>> getBadges() async {
    try {
      final badges = await _isar.badgeAchievements.where().findAll();
      return badges;
    } catch (e) {
      print('Error getting badges: $e');
      return [];
    }
  }

  @override
  Future<void> saveBadges(List<BadgeAchievement> badges) async {
    final isar = IsarService.instance;
    // Write Transaction သုံးပြီး Badge တွေကို Database ထဲ သိမ်းပါမယ်
    await isar.writeTxn(() async {
      await isar.badgeAchievements.putAll(badges);
    });
  }

  UserRepositoryImpl() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // SharedPreferences ready ဖြစ်မဖြစ် စစ်ပေးမယ့် method
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<bool> getIsPremium() async {
    final entitlement = await _premiumLicenseService.getEntitlement();
    await _ensureInitialized();
    final cachedFlag = _prefs!.getBool(_premiumKey) ?? false;
    if (cachedFlag != entitlement.isPremium) {
      await _prefs!.setBool(_premiumKey, entitlement.isPremium);
    }
    return entitlement.isPremium;
  }

  @override
  Future<void> setIsPremium(bool isPremium) async {
    await _ensureInitialized();
    if (isPremium) {
      throw UnsupportedError(
        'Direct premium toggle is disabled. Use activatePremiumLicense().',
      );
    }
    await _premiumLicenseService.clearLicense();
    await _prefs!.setBool(_premiumKey, false);
  }

  @override
  Future<LicenseActivationResult> activatePremiumLicense(
    String licenseKey,
  ) async {
    await _ensureInitialized();
    final result = await _premiumLicenseService.activateLicense(licenseKey);
    await _prefs!.setBool(_premiumKey, result.ok);
    return result;
  }

  @override
  Future<PremiumEntitlement> refreshPremiumEntitlement({
    bool forceServerCheck = false,
  }) async {
    await _ensureInitialized();
    final entitlement = await _premiumLicenseService.getEntitlement(
      forceServerCheck: forceServerCheck,
    );
    await _prefs!.setBool(_premiumKey, entitlement.isPremium);
    return entitlement;
  }

  @override
  Future<PremiumEntitlement> getPremiumEntitlement({
    bool forceServerCheck = false,
  }) async {
    return _premiumLicenseService.getEntitlement(
      forceServerCheck: forceServerCheck,
    );
  }

  @override
  Future<void> clearPremiumLicense() async {
    await _ensureInitialized();
    await _premiumLicenseService.clearLicense();
    await _prefs!.setBool(_premiumKey, false);
  }

  @override
  Future<bool> getVoiceCountingEnabled() async {
    await _ensureInitialized();
    return _prefs!.getBool(_voiceCountingEnabledKey) ?? false;
  }

  @override
  Future<void> setVoiceCountingEnabled(bool enabled) async {
    await _ensureInitialized();
    await _prefs!.setBool(_voiceCountingEnabledKey, enabled);
  }

  @override
  Future<String> getVoiceCountingLanguage() async {
    await _ensureInitialized();
    return _prefs!.getString(_voiceCountingLanguageKey) ?? 'en-US';
  }

  @override
  Future<void> setVoiceCountingLanguage(String languageCode) async {
    await _ensureInitialized();
    await _prefs!.setString(_voiceCountingLanguageKey, languageCode);
  }

  @override
  Future<bool> getShowLandmarks() async {
    await _ensureInitialized();
    return _prefs!.getBool(_showLandmarksKey) ?? false;
  }

  @override
  Future<void> setShowLandmarks(bool show) async {
    await _ensureInitialized();
    await _prefs!.setBool(_showLandmarksKey, show);
  }

  @override
  Future<bool> getAutoRecording() async {
    await _ensureInitialized();
    return _prefs!.getBool(_autoRecordingKey) ?? false;
  }

  @override
  Future<void> setAutoRecording(bool auto) async {
    await _ensureInitialized();
    await _prefs!.setBool(_autoRecordingKey, auto);
  }

  @override
  Future<IconicProgram> getIconicProgram() async {
    await _ensureInitialized();
    return iconicProgramFromStorage(_prefs!.getString(_iconicProgramKey));
  }

  @override
  Future<void> setIconicProgram(IconicProgram program) async {
    await _ensureInitialized();
    await _prefs!.setString(_iconicProgramKey, program.storageValue);
  }

  @override
  Future<String?> getProfessionThemeKey() async {
    await _ensureInitialized();
    final saved = _prefs!.getString(_professionThemeKey);
    if (!isProfessionThemeKey(saved)) {
      return defaultProfessionThemeKey;
    }
    return saved;
  }

  @override
  Future<void> setProfessionThemeKey(String key) async {
    await _ensureInitialized();
    final normalized = key.trim();
    if (!isProfessionThemeKey(normalized)) {
      return;
    }
    await _prefs!.setString(_professionThemeKey, normalized);
  }

  @override
  Future<WorkoutOverlayCustomization> getWorkoutOverlayCustomization() async {
    await _ensureInitialized();
    final raw = _prefs!.getString(_workoutOverlayCustomizationKey);
    return WorkoutOverlayCustomization.fromJsonString(raw);
  }

  @override
  Future<void> setWorkoutOverlayCustomization(
    WorkoutOverlayCustomization customization,
  ) async {
    await _ensureInitialized();
    await _prefs!.setString(
      _workoutOverlayCustomizationKey,
      customization.toJsonString(),
    );
  }

  @override
  Future<String> getSelectedTheme() async {
    await _ensureInitialized();
    return _prefs!.getString(_selectedThemeKey) ?? 'dark';
  }

  @override
  Future<void> setSelectedTheme(String theme) async {
    await _ensureInitialized();
    await _prefs!.setString(_selectedThemeKey, theme);
  }

  @override
  Future<String> getAppLanguage() async {
    await _ensureInitialized();
    return _prefs!.getString(_appLanguageKey) ?? 'en';
  }

  @override
  Future<void> setAppLanguage(String languageCode) async {
    await _ensureInitialized();
    await _prefs!.setString(_appLanguageKey, languageCode);
  }

  @override
  Future<bool> getAppLanguageSelected() async {
    await _ensureInitialized();
    if (_prefs!.containsKey(_appLanguageSelectedKey)) {
      return _prefs!.getBool(_appLanguageSelectedKey) ?? false;
    }
    return _prefs!.containsKey(_appLanguageKey);
  }

  @override
  Future<void> setAppLanguageSelected(bool selected) async {
    await _ensureInitialized();
    await _prefs!.setBool(_appLanguageSelectedKey, selected);
  }

  @override
  Future<String?> getUserName() async {
    await _ensureInitialized();
    final value = _prefs!.getString(_userNameKey);
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> setUserName(String? name) async {
    await _ensureInitialized();
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs!.remove(_userNameKey);
      return;
    }
    await _prefs!.setString(_userNameKey, trimmed);
  }

  @override
  Future<String?> getProfilePhotoPath() async {
    await _ensureInitialized();
    final value = _prefs!.getString(_profilePhotoPathKey);
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Future<void> setProfilePhotoPath(String? path) async {
    await _ensureInitialized();
    final trimmed = path?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs!.remove(_profilePhotoPathKey);
      return;
    }
    await _prefs!.setString(_profilePhotoPathKey, trimmed);
  }

  @override
  Future<bool> getDisclaimerAccepted() async {
    await _ensureInitialized();
    return _prefs!.getBool(_disclaimerAcceptedKey) ?? false;
  }

  @override
  Future<void> setDisclaimerAccepted(bool accepted) async {
    await _ensureInitialized();
    await _prefs!.setBool(_disclaimerAcceptedKey, accepted);
  }

  @override
  Future<String?> getDisclaimerAcceptedAt() async {
    await _ensureInitialized();
    return _prefs!.getString(_disclaimerAcceptedAtKey);
  }

  @override
  Future<void> setDisclaimerAcceptedAt(String? value) async {
    await _ensureInitialized();
    if (value == null || value.trim().isEmpty) {
      await _prefs!.remove(_disclaimerAcceptedAtKey);
      return;
    }
    await _prefs!.setString(_disclaimerAcceptedAtKey, value);
  }

  @override
  Future<bool> getTermsAccepted() async {
    await _ensureInitialized();
    return _prefs!.getBool(_termsAcceptedKey) ?? false;
  }

  @override
  Future<void> setTermsAccepted(bool accepted) async {
    await _ensureInitialized();
    await _prefs!.setBool(_termsAcceptedKey, accepted);
  }

  @override
  Future<String?> getTermsAcceptedAt() async {
    await _ensureInitialized();
    return _prefs!.getString(_termsAcceptedAtKey);
  }

  @override
  Future<void> setTermsAcceptedAt(String? value) async {
    await _ensureInitialized();
    if (value == null || value.trim().isEmpty) {
      await _prefs!.remove(_termsAcceptedAtKey);
      return;
    }
    await _prefs!.setString(_termsAcceptedAtKey, value);
  }

  @override
  Future<bool> getOnboardingComplete() async {
    await _ensureInitialized();
    return _prefs!.getBool(_onboardingCompleteKey) ?? false;
  }

  @override
  Future<void> setOnboardingComplete(bool complete) async {
    await _ensureInitialized();
    await _prefs!.setBool(_onboardingCompleteKey, complete);
  }

  @override
  Future<int> getDailyGoal() async {
    await _ensureInitialized();
    final raw = _prefs!.getInt(_dailyGoalKey) ?? 100;
    return _clampDailyGoal(raw);
  }

  @override
  Future<void> setDailyGoal(int reps) async {
    await _ensureInitialized();
    await _prefs!.setInt(_dailyGoalKey, _clampDailyGoal(reps));
  }

  @override
  Future<List<String>> getFavoriteExercises() async {
    await _ensureInitialized();
    final favoritesString = _prefs!.getString(_favoriteExercisesKey) ?? '';
    return favoritesString.isNotEmpty ? favoritesString.split(',') : [];
  }

  @override
  Future<void> setFavoriteExercises(List<String> exerciseIds) async {
    await _ensureInitialized();
    await _prefs!.setString(_favoriteExercisesKey, exerciseIds.join(','));
  }

  int _clampDailyGoal(int value) {
    if (value < 0) return 0;
    if (value > 10000) return 10000;
    return value;
  }

  @override
  Stream<List<BadgeAchievement>> watchBadges() {
    final isar = IsarService.instance;
    // Query Logic အမှန်
    return isar.badgeAchievements.where().watch(fireImmediately: true);
  }

  @override
  Future<List<BadgeAchievement>> getAllBadges() async {
    final isar = IsarService.instance;
    return await isar.badgeAchievements.where().findAll();
  }

  @override
  Future<void> unlockBadge(String badgeId) async {
    final isar = IsarService.instance;
    final badge = await isar.badgeAchievements
        .where()
        .badgeIdEqualTo(badgeId)
        .findFirst();

    if (badge != null && !badge.isUnlocked) {
      badge.progress = badge.requirement;
      badge.unlockedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.badgeAchievements.put(badge);
      });
    }
  }

  @override
  Future<void> updateBadgeProgress(String badgeId, int progress) async {
    final isar = IsarService.instance;
    final badge = await isar.badgeAchievements
        .where()
        .badgeIdEqualTo(badgeId)
        .findFirst();

    if (badge != null && progress > badge.progress) {
      badge.progress = progress;

      await isar.writeTxn(() async {
        await isar.badgeAchievements.put(badge);
      });
    }
  }

  @override
  Future<DateTime> getFirstWorkoutDate() async {
    final isar = IsarService.instance;

    // မှတ်ချက်: ExerciseLog model ကို import လုပ်ထားမှ exerciseLogs ကိုခေါ်လို့ရမယ်
    final firstLog =
        await isar.exerciseLogs.where().sortByTimestamp().findFirst();

    return firstLog?.timestamp ?? DateTime.now();
  }

  @override
  Future<int> getTotalWorkoutDays() async {
    final isar = IsarService.instance;
    // Typo Fix: userActivitiys -> userActivities
    final activities = await isar.userActivitys.where().findAll();
    return activities.length;
  }

  @override
  Future<int> getCurrentStreak() async {
    final isar = IsarService.instance;

    // Typo Fix: userActivitys -> userActivities
    final activities =
        await isar.userActivitys.where().sortByDateDesc().findAll();

    if (activities.isEmpty) return 0;

    int streak = 0;

    // Logic Improvement: အချိန်တွေကိုဖယ်ပြီး ရက်စွဲသီးသန့်တွက်ခြင်း
    DateTime now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    // ပထမဆုံးရက်က "ဒီနေ့" ဒါမှမဟုတ် "မနေ့က" မဟုတ်ရင် streak ပြတ်နေပြီ
    if (activities.isNotEmpty) {
      DateTime firstLogDate = activities.first.date;
      DateTime normalizedFirst =
          DateTime(firstLogDate.year, firstLogDate.month, firstLogDate.day);

      // ဒီနေ့လည်း မလုပ်၊ မနေ့ကလည်း မလုပ်ခဲ့ရင် 0 ပဲ
      DateTime yesterday = checkDate.subtract(const Duration(days: 1));
      if (normalizedFirst != checkDate && normalizedFirst != yesterday) {
        return 0;
      }

      // အကယ်၍ နောက်ဆုံးလုပ်ခဲ့တာ မနေ့ကဆိုရင် checkDate ကို မနေ့ကကနေ စမယ်
      if (normalizedFirst == yesterday) {
        checkDate = yesterday;
      }
    }

    for (final activity in activities) {
      // Activity date ကိုလည်း time ဖြုတ်မယ်
      DateTime activityDate =
          DateTime(activity.date.year, activity.date.month, activity.date.day);

      if (activityDate == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (activityDate.isBefore(checkDate)) {
        // ရက်ကျော်သွားရင် ရပ်မယ်
        break;
      }
      // activityDate က checkDate ထက်ကြီးနေရင် (duplicate entries for same day) ကျော်သွားမယ်
    }

    return streak;
  }
}

