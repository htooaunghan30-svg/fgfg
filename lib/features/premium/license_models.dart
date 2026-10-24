enum LicenseStatusCode {
  activated,
  alreadyBound,
  invalidFormat,
  invalidDevice,
  notFound,
  revoked,
  expired,
  deviceLimit,
  integrityBlocked,
  configMissing,
  networkError,
  serverError,
  unknown,
}

enum LicensePlanCode {
  planA,
  planB,
  planC,
  planD,
}

enum AppFeature {
  premiumExercises,
  professionHobby,
  zodiac,
  worldFestival,
  luxuryOverlayStudio,
  standardOutput,
}

LicensePlanCode? parseLicensePlanCode(String? raw) {
  switch ((raw ?? '').trim().toUpperCase()) {
    case 'PLAN_A':
      return LicensePlanCode.planA;
    case 'PLAN_B':
      return LicensePlanCode.planB;
    case 'PLAN_C':
      return LicensePlanCode.planC;
    case 'PLAN_D':
      return LicensePlanCode.planD;
    default:
      return null;
  }
}

AppFeature? parseAppFeature(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'premium_exercises':
    case 'premium_exercise_library':
      return AppFeature.premiumExercises;
    case 'profession_hobby':
    case 'profession_or_hobby_program_ui':
      return AppFeature.professionHobby;
    case 'zodiac':
    case 'zodiac_sign_ui':
      return AppFeature.zodiac;
    case 'world_festival':
    case 'world_festival_program_ui':
      return AppFeature.worldFestival;
    case 'luxury_overlay_studio':
    case 'luxury_overlay_studio_ui':
      return AppFeature.luxuryOverlayStudio;
    case 'standard_output':
      return AppFeature.standardOutput;
    default:
      return null;
  }
}

Set<AppFeature> featuresForPlanCode(LicensePlanCode? planCode) {
  switch (planCode) {
    case LicensePlanCode.planA:
      return const {
        AppFeature.premiumExercises,
        AppFeature.standardOutput,
        AppFeature.zodiac,
      };
    case LicensePlanCode.planB:
      return const {
        AppFeature.premiumExercises,
        AppFeature.standardOutput,
        AppFeature.zodiac,
        AppFeature.worldFestival,
        AppFeature.professionHobby,
      };
    case LicensePlanCode.planC:
      return const {
        AppFeature.premiumExercises,
        AppFeature.standardOutput,
        AppFeature.zodiac,
        AppFeature.professionHobby,
        AppFeature.luxuryOverlayStudio,
      };
    case LicensePlanCode.planD:
      return const {
        AppFeature.premiumExercises,
        AppFeature.standardOutput,
        AppFeature.zodiac,
        AppFeature.professionHobby,
        AppFeature.luxuryOverlayStudio,
        AppFeature.worldFestival,
      };
    case null:
      return const {};
  }
}

class LicenseActivationResult {
  final bool ok;
  final LicenseStatusCode code;
  final String message;
  final String? licenseId;
  final DateTime? expiresAt;
  final int? remainingActivations;
  final LicensePlanCode? planCode;
  final Set<AppFeature> allowedFeatures;

  const LicenseActivationResult({
    required this.ok,
    required this.code,
    required this.message,
    this.licenseId,
    this.expiresAt,
    this.remainingActivations,
    this.planCode,
    this.allowedFeatures = const {},
  });
}

class PremiumEntitlement {
  final bool isPremium;
  final String? licenseId;
  final DateTime? expiresAt;
  final DateTime? lastValidatedAt;
  final String? message;
  final LicensePlanCode? planCode;
  final Set<AppFeature> allowedFeatures;

  const PremiumEntitlement({
    required this.isPremium,
    this.licenseId,
    this.expiresAt,
    this.lastValidatedAt,
    this.message,
    this.planCode,
    this.allowedFeatures = const {},
  });

  const PremiumEntitlement.free({String? message})
      : isPremium = false,
        licenseId = null,
        expiresAt = null,
        lastValidatedAt = null,
        message = message,
        planCode = null,
        allowedFeatures = const {};

  bool hasFeature(AppFeature feature) => allowedFeatures.contains(feature);
}
