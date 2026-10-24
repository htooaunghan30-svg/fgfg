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

class LicenseActivationResult {
  final bool ok;
  final LicenseStatusCode code;
  final String message;
  final String? licenseId;
  final DateTime? expiresAt;
  final int? remainingActivations;

  const LicenseActivationResult({
    required this.ok,
    required this.code,
    required this.message,
    this.licenseId,
    this.expiresAt,
    this.remainingActivations,
  });
}

class PremiumEntitlement {
  final bool isPremium;
  final String? licenseId;
  final DateTime? expiresAt;
  final DateTime? lastValidatedAt;
  final String? message;

  const PremiumEntitlement({
    required this.isPremium,
    this.licenseId,
    this.expiresAt,
    this.lastValidatedAt,
    this.message,
  });

  const PremiumEntitlement.free({String? message})
      : isPremium = false,
        licenseId = null,
        expiresAt = null,
        lastValidatedAt = null,
        message = message;
}
