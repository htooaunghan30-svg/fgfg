import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import 'workout_overlay_customization.dart';

class ImportedOverlaySvgAsset {
  final String svgPath;
  final String displayName;
  final bool removedWhiteBackground;
  final bool normalizedViewBox;
  final bool removedUnsupportedNodes;

  const ImportedOverlaySvgAsset({
    required this.svgPath,
    required this.displayName,
    required this.removedWhiteBackground,
    required this.normalizedViewBox,
    required this.removedUnsupportedNodes,
  });

  String get summary {
    final notes = <String>[];
    if (removedWhiteBackground) {
      notes.add('white background cleaned');
    }
    if (normalizedViewBox) {
      notes.add('bounds normalized');
    }
    if (removedUnsupportedNodes) {
      notes.add('unsafe layers removed');
    }
    if (notes.isEmpty) {
      return '$displayName imported successfully.';
    }
    return '$displayName imported: ${notes.join(', ')}.';
  }
}

class OverlaySvgIconImportService {
  static const MethodChannel _channel = MethodChannel('hf.overlay.assets');
  static const Set<String> _blockedTags = <String>{
    'script',
    'foreignobject',
    'iframe',
    'metadata',
  };

  static Future<ImportedOverlaySvgAsset?> pickAndImportSvg({
    required String slotKey,
  }) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('SVG icon import is available on Android only.');
    }

    final payload = await _channel.invokeMapMethod<String, dynamic>('pickSvgFile');
    if (payload == null) {
      return null;
    }

    final sourcePath = (payload['path'] as String?)?.trim();
    final displayName = ((payload['name'] as String?)?.trim().isNotEmpty ?? false)
        ? (payload['name'] as String).trim()
        : _fileName(sourcePath);
    if (sourcePath == null || sourcePath.isEmpty) {
      throw const FormatException('Selected SVG file path is missing.');
    }
    if (!sourcePath.toLowerCase().endsWith('.svg')) {
      throw const FormatException('Only SVG files are supported.');
    }

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw const FileSystemException('Selected SVG file could not be read.');
    }

    final rawSvg = await sourceFile.readAsString();
    final sanitized = _sanitizeSvg(rawSvg);
    final managedFile = await _persistSanitizedSvg(
      slotKey: slotKey,
      svgText: sanitized.svgText,
    );

    await _safeDelete(sourceFile.path);

    return ImportedOverlaySvgAsset(
      svgPath: managedFile.path,
      displayName: displayName,
      removedWhiteBackground: sanitized.removedWhiteBackground,
      normalizedViewBox: sanitized.normalizedViewBox,
      removedUnsupportedNodes: sanitized.removedUnsupportedNodes,
    );
  }

  static Future<void> cleanupIconConfiguration(
    OverlayIconConfiguration icons,
  ) async {
    await removeImportedSvg(icons.defaultIcon.svgPath);
    await removeImportedSvg(icons.upIcon.svgPath);
    await removeImportedSvg(icons.downIcon.svgPath);
    await removeImportedSvg(icons.holdIcon.svgPath);
  }

  static Future<void> removeImportedSvg(String? svgPath) async {
    final path = svgPath?.trim();
    if (path == null || path.isEmpty || !isManagedSvgPath(path)) {
      return;
    }
    await _safeDelete(path);
  }

  static bool isManagedSvgPath(String? svgPath) {
    final path = svgPath?.trim();
    if (path == null || path.isEmpty) {
      return false;
    }
    final normalized = path.replaceAll('\\', '/').toLowerCase();
    return normalized.contains('/overlay_icons/');
  }

  static String displayNameForPath(String? svgPath) => _fileName(svgPath);

  static Future<File> _persistSanitizedSvg({
    required String slotKey,
    required String svgText,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final iconsDir = Directory('${docsDir.path}${Platform.pathSeparator}overlay_icons');
    if (!await iconsDir.exists()) {
      await iconsDir.create(recursive: true);
    }
    final safeKey = slotKey
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final target = File(
      '${iconsDir.path}${Platform.pathSeparator}${safeKey.isEmpty ? 'icon' : safeKey}_${DateTime.now().millisecondsSinceEpoch}.svg',
    );
    await target.writeAsString(svgText, flush: true);
    return target;
  }

  static Future<void> _safeDelete(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore cleanup failures for imported SVG temp files.
    }
  }

  static _SanitizedSvgResult _sanitizeSvg(String rawSvg) {
    final document = XmlDocument.parse(rawSvg);
    for (final node in List<XmlNode>.from(document.children)) {
      if (node is XmlComment || node is XmlDoctype || node is XmlProcessing) {
        node.remove();
      }
    }

    final root = document.rootElement;
    if (root.name.local.toLowerCase() != 'svg') {
      throw const FormatException('Selected file is not a valid SVG document.');
    }

    var removedUnsupportedNodes = false;
    _sanitizeElement(
      root,
      onUnsupportedNodeRemoved: () {
        removedUnsupportedNodes = true;
      },
    );

    final removedWhiteBackground = _removeBackgroundArtifacts(root);
    final normalizedViewBox = _ensureViewBox(root);
    root.setAttribute('preserveAspectRatio', 'xMidYMid meet');
    root.setAttribute('overflow', 'visible');

    return _SanitizedSvgResult(
      svgText: document.toXmlString(pretty: false),
      removedWhiteBackground: removedWhiteBackground,
      normalizedViewBox: normalizedViewBox,
      removedUnsupportedNodes: removedUnsupportedNodes,
    );
  }

  static void _sanitizeElement(
    XmlElement element, {
    required void Function() onUnsupportedNodeRemoved,
  }) {
    for (final attribute in List<XmlAttribute>.from(element.attributes)) {
      final attributeName = attribute.name.local.toLowerCase();
      if (attributeName.startsWith('on')) {
        attribute.remove();
        onUnsupportedNodeRemoved();
        continue;
      }
      if ((attributeName == 'href' || attributeName.endsWith(':href')) &&
          _isExternalReference(attribute.value)) {
        attribute.remove();
        onUnsupportedNodeRemoved();
      }
    }

    for (final child in List<XmlNode>.from(element.children)) {
      if (child is XmlComment || child is XmlProcessing) {
        child.remove();
        continue;
      }
      if (child is! XmlElement) {
        continue;
      }
      final tag = child.name.local.toLowerCase();
      if (_blockedTags.contains(tag)) {
        child.remove();
        onUnsupportedNodeRemoved();
        continue;
      }
      _sanitizeElement(
        child,
        onUnsupportedNodeRemoved: onUnsupportedNodeRemoved,
      );
    }
  }

  static bool _removeBackgroundArtifacts(XmlElement root) {
    final viewBox = _resolveViewport(root);
    if (viewBox == null) {
      return false;
    }

    var removed = false;
    final candidates = <XmlElement>[
      ...root.children.whereType<XmlElement>(),
      ...root.descendants.whereType<XmlElement>(),
    ];

    for (final element in candidates) {
      if (element.name.local.toLowerCase() != 'rect') {
        continue;
      }
      if (!_isLikelyWhiteBackgroundRect(element, viewBox.$1, viewBox.$2)) {
        continue;
      }
      element.remove();
      removed = true;
    }
    return removed;
  }

  static (double, double)? _resolveViewport(XmlElement root) {
    final viewBox = root.getAttribute('viewBox');
    if (viewBox != null) {
      final parts = viewBox
          .split(RegExp(r'[\s,]+'))
          .where((part) => part.trim().isNotEmpty)
          .toList();
      if (parts.length == 4) {
        final width = double.tryParse(parts[2]);
        final height = double.tryParse(parts[3]);
        if (width != null && height != null && width > 0 && height > 0) {
          return (width, height);
        }
      }
    }

    final width = _parseSvgLength(root.getAttribute('width'));
    final height = _parseSvgLength(root.getAttribute('height'));
    if (width != null && height != null && width > 0 && height > 0) {
      return (width, height);
    }
    return null;
  }

  static bool _ensureViewBox(XmlElement root) {
    final existing = root.getAttribute('viewBox');
    if (existing != null && existing.trim().isNotEmpty) {
      return false;
    }
    final width = _parseSvgLength(root.getAttribute('width')) ?? 512;
    final height = _parseSvgLength(root.getAttribute('height')) ?? 512;
    root.setAttribute('viewBox', '0 0 ${width.toStringAsFixed(0)} ${height.toStringAsFixed(0)}');
    return true;
  }

  static bool _isLikelyWhiteBackgroundRect(
    XmlElement element,
    double viewportWidth,
    double viewportHeight,
  ) {
    final x = _parseSvgLength(element.getAttribute('x')) ?? 0;
    final y = _parseSvgLength(element.getAttribute('y')) ?? 0;
    final width = _parseMeasuredLength(
      element.getAttribute('width'),
      viewportWidth,
    );
    final height = _parseMeasuredLength(
      element.getAttribute('height'),
      viewportHeight,
    );
    if (width == null || height == null) {
      return false;
    }

    final coversViewport = x.abs() <= viewportWidth * 0.04 &&
        y.abs() <= viewportHeight * 0.04 &&
        width >= viewportWidth * 0.94 &&
        height >= viewportHeight * 0.94;
    if (!coversViewport) {
      return false;
    }

    final fill = _resolvePresentationValue(element, 'fill') ?? '';
    final stroke = _resolvePresentationValue(element, 'stroke') ?? '';
    final opacity = double.tryParse(
          _resolvePresentationValue(element, 'fill-opacity') ??
              _resolvePresentationValue(element, 'opacity') ??
              '1',
        ) ??
        1;

    return opacity > 0.85 &&
        _isWhiteLike(fill) &&
        (stroke.isEmpty || stroke == 'none' || _isWhiteLike(stroke));
  }

  static String? _resolvePresentationValue(XmlElement element, String key) {
    final direct = element.getAttribute(key);
    if (direct != null && direct.trim().isNotEmpty) {
      return direct.trim().toLowerCase();
    }
    final style = element.getAttribute('style');
    if (style == null || style.trim().isEmpty) {
      return null;
    }
    for (final chunk in style.split(';')) {
      final parts = chunk.split(':');
      if (parts.length != 2) {
        continue;
      }
      if (parts[0].trim().toLowerCase() == key.toLowerCase()) {
        final value = parts[1].trim().toLowerCase();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    return null;
  }

  static bool _isWhiteLike(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty || value == 'none') {
      return false;
    }
    return value == '#fff' ||
        value == '#ffffff' ||
        value == '#ffff' ||
        value == '#ffffffff' ||
        value == 'white' ||
        value == 'rgb(255,255,255)' ||
        value == 'rgb(100%,100%,100%)' ||
        value == 'rgba(255,255,255,1)';
  }

  static bool _isExternalReference(String raw) {
    final value = raw.trim().toLowerCase();
    return value.startsWith('http:') ||
        value.startsWith('https:') ||
        value.startsWith('data:');
  }

  static double? _parseMeasuredLength(String? raw, double viewportExtent) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final normalized = raw.trim().toLowerCase();
    if (normalized.endsWith('%')) {
      final value = double.tryParse(normalized.substring(0, normalized.length - 1));
      if (value == null) {
        return null;
      }
      return viewportExtent * (value / 100);
    }
    return _parseSvgLength(normalized);
  }

  static double? _parseSvgLength(String? raw) {
    if (raw == null) {
      return null;
    }
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    final match = RegExp(r'^-?\d+(\.\d+)?').firstMatch(normalized);
    return match == null ? null : double.tryParse(match.group(0)!);
  }

  static String _fileName(String? path) {
    final normalized = (path ?? '').replaceAll('\\', '/').trim();
    if (normalized.isEmpty) {
      return 'icon.svg';
    }
    final segments = normalized.split('/');
    return segments.isEmpty ? normalized : segments.last;
  }
}

class _SanitizedSvgResult {
  final String svgText;
  final bool removedWhiteBackground;
  final bool normalizedViewBox;
  final bool removedUnsupportedNodes;

  const _SanitizedSvgResult({
    required this.svgText,
    required this.removedWhiteBackground,
    required this.normalizedViewBox,
    required this.removedUnsupportedNodes,
  });
}
