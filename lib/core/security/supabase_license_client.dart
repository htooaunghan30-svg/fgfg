import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

import 'security_build_config.dart';

class SupabaseLicenseResponse {
  final bool ok;
  final int statusCode;
  final String code;
  final String? licenseId;
  final DateTime? expiresAt;
  final int? remainingActivations;
  final String? planCode;
  final List<String> allowedFeatures;

  const SupabaseLicenseResponse({
    required this.ok,
    required this.statusCode,
    required this.code,
    this.licenseId,
    this.expiresAt,
    this.remainingActivations,
    this.planCode,
    this.allowedFeatures = const [],
  });
}

class SupabaseLicenseClient {
  Future<SupabaseLicenseResponse> verify({
    required String licenseKey,
    required String deviceId,
    required String appVersion,
    required String platform,
  }) async {
    final verifyUrl = SecurityBuildConfig.verifyLicenseUrl;
    if (verifyUrl.isEmpty) {
      return const SupabaseLicenseResponse(
        ok: false,
        statusCode: 500,
        code: 'CONFIG_MISSING_VERIFY_URL',
      );
    }

    final uri = Uri.tryParse(verifyUrl);
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        !SecurityBuildConfig.isTrustedVerifyLicenseUri(uri)) {
      return const SupabaseLicenseResponse(
        ok: false,
        statusCode: 500,
        code: 'CONFIG_INVALID_VERIFY_URL',
      );
    }

    final candidateUris = _buildCandidateUris(uri);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12)
      ..idleTimeout = const Duration(seconds: 12);

    try {
      SupabaseLicenseResponse? lastFailure;
      for (var i = 0; i < candidateUris.length; i++) {
        final candidate = candidateUris[i];
        final result = await _verifyAtUri(
          client: client,
          uri: candidate,
          licenseKey: licenseKey,
          deviceId: deviceId,
          appVersion: appVersion,
          platform: platform,
        );

        if (result.ok) {
          return result;
        }

        lastFailure = result;
        final hasNextCandidate = i < candidateUris.length - 1;
        if (!hasNextCandidate || !_isLikelyPathMismatch(result)) {
          return result;
        }
      }

      return lastFailure ??
          const SupabaseLicenseResponse(
            ok: false,
            statusCode: 500,
            code: 'SERVER_ERROR',
          );
    } on IOException {
      // DNS, connect, TLS handshake, and response-stream failures are
      // transport failures. Reporting these as SERVER_ERROR misleads users
      // into thinking the license service rejected the key.
      return const SupabaseLicenseResponse(
        ok: false,
        statusCode: 0,
        code: 'NETWORK_ERROR',
      );
    } on TimeoutException {
      return const SupabaseLicenseResponse(
        ok: false,
        statusCode: 0,
        code: 'NETWORK_ERROR',
      );
    } catch (_) {
      return const SupabaseLicenseResponse(
        ok: false,
        statusCode: 500,
        code: 'SERVER_ERROR',
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<SupabaseLicenseResponse> _verifyAtUri({
    required HttpClient client,
    required Uri uri,
    required String licenseKey,
    required String deviceId,
    required String appVersion,
    required String platform,
  }) async {
    final request = await client.postUrl(uri);
    request.followRedirects = false;
    request.maxRedirects = 0;
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(
      SecurityBuildConfig.clientHeaderKey,
      SecurityBuildConfig.clientHeaderValue,
    );
    final anonKey = SecurityBuildConfig.supabaseAnonKey;
    if (anonKey.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $anonKey');
      request.headers.set('apikey', anonKey);
    }
    request.add(
      utf8.encode(
        jsonEncode({
          // Send both camelCase and snake_case for compatibility with
          // Supabase Edge Functions and Postgres RPC signatures.
          'licenseKey': licenseKey,
          'license_key': licenseKey,
          'deviceId': deviceId,
          'device_hash': deviceId,
          'appVersion': appVersion,
          'app_version': appVersion,
          'platform': platform,
        }),
      ),
    );

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    final json = _decodeResponseJson(body);

    // Preferred: signed response envelope verification.
    final signed = await _parseSignedEnvelope(
      responseStatusCode: response.statusCode,
      json: json,
    );
    if (signed != null) {
      return signed;
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        json['ok'] == true) {
      return SupabaseLicenseResponse(
        ok: true,
        statusCode: response.statusCode,
        code: (json['code'] as String? ?? 'ACTIVATED').toUpperCase(),
        licenseId: json['licenseId'] as String?,
        expiresAt: _parseDate(json['expiresAt']),
        remainingActivations: json['remainingActivations'] as int?,
        planCode: json['planCode'] as String?,
        allowedFeatures: (json['allowedFeatures'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
    }

    return SupabaseLicenseResponse(
      ok: false,
      statusCode: response.statusCode,
      code: (json['error'] as String? ?? 'LICENSE_INVALID').toUpperCase(),
    );
  }

  List<Uri> _buildCandidateUris(Uri primary) {
    final normalizedPrimary = _normalizePath(primary.path);
    final candidates = <Uri>[primary.replace(path: normalizedPrimary)];

    const legacyPath = '/verify-license';
    const edgeFunctionPath = '/functions/v1/verify-license';
    const dynamicFunctionPath = '/functions/v1/dynamic-function';

    if (normalizedPrimary == legacyPath) {
      candidates.add(primary.replace(path: edgeFunctionPath));
    } else if (normalizedPrimary == edgeFunctionPath) {
      candidates.add(primary.replace(path: legacyPath));
    }

    if (normalizedPrimary != dynamicFunctionPath) {
      candidates.add(primary.replace(path: dynamicFunctionPath));
    }

    final seen = <String>{};
    final deduped = <Uri>[];
    for (final uri in candidates) {
      final key = uri.toString();
      if (seen.add(key)) {
        deduped.add(uri);
      }
    }
    return deduped;
  }

  bool _isLikelyPathMismatch(SupabaseLicenseResponse response) {
    if (response.statusCode == 404) {
      return true;
    }
    final code = response.code.toUpperCase();
    return code.contains('REQUESTED PATH') ||
        code.contains('REQUESTED PATH IS INVALID') ||
        code.contains('REQUESTED_PATH_IS_INVALID') ||
        code.contains('ROUTE_NOT_FOUND') ||
        code == 'NOT_FOUND';
  }

  String _normalizePath(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  Map<String, dynamic> _decodeResponseJson(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
      if (decoded is String) {
        return <String, dynamic>{'error': _normalizeErrorCode(decoded)};
      }
      return <String, dynamic>{'error': _normalizeErrorCode(decoded.toString())};
    } on FormatException {
      return <String, dynamic>{'error': _normalizeErrorCode(trimmed)};
    } catch (_) {
      return <String, dynamic>{'error': 'SERVER_ERROR'};
    }
  }

  String _normalizeErrorCode(String value) {
    final normalized = value
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return normalized.isEmpty ? 'SERVER_ERROR' : normalized;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }

  Future<SupabaseLicenseResponse?> _parseSignedEnvelope({
    required int responseStatusCode,
    required Map<String, dynamic> json,
  }) async {
    final payloadRaw = json['payload'];
    final signatureRaw = json['signature'];
    final alg = (json['alg'] as String? ?? '').trim();
    if (payloadRaw is! Map<String, dynamic> ||
        signatureRaw is! String ||
        signatureRaw.trim().isEmpty) {
      return null;
    }

    if (alg.toUpperCase() != 'ED25519') {
      return const SupabaseLicenseResponse(
        ok: false,
        statusCode: 500,
        code: 'INTEGRITY_BLOCKED',
      );
    }

    final ok = await _verifySignature(payloadRaw, signatureRaw);
    if (!ok) {
      return const SupabaseLicenseResponse(
        ok: false,
        statusCode: 500,
        code: 'INTEGRITY_BLOCKED',
      );
    }

    final issuedAt = _parseDate(payloadRaw['issuedAt']);
    if (issuedAt == null ||
        DateTime.now().toUtc().difference(issuedAt).abs() >
            const Duration(minutes: 5)) {
      return const SupabaseLicenseResponse(
        ok: false,
        statusCode: 500,
        code: 'INTEGRITY_BLOCKED',
      );
    }

    final payloadOk = payloadRaw['ok'] == true;
    if (payloadOk) {
      return SupabaseLicenseResponse(
        ok: true,
        statusCode: responseStatusCode,
        code: (payloadRaw['code'] as String? ?? 'ACTIVATED').toUpperCase(),
        licenseId: payloadRaw['licenseId'] as String?,
        expiresAt: _parseDate(payloadRaw['expiresAt']),
        remainingActivations: payloadRaw['remainingActivations'] as int?,
        planCode: payloadRaw['planCode'] as String?,
        allowedFeatures:
            (payloadRaw['allowedFeatures'] as List<dynamic>? ?? const [])
                .map((e) => e.toString())
                .toList(),
      );
    }

    return SupabaseLicenseResponse(
      ok: false,
      statusCode: responseStatusCode,
      code: (payloadRaw['error'] as String? ??
              payloadRaw['code'] as String? ??
              'LICENSE_INVALID')
          .toUpperCase(),
    );
  }

  Future<bool> _verifySignature(
    Map<String, dynamic> payload,
    String signatureBase64,
  ) async {
    final publicKeyB64 = SecurityBuildConfig.licenseResponsePublicKeyBase64;
    if (publicKeyB64.isEmpty) {
      return false;
    }

    final canonical = _canonicalJson(payload);
    try {
      final algorithm = Ed25519();
      final publicKey = SimplePublicKey(
        base64Decode(publicKeyB64),
        type: KeyPairType.ed25519,
      );
      final sig = Signature(
        base64Decode(signatureBase64),
        publicKey: publicKey,
      );
      return algorithm.verify(
        utf8.encode(canonical),
        signature: sig,
      );
    } catch (_) {
      return false;
    }
  }

  String _canonicalJson(Map<String, dynamic> source) {
    final normalized = _sortJson(source);
    return jsonEncode(normalized);
  }

  Object? _sortJson(Object? value) {
    if (value is Map) {
      final entries = value.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      final out = <String, Object?>{};
      for (final e in entries) {
        out[e.key.toString()] = _sortJson(e.value);
      }
      return out;
    }
    if (value is List) {
      return value.map(_sortJson).toList(growable: false);
    }
    return value;
  }
}
