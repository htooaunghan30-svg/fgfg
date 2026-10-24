// lib/presentation/providers/user_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/security/input_sanitizer.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/models/badge_achievement.dart';
import '../../features/gamification/badge_manager.dart';
import '../../features/gamification/badge_poster_service.dart';
import '../../features/iconic/iconic_program.dart';
import '../../features/iconic/profession_hobby_theme.dart';
import '../../features/premium/license_models.dart';
import '../../features/premium/exercise_access_policy.dart';
import '../../features/premium/workout_overlay_customization.dart';
import '../../data/services/profile_photo_storage.dart';

class UserProvider with ChangeNotifier {
  final UserRepository repository;

  UserProvider(this.repository);

  // User State
  bool _isPremium = false;
  bool _voiceCountingEnabled = false;
  String _voiceCountingLanguage = 'en-US';
  bool _showLandmarks = false;
  bool _autoRecording = false;
  IconicProgram _iconicProgram = IconicProgram.none;
  String _professionThemeKey = defaultProfessionThemeKey;
  WorkoutOverlayCustomization _workoutOverlayCustomization =
      WorkoutOverlayCustomization.defaults();
  String _selectedTheme = 'dark';
  String _appLanguage = 'en';
  bool _appLanguageSelected = false;
  String _userName = '';
  String? _profilePhotoPath;
  bool _disclaimerAccepted = false;
  DateTime? _disclaimerAcceptedAt;
  bool _termsAccepted = false;
  DateTime? _termsAcceptedAt;
  bool _onboardingComplete = false;
  int _dailyGoal = 100;
  List<String> _favoriteExercises = [];
  List<BadgeAchievement> _badges = [];
  final Set<String> _knownUnlockedBadgeIds = <String>{};
  final Set<String> _savedBadgePosterIds = <String>{};
  final Set<String> _failedBadgePosterIds = <String>{};
  bool _badgeStreamPrimed = false;
  bool _suppressBadgePosterAutoSaveOnce = false;
  final BadgePosterService _badgePosterService = BadgePosterService();
  bool _isLoading = false;
  bool _isPremiumSyncing = false;
  String? _premiumMessage;
  DateTime? _premiumExpiresAt;
  PremiumEntitlement _premiumEntitlement = const PremiumEntitlement.free();
  String? _error;
  bool _initialized = false;
  Future<void>? _initializationFuture;

  AppLocalizations get _l10n => AppLocalizations(Locale(_appLanguage));

  // Streams
  Stream<List<BadgeAchievement>>? _badgesStream;
  StreamSubscription<List<BadgeAchievement>>? _badgesSubscription;

  // Getters
  bool get isPremium => _isPremium;
  bool get voiceCountingEnabled => _voiceCountingEnabled;
  String get voiceCountingLanguage => _voiceCountingLanguage;
  bool get showLandmarks => _showLandmarks;
  bool get autoRecording => _autoRecording;
  IconicProgram get iconicProgram => _iconicProgram;
  String get professionThemeKey => _professionThemeKey;
  WorkoutOverlayCustomization get workoutOverlayCustomization =>
      _workoutOverlayCustomization;
  String get selectedTheme => _selectedTheme;
  String get appLanguage => _appLanguage;
  bool get appLanguageSelected => _appLanguageSelected;
  String get userName => _userName;
  String? get profilePhotoPath => _profilePhotoPath;
  bool get disclaimerAccepted => _disclaimerAccepted;
  DateTime? get disclaimerAcceptedAt => _disclaimerAcceptedAt;
  bool get termsAccepted => _termsAccepted;
  DateTime? get termsAcceptedAt => _termsAcceptedAt;
  bool get onboardingComplete => _onboardingComplete;
  int get dailyGoal => _dailyGoal;
  List<String> get favoriteExercises => _favoriteExercises;
  List<BadgeAchievement> get badges => _badges;
  String get badgePosterAlbumName => BadgePosterService.albumName;
  bool get isLoading => _isLoading;
  bool get isPremiumSyncing => _isPremiumSyncing;
  String? get premiumMessage => _premiumMessage;
  DateTime? get premiumExpiresAt => _premiumExpiresAt;
  PremiumEntitlement get premiumEntitlement => _premiumEntitlement;
  bool canUseFeature(AppFeature feature) =>
      _isPremium && _premiumEntitlement.hasFeature(feature);
  bool get canUseProfessionHobby =>
      canUseFeature(AppFeature.professionHobby);
  bool get canUseZodiac => canUseFeature(AppFeature.zodiac);
  bool get canUseWorldFestival => canUseFeature(AppFeature.worldFestival);
  bool get canUseLuxuryOverlayStudio =>
      canUseFeature(AppFeature.luxuryOverlayStudio);
  bool get canUseStandardOutput => canUseFeature(AppFeature.standardOutput);
  bool get canUsePremiumExercises =>
      canUseFeature(AppFeature.premiumExercises);
  String? get error => _error;

  // Initialization
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final inFlight = _initializationFuture;
    if (inFlight != null) {
      return inFlight;
    }
    return _initializationFuture = _initializeInternal();
  }

  Future<void> _initializeInternal() async {
    _isLoading = true;
    notifyListeners();

    try {
      await BadgeManager().initialize();

      // Load user preferences
      _isPremium = await repository.getIsPremium();
      _premiumEntitlement = await repository.getPremiumEntitlement();
      _voiceCountingEnabled = await repository.getVoiceCountingEnabled();
      _voiceCountingLanguage = await repository.getVoiceCountingLanguage();
      _showLandmarks = await repository.getShowLandmarks();
      if (_showLandmarks) {
        _showLandmarks = false;
        await repository.setShowLandmarks(false);
      }
      _autoRecording = await repository.getAutoRecording();
      _iconicProgram = await repository.getIconicProgram();
      await _sanitizeIconicProgramByEntitlement();
      _professionThemeKey =
          await repository.getProfessionThemeKey() ?? defaultProfessionThemeKey;
      if (!isProfessionThemeKey(_professionThemeKey)) {
        _professionThemeKey = defaultProfessionThemeKey;
      }
      _workoutOverlayCustomization =
          await repository.getWorkoutOverlayCustomization();
      _workoutOverlayCustomization = _workoutOverlayCustomization.sanitized();
      _selectedTheme = await repository.getSelectedTheme();
      _appLanguage = await repository.getAppLanguage();
      _appLanguageSelected = await repository.getAppLanguageSelected();
      _userName = _sanitizeUserName((await repository.getUserName()) ?? '');
      final storedPhotoPath = await repository.getProfilePhotoPath();
      _profilePhotoPath =
          await ProfilePhotoStorage.validateStoredPath(storedPhotoPath);
      if (storedPhotoPath != _profilePhotoPath) {
        await repository.setProfilePhotoPath(_profilePhotoPath);
      }
      _disclaimerAccepted = await repository.getDisclaimerAccepted();
      _termsAccepted = await repository.getTermsAccepted();
      _onboardingComplete = await repository.getOnboardingComplete();
      final rawDisclaimerAt = await repository.getDisclaimerAcceptedAt();
      final rawTermsAt = await repository.getTermsAcceptedAt();
      _disclaimerAcceptedAt =
          rawDisclaimerAt == null ? null : DateTime.tryParse(rawDisclaimerAt);
      _termsAcceptedAt =
          rawTermsAt == null ? null : DateTime.tryParse(rawTermsAt);
      if (_disclaimerAccepted && _disclaimerAcceptedAt == null) {
        _disclaimerAcceptedAt = DateTime.now().toUtc();
        await repository.setDisclaimerAcceptedAt(
          _disclaimerAcceptedAt!.toIso8601String(),
        );
      }
      if (_termsAccepted && _termsAcceptedAt == null) {
        _termsAcceptedAt = DateTime.now().toUtc();
        await repository.setTermsAcceptedAt(
          _termsAcceptedAt!.toIso8601String(),
        );
      }
      if (_disclaimerAccepted && _termsAccepted && !_onboardingComplete) {
        _onboardingComplete = true;
        await repository.setOnboardingComplete(true);
      }
      if (_selectedTheme == 'system') {
        _selectedTheme = 'dark';
        await repository.setSelectedTheme(_selectedTheme);
      }
      _dailyGoal = await repository.getDailyGoal();
      _favoriteExercises = await repository.getFavoriteExercises();
      final savedBadgeIds = await _badgePosterService.getSavedBadgeIds();
      _savedBadgePosterIds
        ..clear()
        ..addAll(savedBadgeIds);
      _failedBadgePosterIds.clear();
      unawaited(refreshPremiumStatus(forceServerCheck: false));

      // Load badges
      _startBadgesSubscription();

      _error = null;
      _initialized = true;
    } catch (e) {
      _error = _l10n.t(
        'common.error_with_message',
        params: {'message': 'Failed to initialize user data: $e'},
      );
    } finally {
      _isLoading = false;
      _initializationFuture = null;
      notifyListeners();
    }
  }

  void _startBadgesSubscription() {
    _badgesSubscription?.cancel();
    _badgesStream = repository.watchBadges();
    _badgesSubscription = _badgesStream?.listen((badges) {
      _badges = badges;
      final unlockedBadgeIds = badges
          .where((badge) => badge.isUnlocked)
          .map((badge) => badge.badgeId)
          .toSet();

      if (!_badgeStreamPrimed) {
        _badgeStreamPrimed = true;
        _knownUnlockedBadgeIds
          ..clear()
          ..addAll(unlockedBadgeIds);
      } else {
        final newlyUnlocked =
            unlockedBadgeIds.difference(_knownUnlockedBadgeIds);
        _knownUnlockedBadgeIds
          ..clear()
          ..addAll(unlockedBadgeIds);
        if (newlyUnlocked.isNotEmpty) {
          if (_suppressBadgePosterAutoSaveOnce) {
            _suppressBadgePosterAutoSaveOnce = false;
          } else {
            unawaited(_saveNewBadgePosters(newlyUnlocked, badges));
          }
        }
      }

      notifyListeners();
    });
  }

  Future<void> _saveNewBadgePosters(
    Set<String> newlyUnlockedBadgeIds,
    List<BadgeAchievement> currentBadges,
  ) async {
    final badgesById = {
      for (final badge in currentBadges) badge.badgeId: badge
    };
    for (final badgeId in newlyUnlockedBadgeIds) {
      final badge = badgesById[badgeId];
      if (badge == null || !badge.isUnlocked) {
        continue;
      }

      final result = await _badgePosterService.saveUnlockedBadgePoster(
        badge: badge,
        appLanguageCode: _appLanguage,
        userName: _userName,
        profilePhotoPath: _profilePhotoPath,
      );

      if (result.status == BadgePosterSaveStatus.success ||
          result.status == BadgePosterSaveStatus.alreadySaved) {
        _savedBadgePosterIds.add(badgeId);
        _failedBadgePosterIds.remove(badgeId);
      } else {
        _failedBadgePosterIds.add(badgeId);
      }
    }
    notifyListeners();
  }

  // Premium Management
  Future<void> upgradeToPremium() async {
    _error = _l10n.t('premium.license.enter_key');
    notifyListeners();
  }

  Future<void> downgradeToFree() async {
    await deactivatePremiumLicense();
  }

  Future<LicenseActivationResult> activatePremiumLicense(
    String licenseKey,
  ) async {
    final normalizedLicenseKey = InputSanitizer.licenseKey(licenseKey);
    if (normalizedLicenseKey.isEmpty) {
      return const LicenseActivationResult(
        ok: false,
        code: LicenseStatusCode.invalidFormat,
        message: 'Invalid license key format.',
      );
    }

    _isLoading = true;
    _premiumMessage = null;
    _error = null;
    notifyListeners();

    try {
      final result =
          await repository.activatePremiumLicense(normalizedLicenseKey);
      _isPremium = result.ok;
      _premiumEntitlement = result.ok
          ? PremiumEntitlement(
              isPremium: true,
              licenseId: result.licenseId,
              expiresAt: result.expiresAt,
              planCode: result.planCode,
              allowedFeatures: result.allowedFeatures,
            )
          : const PremiumEntitlement.free();
      _premiumMessage = result.ok
          ? (result.code == LicenseStatusCode.alreadyBound
              ? _l10n.t('premium.license.already_active')
              : _l10n.t('premium.license.activated'))
          : result.message;
      _premiumExpiresAt = result.expiresAt;
      await _sanitizeIconicProgramByEntitlement();
      if (!result.ok) {
        _error = result.message;
      }
      return result;
    } catch (e) {
      _error = _l10n.t(
        'common.error_with_message',
        params: {'message': 'Failed to activate premium: $e'},
      );
      return const LicenseActivationResult(
        ok: false,
        code: LicenseStatusCode.unknown,
        message: 'Activation failed.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deactivatePremiumLicense() async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.clearPremiumLicense();
      _isPremium = false;
      _premiumEntitlement = const PremiumEntitlement.free();
      _premiumExpiresAt = null;
      _premiumMessage = _l10n.t('premium.license.disabled_device');
      _error = null;
      await _sanitizeIconicProgramByEntitlement();
    } catch (e) {
      _error = _l10n.t(
        'common.error_with_message',
        params: {'message': 'Failed to downgrade to free: $e'},
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPremiumStatus({bool forceServerCheck = false}) async {
    _isPremiumSyncing = true;
    notifyListeners();

    try {
      final entitlement = await repository.refreshPremiumEntitlement(
        forceServerCheck: forceServerCheck,
      );
      _premiumEntitlement = entitlement;
      _isPremium = entitlement.isPremium;
      if (!entitlement.isPremium) {
        _premiumExpiresAt = null;
      }
      await _sanitizeIconicProgramByEntitlement();
    } catch (e) {
      _error = _l10n.t(
        'common.error_with_message',
        params: {'message': 'Premium validation failed: $e'},
      );
    } finally {
      _isPremiumSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> ensurePremiumAccess({bool refresh = true}) async {
    if (refresh) {
      try {
        final premium = await repository.getIsPremium();
        if (_isPremium != premium) {
          _isPremium = premium;
          if (!premium) {
            _premiumExpiresAt = null;
          }
          notifyListeners();
        }
      } catch (e) {
        _error = _l10n.t(
          'common.error_with_message',
          params: {'message': 'Premium validation failed: $e'},
        );
        notifyListeners();
      }
    }

    if (_isPremium) {
      return true;
    }

    _premiumMessage ??= _l10n.t('exercise.premium.required_title');
    notifyListeners();
    return false;
  }

  Future<bool> ensureFeatureAccess(
    AppFeature feature, {
    bool refresh = true,
  }) async {
    if (refresh) {
      try {
        final entitlement = await repository.getPremiumEntitlement();
        _premiumEntitlement = entitlement;
        _isPremium = entitlement.isPremium;
        if (!_isPremium) {
          _premiumExpiresAt = null;
        }
        await _sanitizeIconicProgramByEntitlement();
        notifyListeners();
      } catch (e) {
        _error = _l10n.t(
          'common.error_with_message',
          params: {'message': 'Feature validation failed: $e'},
        );
        notifyListeners();
      }
    }

    if (canUseFeature(feature)) {
      return true;
    }

    _premiumMessage ??= _l10n.t('exercise.premium.required_title');
    notifyListeners();
    return false;
  }

  Future<bool> ensureExerciseAccess(
    String exerciseId, {
    bool refresh = true,
  }) {
    if (ExerciseAccessPolicy.isFreeExercise(exerciseId)) {
      return Future.value(true);
    }
    return ensureFeatureAccess(
      AppFeature.premiumExercises,
      refresh: refresh,
    );
  }

  // Settings Management
  Future<void> toggleVoiceCounting() async {
    if (!await ensurePremiumAccess()) {
      return;
    }
    _voiceCountingEnabled = !_voiceCountingEnabled;
    await repository.setVoiceCountingEnabled(_voiceCountingEnabled);
    notifyListeners();
  }

  Future<void> setVoiceCountingLanguage(String languageCode) async {
    if (!await ensurePremiumAccess()) {
      return;
    }
    _voiceCountingLanguage = languageCode;
    await repository.setVoiceCountingLanguage(languageCode);
    notifyListeners();
  }

  Future<void> toggleLandmarks() async {
    _showLandmarks = !_showLandmarks;
    await repository.setShowLandmarks(_showLandmarks);
    notifyListeners();
  }

  Future<void> toggleAutoRecording() async {
    _autoRecording = !_autoRecording;
    await repository.setAutoRecording(_autoRecording);
    notifyListeners();
  }

  Future<void> setIconicProgram(IconicProgram program) async {
    if (program == IconicProgram.zodiac &&
        !await ensureFeatureAccess(AppFeature.zodiac)) {
      return;
    }
    if (program == IconicProgram.worldFestival &&
        !await ensureFeatureAccess(AppFeature.worldFestival)) {
      return;
    }
    if (program == IconicProgram.professionHobby &&
        !await ensureFeatureAccess(AppFeature.professionHobby)) {
      return;
    }
    if (program == IconicProgram.luxuryStudio &&
        !await ensureFeatureAccess(AppFeature.luxuryOverlayStudio)) {
      return;
    }
    if (_iconicProgram == program) return;
    _iconicProgram = program;
    await repository.setIconicProgram(program);
    notifyListeners();
  }

  Future<void> _sanitizeIconicProgramByEntitlement() async {
    final mappedFeature = _featureForIconicProgram(_iconicProgram);
    if (mappedFeature == null || canUseFeature(mappedFeature)) {
      return;
    }
    _iconicProgram = IconicProgram.none;
    await repository.setIconicProgram(_iconicProgram);
  }

  AppFeature? _featureForIconicProgram(IconicProgram program) {
    switch (program) {
      case IconicProgram.professionHobby:
        return AppFeature.professionHobby;
      case IconicProgram.zodiac:
        return AppFeature.zodiac;
      case IconicProgram.worldFestival:
        return AppFeature.worldFestival;
      case IconicProgram.luxuryStudio:
        return AppFeature.luxuryOverlayStudio;
      case IconicProgram.none:
        return null;
    }
  }

  Future<void> setProfessionThemeKey(String key) async {
    if (!await ensurePremiumAccess()) {
      return;
    }
    final normalized = key.trim();
    if (!isProfessionThemeKey(normalized)) {
      return;
    }
    if (_professionThemeKey == normalized) {
      if (_iconicProgram != IconicProgram.professionHobby) {
        _iconicProgram = IconicProgram.professionHobby;
        await repository.setIconicProgram(_iconicProgram);
        notifyListeners();
      }
      return;
    }

    _professionThemeKey = normalized;
    if (_iconicProgram != IconicProgram.professionHobby) {
      _iconicProgram = IconicProgram.professionHobby;
      await repository.setIconicProgram(_iconicProgram);
    }
    await repository.setProfessionThemeKey(normalized);
    notifyListeners();
  }

  Future<void> setWorkoutOverlayCustomization(
    WorkoutOverlayCustomization customization,
  ) async {
    final sanitizedCustomization = customization.sanitized();
    final defaults = WorkoutOverlayCustomization.defaults();
    final requiresPremium =
        sanitizedCustomization.toJsonString() != defaults.toJsonString();
    if (requiresPremium && !await ensurePremiumAccess()) {
      return;
    }
    _workoutOverlayCustomization = sanitizedCustomization;
    await repository.setWorkoutOverlayCustomization(sanitizedCustomization);
    notifyListeners();
  }

  Future<void> resetWorkoutOverlayCustomization() async {
    await setWorkoutOverlayCustomization(
      WorkoutOverlayCustomization.defaults(),
    );
  }

  static const Set<String> _allowedThemes = {'light', 'dark', 'gold', 'pink'};

  Future<void> setTheme(String theme) async {
    if (!_allowedThemes.contains(theme)) return;
    _selectedTheme = theme;
    await repository.setSelectedTheme(theme);
    notifyListeners();
  }

  Future<void> setAppLanguage(String languageCode) async {
    _appLanguage = languageCode;
    await repository.setAppLanguage(languageCode);
    if (!_appLanguageSelected) {
      _appLanguageSelected = true;
      await repository.setAppLanguageSelected(true);
    }
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    final sanitized = _sanitizeUserName(name);
    _userName = sanitized;
    await repository.setUserName(sanitized.isEmpty ? null : sanitized);
    notifyListeners();
  }

  Future<ProfilePhotoSaveStatus> updateProfilePhoto(XFile file) async {
    final result = await ProfilePhotoStorage.saveProfilePhoto(
      file,
      previousPath: _profilePhotoPath,
    );
    if (result.isSuccess) {
      _profilePhotoPath = result.path;
      await repository.setProfilePhotoPath(result.path);
      notifyListeners();
    }
    return result.status;
  }

  Future<void> removeProfilePhoto() async {
    await ProfilePhotoStorage.deleteProfilePhoto(_profilePhotoPath);
    _profilePhotoPath = null;
    await repository.setProfilePhotoPath(null);
    notifyListeners();
  }

  String _sanitizeUserName(String value) {
    return InputSanitizer.userName(value);
  }

  Future<void> acceptDisclaimer() async {
    _disclaimerAccepted = true;
    _disclaimerAcceptedAt = DateTime.now().toUtc();
    await repository.setDisclaimerAccepted(true);
    await repository.setDisclaimerAcceptedAt(
      _disclaimerAcceptedAt!.toIso8601String(),
    );
    notifyListeners();
  }

  Future<void> acceptTerms() async {
    _termsAccepted = true;
    _termsAcceptedAt = DateTime.now().toUtc();
    await repository.setTermsAccepted(true);
    await repository.setTermsAcceptedAt(
      _termsAcceptedAt!.toIso8601String(),
    );
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await repository.setOnboardingComplete(true);
    notifyListeners();
  }

  Future<void> setDailyGoal(int goal) async {
    final sanitized = _clampDailyGoal(goal);
    _dailyGoal = sanitized;
    await repository.setDailyGoal(sanitized);
    notifyListeners();
  }

  Future<void> toggleFavoriteExercise(String exerciseId) async {
    if (_favoriteExercises.contains(exerciseId)) {
      _favoriteExercises.remove(exerciseId);
    } else {
      _favoriteExercises.add(exerciseId);
    }

    await repository.setFavoriteExercises(_favoriteExercises);
    notifyListeners();
  }

  // Badge Management
  Future<void> unlockBadge(String badgeId) async {
    await repository.unlockBadge(badgeId);
  }

  Future<void> updateBadgeProgress(String badgeId, int progress) async {
    await repository.updateBadgeProgress(badgeId, progress);
  }

  Future<void> loadBadges() async {
    try {
      _badges = await repository.getBadges();
      notifyListeners();
    } catch (e) {
      print('Error loading badges: $e');
    }
  }

  void suppressBadgePosterAutoSaveOnce() {
    _suppressBadgePosterAutoSaveOnce = true;
  }

  // Analytics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final stats = {
        'firstWorkoutDate': await repository.getFirstWorkoutDate(),
        'totalWorkoutDays': await repository.getTotalWorkoutDays(),
        'currentStreak': await repository.getCurrentStreak(),
        'dailyGoal': _dailyGoal,
        'favoriteExercises': _favoriteExercises.length,
        'unlockedBadges': _badges.where((b) => b.isUnlocked).length,
        'totalBadges': _badges.length,
        'totalReps': await _calculateTotalReps(),
        'totalWorkouts': await _calculateTotalWorkouts(),
      };
      return stats;
    } catch (e) {
      print('Error getting user statistics: $e');
      return {};
    }
  }

  Future<int> _calculateTotalReps() async {
    // Implement total reps calculation
    return 0; // Temporary
  }

  Future<int> _calculateTotalWorkouts() async {
    // Implement total workouts calculation
    return 0; // Temporary
  }

  int _clampDailyGoal(int value) {
    if (value < 0) return 0;
    if (value > 10000) return 10000;
    return value;
  }

  bool isBadgePosterSaved(String badgeId) {
    return _savedBadgePosterIds.contains(badgeId);
  }

  bool isBadgePosterSaveFailed(String badgeId) {
    return _failedBadgePosterIds.contains(badgeId);
  }

  // Cleanup
  @override
  void dispose() {
    _badgesSubscription?.cancel();
    super.dispose();
  }
}
