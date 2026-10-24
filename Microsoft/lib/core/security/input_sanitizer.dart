class InputSanitizer {
  const InputSanitizer._();

  static final RegExp _asciiControlChars = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');
  static final RegExp _allControlChars = RegExp(r'[\x00-\x1F\x7F]');

  static String userName(String raw, {int maxLength = 40}) {
    return sanitizeSingleLine(
      raw,
      maxLength: maxLength,
      collapseWhitespace: true,
    );
  }

  static String overlayShortText(String raw, {int maxLength = 64}) {
    return sanitizeSingleLine(
      raw,
      maxLength: maxLength,
      collapseWhitespace: true,
    );
  }

  static String overlayNarrativeText(String raw, {int maxLength = 240}) {
    return sanitizeMultiline(raw, maxLength: maxLength);
  }

  static String licenseKey(String raw, {int maxLength = 64}) {
    final cleaned = raw
        .replaceAll(_allControlChars, '')
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^A-Z0-9-]'), '');
    return _truncate(cleaned, maxLength);
  }

  static String sanitizeSingleLine(
    String raw, {
    int maxLength = 200,
    bool collapseWhitespace = false,
  }) {
    var value = raw.replaceAll(_allControlChars, '');
    value = value.trim();
    if (collapseWhitespace) {
      value = value.replaceAll(RegExp(r'\s+'), ' ');
    }
    return _truncate(value, maxLength);
  }

  static String sanitizeMultiline(
    String raw, {
    int maxLength = 500,
  }) {
    var value = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    value = value.replaceAll(_asciiControlChars, '');
    // Keep new lines for narrative text but normalize noisy trailing spaces.
    value = value
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'[ \t]+$'), ''))
        .join('\n')
        .trim();
    return _truncate(value, maxLength);
  }

  static String _truncate(String value, int maxLength) {
    if (maxLength < 1) {
      return '';
    }
    if (value.length <= maxLength) {
      return value;
    }
    return value.substring(0, maxLength);
  }
}
