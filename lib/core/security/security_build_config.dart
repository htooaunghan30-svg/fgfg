import 'package:flutter/foundation.dart';

import 'security_obfuscation.dart';

class SecurityBuildConfig {
  const SecurityBuildConfig._();

  static String get verifyLicenseUrl {
    final encryptedUrl = const String.fromEnvironment('LICENSE_VERIFY_URL_ENC');
    final decryptKey = const String.fromEnvironment('LICENSE_VERIFY_URL_KEY');

    final candidates = <String>[
      // Prefer the original endpoint when a build still carries an override
      // for the newer endpoint.
      _sanitizeVerifyUrl(
        _decryptUrl(_defaultVerifyLicenseUrlEnc, _defaultVerifyLicenseUrlKey),
      ),
      _sanitizeVerifyUrl(_decryptUrl(encryptedUrl, decryptKey)),
      'https://$_verifyLicenseHost/functions/v1/dynamic-function',
      'https://$_verifyLicenseHost/verify-license',
    ];

    for (final value in candidates) {
      final uri = Uri.tryParse(value);
      if (uri != null && isTrustedVerifyLicenseUri(uri)) {
        return uri.toString();
      }
    }
    return '';
  }

  static bool isTrustedVerifyLicenseUri(Uri uri) {
    final isHttps = uri.scheme == 'https';
    final hostMatches = uri.host == _verifyLicenseHost;
    final pathMatches =
        _allowedVerifyPaths.contains(_normalizePath(uri.path));
    final hasAllowedPort = !uri.hasPort || uri.port == 443;
    final noQueryOrFragment = !uri.hasQuery && uri.fragment.isEmpty;
    return isHttps &&
        hostMatches &&
        pathMatches &&
        hasAllowedPort &&
        noQueryOrFragment;
  }

  static String get licensePrefix {
    final prefix = const String.fromEnvironment('LICENSE_PREFIX');
    if (prefix.trim().isNotEmpty) {
      return prefix.trim().toUpperCase();
    }
    return 'HF';
  }

  static List<String> get allowedAndroidSignatures {
    final signatures = const String.fromEnvironment('APP_SIGNATURE_SHA256');
    return _csvUpper(signatures);
  }

  static String get expectedPackageId {
    final packageId = const String.fromEnvironment('EXPECTED_PACKAGE_ID');
    if (packageId.trim().isNotEmpty) {
      return packageId.trim();
    }
    return SecurityObfuscation.decode(const [
      112,
      124,
      126,
      61,
      118,
      107,
      114,
      126,
      99,
      127,
      118,
      61,
      123,
      118,
      114,
      127,
      103,
      123,
      106,
      76,
      127,
      122,
      117,
      118,
    ], 19);
  }

  static String get methodChannelName => SecurityObfuscation.decode(const [
        33,
        47,
        103,
        58,
        44,
        42,
        103,
        46,
        60,
        40,
        59,
        45,
      ], 73);

  static String get secureStorageNamespace => SecurityObfuscation.decode(const [
        89,
        91,
        76,
        68,
        64,
        92,
        68,
        4,
        69,
        64,
        74,
        76,
        71,
        90,
        76,
        4,
        95,
        24,
      ], 41);

  static String get clientHeaderKey => SecurityObfuscation.decode(const [
        59,
        110,
        43,
        37,
        110,
        32,
        47,
        42,
        38,
        45,
        55,
      ], 67);

  static String get clientHeaderValue => SecurityObfuscation.decode(const [
        41,
        43,
        47,
        43,
        47,
        38,
        116,
        113,
        122,
        112,
        123,
        43,
        52,
        52,
        54,
        38,
        58,
        37,
        123,
        123,
        43,
        43,
        38,
        43,
        41,
        41,
        9,
        8,
        11,
        22,
        43,
        54,
        115,
        115,
        115,
        122,
        115,
        41,
        40,
        43,
        36,
        43,
        36,
        41,
        40,
        36,
        58,
        36,
        43,
        41,
        36,
        41,
        43,
        40,
        43,
        43,
        36,
        37,
        58,
        39,
        38,
        39,
        38,
        52,
        39,
        48,
        37,
        32,
        36,
        43,
        41,
        123,
        123,
        118,
        117,
        36,
        41,
        43,
        43,
        36,
        36,
        43,
        41,
        36,
        43,
        36,
        43,
        41,
        36,
        123,
        115,
        122,
        123,
        41,
        40,
        47,
        40,
        43,
        43,
        41,
        40,
        43,
        41,
      ], 67);

  static String get licenseResponsePublicKeyBase64 {
    final value = const String.fromEnvironment('LICENSE_SIGN_PUBKEY_B64');
    return value.trim();
  }

  static String get supabaseAnonKey {
    final value = const String.fromEnvironment('SUPABASE_ANON_KEY');
    return value.trim();
  }

  static Duration get revalidateInterval => const Duration(hours: 12);
  static Duration get offlineGraceWindow => const Duration(days: 3);

  static bool get strictMode {
    final strict = const bool.fromEnvironment('PREMIUM_STRICT_SECURITY');
    if (kReleaseMode) {
      return true;
    }
    return strict;
  }

  static List<String> _csvUpper(String value) {
    return value
        .split(',')
        .map((item) => item.trim().toUpperCase().replaceAll(':', ''))
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String _decryptUrl(String encrypted, String key) {
    final enc = encrypted.trim();
    final sec = key.trim();
    if (enc.isEmpty || sec.isEmpty) {
      return '';
    }
    try {
      return SecurityObfuscation.xorBase64Decode(enc, sec).trim();
    } catch (_) {
      return '';
    }
  }

  static String _sanitizeVerifyUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    // Handle malformed decrypted URLs like "https<control>//host/path".
    return trimmed.replaceFirst(
      RegExp(r'^https[\x00-\x20]+//', caseSensitive: false),
      'https://',
    );
  }

  static String _normalizePath(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  static Set<String> get _allowedVerifyPaths => {
        _urlPath,
        '/functions/v1/verify-license',
        '/functions/v1/dynamic-function',
      };

  static String get _urlPath => SecurityObfuscation.decode(const [
        108,
        53,
        38,
        49,
        42,
        37,
        58,
        110,
        47,
        42,
        32,
        38,
        45,
        48,
        38,
      ], 67);

  static const String _verifyLicenseHost = 'vlkflfffznjgvthysong.supabase.co';
  static String get _defaultVerifyLicenseUrlEnc => SecurityObfuscation.decode(const [
        10,
        0,
        115,
        21,
        37,
        40,
        49,
        34,
        52,
        8,
        23,
        15,
        15,
        52,
        21,
        54,
        20,
        34,
        4,
        34,
        122,
        39,
        26,
        44,
        26,
        2,
        2,
        58,
        114,
        118,
        23,
        48,
        112,
        42,
        44,
        38,
        32,
        2,
        42,
        57,
        36,
        37,
        108,
        33,
        10,
        59,
        122,
        122,
        27,
        54,
        16,
        22,
        108,
        37,
        5,
        4,
        34,
        1,
        25,
        4,
        53,
        51,
        112,
        113,
        52,
        41,
        114,
        20,
        33,
        59,
        116,
        118,
        42,
        108,
        7,
        26,
        19,
        2,
        17,
        115,
        6,
        116,
        27,
        104,
        47,
        116,
        17,
        37,
        11,
        20,
        26,
        126,
      ], 67);

  static String get _defaultVerifyLicenseUrlKey => SecurityObfuscation.decode(const [
        11,
        5,
        28,
        16,
        6,
        0,
        22,
        17,
        6,
        28,
        22,
        17,
        15,
        28,
        8,
        6,
        26,
        28,
        113,
        115,
        113,
        117,
      ], 67);

}
