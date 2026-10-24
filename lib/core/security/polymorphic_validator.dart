import 'dart:convert';

import 'package:crypto/crypto.dart';

class PolymorphicValidator {
  const PolymorphicValidator._();

  static int shardAlpha(String licenseKey) {
    var total = 0;
    for (var i = 0; i < licenseKey.length; i++) {
      total += (licenseKey.codeUnitAt(i) * (i + 3)) % 211;
    }
    return total % 997;
  }

  static int shardBeta(String deviceId) {
    var total = 17;
    for (var i = 0; i < deviceId.length; i++) {
      total = ((total * 31) + deviceId.codeUnitAt(i) + i) % 1543;
    }
    return total;
  }

  static int shardGamma(String runtimeSignature) {
    final digest = sha256.convert(utf8.encode(runtimeSignature)).bytes;
    var total = 0;
    for (var i = 0; i < 8; i++) {
      total += digest[i] * (i + 1);
    }
    return total % 2029;
  }

  static int shardDelta(String serverCode) {
    var total = 7;
    for (var i = 0; i < serverCode.length; i++) {
      total = (total + (serverCode.codeUnitAt(i) ^ (i * 13))) % 4099;
    }
    return total;
  }

  static int shardEpsilon(String licenseId) {
    final digest = sha1.convert(utf8.encode(licenseId)).bytes;
    var total = 0;
    for (final value in digest.take(10)) {
      total = ((total << 1) ^ value) % 8191;
    }
    return total;
  }

  static String buildSeal({
    required String licenseKey,
    required String deviceId,
    required String runtimeSignature,
    required String serverCode,
    required String licenseId,
  }) {
    final alpha = shardAlpha(licenseKey);
    final beta = shardBeta(deviceId);
    final gamma = shardGamma(runtimeSignature);
    final delta = shardDelta(serverCode);
    final epsilon = shardEpsilon(licenseId);
    final mixed = _mix(alpha, beta, gamma, delta, epsilon);
    return sha256
        .convert(utf8.encode('$alpha|$beta|$gamma|$delta|$epsilon|$mixed'))
        .toString();
  }

  static bool verifySeal({
    required String expectedSeal,
    required String licenseKey,
    required String deviceId,
    required String runtimeSignature,
    required String serverCode,
    required String licenseId,
  }) {
    final rebuilt = buildSeal(
      licenseKey: licenseKey,
      deviceId: deviceId,
      runtimeSignature: runtimeSignature,
      serverCode: serverCode,
      licenseId: licenseId,
    );
    return rebuilt == expectedSeal;
  }

  static int _mix(int a, int b, int c, int d, int e) {
    final x = (a * 37 + b * 29 + c * 23 + d * 19 + e * 17) % 9973;
    final y = ((a ^ c) + (b ^ d) + e) % 7919;
    return (x * 3 + y * 5) % 65521;
  }
}
