import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/security/app_integrity_service.dart';
import '../../core/security/license_secure_vault.dart';
import '../../core/security/polymorphic_validator.dart';
import '../../core/security/security_build_config.dart';
import '../../core/security/security_obfuscation.dart';
import '../../core/security/supabase_license_client.dart';
import 'license_models.dart';

class PremiumLicenseService {
  PremiumLicenseService({
    AppIntegrityService? integrityService,
    LicenseSecureVault? vault,
    SupabaseLicenseClient? client,
  })  : _integrityService = integrityService ?? AppIntegrityService.instance,
        _vault = vault ?? LicenseSecureVault(),
        _client = client ?? SupabaseLicenseClient();

  final AppIntegrityService _integrityService;
  final LicenseSecureVault _vault;
  final SupabaseLicenseClient _client;

  static final String _lastCheckKey = SecurityObfuscation.decode(const [
    13,
    8,
    2,
    4,
    15,
    18,
    4,
    76,
    13,
    0,
    18,
    21,
    76,
    2,
    9,
    4,
    2,
    10,
  ], 97);

  Future<LicenseActivationResult> activateLicense(String rawLicenseKey) async {
    final normalizedKey = _normalizeLicense(rawLicenseKey);
    if (!_isLicenseFormatValid(normalizedKey)) {
      return const LicenseActivationResult(
        ok: false,
        code: LicenseStatusCode.invalidFormat,
        message: 'Invalid license key format.',
      );
    }

    final verdict = await _integrityService.verify();
    if (!verdict.ok) {
      await _vault.clearAll();
      return LicenseActivationResult(
        ok: false,
        code: LicenseStatusCode.integrityBlocked,
        message: verdict.message,
      );
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final deviceId = await _getOrCreateDeviceId(verdict.runtimeSignature);

    final response = await _client.verify(
      licenseKey: normalizedKey,
      deviceId: deviceId,
      appVersion: packageInfo.version,
      platform: verdict.platform,
    );

    if (!response.ok) {
      return _mapFailure(response.code);
    }

    final licenseId = response.licenseId ?? '';
    if (licenseId.isEmpty) {
      return const LicenseActivationResult(
        ok: false,
        code: LicenseStatusCode.serverError,
        message: 'License ID was not returned by server.',
      );
    }

    final seal = PolymorphicValidator.buildSeal(
      licenseKey: normalizedKey,
      deviceId: deviceId,
      runtimeSignature: verdict.runtimeSignature,
      serverCode: response.code,
      licenseId: licenseId,
    );

    final payload = <String, dynamic>{
      'version': 1,
      'license': _encodeWithRuntime(normalizedKey, verdict.runtimeSignature),
      'licenseId': licenseId,
      'expiresAt': response.expiresAt?.toUtc().toIso8601String(),
      'serverCode': response.code,
      'seal': seal,
      _lastCheckKey: DateTime.now().toUtc().toIso8601String(),
    };

    await _vault.writePayload(payload);

    return LicenseActivationResult(
      ok: true,
      code: response.code == 'ALREADY_BOUND'
          ? LicenseStatusCode.alreadyBound
          : LicenseStatusCode.activated,
      message: response.code == 'ALREADY_BOUND'
          ? 'License is already activated on this device.'
          : 'Premium activated successfully.',
      licenseId: response.licenseId,
      expiresAt: response.expiresAt,
      remainingActivations: response.remainingActivations,
    );
  }

  Future<PremiumEntitlement> getEntitlement({
    bool forceServerCheck = false,
  }) async {
    final payload = await _vault.readPayload();
    if (payload == null) {
      return const PremiumEntitlement.free();
    }

    final verdict = await _integrityService.verify();
    if (!verdict.ok) {
      await _vault.clearAll();
      return PremiumEntitlement.free(message: verdict.message);
    }

    final encodedLicense = payload['license'] as String? ?? '';
    final licenseId = payload['licenseId'] as String? ?? '';
    final serverCode = payload['serverCode'] as String? ?? 'ACTIVATED';
    final expectedSeal = payload['seal'] as String? ?? '';

    if (encodedLicense.isEmpty || licenseId.isEmpty || expectedSeal.isEmpty) {
      await _vault.clearAll();
      return const PremiumEntitlement.free(message: 'License payload invalid.');
    }

    final licenseKey =
        _decodeWithRuntime(encodedLicense, verdict.runtimeSignature);
    final deviceId = await _getOrCreateDeviceId(verdict.runtimeSignature);

    final sealOk = PolymorphicValidator.verifySeal(
      expectedSeal: expectedSeal,
      licenseKey: licenseKey,
      deviceId: deviceId,
      runtimeSignature: verdict.runtimeSignature,
      serverCode: serverCode,
      licenseId: licenseId,
    );
    if (!sealOk) {
      await _vault.clearAll();
      return const PremiumEntitlement.free(message: 'License tamper detected.');
    }

    final expiresAt = _parseDate(payload['expiresAt']);
    if (expiresAt != null && expiresAt.isBefore(DateTime.now().toUtc())) {
      await _vault.clearAll();
      return const PremiumEntitlement.free(message: 'License expired.');
    }

    final lastValidatedAt = _parseDate(payload[_lastCheckKey]);
    if (forceServerCheck) {
      // One-time activation mode: local sealed entitlement is authoritative.
    }

    return PremiumEntitlement(
      isPremium: true,
      licenseId: licenseId,
      expiresAt: expiresAt,
      lastValidatedAt: lastValidatedAt,
      message: 'Offline grace mode.',
    );
  }

  Future<void> clearLicense() => _vault.clearAll();

  Future<void> clearAllSensitiveData() => _vault.clearAll();

  Future<String> _getOrCreateDeviceId(String runtimeSignature) async {
    final existing = await _vault.readDeviceId();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final seed = await _deviceFingerprintSeed();
    final combined = '$seed|$runtimeSignature';
    final hash = sha256.convert(utf8.encode(combined)).toString().toUpperCase();
    final deviceId = 'HF-${hash.substring(0, 40)}';
    await _vault.writeDeviceId(deviceId);
    return deviceId;
  }

  Future<String> _deviceFingerprintSeed() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      return [
        a.id,
        a.brand,
        a.model,
        a.device,
        a.hardware,
        a.fingerprint,
      ].join('|');
    }
    if (Platform.isIOS) {
      final i = await info.iosInfo;
      return [
        i.identifierForVendor ?? '',
        i.model,
        i.localizedModel,
        i.systemVersion,
      ].join('|');
    }
    return '${Platform.operatingSystem}|${Platform.operatingSystemVersion}';
  }

  bool _isLicenseFormatValid(String normalized) {
    final prefix = SecurityBuildConfig.licensePrefix;
    final pattern = RegExp('^$prefix-[A-Z2-9]{4}(?:-[A-Z2-9]{4}){3}\$');
    return pattern.hasMatch(normalized);
  }

  String _normalizeLicense(String raw) {
    return raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  String _runtimeKey(String runtimeSignature) {
    return sha256
        .convert(
          utf8.encode(
              '$runtimeSignature|${SecurityBuildConfig.secureStorageNamespace}'),
        )
        .toString();
  }

  String _encodeWithRuntime(String value, String runtimeSignature) {
    return SecurityObfuscation.xorBase64(value, _runtimeKey(runtimeSignature));
  }

  String _decodeWithRuntime(String value, String runtimeSignature) {
    return SecurityObfuscation.xorBase64Decode(
        value, _runtimeKey(runtimeSignature));
  }

  LicenseActivationResult _mapFailure(String code) {
    switch (code) {
      case 'INVALID_LICENSE_FORMAT':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.invalidFormat,
          message: 'Invalid license format.',
        );
      case 'INVALID_DEVICE_ID':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.invalidDevice,
          message: 'Invalid device identity.',
        );
      case 'LICENSE_NOT_FOUND':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.notFound,
          message: 'License key not found.',
        );
      case 'LICENSE_REVOKED':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.revoked,
          message: 'License was revoked.',
        );
      case 'LICENSE_EXPIRED':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.expired,
          message: 'License has expired.',
        );
      case 'DEVICE_LIMIT_REACHED':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.deviceLimit,
          message: 'Activation limit reached.',
        );
      case 'TLS_PINNING_FAILED':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.integrityBlocked,
          message: 'TLS pinning failed.',
        );
      case 'CONFIG_MISSING_VERIFY_URL':
      case 'CONFIG_INVALID_VERIFY_URL':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.configMissing,
          message: 'License endpoint configuration missing.',
        );
      case 'NETWORK_ERROR':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.networkError,
          message: 'Network unavailable. Try again.',
        );
      case 'SERVER_ERROR':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.serverError,
          message: 'Server error.',
        );
      case 'REQUESTED PATH IS INVALID':
      case 'REQUESTED_PATH_IS_INVALID':
      case 'ROUTE_NOT_FOUND':
      case 'NOT_FOUND':
        return const LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.configMissing,
          message: 'License endpoint path is invalid. Please update the app.',
        );
      default:
        return LicenseActivationResult(
          ok: false,
          code: LicenseStatusCode.unknown,
          message: code,
        );
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}
