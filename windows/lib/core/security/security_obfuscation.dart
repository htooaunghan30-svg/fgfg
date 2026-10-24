import 'dart:convert';
import 'dart:math';

class SecurityObfuscation {
  const SecurityObfuscation._();

  static String decode(List<int> encoded, int seed) {
    final out = encoded.map((value) => value ^ seed).toList(growable: false);
    return utf8.decode(out, allowMalformed: true);
  }

  static String xorBase64(String value, String secret) {
    if (value.isEmpty || secret.isEmpty) {
      return value;
    }
    final bytes = utf8.encode(value);
    final key = utf8.encode(secret);
    final out = <int>[];
    for (var i = 0; i < bytes.length; i++) {
      out.add(bytes[i] ^ key[i % key.length] ^ ((i * 31) % 251));
    }
    return base64Encode(out);
  }

  static String xorBase64Decode(String value, String secret) {
    if (value.isEmpty || secret.isEmpty) {
      return value;
    }
    final bytes = base64Decode(value);
    final key = utf8.encode(secret);
    final out = <int>[];
    for (var i = 0; i < bytes.length; i++) {
      out.add(bytes[i] ^ key[i % key.length] ^ ((i * 31) % 251));
    }
    return utf8.decode(out, allowMalformed: true);
  }

  static String mask(String raw, {int preserve = 4}) {
    if (raw.length <= preserve * 2) {
      return '*' * raw.length;
    }
    final left = raw.substring(0, preserve);
    final right = raw.substring(raw.length - preserve);
    return '$left${'*' * max(raw.length - (preserve * 2), 2)}$right';
  }
}
