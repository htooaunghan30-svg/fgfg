import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/premium/workout_overlay_customization.dart';

class LuxuryOverlayPreview extends StatelessWidget {
  final WorkoutOverlayCustomization customization;
  final int repCount;
  final double accuracy;
  final OverlayMovementPhase phase;
  final double minHeight;
  final VoidCallback? onToggleBranding;
  final VoidCallback? onToggleAccuracy;
  final VoidCallback? onToggleRepCounter;

  const LuxuryOverlayPreview({
    super.key,
    required this.customization,
    this.repCount = 24,
    this.accuracy = 0.87,
    this.phase = OverlayMovementPhase.up,
    this.minHeight = 360,
    this.onToggleBranding,
    this.onToggleAccuracy,
    this.onToggleRepCounter,
  });

  @override
  Widget build(BuildContext context) {
    final palette = customization.palette;
    final phaseColor = customization.phaseColorFor(phase);
    final iconSlot = customization.icons.iconForPhase(phase);
    final previewIconLabel =
        (iconSlot.svgPath ?? '').trim().isNotEmpty ? 'SVG' : iconSlot.glyph;
    final compact = MediaQuery.of(context).size.width < 380;
    final clusterPos = customization.layout.counterClusterPosition;

    return Opacity(
      opacity: customization.layout.opacity,
      child: Transform.scale(
        scale: customization.layout.globalScale,
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.primary,
                Color.lerp(palette.primary, palette.secondary, 0.65) ??
                    palette.secondary,
                palette.surface,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: palette.accent.withOpacity(0.12),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AmbientLuxuryPainter(
                      primary: palette.primary,
                      secondary: palette.secondary,
                      accent: palette.accent,
                      performanceMode: customization.performanceMode,
                      finish: customization.finish,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(compact ? 18 : 22),
                  child: _buildLayoutForPosition(
                    clusterPos: clusterPos,
                    previewIconLabel: previewIconLabel,
                    phaseColor: phaseColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayoutForPosition({
    required OverlaySlotPosition clusterPos,
    required String previewIconLabel,
    required Color phaseColor,
  }) {
    final palette = customization.palette;
    final showStatsCard =
        customization.layout.statsCardPosition != OverlaySlotPosition.none;
    if (clusterPos == OverlaySlotPosition.left) {
      // Left layout: banner stays at top, accuracy bar + rep counter
      // positioned vertically at the top-left corner
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Opacity(
                opacity: customization.showBranding ? 1.0 : 0.25,
                child: _TopBanner(
                  customization: customization,
                  iconGlyph: previewIconLabel,
                ),
              ),
              if (onToggleBranding != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: _VisibilityToggleButton(
                    isVisible: customization.showBranding,
                    onToggle: onToggleBranding!,
                    accentColor: palette.accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: accuracy bar + rep counter stacked vertically
              SizedBox(
                width: 104,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 136,
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: customization.accuracyBar.show ? 1.0 : 0.25,
                            child: _AccuracyBarPreview(
                              customization: customization,
                              accuracy: accuracy,
                              isVertical: true,
                            ),
                          ),
                          if (onToggleAccuracy != null)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: _VisibilityToggleButton(
                                isVisible: customization.accuracyBar.show,
                                onToggle: onToggleAccuracy!,
                                accentColor: palette.accent,
                                mini: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: customization.repCounter.show ? 1.0 : 0.25,
                            child: _RepCounterPreview(
                              customization: customization,
                              repCount: repCount,
                              phase: phase,
                              iconGlyph: previewIconLabel,
                              phaseColor: phaseColor,
                            ),
                          ),
                          if (onToggleRepCounter != null)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: _VisibilityToggleButton(
                                isVisible: customization.repCounter.show,
                                onToggle: onToggleRepCounter!,
                                accentColor: palette.accent,
                                mini: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          const Spacer(),
          if (showStatsCard)
            _BottomStatsCard(
              customization: customization,
              repCount: repCount,
              accuracy: accuracy,
              phase: phase,
            ),
        ],
      );
    }

    if (clusterPos == OverlaySlotPosition.right) {
      // Right layout: banner stays at top, accuracy bar + rep counter
      // positioned vertically at the top-right corner
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Opacity(
                opacity: customization.showBranding ? 1.0 : 0.25,
                child: _TopBanner(
                  customization: customization,
                  iconGlyph: previewIconLabel,
                ),
              ),
              if (onToggleBranding != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: _VisibilityToggleButton(
                    isVisible: customization.showBranding,
                    onToggle: onToggleBranding!,
                    accentColor: palette.accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Right side: accuracy bar + rep counter stacked vertically
              SizedBox(
                width: 104,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 136,
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: customization.accuracyBar.show ? 1.0 : 0.25,
                            child: _AccuracyBarPreview(
                              customization: customization,
                              accuracy: accuracy,
                              isVertical: true,
                            ),
                          ),
                          if (onToggleAccuracy != null)
                            Positioned(
                              top: 2,
                              left: 2,
                              child: _VisibilityToggleButton(
                                isVisible: customization.accuracyBar.show,
                                onToggle: onToggleAccuracy!,
                                accentColor: palette.accent,
                                mini: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: customization.repCounter.show ? 1.0 : 0.25,
                            child: _RepCounterPreview(
                              customization: customization,
                              repCount: repCount,
                              phase: phase,
                              iconGlyph: previewIconLabel,
                              phaseColor: phaseColor,
                            ),
                          ),
                          if (onToggleRepCounter != null)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: _VisibilityToggleButton(
                                isVisible: customization.repCounter.show,
                                onToggle: onToggleRepCounter!,
                                accentColor: palette.accent,
                                mini: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (showStatsCard)
            _BottomStatsCard(
              customization: customization,
              repCount: repCount,
              accuracy: accuracy,
              phase: phase,
            ),
        ],
      );
    }

    // Top (default): original layout — accuracy bar + rep counter in a row
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Opacity(
              opacity: customization.showBranding ? 1.0 : 0.25,
              child: _TopBanner(
                customization: customization,
                iconGlyph: previewIconLabel,
              ),
            ),
            if (onToggleBranding != null)
              Positioned(
                top: 4,
                right: 4,
                child: _VisibilityToggleButton(
                  isVisible: customization.showBranding,
                  onToggle: onToggleBranding!,
                  accentColor: palette.accent,
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Opacity(
                    opacity: customization.accuracyBar.show ? 1.0 : 0.25,
                    child: _AccuracyBarPreview(
                      customization: customization,
                      accuracy: accuracy,
                      isVertical: false,
                    ),
                  ),
                  if (onToggleAccuracy != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _VisibilityToggleButton(
                        isVisible: customization.accuracyBar.show,
                        onToggle: onToggleAccuracy!,
                        accentColor: palette.accent,
                        mini: true,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Stack(
              children: [
                Opacity(
                  opacity: customization.repCounter.show ? 1.0 : 0.25,
                  child: _RepCounterPreview(
                    customization: customization,
                    repCount: repCount,
                    phase: phase,
                    iconGlyph: previewIconLabel,
                    phaseColor: phaseColor,
                  ),
                ),
                if (onToggleRepCounter != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _VisibilityToggleButton(
                      isVisible: customization.repCounter.show,
                      onToggle: onToggleRepCounter!,
                      accentColor: palette.accent,
                      mini: true,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const Spacer(),
        if (showStatsCard)
          _BottomStatsCard(
            customization: customization,
            repCount: repCount,
            accuracy: accuracy,
            phase: phase,
          ),
      ],
    );
  }
}

class _VisibilityToggleButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onToggle;
  final Color accentColor;
  final bool mini;

  const _VisibilityToggleButton({
    required this.isVisible,
    required this.onToggle,
    required this.accentColor,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.all(mini ? 4 : 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.4),
          border: Border.all(
            color: (isVisible ? accentColor : Colors.white).withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            if (isVisible)
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          size: mini ? 14 : 18,
          color: isVisible ? accentColor : Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _TopBanner extends StatelessWidget {
  final WorkoutOverlayCustomization customization;
  final String iconGlyph;

  const _TopBanner({
    required this.customization,
    required this.iconGlyph,
  });

  @override
  Widget build(BuildContext context) {
    final palette = customization.palette;
    final sheen = customization.finish.sheenSweep.clamp(0.0, 1.0);
    final bloom = customization.finish.bloomIntensity.clamp(0.0, 1.0);
    return _GradientBorderWrapper(
      config: customization.bannerGradientBorder,
      borderRadius: 24,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
              boxShadow: [
                BoxShadow(
                  color: palette.accent.withOpacity(0.06 + (0.10 * bloom)),
                  blurRadius: 10 + (16 * bloom),
                  spreadRadius: 0.5 + (1.4 * bloom),
                ),
              ],
            ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      palette.accent,
                      Color.lerp(palette.accent, palette.secondary, 0.55) ??
                          palette.secondary,
                    ],
                  ),
                ),
                child: Text(
                  iconGlyph,
                  style: TextStyle(
                    color: palette.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customization.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customization.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                customization.brandingText,
                style: TextStyle(
                  color: palette.accent.withOpacity(0.92),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: const Alignment(-1.0, -0.3),
                    end: const Alignment(0.8, 0.5),
                    colors: [
                      Colors.white.withOpacity(0.02 + (0.10 * sheen)),
                      Colors.white.withOpacity(0.10 + (0.16 * sheen)),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.34, 0.78],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccuracyBarPreview extends StatelessWidget {
  final WorkoutOverlayCustomization customization;
  final double accuracy;
  final bool isVertical;

  const _AccuracyBarPreview({
    required this.customization,
    required this.accuracy,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = customization.palette;
    final density = 4 + (customization.accuracyBar.markerDensity * 8).round();
    final glow = customization.accuracyBar.glowIntensity;
    final styleIntensity = customization.accuracyBar.styleIntensity;
    final motion = customization.accuracyBar.liquidMotion;
    final spill = customization.accuracyBar.spillLength;
    final spillWidth = customization.accuracyBar.spillWidth;
    final thresholdGlow = customization.accuracyBar.thresholdGlow;
    final shape = customization.accuracyBar.shape;
    final frameDepth = customization.accuracyBar.frameDepth;
    final glossAmount = customization.accuracyBar.glossAmount;
    final jewelInset = customization.accuracyBar.jewelInset;
    final flareAmount = customization.accuracyBar.flareAmount;
    final barColor = accuracy >= 0.8
        ? palette.accent
        : accuracy >= 0.6
            ? palette.phaseDown
            : palette.phaseHold;

    return LayoutBuilder(
      builder: (context, constraints) {
        final thresholdOffset = isVertical
            ? math.max(0.0, (constraints.maxHeight * 0.2) - 2).toDouble()
            : math.max(0.0, (constraints.maxWidth * 0.8) - 2).toDouble();
        final outerRadius = 18 + (10 * styleIntensity);
        final innerRadius = 10 + (10 * styleIntensity);
        final clipper = _AccuracyShapeClipper(
          shape: shape,
          jewelInset: jewelInset,
        );
        final valueFactor = accuracy.clamp(0.0, 1.0).toDouble();
        final barGradient = () {
          switch (customization.accuracyBar.style) {
            case OverlayAccuracyBarStyle.flat:
              return [barColor, barColor];
            case OverlayAccuracyBarStyle.glass:
              return [
                Color.lerp(barColor, Colors.white, 0.38 + (0.22 * styleIntensity))!,
                Color.lerp(barColor, palette.textPrimary, 0.16)!,
                barColor.withOpacity(0.78 + (0.16 * styleIntensity)),
              ];
            case OverlayAccuracyBarStyle.neon:
              return [
                Color.lerp(barColor, palette.accent, 0.12)!,
                Color.lerp(barColor, Colors.white, 0.18)!,
                palette.accent,
              ];
            case OverlayAccuracyBarStyle.prism:
              return [
                palette.phaseDown,
                barColor,
                palette.phaseHold,
                palette.accent,
              ];
            case OverlayAccuracyBarStyle.velvet:
              return [
                Color.lerp(barColor, palette.primary, 0.34)!,
                Color.lerp(barColor, palette.secondary, 0.18)!,
                Color.lerp(barColor, palette.accent, 0.12)!,
              ];
            case OverlayAccuracyBarStyle.segmented:
            case OverlayAccuracyBarStyle.gradient:
              return [
                Color.lerp(barColor, palette.secondary, 0.18) ?? barColor,
                barColor,
                palette.accent,
              ];
          }
        }();
        return _GradientBorderWrapper(
          config: customization.accuracyBar.gradientBorder,
          borderRadius: outerRadius.toDouble(),
          child: Container(
            height: isVertical ? constraints.maxHeight : 72,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                        palette.surface,
                        palette.textPrimary,
                        0.04 + (0.18 * frameDepth),
                      ) ??
                      palette.surface,
                  palette.surface.withOpacity(0.82),
                  Color.lerp(
                        palette.primary,
                        palette.surface,
                        0.32 - (0.10 * frameDepth),
                      ) ??
                      palette.primary,
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.08 + (0.18 * frameDepth)),
              ),
              boxShadow: [
                BoxShadow(
                  color: barColor.withOpacity(0.06 + (0.16 * flareAmount)),
                  blurRadius: 10 + (14 * flareAmount),
                  spreadRadius: frameDepth,
                ),
              ],
            ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: clipper,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(
                            customization.accuracyBar.style ==
                                    OverlayAccuracyBarStyle.glass
                                ? 0.09 +
                                    (0.08 * styleIntensity) +
                                    (0.12 * glossAmount)
                                : 0.03 + (0.10 * glossAmount),
                          ),
                          Colors.white.withOpacity(0.01 + (0.05 * glossAmount)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipPath(
                  clipper: clipper,
                  child: isVertical
                      ? Column(
                          children: List.generate(density, (index) {
                            final segmentVisible =
                                customization.accuracyBar.style ==
                                        OverlayAccuracyBarStyle.segmented ||
                                    customization.accuracyBar.style ==
                                        OverlayAccuracyBarStyle.prism;
                            final opacity =
                                segmentVisible ? 0.14 + (index * 0.02) : 0.0;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == density - 1 ? 0 : 3,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(
                                      opacity.clamp(0.0, 0.28).toDouble(),
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(999 * innerRadius),
                                  ),
                                ),
                              ),
                            );
                          }),
                        )
                      : Row(
                          children: List.generate(density, (index) {
                            final segmentVisible =
                                customization.accuracyBar.style ==
                                        OverlayAccuracyBarStyle.segmented ||
                                    customization.accuracyBar.style ==
                                        OverlayAccuracyBarStyle.prism;
                            final opacity =
                                segmentVisible ? 0.14 + (index * 0.02) : 0.0;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == density - 1 ? 0 : 3,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(
                                      opacity.clamp(0.0, 0.28).toDouble(),
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(999 * innerRadius),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                ),
              ),
              if (isVertical)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: valueFactor,
                    widthFactor: 1.0,
                    child: ClipPath(
                      clipper: clipper,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: barGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (customization.accuracyBar.style ==
                                      OverlayAccuracyBarStyle.neon
                                  ? palette.accent
                                  : barColor)
                                  .withOpacity(
                                    0.14 +
                                        (0.26 * glow) +
                                        (0.10 * styleIntensity) +
                                        (0.12 * flareAmount),
                                  ),
                              blurRadius: 8 +
                                  (18 * glow) +
                                  (8 * styleIntensity) +
                                  (10 * flareAmount),
                              spreadRadius: 0.5 +
                                  (1.8 * glow) +
                                  (0.8 * styleIntensity) +
                                  flareAmount,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _AccuracyLiquidPainter(
                            barColor: barColor,
                            accent: palette.accent,
                            gloss: palette.textPrimary,
                            liquidMotion: motion + (styleIntensity * 0.08),
                            isVertical: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                FractionallySizedBox(
                  widthFactor: valueFactor,
                  child: ClipPath(
                    clipper: clipper,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: barGradient),
                        boxShadow: [
                          BoxShadow(
                            color: (customization.accuracyBar.style ==
                                    OverlayAccuracyBarStyle.neon
                                ? palette.accent
                                : barColor)
                                .withOpacity(
                                  0.14 +
                                      (0.26 * glow) +
                                      (0.10 * styleIntensity) +
                                      (0.12 * flareAmount),
                                ),
                            blurRadius: 8 +
                                (18 * glow) +
                                (8 * styleIntensity) +
                                (10 * flareAmount),
                            spreadRadius: 0.5 +
                                (1.8 * glow) +
                                (0.8 * styleIntensity) +
                                flareAmount,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _AccuracyLiquidPainter(
                          barColor: barColor,
                          accent: palette.accent,
                          gloss: palette.textPrimary,
                          liquidMotion: motion + (styleIntensity * 0.08),
                          isVertical: false,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _AccuracyFramePainter(
                      shape: shape,
                      frameDepth: frameDepth,
                      glossAmount: glossAmount,
                      jewelInset: jewelInset,
                      flareAmount: flareAmount,
                      barColor: barColor,
                      palette: palette,
                    ),
                  ),
                ),
              ),
              if (customization.accuracyBar.showThresholdLine)
                isVertical
                    ? Positioned(
                        left: 2,
                        right: 2,
                        top: thresholdOffset,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 8.0 + (10 * thresholdGlow),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: palette.textPrimary.withOpacity(
                                  0.08 +
                                      (0.14 * thresholdGlow) +
                                      (0.06 * flareAmount),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: palette.textPrimary.withOpacity(
                                      0.14 + (0.24 * thresholdGlow),
                                    ),
                                    blurRadius: 8 + (14 * thresholdGlow),
                                    spreadRadius: 0.4 + (1.6 * thresholdGlow),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 2.4 + (2.0 * thresholdGlow),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: palette.textPrimary.withOpacity(
                                  0.72 + (0.24 * thresholdGlow),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Positioned(
                        left: thresholdOffset,
                        top: 2,
                        bottom: 2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 8.0 + (10 * thresholdGlow),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: palette.textPrimary.withOpacity(
                                  0.08 +
                                      (0.14 * thresholdGlow) +
                                      (0.06 * flareAmount),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: palette.textPrimary.withOpacity(
                                      0.14 + (0.24 * thresholdGlow),
                                    ),
                                    blurRadius: 8 + (14 * thresholdGlow),
                                    spreadRadius: 0.4 + (1.6 * thresholdGlow),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 2.4 + (2.0 * thresholdGlow),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: palette.textPrimary.withOpacity(
                                  0.72 + (0.24 * thresholdGlow),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              if (accuracy >= 0.8)
                isVertical
                    ? Positioned(
                        left: 10,
                        right: 10,
                        top: math.max(0.0, thresholdOffset - 20).toDouble(),
                        child: IgnorePointer(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: CustomPaint(
                              size: Size(
                                26 + (18 * spillWidth),
                                34 + (70 * spill),
                              ),
                              painter: _AccuracySpillPainter(
                                color: barColor,
                                accent: palette.accent,
                                glowIntensity:
                                    (glow + flareAmount * 0.18).clamp(0.0, 1.0),
                                spillLength: spill,
                                spillWidth: spillWidth,
                                liquidMotion: motion,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Positioned(
                        left: math.max(0.0, thresholdOffset - 14).toDouble(),
                        top: 18,
                        child: IgnorePointer(
                          child: CustomPaint(
                            size: Size(30 + (18 * spillWidth), 42 + (80 * spill)),
                            painter: _AccuracySpillPainter(
                              color: barColor,
                              accent: palette.accent,
                              glowIntensity:
                                  (glow + flareAmount * 0.18).clamp(0.0, 1.0),
                              spillLength: spill,
                              spillWidth: spillWidth,
                              liquidMotion: motion,
                            ),
                          ),
                        ),
                      ),
              Positioned.fill(
                child: Center(
                  child: isVertical
                      ? RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            '${(accuracy * 100).toStringAsFixed(1)}% ACCURACY',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      : Text(
                          '${(accuracy * 100).toStringAsFixed(1)}% ACCURACY',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RepCounterPreview extends StatelessWidget {
  final WorkoutOverlayCustomization customization;
  final int repCount;
  final OverlayMovementPhase phase;
  final String iconGlyph;
  final Color phaseColor;

  const _RepCounterPreview({
    required this.customization,
    required this.repCount,
    required this.phase,
    required this.iconGlyph,
    required this.phaseColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = customization.palette;
    final size = 118.0 * customization.repCounter.scale;

    return _GradientBorderWrapper(
      config: customization.repCounter.gradientBorder,
      borderRadius: size / 2,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CounterRingPainter(
            customization: customization,
            phaseColor: phaseColor,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  iconGlyph,
                  style: TextStyle(
                    color: palette.accent.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$repCount',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  phase.storageValue.toUpperCase(),
                  style: TextStyle(
                    color: phaseColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomStatsCard extends StatelessWidget {
  final WorkoutOverlayCustomization customization;
  final int repCount;
  final double accuracy;
  final OverlayMovementPhase phase;

  const _BottomStatsCard({
    required this.customization,
    required this.repCount,
    required this.accuracy,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final palette = customization.palette;
    final sheen = customization.finish.sheenSweep.clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black.withOpacity(0.18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.02 + (0.04 * sheen)),
            Colors.transparent,
            palette.accent.withOpacity(0.04 + (0.06 * sheen)),
          ],
        ),
      ),
      child: Row(
        children: [
          _MetricChip(
            label: 'Reps',
            value: '$repCount',
            accent: palette.accent,
            textColor: palette.textPrimary,
          ),
          const SizedBox(width: 10),
          _MetricChip(
            label: 'Phase',
            value: phase.storageValue.toUpperCase(),
            accent: customization.phaseColorFor(phase),
            textColor: palette.textPrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricChip(
              label: 'Mode',
              value: customization.performanceMode.storageValue.toUpperCase(),
              accent: palette.textSecondary,
              textColor: palette.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${(accuracy * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: palette.accent,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final Color textColor;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.accent,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: textColor.withOpacity(0.55),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientLuxuryPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final Color accent;
  final OverlayPerformanceMode performanceMode;
  final OverlayFinishConfiguration finish;

  const _AmbientLuxuryPainter({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.performanceMode,
    required this.finish,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final vignette = finish.vignetteStrength.clamp(0.0, 1.0);
    final bloom = finish.bloomIntensity.clamp(0.0, 1.0);
    final sparkleDensity = finish.sparkleDensity.clamp(0.0, 1.0);
    final topGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.9, -0.9),
        radius: 1.1,
        colors: [
          accent.withOpacity(
              (performanceMode == OverlayPerformanceMode.low ? 0.12 : 0.22) +
                  (0.10 * bloom)),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    final sideGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.0, -0.2),
        radius: 1.0,
        colors: [
          secondary.withOpacity(0.18 + (0.08 * bloom)),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, topGlow);
    canvas.drawRect(Offset.zero & size, sideGlow);

    if (vignette > 0) {
      final vignettePaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.96,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.14 + (0.22 * vignette)),
          ],
          stops: const [0.0, 0.64, 1.0],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, vignettePaint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.045)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.18 + (i * 0.18));
      canvas.drawLine(Offset(size.width * 0.08, y),
          Offset(size.width * 0.92, y), linePaint);
    }

    if (performanceMode != OverlayPerformanceMode.low) {
      final dotPaint = Paint()..color = accent.withOpacity(0.12 + (0.18 * sparkleDensity));
      final sparkles = <Offset>[
        Offset(size.width * 0.86, size.height * 0.18),
        Offset(size.width * 0.18, size.height * 0.74),
        Offset(size.width * 0.70, size.height * 0.66),
        if (sparkleDensity > 0.30) Offset(size.width * 0.58, size.height * 0.24),
        if (sparkleDensity > 0.55) Offset(size.width * 0.30, size.height * 0.34),
        if (sparkleDensity > 0.80) Offset(size.width * 0.82, size.height * 0.48),
      ];
      for (var i = 0; i < sparkles.length; i++) {
        canvas.drawCircle(sparkles[i], 1.8 + (i % 3) * 0.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientLuxuryPainter oldDelegate) {
    return primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary ||
        accent != oldDelegate.accent ||
        performanceMode != oldDelegate.performanceMode ||
        finish != oldDelegate.finish;
  }
}

class _CounterRingPainter extends CustomPainter {
  final WorkoutOverlayCustomization customization;
  final Color phaseColor;

  const _CounterRingPainter({
    required this.customization,
    required this.phaseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final ringWidth =
        customization.repCounter.ringThickness.clamp(4.0, 16.0).toDouble();
    final contourSoftness =
        customization.repCounter.contourSoftness.clamp(0.0, 1.0).toDouble();
    final radius = (size.shortestSide / 2) - (ringWidth / 2) - 4;
    final depth = customization.repCounter.surfaceDepth.clamp(0.0, 1.0);
    final orbitIntensity =
        customization.repCounter.orbitIntensity.clamp(0.0, 1.0);
    final bevelIntensity =
        customization.repCounter.bevelIntensity.clamp(0.0, 1.0).toDouble();
    final haloSpread =
        customization.repCounter.haloSpread.clamp(0.0, 1.0).toDouble();
    final coreRadius =
        customization.repCounter.coreRadius.clamp(0.38, 0.82).toDouble();
    final jewelSparkle =
        customization.repCounter.jewelSparkle.clamp(0.0, 1.0).toDouble();
    final innerRadius = radius - (ringWidth * (0.48 + (coreRadius * 0.72)));
    final shape = customization.repCounter.shape;

    final outerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth +
          (customization.repCounter.glowIntensity * 8) +
          (haloSpread * 5)
      ..color = phaseColor.withOpacity(
        customization.performanceMode == OverlayPerformanceMode.low
            ? 0.10
            : 0.16 + (haloSpread * 0.10),
      )
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        10 + (haloSpread * 10),
      );

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = ringWidth
      ..shader = SweepGradient(
        colors: [
          customization.palette.secondary,
          customization.palette.accent,
          phaseColor,
          customization.palette.secondary,
        ],
      ).createShader(rect);

    final shellPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(
                customization.palette.textPrimary,
                customization.palette.surface,
                0.86 - (depth * 0.22) - (bevelIntensity * 0.08),
              ) ??
              customization.palette.surface,
          customization.palette.surface
              .withOpacity(customization.repCounter.opacity),
          Color.lerp(
                customization.palette.primary,
                customization.palette.surface,
                0.30 + (depth * 0.24),
              ) ??
              customization.palette.primary,
        ],
        stops: [
          0.0,
          (0.54 + (depth * 0.08)).clamp(0.0, 1.0),
          1.0,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final bevelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 + (bevelIntensity * 2.2)
      ..color = Colors.white.withOpacity(0.10 + (bevelIntensity * 0.18));

    final outerShapePath = _buildCounterShapePath(
      rect: Rect.fromCircle(center: center, radius: radius),
      shape: shape,
      softness: contourSoftness,
    );
    final innerShapePath = _buildCounterShapePath(
      rect: Rect.fromCircle(
        center: center,
        radius: innerRadius.clamp(10.0, radius - 4),
      ),
      shape: shape,
      softness: contourSoftness,
    );

    if (shape == OverlayCounterShape.arc) {
      canvas.drawCircle(center, radius, outerGlow);
      canvas.drawCircle(
        center,
        innerRadius.clamp(10.0, radius - 4),
        shellPaint,
      );
    } else {
      canvas.drawPath(outerShapePath, outerGlow);
      canvas.drawPath(innerShapePath, shellPaint);
    }

    if (shape == OverlayCounterShape.arc) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi * 0.8,
        math.pi * 1.6,
        false,
        ringPaint,
      );
    } else {
      canvas.drawPath(outerShapePath, ringPaint);
      canvas.drawPath(innerShapePath, bevelPaint);
    }

    if (customization.repCounter.animationStyle !=
            OverlayAnimationStyle.minimal &&
        customization.performanceMode != OverlayPerformanceMode.low) {
      final accentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withOpacity(0.20);
      canvas.drawCircle(center, radius - ringWidth - 4, accentPaint);

      final orbitPaint = Paint()
        ..color = customization.palette.accent
            .withOpacity(0.10 + (0.18 * orbitIntensity));
      final orbitStroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + orbitIntensity
        ..color = phaseColor.withOpacity(0.08 + (0.12 * orbitIntensity));
      if (shape == OverlayCounterShape.arc || shape == OverlayCounterShape.circle) {
        canvas.drawCircle(
          center,
          radius - ringWidth - (8 + (6 * orbitIntensity)),
          orbitStroke,
        );
      } else {
        final orbitPath = _buildCounterShapePath(
          rect: Rect.fromCircle(
            center: center,
            radius: radius - ringWidth - (8 + (6 * orbitIntensity)),
          ),
          shape: shape,
          softness: contourSoftness,
        );
        canvas.drawPath(orbitPath, orbitStroke);
      }
      final sparkleCount = 3 + (jewelSparkle * 4).round();
      for (var i = 0; i < sparkleCount; i++) {
        final angle = (-math.pi / 3) + (i * 1.9);
        final orbitRadius = radius - ringWidth - (8 + (6 * orbitIntensity));
        final dot = Offset(
          center.dx + (math.cos(angle) * orbitRadius * 0.92),
          center.dy + (math.sin(angle) * orbitRadius * 0.92),
        );
        canvas.drawCircle(
          dot,
          1.2 +
              (1.8 * orbitIntensity) +
              (jewelSparkle * 1.6) +
              (i * 0.18),
          orbitPaint,
        );
      }

      final facetPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9 + bevelIntensity
        ..color = customization.palette.textPrimary
            .withOpacity(0.08 + (0.14 * jewelSparkle));
      final facetRadius = innerRadius + ((radius - innerRadius) * 0.52);
      final facetPath = _buildCounterShapePath(
        rect: Rect.fromCircle(center: center, radius: facetRadius),
        shape: shape,
        softness: (contourSoftness + bevelIntensity * 0.3).clamp(0.0, 1.0),
      );
      if (shape == OverlayCounterShape.arc) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: facetRadius),
          -math.pi * 0.8,
          math.pi * 1.6,
          false,
          facetPaint,
        );
      } else {
        canvas.drawPath(facetPath, facetPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CounterRingPainter oldDelegate) {
    return customization != oldDelegate.customization ||
        phaseColor != oldDelegate.phaseColor;
  }
}

Path _buildCounterShapePath({
  required Rect rect,
  required OverlayCounterShape shape,
  required double softness,
}) {
  final safeSoftness = softness.clamp(0.0, 1.0);
  switch (shape) {
    case OverlayCounterShape.circle:
    case OverlayCounterShape.arc:
      return Path()..addOval(rect);
    case OverlayCounterShape.hex:
      return _polygonPath(rect, 6, safeSoftness);
    case OverlayCounterShape.octagon:
      return _polygonPath(rect, 8, safeSoftness);
    case OverlayCounterShape.diamond:
      return _diamondPath(rect, safeSoftness);
    case OverlayCounterShape.shield:
      return _shieldPath(rect, safeSoftness);
    case OverlayCounterShape.flower:
      return _flowerPath(rect, safeSoftness);
    case OverlayCounterShape.lotus:
      return _lotusPath(rect, safeSoftness);
    case OverlayCounterShape.crown:
      return _crownPath(rect, safeSoftness);
    case OverlayCounterShape.star:
      return _starPath(rect, safeSoftness);
  }
}

Path _polygonPath(Rect rect, int sides, double softness) {
  final center = rect.center;
  final radius = rect.shortestSide / 2;
  final points = List<Offset>.generate(sides, (index) {
    final angle = (-math.pi / 2) + ((math.pi * 2 * index) / sides);
    return Offset(
      center.dx + (math.cos(angle) * radius),
      center.dy + (math.sin(angle) * radius),
    );
  });
  return _roundedPointsPath(points, rect.shortestSide * (0.04 + (0.10 * softness)));
}

Path _diamondPath(Rect rect, double softness) {
  final center = rect.center;
  final points = <Offset>[
    Offset(center.dx, rect.top),
    Offset(rect.right, center.dy),
    Offset(center.dx, rect.bottom),
    Offset(rect.left, center.dy),
  ];
  return _roundedPointsPath(points, rect.shortestSide * (0.06 + (0.12 * softness)));
}

Path _shieldPath(Rect rect, double softness) {
  final radius = rect.shortestSide * (0.10 + (0.12 * softness));
  return Path()
    ..moveTo(rect.left + radius, rect.top + (rect.height * 0.10))
    ..quadraticBezierTo(rect.left, rect.top + (rect.height * 0.10),
        rect.left, rect.top + radius)
    ..lineTo(rect.left, rect.center.dy)
    ..quadraticBezierTo(
      rect.left,
      rect.bottom - (rect.height * 0.18),
      rect.center.dx,
      rect.bottom,
    )
    ..quadraticBezierTo(
      rect.right,
      rect.bottom - (rect.height * 0.18),
      rect.right,
      rect.center.dy,
    )
    ..lineTo(rect.right, rect.top + radius)
    ..quadraticBezierTo(rect.right, rect.top + (rect.height * 0.10),
        rect.right - radius, rect.top + (rect.height * 0.10))
    ..close();
}

Path _flowerPath(Rect rect, double softness) {
  final center = rect.center;
  final radius = rect.shortestSide / 2;
  final petals = 6;
  final inner = radius * (0.68 - (0.10 * softness));
  final points = List<Offset>.generate(petals * 2, (index) {
    final isOuter = index.isEven;
    final angle = (-math.pi / 2) + ((math.pi * index) / petals);
    final r = isOuter ? radius : inner;
    return Offset(
      center.dx + math.cos(angle) * r,
      center.dy + math.sin(angle) * r,
    );
  });
  return _roundedPointsPath(points, rect.shortestSide * (0.04 + (0.09 * softness)));
}

Path _lotusPath(Rect rect, double softness) {
  final center = rect.center;
  final radius = rect.shortestSide / 2;
  final petals = 8;
  final inner = radius * (0.52 - (0.06 * softness));
  final points = List<Offset>.generate(petals * 2, (index) {
    final isOuter = index.isEven;
    final angle = (-math.pi / 2) + ((math.pi * index) / petals);
    final radialScale = isOuter
        ? (index % 4 == 0 ? 1.0 : 0.90)
        : (index % 3 == 0 ? 0.60 : inner / radius);
    final r = radius * radialScale;
    return Offset(
      center.dx + math.cos(angle) * r,
      center.dy + math.sin(angle) * r,
    );
  });
  return _roundedPointsPath(points, rect.shortestSide * (0.05 + (0.09 * softness)));
}

Path _crownPath(Rect rect, double softness) {
  final center = rect.center;
  final inset = rect.width * (0.10 + (0.04 * softness));
  final points = <Offset>[
    Offset(rect.left + inset, rect.bottom - rect.height * 0.12),
    Offset(rect.left + rect.width * 0.18, rect.top + rect.height * 0.38),
    Offset(rect.left + rect.width * 0.34, rect.top + rect.height * 0.18),
    Offset(center.dx, rect.top),
    Offset(rect.right - rect.width * 0.34, rect.top + rect.height * 0.18),
    Offset(rect.right - rect.width * 0.18, rect.top + rect.height * 0.38),
    Offset(rect.right - inset, rect.bottom - rect.height * 0.12),
    Offset(center.dx, rect.bottom),
  ];
  return _roundedPointsPath(points, rect.shortestSide * (0.05 + (0.08 * softness)));
}

Path _starPath(Rect rect, double softness) {
  final center = rect.center;
  final radius = rect.shortestSide / 2;
  final inner = radius * (0.48 - (0.06 * softness));
  final points = List<Offset>.generate(16, (index) {
    final angle = (-math.pi / 2) + ((math.pi * index) / 8);
    final r = index.isEven ? radius : inner;
    return Offset(
      center.dx + math.cos(angle) * r,
      center.dy + math.sin(angle) * r,
    );
  });
  return _roundedPointsPath(points, rect.shortestSide * (0.03 + (0.07 * softness)));
}

Path _roundedPointsPath(List<Offset> points, double radius) {
  if (points.length < 3) {
    return Path()..addPolygon(points, true);
  }
  final path = Path();
  for (var i = 0; i < points.length; i++) {
    final prev = points[(i - 1 + points.length) % points.length];
    final current = points[i];
    final next = points[(i + 1) % points.length];
    final prevDistance = (current - prev).distance;
    final nextDistance = (current - next).distance;
    final start = Offset.lerp(
      current,
      prev,
      prevDistance == 0 ? 0 : (radius / prevDistance).clamp(0.0, 0.45),
    )!;
    final end = Offset.lerp(
      current,
      next,
      nextDistance == 0 ? 0 : (radius / nextDistance).clamp(0.0, 0.45),
    )!;
    if (i == 0) {
      path.moveTo(start.dx, start.dy);
    } else {
      path.lineTo(start.dx, start.dy);
    }
    path.quadraticBezierTo(current.dx, current.dy, end.dx, end.dy);
  }
  path.close();
  return path;
}

class _AccuracyLiquidPainter extends CustomPainter {
  final Color barColor;
  final Color accent;
  final Color gloss;
  final double liquidMotion;
  final bool isVertical;

  const _AccuracyLiquidPainter({
    required this.barColor,
    required this.accent,
    required this.gloss,
    required this.liquidMotion,
    this.isVertical = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final motion = liquidMotion.clamp(0.0, 1.0);
    if (isVertical) {
      final wave = size.width * (0.10 + (motion * 0.12));
      final path = Path()
        ..moveTo(size.width * 0.18, size.height)
        ..cubicTo(
          size.width * 0.10,
          size.height * 0.78,
          size.width * (0.18 + motion * 0.05),
          size.height * 0.58,
          size.width * 0.22,
          size.height * 0.40,
        )
        ..cubicTo(
          size.width * 0.26,
          size.height * 0.24,
          size.width * (0.20 - motion * 0.04),
          size.height * 0.12,
          size.width * 0.16,
          0,
        )
        ..lineTo(0, 0)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              gloss.withOpacity(0.18 + (motion * 0.08)),
              accent.withOpacity(0.08 + (motion * 0.10)),
              Colors.transparent,
            ],
          ).createShader(Offset.zero & size),
      );

      final streamPaint = Paint()
        ..color = barColor.withOpacity(0.08 + (motion * 0.08))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      for (var i = 0; i < 3; i++) {
        final x = size.width * (0.34 + (i * 0.16));
        final stream = Path()
          ..moveTo(x, size.height)
          ..quadraticBezierTo(
            x - wave + (i * 1.2),
            size.height * 0.66,
            x - (wave * 0.24),
            size.height * 0.34,
          )
          ..quadraticBezierTo(
            x + (wave * 0.45),
            size.height * 0.16,
            x - (wave * 0.08),
            0,
          );
        canvas.drawPath(stream, streamPaint);
      }
      return;
    }

    final wave = size.height * (0.10 + (motion * 0.12));
    final path = Path()
      ..moveTo(0, size.height * 0.26)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.10,
        size.width * 0.38,
        size.height * (0.18 + motion * 0.05),
        size.width * 0.56,
        size.height * 0.22,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.26,
        size.width * 0.84,
        size.height * (0.20 - motion * 0.04),
        size.width,
        size.height * 0.16,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gloss.withOpacity(0.18 + (motion * 0.08)),
            accent.withOpacity(0.08 + (motion * 0.10)),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );

    final streamPaint = Paint()
      ..color = barColor.withOpacity(0.08 + (motion * 0.08))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.38 + (i * 0.16));
      final stream = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(
          size.width * 0.34,
          y - wave + (i * 1.2),
          size.width * 0.66,
          y - (wave * 0.24),
        )
        ..quadraticBezierTo(
          size.width * 0.84,
          y + (wave * 0.45),
          size.width,
          y - (wave * 0.08),
        );
      canvas.drawPath(stream, streamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AccuracyLiquidPainter oldDelegate) {
    return barColor != oldDelegate.barColor ||
        accent != oldDelegate.accent ||
        gloss != oldDelegate.gloss ||
        liquidMotion != oldDelegate.liquidMotion ||
        isVertical != oldDelegate.isVertical;
  }
}

class _AccuracyShapeClipper extends CustomClipper<Path> {
  final OverlayAccuracyBarShape shape;
  final double jewelInset;

  const _AccuracyShapeClipper({
    required this.shape,
    required this.jewelInset,
  });

  @override
  Path getClip(Size size) {
    return _buildAccuracyShapePath(
      Offset.zero & size,
      shape,
      jewelInset,
    );
  }

  @override
  bool shouldReclip(covariant _AccuracyShapeClipper oldClipper) {
    return shape != oldClipper.shape || jewelInset != oldClipper.jewelInset;
  }
}

class _AccuracyFramePainter extends CustomPainter {
  final OverlayAccuracyBarShape shape;
  final double frameDepth;
  final double glossAmount;
  final double jewelInset;
  final double flareAmount;
  final Color barColor;
  final OverlayPaletteConfiguration palette;

  const _AccuracyFramePainter({
    required this.shape,
    required this.frameDepth,
    required this.glossAmount,
    required this.jewelInset,
    required this.flareAmount,
    required this.barColor,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final outerPath = _buildAccuracyShapePath(rect, shape, jewelInset);
    final innerPath = _buildAccuracyShapePath(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      shape,
      (jewelInset + 0.08).clamp(0.0, 1.0),
    );
    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 + (frameDepth * 1.8)
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.12 + (0.20 * glossAmount)),
          barColor.withOpacity(0.12 + (0.14 * flareAmount)),
          palette.accent.withOpacity(0.18 + (0.18 * frameDepth)),
        ],
      ).createShader(rect);
    final innerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 + (glossAmount * 1.2)
      ..color = palette.textPrimary.withOpacity(0.08 + (0.12 * glossAmount));

    canvas.drawPath(outerPath, framePaint);
    canvas.drawPath(innerPath, innerGlow);

    final glossRect = Rect.fromLTWH(
      rect.left + (8 + jewelInset * 8),
      rect.top + 4,
      rect.width * (0.40 + (0.18 * glossAmount)),
      rect.height * (0.24 + (0.14 * glossAmount)),
    );
    canvas.save();
    canvas.clipPath(outerPath);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glossRect, Radius.circular(glossRect.height)),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.10 + (0.18 * glossAmount)),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(glossRect),
    );

    final flarePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          palette.accent.withOpacity(0.10 + (0.18 * flareAmount)),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(rect.right - 18, rect.center.dy),
          radius: 20 + (18 * flareAmount),
        ),
      );
    canvas.drawCircle(
      Offset(rect.right - 18, rect.center.dy),
      20 + (18 * flareAmount),
      flarePaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AccuracyFramePainter oldDelegate) {
    return shape != oldDelegate.shape ||
        frameDepth != oldDelegate.frameDepth ||
        glossAmount != oldDelegate.glossAmount ||
        jewelInset != oldDelegate.jewelInset ||
        flareAmount != oldDelegate.flareAmount ||
        barColor != oldDelegate.barColor ||
        palette != oldDelegate.palette;
  }
}

Path _buildAccuracyShapePath(
  Rect rect,
  OverlayAccuracyBarShape shape,
  double jewelInset,
) {
  final inset = jewelInset.clamp(0.0, 1.0);
  switch (shape) {
    case OverlayAccuracyBarShape.capsule:
      return Path()
        ..addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)),
        );
    case OverlayAccuracyBarShape.beveled:
      return _beveledBarPath(rect, inset);
    case OverlayAccuracyBarShape.prism:
      return _prismBarPath(rect, inset);
    case OverlayAccuracyBarShape.crest:
      return _crestBarPath(rect, inset);
    case OverlayAccuracyBarShape.ribbon:
      return _ribbonBarPath(rect, inset);
  }
}

Path _beveledBarPath(Rect rect, double inset) {
  final bevel = rect.height * (0.18 + (0.10 * inset));
  return Path()
    ..moveTo(rect.left + bevel, rect.top)
    ..lineTo(rect.right - bevel, rect.top)
    ..lineTo(rect.right, rect.center.dy)
    ..lineTo(rect.right - bevel, rect.bottom)
    ..lineTo(rect.left + bevel, rect.bottom)
    ..lineTo(rect.left, rect.center.dy)
    ..close();
}

Path _prismBarPath(Rect rect, double inset) {
  final notch = rect.height * (0.24 + (0.12 * inset));
  return Path()
    ..moveTo(rect.left + notch, rect.top)
    ..lineTo(rect.right - notch, rect.top)
    ..lineTo(rect.right, rect.top + rect.height * 0.30)
    ..lineTo(rect.right - notch, rect.bottom)
    ..lineTo(rect.left + notch, rect.bottom)
    ..lineTo(rect.left, rect.bottom - rect.height * 0.30)
    ..close();
}

Path _crestBarPath(Rect rect, double inset) {
  final radius = rect.height * (0.22 + (0.12 * inset));
  return Path()
    ..moveTo(rect.left + radius, rect.top)
    ..quadraticBezierTo(rect.left, rect.top, rect.left, rect.top + radius)
    ..lineTo(rect.left, rect.bottom - radius)
    ..quadraticBezierTo(rect.left, rect.bottom, rect.left + radius, rect.bottom)
    ..lineTo(rect.right - radius, rect.bottom)
    ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - radius)
    ..lineTo(rect.right, rect.top + radius)
    ..quadraticBezierTo(rect.right, rect.top, rect.right - radius, rect.top)
    ..lineTo(rect.center.dx + rect.width * 0.06, rect.top)
    ..quadraticBezierTo(
      rect.center.dx,
      rect.top + rect.height * (0.20 + 0.12 * inset),
      rect.center.dx - rect.width * 0.06,
      rect.top,
    )
    ..close();
}

Path _ribbonBarPath(Rect rect, double inset) {
  final tail = rect.height * (0.22 + (0.10 * inset));
  return Path()
    ..moveTo(rect.left + tail, rect.top)
    ..lineTo(rect.right - tail, rect.top)
    ..lineTo(rect.right, rect.center.dy)
    ..lineTo(rect.right - tail, rect.bottom)
    ..lineTo(rect.left + tail, rect.bottom)
    ..lineTo(rect.left, rect.center.dy)
    ..close();
}

class _AccuracySpillPainter extends CustomPainter {
  final Color color;
  final Color accent;
  final double glowIntensity;
  final double spillLength;
  final double spillWidth;
  final double liquidMotion;

  const _AccuracySpillPainter({
    required this.color,
    required this.accent,
    required this.glowIntensity,
    required this.spillLength,
    required this.spillWidth,
    required this.liquidMotion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final streamWidth = 10 + (10 * liquidMotion) + (8 * spillWidth);
    final centerX = size.width / 2;
    final sway = (liquidMotion - 0.5) * size.width * 0.18;
    final destinationX = centerX + sway;
    final destinationY = size.height * (0.82 + (spillLength * 0.12));
    final ribbon = Path()
      ..moveTo(centerX - (streamWidth * 0.24), 0)
      ..cubicTo(
        centerX - (streamWidth * 0.84),
        size.height * 0.12,
        centerX - (streamWidth * 0.30) + (sway * 0.28),
        size.height * 0.34,
        destinationX - (streamWidth * 0.18),
        destinationY,
      )
      ..cubicTo(
        destinationX + (streamWidth * 0.34),
        size.height * 0.70,
        centerX + (streamWidth * 0.52) + (sway * 0.16),
        size.height * 0.24,
        centerX + (streamWidth * 0.16),
        0,
      )
      ..close();

    canvas.drawPath(
      ribbon,
      Paint()
        ..color = color.withOpacity(0.14 + (0.14 * glowIntensity))
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          10 + (10 * glowIntensity),
        ),
    );
    canvas.drawPath(
      ribbon,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withOpacity(0.52),
            Color.lerp(accent, color, 0.42)!.withOpacity(0.42 + (0.16 * spillLength)),
            color.withOpacity(0.18 + (0.14 * spillLength)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.28, 0.78, 1.0],
        ).createShader(Offset.zero & size),
    );

    canvas.save();
    canvas.clipPath(ribbon);
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 + liquidMotion
      ..color = Colors.white.withOpacity(0.14 + (0.10 * glowIntensity));
    for (var i = 0; i < 3; i++) {
      final startY = size.height * (0.18 + (i * 0.18));
      final highlight = Path()
        ..moveTo(centerX - (streamWidth * 0.18), startY)
        ..quadraticBezierTo(
          centerX + (streamWidth * (0.12 + (i * 0.06))),
          startY + (size.height * 0.12),
          destinationX - (streamWidth * 0.06),
          startY + (size.height * 0.26),
        );
      canvas.drawPath(highlight, highlightPaint);
    }
    canvas.restore();

    final mistPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withOpacity(0.16 + (0.08 * glowIntensity)),
          color.withOpacity(0.08 + (0.06 * spillLength)),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(destinationX, destinationY - (size.height * 0.06)),
          radius: streamWidth * (1.1 + spillLength),
        ),
      );
    canvas.drawCircle(
      Offset(destinationX, destinationY - (size.height * 0.06)),
      streamWidth * (1.1 + spillLength),
      mistPaint,
    );

    final dropletRadius = streamWidth * (0.26 + (0.10 * spillLength));
    final dropletCenter = Offset(destinationX, destinationY + (streamWidth * 0.05));
    final streamPath = Path()
      ..moveTo(centerX, 0)
      ..cubicTo(
        centerX + (streamWidth * 0.16),
        size.height * 0.18,
        destinationX - (streamWidth * 0.34),
        size.height * 0.62,
        dropletCenter.dx,
        dropletCenter.dy - dropletRadius,
      );

    canvas.drawPath(
      streamPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(streamWidth * 0.18, dropletRadius * 0.55)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withOpacity(0.0),
            accent.withOpacity(0.54),
            color.withOpacity(0.24),
            Colors.transparent,
          ],
          stops: const [0.0, 0.22, 0.72, 1.0],
        ).createShader(Offset.zero & size),
    );

    canvas.drawCircle(
      dropletCenter,
      dropletRadius * 1.95,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withOpacity(0.26 + (0.10 * glowIntensity)),
            color.withOpacity(0.10 + (0.05 * spillLength)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.56, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: dropletCenter,
            radius: dropletRadius * 1.95,
          ),
        ),
    );

    canvas.drawCircle(
      dropletCenter,
      dropletRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.94),
            accent.withOpacity(0.68),
            color.withOpacity(0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.24, 0.72, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(
              dropletCenter.dx - (dropletRadius * 0.18),
              dropletCenter.dy - (dropletRadius * 0.22),
            ),
            radius: dropletRadius,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _AccuracySpillPainter oldDelegate) {
    return color != oldDelegate.color ||
        accent != oldDelegate.accent ||
        glowIntensity != oldDelegate.glowIntensity ||
        spillLength != oldDelegate.spillLength ||
        spillWidth != oldDelegate.spillWidth ||
        liquidMotion != oldDelegate.liquidMotion;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TikTok-style gradient border
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] with an animated-style sweep-gradient border described by
/// [config]. When [config.enabled] is false the child is returned directly
/// so there is no performance cost.
class _GradientBorderWrapper extends StatelessWidget {
  final OverlayGradientBorderConfiguration config;
  final double borderRadius;
  final Widget child;

  const _GradientBorderWrapper({
    required this.config,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!config.enabled || config.colors.length < 2) {
      return child;
    }
    return CustomPaint(
      foregroundPainter: _GradientBorderPainter(
        config: config,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final OverlayGradientBorderConfiguration config;
  final double borderRadius;

  const _GradientBorderPainter({
    required this.config,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!config.enabled || config.colors.length < 2) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    // Build a SweepGradient rotated by rotationTurns.
    final turns = config.rotationTurns;
    final gradient = SweepGradient(
      colors: config.colors,
      transform: GradientRotation(turns * 2 * math.pi),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.width
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter old) {
    return config != old.config || borderRadius != old.borderRadius;
  }
}
