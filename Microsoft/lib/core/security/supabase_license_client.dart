import 'dart:convert';
import 'dart:io';

import 'security_build_config.dart';

class SupabaseLicenseResponse {
  final bool ok;
  final int statusCode;
  final String code;
  final String? licenseId;
  final DateTime? expiresAt;
  final int? remainingActivations;

  const SupabaseLicenseResponse({
    required this.ok,
    required this.statusCode,
    required this.code,
    this.licenseId,
    this.expiresAt,
    this.remainingActivations,
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
    } on SocketException {
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
    request.add(
      utf8.encode(
        jsonEncode({
          'licenseKey': licenseKey,
          'deviceId': deviceId,
          'appVersion': appVersion,
          'platform': platform,
        }),
      ),
    );

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    final json = body.trim().isEmpty
        ? <String, dynamic>{}
        : (jsonDecode(body) as Map<String, dynamic>);

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

    if (normalizedPrimary == legacyPath) {
      candidates.add(primary.replace(path: edgeFunctionPath));
    } else if (normalizedPrimary == edgeFunctionPath) {
      candidates.add(primary.replace(path: legacyPath));
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

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}
