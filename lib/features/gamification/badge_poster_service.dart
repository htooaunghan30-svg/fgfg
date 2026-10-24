import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/localization/badge_text_localizer.dart';
import '../../data/models/badge_achievement.dart';
import '../../data/services/profile_photo_storage.dart';

enum BadgePosterSaveStatus {
  success,
  alreadySaved,
  permissionDenied,
  renderFailed,
  saveFailed,
}

class BadgePosterSaveResult {
  final BadgePosterSaveStatus status;
  final String badgeId;
  final String? localFilePath;

  const BadgePosterSaveResult({
    required this.status,
    required this.badgeId,
    this.localFilePath,
  });

  bool get isSuccess =>
      status == BadgePosterSaveStatus.success ||
      status == BadgePosterSaveStatus.alreadySaved;
}

class BadgePosterService {
  static const String albumName = 'H_F_Badges';
  static const String _prefsKeySavedIds = 'badge_poster_saved_ids_v1';
  static const String _folderName = 'HF_Badge_Posters';
  static const int _posterWidth = 2200;
  static const int _posterHeight = 1400;
  static const int _maxRequirementsOnPoster = 4;

  Future<Set<String>> getSavedBadgeIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKeySavedIds) ?? const [];
    return raw.map((value) => value.trim()).where((value) => value.isNotEmpty).toSet();
  }

  Future<BadgePosterSaveResult> saveUnlockedBadgePoster({
    required BadgeAchievement badge,
    required String appLanguageCode,
    required String userName,
    String? profilePhotoPath,
  }) async {
    if (!badge.isUnlocked) {
      return BadgePosterSaveResult(
        status: BadgePosterSaveStatus.saveFailed,
        badgeId: badge.badgeId,
      );
    }

    final savedIds = await getSavedBadgeIds();
    if (savedIds.contains(badge.badgeId)) {
      return BadgePosterSaveResult(
        status: BadgePosterSaveStatus.alreadySaved,
        badgeId: badge.badgeId,
      );
    }

    final hasPermission = await _ensureGalleryPermission();
    if (!hasPermission) {
      return BadgePosterSaveResult(
        status: BadgePosterSaveStatus.permissionDenied,
        badgeId: badge.badgeId,
      );
    }

    final localFilePath = await _renderPosterToFile(
      badge: badge,
      appLanguageCode: appLanguageCode,
      userName: userName,
      profilePhotoPath: profilePhotoPath,
    );
    if (localFilePath == null) {
      return BadgePosterSaveResult(
        status: BadgePosterSaveStatus.renderFailed,
        badgeId: badge.badgeId,
      );
    }

    final saveResult = await GallerySaver.saveImage(
      localFilePath,
      albumName: albumName,
    );
    final savedToGallery = _isGallerySaveSuccess(saveResult);
    if (!savedToGallery) {
      return BadgePosterSaveResult(
        status: BadgePosterSaveStatus.saveFailed,
        badgeId: badge.badgeId,
        localFilePath: localFilePath,
      );
    }

    await _markBadgeSaved(badge.badgeId);
    return BadgePosterSaveResult(
      status: BadgePosterSaveStatus.success,
      badgeId: badge.badgeId,
      localFilePath: localFilePath,
    );
  }

  Future<String?> _renderPosterToFile({
    required BadgeAchievement badge,
    required String appLanguageCode,
    required String userName,
    required String? profilePhotoPath,
  }) async {
    final safeLanguage = _safeLanguageCode(appLanguageCode);
    final l10n = AppLocalizations(Locale(safeLanguage));

    final cleanUserName = _cleanText(
      userName.trim().isEmpty ? l10n.t('profile.guest_name') : userName,
      maxLen: 48,
    );
    final badgeName = _cleanText(
      BadgeTextLocalizer.localizedName(l10n, badge),
      maxLen: 64,
    );
    final requirements = BadgeTextLocalizer.localizedPlanDetails(l10n, badge)
        .map((line) => _cleanText(line, maxLen: 160))
        .where((line) => line.isNotEmpty)
        .take(_maxRequirementsOnPoster)
        .toList();

    final validatedPhotoPath =
        await ProfilePhotoStorage.validateStoredPath(profilePhotoPath);
    final ui.Image? userPhoto = await _loadPhoto(validatedPhotoPath);
    final ui.Image? badgeIcon = await _loadAssetImage(badge.iconPath);
    final theme = _themeForTier(badge.tier);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, _posterWidth.toDouble(), _posterHeight.toDouble()),
    );

    final sparkleSeed = _seedFromBadge(badge.badgeId);
    _drawBackground(canvas, theme, sparkleSeed);
    _drawMainCard(canvas, theme);
    _drawHeader(canvas, l10n, badgeName, cleanUserName, badge, theme, badgeIcon);
    _drawRequirementSection(canvas, l10n, requirements, theme);
    _drawPhotoSection(canvas, userPhoto, theme, sparkleSeed);

    final picture = recorder.endRecording();
    final image = await picture.toImage(_posterWidth, _posterHeight);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    badgeIcon?.dispose();
    userPhoto?.dispose();
    if (bytes == null) {
      return null;
    }

    final directory = await _getPosterDirectory();
    final safeBadgeId = badge.badgeId.replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_');
    final fileName =
        'badge_${safeBadgeId}_${badge.unlockedAt.millisecondsSinceEpoch}.png';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    return file.path;
  }

  Future<Directory> _getPosterDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final folder = Directory('${appDir.path}/$_folderName');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder;
  }

  Future<void> _markBadgeSaved(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await getSavedBadgeIds();
    saved.add(badgeId);
    await prefs.setStringList(_prefsKeySavedIds, saved.toList()..sort());
  }

  Future<bool> _ensureGalleryPermission() async {
    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted || photos.isLimited) {
        return true;
      }
      final storage = await Permission.storage.request();
      return storage.isGranted || storage.isLimited;
    }
    if (Platform.isIOS) {
      final photos = await Permission.photos.request();
      return photos.isGranted || photos.isLimited;
    }
    return true;
  }

  bool _isGallerySaveSuccess(dynamic result) {
    if (result == true) {
      return true;
    }
    if (result is Map) {
      final dynamic success = result['isSuccess'] ?? result['success'];
      if (success is bool) {
        return success;
      }
      if (success is String) {
        return success.toLowerCase() == 'true';
      }
      final dynamic filePath = result['filePath'] ?? result['path'];
      return filePath is String && filePath.trim().isNotEmpty;
    }
    return false;
  }

  Future<ui.Image?> _loadAssetImage(String path) async {
    if (path.trim().isEmpty) {
      return null;
    }
    try {
      final byteData = await rootBundle.load(path);
      return _decodeImage(byteData.buffer.asUint8List(), targetWidth: 180, targetHeight: 180);
    } catch (_) {
      return null;
    }
  }

  Future<ui.Image?> _loadPhoto(String? filePath) async {
    if (filePath == null || filePath.trim().isEmpty) {
      return null;
    }
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return null;
      }
      return _decodeImage(bytes, targetWidth: 960, targetHeight: 1500);
    } catch (_) {
      return null;
    }
  }

  Future<ui.Image> _decodeImage(
    Uint8List bytes, {
    required int targetWidth,
    required int targetHeight,
  }) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _drawBackground(Canvas canvas, _BadgeTheme theme, int seed) {
    final rect = Rect.fromLTWH(0, 0, _posterWidth.toDouble(), _posterHeight.toDouble());
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomRight,
        [theme.backgroundStart, theme.backgroundEnd],
      );
    canvas.drawRect(rect, paint);

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(520, 420),
        820,
        [
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.02),
        ],
      );
    canvas.drawCircle(const Offset(520, 420), 820, glowPaint);

    final edgeGlow = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(1920, 210),
        560,
        [
          Colors.white.withOpacity(0.28),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(const Offset(1920, 210), 560, edgeGlow);

    _drawSparkles(canvas, theme, seed);
  }

  void _drawMainCard(Canvas canvas, _BadgeTheme theme) {
    final cardRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(80, 90, 2040, 1220),
      const Radius.circular(50),
    );
    final cardPath = Path()..addRRect(cardRect);
    canvas.drawShadow(cardPath, Colors.black.withOpacity(0.25), 18, false);
    canvas.drawRRect(
      cardRect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(80, 90),
          const Offset(2120, 1310),
          [
            Colors.white.withOpacity(0.96),
            _tint(theme.backgroundStart, 0.78).withOpacity(0.95),
          ],
        ),
    );
    canvas.drawRRect(
      cardRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = _shade(theme.accent, 0.12).withOpacity(0.45),
    );

    final leftPanel = RRect.fromRectAndRadius(
      const Rect.fromLTWH(140, 140, 1180, 1120),
      const Radius.circular(40),
    );
    canvas.drawRRect(
      leftPanel,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(140, 140),
          const Offset(1320, 1260),
          [
            Colors.white.withOpacity(0.94),
            _tint(theme.backgroundEnd, 0.92).withOpacity(0.95),
          ],
        ),
    );
    canvas.drawRRect(
      leftPanel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = theme.accent.withOpacity(0.22),
    );
  }

  void _drawHeader(
    Canvas canvas,
    AppLocalizations l10n,
    String badgeName,
    String userName,
    BadgeAchievement badge,
    _BadgeTheme theme,
    ui.Image? badgeIcon,
  ) {
    _paintText(
      canvas,
      'H & F',
      const Offset(190, 180),
      const TextStyle(
        fontSize: 66,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        letterSpacing: 1.4,
        color: Color(0xFF1F2937),
      ),
      maxWidth: 760,
    );

    _paintText(
      canvas,
      BadgeTextLocalizer.tierLabel(l10n, badge).toUpperCase(),
      const Offset(190, 268),
      TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.1,
        color: _shade(theme.accent, 0.08),
      ),
      maxWidth: 700,
    );

    final dividerPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(190, 312),
        const Offset(520, 312),
        [
          theme.accent.withOpacity(0.65),
          Colors.transparent,
        ],
      )
      ..strokeWidth = 2.4;
    canvas.drawLine(const Offset(190, 312), const Offset(520, 312), dividerPaint);

    _drawEmblem(
      canvas: canvas,
      badgeIcon: badgeIcon,
      center: const Offset(330, 470),
      size: 230,
      theme: theme,
    );

    _paintText(
      canvas,
      l10n.t('badge.poster.badge_label'),
      const Offset(520, 382),
      const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: Color(0xFF4B5563),
      ),
      maxWidth: 620,
    );

    _drawDumbbellIcon(
      canvas,
      const Offset(470, 390),
      28,
      _shade(theme.accent, 0.05),
    );

    _paintText(
      canvas,
      badgeName,
      const Offset(520, 420),
      const TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
        height: 1.08,
        letterSpacing: 0.2,
      ),
      maxWidth: 760,
      maxLines: 2,
    );

    _paintText(
      canvas,
      l10n.t('badge.poster.user_label'),
      const Offset(520, 552),
      const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Color(0xFF4B5563),
      ),
      maxWidth: 640,
    );

    _paintText(
      canvas,
      userName,
      const Offset(520, 584),
      const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
      maxWidth: 760,
      maxLines: 1,
    );
  }

  void _drawRequirementSection(
    Canvas canvas,
    AppLocalizations l10n,
    List<String> requirements,
    _BadgeTheme theme,
  ) {
    final box = RRect.fromRectAndRadius(
      const Rect.fromLTWH(180, 690, 1100, 520),
      const Radius.circular(32),
    );
    canvas.drawRRect(
      box,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(180, 690),
          const Offset(1280, 1210),
          [
            Colors.white.withOpacity(0.88),
            theme.accent.withOpacity(0.08),
          ],
        ),
    );
    canvas.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = theme.accent.withOpacity(0.28),
    );

    _paintText(
      canvas,
      l10n.t('badge.poster.requirements_label'),
      const Offset(220, 742),
      const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
      maxWidth: 940,
    );

    var y = 808.0;
    for (final requirement in requirements) {
      _drawMedalDot(
        canvas,
        Offset(230, y + 10),
        theme,
      );
      _paintText(
        canvas,
        requirement,
        Offset(260, y),
        const TextStyle(
          fontSize: 27,
          height: 1.38,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w600,
        ),
        maxWidth: 980,
        maxLines: 2,
      );
      y += 110;
    }
  }

  void _drawPhotoSection(
    Canvas canvas,
    ui.Image? userPhoto,
    _BadgeTheme theme,
    int sparkleSeed,
  ) {
    final photoRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(1380, 150, 700, 1100),
      const Radius.circular(52),
    );
    final photoPath = Path()..addRRect(photoRect);
    canvas.drawShadow(photoPath, Colors.black.withOpacity(0.25), 16, false);
    canvas.drawRRect(
      photoRect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(1380, 150),
          const Offset(2080, 1250),
          [
            _tint(theme.backgroundStart, 0.6),
            _shade(theme.backgroundEnd, 0.05),
          ],
        ),
    );
    canvas.drawRRect(
      photoRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..color = _tint(theme.accent, 0.2).withOpacity(0.6),
    );

    final innerRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(1410, 180, 640, 1040),
      const Radius.circular(44),
    );
    canvas.drawRRect(
      innerRect,
      Paint()..color = Colors.white.withOpacity(0.95),
    );

    final clipRect = innerRect.outerRect;
    canvas.save();
    canvas.clipRRect(innerRect);
    if (userPhoto != null) {
      _drawImageCover(canvas: canvas, image: userPhoto, dst: clipRect);
    } else {
      canvas.drawRect(
        clipRect,
        Paint()
          ..shader = ui.Gradient.linear(
            clipRect.topCenter,
            clipRect.bottomCenter,
            [
              const Color(0xFFF8FAFC),
              theme.accent.withOpacity(0.25),
            ],
          ),
      );

      final placeholder = Paint()..color = theme.accent.withOpacity(0.28);
      canvas.drawCircle(const Offset(1730, 500), 78, placeholder);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(1628, 604, 204, 300),
          const Radius.circular(100),
        ),
        placeholder,
      );
      _drawSparkleCluster(canvas, theme, sparkleSeed);
    }
    canvas.restore();
  }

  void _drawImageCover({
    required Canvas canvas,
    required ui.Image image,
    required Rect dst,
  }) {
    final src = _coverSrcRect(
      srcWidth: image.width.toDouble(),
      srcHeight: image.height.toDouble(),
      dstWidth: dst.width,
      dstHeight: dst.height,
    );
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  Rect _coverSrcRect({
    required double srcWidth,
    required double srcHeight,
    required double dstWidth,
    required double dstHeight,
  }) {
    final srcAspect = srcWidth / srcHeight;
    final dstAspect = dstWidth / dstHeight;
    if (srcAspect > dstAspect) {
      final width = srcHeight * dstAspect;
      final left = (srcWidth - width) / 2;
      return Rect.fromLTWH(left, 0, width, srcHeight);
    }
    final height = srcWidth / dstAspect;
    final top = (srcHeight - height) / 2;
    return Rect.fromLTWH(0, top, srcWidth, height);
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    required double maxWidth,
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '...',
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }

  int _seedFromBadge(String badgeId) {
    var hash = 0;
    for (final rune in badgeId.runes) {
      hash = 0x1fffffff & (hash + rune);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= (hash >> 6);
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= (hash >> 11);
    hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
    return hash;
  }

  void _drawSparkles(Canvas canvas, _BadgeTheme theme, int seed) {
    final random = Random(seed);
    for (var i = 0; i < 120; i++) {
      final x = random.nextDouble() * _posterWidth;
      final y = random.nextDouble() * _posterHeight;
      final radius = 1.5 + random.nextDouble() * 4.5;
      final opacity = 0.12 + random.nextDouble() * 0.25;
      final paint = Paint()
        ..color = _tint(theme.accent, 0.45).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawSparkleCluster(Canvas canvas, _BadgeTheme theme, int seed) {
    final random = Random(seed + 97);
    for (var i = 0; i < 24; i++) {
      final x = 1500 + random.nextDouble() * 450;
      final y = 260 + random.nextDouble() * 860;
      final radius = 2 + random.nextDouble() * 5;
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.12 + random.nextDouble() * 0.22);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawEmblem({
    required Canvas canvas,
    required ui.Image? badgeIcon,
    required Offset center,
    required double size,
    required _BadgeTheme theme,
  }) {
    final outerRadius = size * 0.55;
    final innerRadius = size * 0.45;
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    final outerPaint = Paint()
      ..shader = ui.Gradient.linear(
        outerRect.topLeft,
        outerRect.bottomRight,
        [
          _tint(theme.accent, 0.5),
          _shade(theme.accent, 0.15),
        ],
      );
    canvas.drawCircle(center, outerRadius, outerPaint);
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()
        ..shader = ui.Gradient.linear(
          innerRect.topLeft,
          innerRect.bottomRight,
          [
            Colors.white.withOpacity(0.85),
            _tint(theme.backgroundStart, 0.65),
          ],
        ),
    );

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.white.withOpacity(0.7),
    );

    if (badgeIcon != null) {
      _drawImageCover(
        canvas: canvas,
        image: badgeIcon,
        dst: Rect.fromCenter(
          center: center,
          width: innerRadius * 1.2,
          height: innerRadius * 1.2,
        ),
      );
    } else {
      _drawDumbbellIcon(canvas, center, innerRadius * 1.1, theme.accent);
    }

    _drawStarIcon(
      canvas,
      Offset(center.dx, center.dy - outerRadius - 16),
      32,
      _tint(theme.accent, 0.4),
    );
  }

  void _drawDumbbellIcon(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color;
    final barHeight = size * 0.18;
    final barWidth = size * 0.9;
    final barRect = Rect.fromCenter(
      center: center,
      width: barWidth,
      height: barHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, Radius.circular(barHeight / 2)),
      paint,
    );
    final plateWidth = size * 0.18;
    final plateHeight = size * 0.5;
    final leftPlate = Rect.fromCenter(
      center: Offset(center.dx - barWidth / 2 + plateWidth / 2, center.dy),
      width: plateWidth,
      height: plateHeight,
    );
    final rightPlate = Rect.fromCenter(
      center: Offset(center.dx + barWidth / 2 - plateWidth / 2, center.dy),
      width: plateWidth,
      height: plateHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftPlate, Radius.circular(plateWidth / 2)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightPlate, Radius.circular(plateWidth / 2)),
      paint,
    );
  }

  void _drawStarIcon(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    final spikes = 5;
    final outerRadius = radius;
    final innerRadius = radius * 0.45;
    for (var i = 0; i < spikes * 2; i++) {
      final angle = (pi / spikes) * i - pi / 2;
      final r = i.isEven ? outerRadius : innerRadius;
      final point = Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawMedalDot(Canvas canvas, Offset center, _BadgeTheme theme) {
    canvas.drawCircle(
      center,
      8,
      Paint()..color = _tint(theme.accent, 0.3),
    );
    canvas.drawCircle(
      center,
      3,
      Paint()..color = Colors.white.withOpacity(0.8),
    );
  }

  _BadgeTheme _themeForTier(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.bronze:
        return const _BadgeTheme(
          backgroundStart: Color(0xFFD4A373),
          backgroundEnd: Color(0xFFB07D4F),
          accent: Color(0xFF8B5A2B),
        );
      case BadgeTier.silver:
        return const _BadgeTheme(
          backgroundStart: Color(0xFFE2E8F0),
          backgroundEnd: Color(0xFFBFC9D8),
          accent: Color(0xFF6B7280),
        );
      case BadgeTier.gold:
        return const _BadgeTheme(
          backgroundStart: Color(0xFFFDE68A),
          backgroundEnd: Color(0xFFF59E0B),
          accent: Color(0xFFB45309),
        );
      case BadgeTier.platinum:
        return const _BadgeTheme(
          backgroundStart: Color(0xFFCBD5E1),
          backgroundEnd: Color(0xFF94A3B8),
          accent: Color(0xFF334155),
        );
    }
  }

  Color _tint(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount) ?? color;
  }

  Color _shade(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount) ?? color;
  }

  String _safeLanguageCode(String code) {
    final normalized = code.trim().toLowerCase();
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == normalized) {
        return normalized;
      }
    }
    return 'en';
  }

  String _cleanText(String value, {required int maxLen}) {
    var result = value.trim();
    result = result.replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '');
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    if (result.characters.length <= maxLen) {
      return result;
    }
    return result.characters.take(max(1, maxLen)).toString().trim();
  }
}

class _BadgeTheme {
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color accent;

  const _BadgeTheme({
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.accent,
  });
}
