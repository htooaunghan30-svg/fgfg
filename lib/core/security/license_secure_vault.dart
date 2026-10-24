import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'security_build_config.dart';
import 'security_obfuscation.dart';

class LicenseSecureVault {
  LicenseSecureVault()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  final FlutterSecureStorage _storage;

  static final String _payloadKey = SecurityObfuscation.decode(const [
    13,
    8,
    2,
    4,
    15,
    18,
    4,
    76,
    17,
    0,
    24,
    13,
    14,
    0,
    5,
  ], 97);
  static final String _deviceKey = SecurityObfuscation.decode(const [
    13,
    8,
    2,
    4,
    15,
    18,
    4,
    76,
    5,
    4,
    23,
    8,
    2,
    4,
  ], 97);

  Future<Map<String, dynamic>?> readPayload() async {
    final raw = await _storage.read(key: _scoped(_payloadKey));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> writePayload(Map<String, dynamic> payload) {
    return _storage.write(
      key: _scoped(_payloadKey),
      value: jsonEncode(payload),
    );
  }

  Future<void> deletePayload() async {
    await _storage.delete(key: _scoped(_payloadKey));
  }

  Future<String?> readDeviceId() => _storage.read(key: _scoped(_deviceKey));

  Future<void> writeDeviceId(String value) {
    return _storage.write(key: _scoped(_deviceKey), value: value);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _scoped(_payloadKey));
    await _storage.delete(key: _scoped(_deviceKey));
  }

  String _scoped(String key) =>
      '${SecurityBuildConfig.secureStorageNamespace}.$key';
}
