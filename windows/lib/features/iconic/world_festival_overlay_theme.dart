import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'world_festival.dart';

@immutable
class WorldFestivalBarArtDirection {
  static const int variantCount = 40;

  final int variantId;

  const WorldFestivalBarArtDirection(this.variantId);

  int get familyIndex => variantId % 10;
  int get ornamentIndex => variantId ~/ 10;

  double get waveAmplitude => 0.10 + ((familyIndex % 4) * 0.018);
  double get crestDepth => 0.08 + ((familyIndex % 5) * 0.015);
  double get leadingBulge => 0.18 + ((familyIndex % 3) * 0.035);
  double get spillReach => 0.30 + (ornamentIndex * 0.05);
  double get glossStrength => 0.16 + (ornamentIndex * 0.035);
  double get textureDensity => 0.22 + ((familyIndex % 4) * 0.07);

  Path buildTrackPath(Rect rect, {double inset = 0}) {
    final safeRect = Rect.fromLTRB(
      rect.left + inset,
      rect.top + inset,
      rect.right - inset,
      rect.bottom - inset,
    );
    if (safeRect.width <= 0 || safeRect.height <= 0) {
      return Path();
    }

    switch (familyIndex) {
      case 0:
        return _buildTidalPath(safeRect);
      case 1:
        return _buildFacetedPath(safeRect);
      case 2:
        return _buildLanternPath(safeRect);
      case 3:
        return _buildRibbonPath(safeRect);
      case 4:
        return _buildCrownPath(safeRect);
      case 5:
        return _buildPetalPath(safeRect);
      case 6:
        return _buildDunePath(safeRect);
      case 7:
        return _buildCometPath(safeRect);
      case 8:
        return _buildCarvedPath(safeRect);
      case 9:
      default:
        return _buildHarborPath(safeRect);
    }
  }

  Path buildFillPath(
    Rect rect,
    double progress, {
    double flowPhase = 0,
  }) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    if (safeProgress <= 0) {
      return Path();
    }

    final fillWidth =
        math.max(rect.height * 0.36, rect.width * safeProgress).toDouble();
    final fillRight = math.min(rect.right, rect.left + fillWidth).toDouble();
    final wave = rect.height * waveAmplitude;
    final bulge = rect.height * leadingBulge;
    final phase = math.sin(flowPhase * math.pi * 2) * wave * 0.45;

    final path = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(fillRight - (bulge * 1.35), rect.top)
      ..cubicTo(
        fillRight - (bulge * 0.35),
        rect.top + (wave * 0.12),
        fillRight + (bulge * 0.30),
        rect.center.dy - wave - phase,
        fillRight - (bulge * 0.08),
        rect.center.dy,
      )
      ..cubicTo(
        fillRight + (bulge * 0.30),
        rect.center.dy + wave - phase,
        fillRight - (bulge * 0.35),
        rect.bottom - (wave * 0.12),
        fillRight - (bulge * 1.35),
        rect.bottom,
      )
      ..lineTo(rect.left, rect.bottom)
      ..close();

    return path;
  }

  Path buildSpillPath(
    Offset origin,
    Size canvasSize, {
    required double intensity,
    required double flowPhase,
  }) {
    final safeIntensity = intensity.clamp(0.0, 1.0).toDouble();
    if (safeIntensity <= 0) {
      return Path();
    }

    final reach = canvasSize.height * (0.18 + (spillReach * safeIntensity));
    final sway = (canvasSize.width * 0.012) + (familyIndex * 0.6);
    final ripple = math.sin(flowPhase * math.pi * 2) * sway;
    final bottomY =
        math.min(canvasSize.height * 0.74, origin.dy + reach).toDouble();
    final waistX = origin.dx + ripple;
    final lowerX = origin.dx - (ripple * 0.55);
    final streamHalf = (10 + (18 * safeIntensity)).toDouble();

    return Path()
      ..moveTo(origin.dx - (streamHalf * 0.42), origin.dy)
      ..cubicTo(
        origin.dx - streamHalf,
        origin.dy + (reach * 0.12),
        waistX - (streamHalf * 0.55),
        origin.dy + (reach * 0.36),
        waistX,
        origin.dy + (reach * 0.52),
      )
      ..cubicTo(
        lowerX + (streamHalf * 0.45),
        origin.dy + (reach * 0.70),
        lowerX + (streamHalf * 0.22),
        bottomY - (reach * 0.10),
        lowerX + (streamHalf * 0.12),
        bottomY,
      )
      ..cubicTo(
        lowerX - (streamHalf * 0.24),
        bottomY - (reach * 0.08),
        lowerX - (streamHalf * 0.82),
        origin.dy + (reach * 0.70),
        waistX - (streamHalf * 0.62),
        origin.dy + (reach * 0.52),
      )
      ..cubicTo(
        waistX - (streamHalf * 1.02),
        origin.dy + (reach * 0.34),
        origin.dx - (streamHalf * 0.58),
        origin.dy + (reach * 0.12),
        origin.dx - (streamHalf * 0.42),
        origin.dy,
      )
      ..close();
  }

  Path _buildTidalPath(Rect rect) {
    final wave = rect.height * crestDepth;
    final radius = rect.height * 0.36;
    return Path()
      ..moveTo(rect.left + radius, rect.top + wave)
      ..quadraticBezierTo(
        rect.left,
        rect.center.dy,
        rect.left + (radius * 0.4),
        rect.bottom - wave,
      )
      ..cubicTo(
        rect.left + (rect.width * 0.24),
        rect.bottom + (wave * 0.85),
        rect.left + (rect.width * 0.52),
        rect.bottom - (wave * 0.25),
        rect.right - (rect.width * 0.18),
        rect.bottom - wave,
      )
      ..quadraticBezierTo(
        rect.right,
        rect.center.dy,
        rect.right - radius,
        rect.top + wave,
      )
      ..cubicTo(
        rect.left + (rect.width * 0.68),
        rect.top - (wave * 0.55),
        rect.left + (rect.width * 0.34),
        rect.top + (wave * 0.10),
        rect.left + radius,
        rect.top + wave,
      )
      ..close();
  }

  Path _buildFacetedPath(Rect rect) {
    final bevel = rect.height * 0.52;
    return Path()
      ..moveTo(rect.left + bevel, rect.top)
      ..lineTo(rect.right - bevel, rect.top)
      ..lineTo(rect.right, rect.center.dy)
      ..lineTo(rect.right - bevel, rect.bottom)
      ..lineTo(rect.left + bevel, rect.bottom)
      ..lineTo(rect.left, rect.center.dy)
      ..close();
  }

  Path _buildLanternPath(Rect rect) {
    final pinch = rect.height * 0.18;
    final bulb = rect.height * 0.34;
    return Path()
      ..moveTo(rect.left + bulb, rect.top + pinch)
      ..quadraticBezierTo(
        rect.left - (bulb * 0.2),
        rect.top + (rect.height * 0.22),
        rect.left + (bulb * 0.18),
        rect.center.dy,
      )
      ..quadraticBezierTo(
        rect.left - (bulb * 0.2),
        rect.bottom - (rect.height * 0.22),
        rect.left + bulb,
        rect.bottom - pinch,
      )
      ..cubicTo(
        rect.left + (rect.width * 0.34),
        rect.bottom,
        rect.left + (rect.width * 0.46),
        rect.bottom - (pinch * 0.2),
        rect.right - bulb,
        rect.bottom - pinch,
      )
      ..quadraticBezierTo(
        rect.right + (bulb * 0.2),
        rect.bottom - (rect.height * 0.22),
        rect.right - (bulb * 0.18),
        rect.center.dy,
      )
      ..quadraticBezierTo(
        rect.right + (bulb * 0.2),
        rect.top + (rect.height * 0.22),
        rect.right - bulb,
        rect.top + pinch,
      )
      ..cubicTo(
        rect.left + (rect.width * 0.46),
        rect.top + (pinch * 0.2),
        rect.left + (rect.width * 0.34),
        rect.top,
        rect.left + bulb,
        rect.top + pinch,
      )
      ..close();
  }

  Path _buildRibbonPath(Rect rect) {
    final notch = rect.height * 0.34;
    return Path()
      ..moveTo(rect.left + notch, rect.top)
      ..lineTo(rect.right - notch, rect.top)
      ..lineTo(rect.right, rect.center.dy)
      ..lineTo(rect.right - notch, rect.bottom)
      ..lineTo(rect.left + notch, rect.bottom)
      ..lineTo(rect.left, rect.center.dy)
      ..close();
  }

  Path _buildCrownPath(Rect rect) {
    final peak = rect.height * 0.22;
    final radius = rect.height * 0.28;
    return Path()
      ..moveTo(rect.left + radius, rect.top + peak)
      ..quadraticBezierTo(
        rect.left + (rect.width * 0.16),
        rect.top - peak,
        rect.left + (rect.width * 0.28),
        rect.top + (peak * 0.65),
      )
      ..quadraticBezierTo(
        rect.left + (rect.width * 0.42),
        rect.top - (peak * 1.15),
        rect.center.dx,
        rect.top + peak,
      )
      ..quadraticBezierTo(
        rect.left + (rect.width * 0.58),
        rect.top - (peak * 1.15),
        rect.left + (rect.width * 0.72),
        rect.top + (peak * 0.65),
      )
      ..quadraticBezierTo(
        rect.left + (rect.width * 0.84),
        rect.top - peak,
        rect.right - radius,
        rect.top + peak,
      )
      ..quadraticBezierTo(
        rect.right,
        rect.center.dy,
        rect.right - radius,
        rect.bottom - peak,
      )
      ..lineTo(rect.left + radius, rect.bottom - peak)
      ..quadraticBezierTo(
        rect.left,
        rect.center.dy,
        rect.left + radius,
        rect.top + peak,
      )
      ..close();
  }

  Path _buildPetalPath(Rect rect) {
    return Path()
      ..moveTo(
          rect.left + (rect.height * 0.42), rect.top + (rect.height * 0.10))
      ..cubicTo(
        rect.left,
        rect.top + (rect.height * 0.22),
        rect.left,
        rect.bottom - (rect.height * 0.22),
        rect.left + (rect.height * 0.42),
        rect.bottom - (rect.height * 0.10),
      )
      ..cubicTo(
        rect.left + (rect.width * 0.36),
        rect.bottom + (rect.height * 0.10),
        rect.left + (rect.width * 0.62),
        rect.bottom + (rect.height * 0.10),
        rect.right - (rect.height * 0.42),
        rect.bottom - (rect.height * 0.10),
      )
      ..cubicTo(
        rect.right,
        rect.bottom - (rect.height * 0.22),
        rect.right,
        rect.top + (rect.height * 0.22),
        rect.right - (rect.height * 0.42),
        rect.top + (rect.height * 0.10),
      )
      ..cubicTo(
        rect.left + (rect.width * 0.62),
        rect.top - (rect.height * 0.10),
        rect.left + (rect.width * 0.36),
        rect.top - (rect.height * 0.10),
        rect.left + (rect.height * 0.42),
        rect.top + (rect.height * 0.10),
      )
      ..close();
  }

  Path _buildDunePath(Rect rect) {
    final crest = rect.height * 0.18;
    return Path()
      ..moveTo(rect.left + (rect.height * 0.36), rect.top + crest)
      ..quadraticBezierTo(
        rect.left + (rect.width * 0.18),
        rect.top - (crest * 0.1),
        rect.left + (rect.width * 0.34),
        rect.top + (crest * 0.55),
      )
      ..quadraticBezierTo(
        rect.left + (rect.width * 0.54),
        rect.top - (crest * 0.45),
        rect.left + (rect.width * 0.74),
        rect.top + (crest * 0.4),
      )
      ..quadraticBezierTo(
        rect.right,
        rect.center.dy,
        rect.right - (rect.height * 0.30),
        rect.bottom - crest,
      )
      ..quadraticBezierTo(
        rect.left + (rect.width * 0.68),
        rect.bottom + (crest * 0.55),
        rect.left + (rect.width * 0.44),
        rect.bottom - (crest * 0.12),
      )
      ..quadraticBezierTo(
        rect.left + (rect.width * 0.20),
        rect.bottom + (crest * 0.35),
        rect.left + (rect.height * 0.28),
        rect.bottom - crest,
      )
      ..quadraticBezierTo(
        rect.left,
        rect.center.dy,
        rect.left + (rect.height * 0.36),
        rect.top + crest,
      )
      ..close();
  }

  Path _buildCometPath(Rect rect) {
    final tail = rect.height * 0.62;
    final radius = Radius.circular(rect.height * 0.44);
    return Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(rect.left, rect.top, rect.right - tail, rect.bottom),
          topLeft: radius,
          bottomLeft: radius,
          topRight: Radius.circular(rect.height * 0.22),
          bottomRight: Radius.circular(rect.height * 0.22),
        ),
      )
      ..moveTo(rect.right - tail, rect.top)
      ..lineTo(rect.right, rect.center.dy)
      ..lineTo(rect.right - tail, rect.bottom)
      ..close();
  }

  Path _buildCarvedPath(Rect rect) {
    final carve = rect.height * 0.16;
    return Path()
      ..moveTo(rect.left + (rect.height * 0.42), rect.top)
      ..lineTo(rect.right - (rect.height * 0.42), rect.top)
      ..quadraticBezierTo(
        rect.right,
        rect.top,
        rect.right,
        rect.center.dy - carve,
      )
      ..quadraticBezierTo(
        rect.right - (rect.width * 0.06),
        rect.center.dy,
        rect.right,
        rect.center.dy + carve,
      )
      ..quadraticBezierTo(
        rect.right,
        rect.bottom,
        rect.right - (rect.height * 0.42),
        rect.bottom,
      )
      ..lineTo(rect.left + (rect.height * 0.42), rect.bottom)
      ..quadraticBezierTo(
        rect.left,
        rect.bottom,
        rect.left,
        rect.center.dy + carve,
      )
      ..quadraticBezierTo(
        rect.left + (rect.width * 0.06),
        rect.center.dy,
        rect.left,
        rect.center.dy - carve,
      )
      ..quadraticBezierTo(
        rect.left,
        rect.top,
        rect.left + (rect.height * 0.42),
        rect.top,
      )
      ..close();
  }

  Path _buildHarborPath(Rect rect) {
    final radius = rect.height * 0.34;
    final bite = rect.height * 0.18;
    return Path()
      ..moveTo(rect.left + radius, rect.top + bite)
      ..cubicTo(
        rect.left + (rect.width * 0.22),
        rect.top - bite,
        rect.left + (rect.width * 0.42),
        rect.top + bite,
        rect.center.dx,
        rect.top + (bite * 0.1),
      )
      ..cubicTo(
        rect.left + (rect.width * 0.64),
        rect.top - bite,
        rect.left + (rect.width * 0.82),
        rect.top + bite,
        rect.right - radius,
        rect.top + bite,
      )
      ..quadraticBezierTo(
        rect.right,
        rect.center.dy,
        rect.right - radius,
        rect.bottom - bite,
      )
      ..cubicTo(
        rect.left + (rect.width * 0.82),
        rect.bottom + bite,
        rect.left + (rect.width * 0.64),
        rect.bottom - bite,
        rect.center.dx,
        rect.bottom - (bite * 0.1),
      )
      ..cubicTo(
        rect.left + (rect.width * 0.42),
        rect.bottom + bite,
        rect.left + (rect.width * 0.22),
        rect.bottom - bite,
        rect.left + radius,
        rect.bottom - bite,
      )
      ..quadraticBezierTo(
        rect.left,
        rect.center.dy,
        rect.left + radius,
        rect.top + bite,
      )
      ..close();
  }
}

extension WorldFestivalVisualStyleOverlayX on WorldFestivalVisualStyle {
  WorldFestivalBarArtDirection get barArtDirection =>
      WorldFestivalBarArtDirection(_stableFestivalVariantId(storageKey));

  Color phaseColorForAccuracy(double accuracy) {
    if (accuracy >= 0.8) return accuracyHighColor;
    if (accuracy >= 0.6) return accuracyMidColor;
    return accuracyLowColor;
  }

  Map<String, dynamic> toOverlayThemeMap() {
    final art = barArtDirection;
    return <String, dynamic>{
      'storageKey': storageKey,
      'themeName': themeName,
      'label': label,
      'subtitle': subtitle,
      'bannerIcon': bannerIcon,
      'cornerIcon': cornerIcon,
      'watermarkIcon': watermarkIcon,
      'bannerTitle': bannerTitle,
      'variantId': art.variantId,
      'primaryStart': primaryStart.value,
      'primaryEnd': primaryEnd.value,
      'accent1': accent1.value,
      'accent2': accent2.value,
      'glowColor': glowColor.value,
      'phaseUpColor': phaseUpColor.value,
      'phaseDownColor': phaseDownColor.value,
      'phaseHoldColor': phaseHoldColor.value,
      'ringGradient': ringGradient.map((color) => color.value).toList(),
      'accuracyBarGradient':
          accuracyBarGradient.map((color) => color.value).toList(),
      'accuracyLowColor': accuracyLowColor.value,
      'accuracyMidColor': accuracyMidColor.value,
      'accuracyHighColor': accuracyHighColor.value,
      'thresholdLineColor': thresholdLineColor.value,
    };
  }
}

int _stableFestivalVariantId(String value) {
  var hash = 0x811C9DC5;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash % WorldFestivalBarArtDirection.variantCount;
}
