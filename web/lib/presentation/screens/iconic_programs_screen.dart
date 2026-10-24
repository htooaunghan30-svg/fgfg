import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/iconic/iconic_program.dart';
import '../../features/iconic/world_festival.dart';
import '../../features/iconic/world_festival_overlay_theme.dart';
import '../providers/user_provider.dart';

class IconicProgramsScreen extends StatelessWidget {
  const IconicProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final selectedProgram = userProvider.iconicProgram;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF08111D),
                colors.surface,
                colors.surface.withOpacity(0.98),
              ],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              const _IconicHeroCard(),
              const SizedBox(height: 18),
              _ProgramCard(
                selected: selectedProgram == IconicProgram.zodiac,
                onTap: () =>
                    userProvider.setIconicProgram(IconicProgram.zodiac),
                accentColors: const [
                  Color(0xFF1E2D57),
                  Color(0xFFD9B66C),
                  Color(0xFF8C6931),
                ],
                eyebrow: 'Post-Processed Signature',
                title: 'Zodiac Program',
                description:
                    'Applies a luxury zodiac overlay after recording. All 12 signs now use distinct palettes, symbols, aura tinting, and engraved styling, with the preview anchored to the Aries art direction.',
                tags: const [
                  '12 Sign Themes',
                  'Luxury Capsule',
                  'Embossed Coin'
                ],
                preview: const _AriesPreview(),
                footer:
                    'Recommended for iconic exports. Live capture stays lightweight so the phone does not overheat, while post-process adds the luxury treatment after recording.',
              ),
              const SizedBox(height: 16),
              _ProgramCard(
                selected: selectedProgram == IconicProgram.worldFestival,
                onTap: () =>
                    userProvider.setIconicProgram(IconicProgram.worldFestival),
                accentColors: const [
                  Color(0xFF3A1026),
                  Color(0xFFEDB65B),
                  Color(0xFF632D4A),
                ],
                eyebrow: 'Cultural Celebration',
                title: 'World Festival Program',
                description:
                    'Applies a unique luxury overlay based on the nearest world festival or sporting event. Each festival has its own color palette, ring glow, accuracy bar gradient, and overlay branding.',
                tags: const ['70 Festivals', 'Date-Aware', 'Luxury Overlay'],
                preview: const _FestivalPreview(),
                footer:
                    'The theme automatically switches to the nearest upcoming celebration. Record your workout and the active festival look is applied during post-processing.',
              ),
              const SizedBox(height: 16),
              _ProgramCard(
                selected: selectedProgram == IconicProgram.none,
                onTap: () => userProvider.setIconicProgram(IconicProgram.none),
                accentColors: const [
                  Color(0xFF17202B),
                  Color(0xFF64748B),
                  Color(0xFF1F2937),
                ],
                eyebrow: 'Lightweight Default',
                title: 'Standard Export',
                description:
                    'Keeps the current simple overlay when you do not want a branded cinematic look.',
                tags: const ['Default', 'Minimal', 'Fast Export'],
                preview: const _StandardPreview(),
                footer:
                    'Use this if you want the existing export style with no premium art direction.',
              ),
              const SizedBox(height: 18),
              _InfoPanel(
                title: 'How It Works',
                lines: const [
                  '1. Pick a program here.',
                  '2. Record your workout as usual.',
                  '3. The selected style is applied only after recording during post-processing.',
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IconicHeroCard extends StatelessWidget {
  const _IconicHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF101C2F),
            Color(0xFF0B1320),
            Color(0xFF2D1E14),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: const Color(0x66E5C57A),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF0CF86),
                      Color(0xFFB8833D),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF1A130B),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Iconic Programs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Choose a premium post-process look for recorded videos. Each program is designed to feel distinct, cinematic, and elegant without adding heat during live capture.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final List<Color> accentColors;
  final String eyebrow;
  final String title;
  final String description;
  final List<String> tags;
  final Widget preview;
  final String footer;

  const _ProgramCard({
    required this.selected,
    required this.onTap,
    required this.accentColors,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.tags,
    required this.preview,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColors.first.withOpacity(0.94),
            accentColors.last.withOpacity(0.92),
          ],
        ),
        border: Border.all(
          color: selected ? accentColors[1] : Colors.white.withOpacity(0.08),
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? accentColors[1].withOpacity(0.18)
                : Colors.black.withOpacity(0.10),
            blurRadius: selected ? 24 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow.toUpperCase(),
                          style: TextStyle(
                            color: accentColors[1],
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? accentColors[1]
                          : Colors.white.withOpacity(0.08),
                      border: Border.all(
                        color: selected
                            ? accentColors[1]
                            : Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: Icon(
                      selected ? Icons.check : Icons.circle_outlined,
                      size: 16,
                      color: selected
                          ? const Color(0xFF1A120A)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              preview,
              const SizedBox(height: 14),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.84),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.86),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              Text(
                footer,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AriesPreview extends StatelessWidget {
  const _AriesPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1627),
            Color(0xFF1F2A42),
            Color(0xFF3B2A1A),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: CustomPaint(
        painter: _AriesPreviewPainter(),
      ),
    );
  }
}

class _FestivalPreview extends StatelessWidget {
  const _FestivalPreview();

  @override
  Widget build(BuildContext context) {
    final festival = worldFestivalForDate(DateTime.now());
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            festival.primaryStart.withOpacity(0.92),
            Color.lerp(festival.primaryStart, festival.primaryEnd, 0.5)!
                .withOpacity(0.90),
            festival.primaryEnd.withOpacity(0.88),
          ],
        ),
        border: Border.all(
          color: festival.accent1.withOpacity(0.18),
        ),
      ),
      child: CustomPaint(
        painter: _FestivalPreviewPainter(festival),
      ),
    );
  }
}

class _FestivalPreviewPainter extends CustomPainter {
  final WorldFestivalVisualStyle festival;

  const _FestivalPreviewPainter(this.festival);

  @override
  void paint(Canvas canvas, Size size) {
    // ─── Theme name ───
    final titlePaint = Paint()
      ..shader = LinearGradient(
        colors: [festival.accent1, festival.accent2],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 32));
    final titleStyle = TextStyle(
      foreground: titlePaint,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    );
    final title = TextPainter(
      text: TextSpan(text: festival.themeName, style: titleStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(canvas, const Offset(16, 14));

    // ─── Subtitle (date + location) ───
    final subtitleStyle = TextStyle(
      color: festival.accent2.withOpacity(0.72),
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    );
    final subtitle = TextPainter(
      text: TextSpan(text: festival.subtitle, style: subtitleStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    subtitle.paint(canvas, const Offset(16, 36));

    // ─── Accuracy bar preview ───
    final art = festival.barArtDirection;
    final resolvedBarRect = Rect.fromLTWH(16, 56, size.width - 120, 26);
    final trackPath = art.buildTrackPath(resolvedBarRect);
    final fillPath = art.buildFillPath(
      resolvedBarRect.deflate(1.6),
      0.84,
      flowPhase: 0.21,
    );
    canvas.drawPath(
      trackPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            festival.primaryStart.withOpacity(0.94),
            Color.lerp(festival.primaryEnd, festival.primaryStart, 0.25)!
                .withOpacity(0.92),
            festival.accuracyBarGradient.last.withOpacity(0.54),
          ],
        ).createShader(resolvedBarRect),
    );
    canvas.drawPath(
      trackPath,
      Paint()
        ..color = festival.accent2.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    canvas.save();
    canvas.clipPath(trackPath);
    canvas.drawRect(
      resolvedBarRect,
      Paint()
        ..shader = LinearGradient(
          colors: festival.accuracyBarGradient
              .map((color) => color.withOpacity(0.14))
              .toList(),
        ).createShader(resolvedBarRect),
    );
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            festival.accuracyMidColor.withOpacity(0.96),
            festival.accuracyHighColor.withOpacity(0.98),
            festival.accent1.withOpacity(0.96),
          ],
        ).createShader(resolvedBarRect),
    );
    canvas.drawPath(
      art.buildFillPath(
        Rect.fromLTWH(
          resolvedBarRect.left,
          resolvedBarRect.top + 2,
          resolvedBarRect.width,
          resolvedBarRect.height - 10,
        ),
        0.80,
        flowPhase: 0.38,
      ),
      Paint()..color = festival.accent2.withOpacity(0.12),
    );
    canvas.restore();

    final thresholdX = resolvedBarRect.left + (resolvedBarRect.width * 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          thresholdX - 1.6,
          resolvedBarRect.top + 3,
          3.2,
          resolvedBarRect.height - 6,
        ),
        const Radius.circular(12),
      ),
      Paint()..color = festival.thresholdLineColor.withOpacity(0.92),
    );
    canvas.drawPath(
      art.buildSpillPath(
        Offset(thresholdX, resolvedBarRect.bottom - 1),
        Size(size.width, size.height),
        intensity: 0.44,
        flowPhase: 0.30,
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            festival.thresholdLineColor.withOpacity(0.70),
            festival.accent1.withOpacity(0.46),
            festival.glowColor.withOpacity(0.08),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromLTWH(
            thresholdX - 18,
            resolvedBarRect.bottom,
            36,
            size.height * 0.5,
          ),
        ),
    );

    // ─── Ring preview (replaces coin) ───
    final ringCenter = Offset(size.width - 52, 90);
    final ringRadius = 34.0;

    // Glow
    canvas.drawCircle(
      ringCenter,
      ringRadius + 3,
      Paint()
        ..color = festival.glowColor.withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Ring gradient
    final ringRect = Rect.fromCircle(center: ringCenter, radius: ringRadius);
    canvas.drawCircle(
      ringCenter,
      ringRadius,
      Paint()
        ..shader = SweepGradient(
          colors: festival.ringGradient,
        ).createShader(ringRect),
    );

    // Inner dark circle
    canvas.drawCircle(
      ringCenter,
      ringRadius - 6,
      Paint()..color = festival.primaryStart.withOpacity(0.85),
    );

    // Ring border
    canvas.drawCircle(
      ringCenter,
      ringRadius,
      Paint()
        ..color = festival.accent1.withOpacity(0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    // Banner icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: festival.bannerIcon,
        style: const TextStyle(fontSize: 22),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(
      canvas,
      Offset(ringCenter.dx - 11, ringCenter.dy - 20),
    );

    // Rep count preview
    final reps = TextPainter(
      text: TextSpan(
        text: '24',
        style: TextStyle(
          color: festival.accent1,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    reps.paint(canvas, Offset(ringCenter.dx - 8, ringCenter.dy + 6));

    // ─── Phase color swatches ───
    final swatchY = 100.0;
    final swatchColors = [
      festival.phaseUpColor,
      festival.phaseDownColor,
      festival.phaseHoldColor,
    ];
    final swatchLabels = ['UP', 'DN', 'HD'];
    for (var i = 0; i < swatchColors.length; i++) {
      final x = 16.0 + (i * 44.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, swatchY, 36, 14),
          const Radius.circular(7),
        ),
        Paint()..color = swatchColors[i],
      );
      final sLabel = TextPainter(
        text: TextSpan(
          text: swatchLabels[i],
          style: TextStyle(
            color: _contrastColor(swatchColors[i]),
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      sLabel.paint(canvas, Offset(x + (36 - sLabel.width) / 2, swatchY + 2));
    }

    // ─── Bottom label ───
    final label = TextPainter(
      text: TextSpan(
        text: 'POST-PROCESS PREVIEW',
        style: TextStyle(
          color: Colors.white.withOpacity(0.54),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset(16, size.height - 24));

    // Sparkle dots
    for (var i = 0; i < 12; i++) {
      final dx = 20 + (i * 16.0);
      final dy = 126 + (math.sin(i * 0.7) * 6.0);
      canvas.drawCircle(
        Offset(dx, dy),
        i.isEven ? 1.3 : 0.9,
        Paint()..color = festival.accent1.withOpacity(0.45),
      );
    }
  }

  /// Pick black or white text based on luminance of the background.
  static Color _contrastColor(Color bg) {
    return bg.computeLuminance() > 0.45 ? Colors.black87 : Colors.white;
  }

  @override
  bool shouldRepaint(covariant _FestivalPreviewPainter oldDelegate) =>
      oldDelegate.festival.storageKey != festival.storageKey;
}

class _StandardPreview extends StatelessWidget {
  const _StandardPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF111827),
            Color(0xFF1F2937),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: const Center(
        child: Text(
          'Default export overlay\nkeeps the current lightweight look.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _InfoPanel({
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                line,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.72),
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AriesPreviewPainter extends CustomPainter {
  const _AriesPreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final titlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFF0D48A),
          Color(0xFFC69444),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 32));
    final titleStyle = TextStyle(
      foreground: titlePaint,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );
    final title = TextPainter(
      text: TextSpan(text: 'Aries Gratitude', style: titleStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(canvas, Offset(16, 14));

    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 48, size.width - 120, 28),
      const Radius.circular(18),
    );
    final barPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0E2240),
          Color(0xFF142C4F),
          Color(0xFF8A6A33),
        ],
      ).createShader(barRect.outerRect);
    canvas.drawRRect(barRect, barPaint);
    canvas.drawRRect(
      barRect,
      Paint()
        ..color = const Color(0xFFE0C27A).withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    final fillRect = Rect.fromLTWH(18, 50, (size.width - 124) * 0.74, 24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, const Radius.circular(16)),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFDAB96E),
            Color(0xFFB88538),
            Color(0xFF70461E),
          ],
        ).createShader(fillRect),
    );

    final constellationPaint = Paint()
      ..color = const Color(0xFFE8D8A6).withOpacity(0.82)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final points = <Offset>[
      const Offset(30, 64),
      const Offset(48, 59),
      const Offset(73, 62),
      const Offset(92, 56),
      const Offset(118, 61),
      const Offset(146, 58),
      const Offset(170, 63),
    ];
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], constellationPaint);
    }
    for (final point in points) {
      canvas.drawCircle(
        point,
        1.9,
        Paint()..color = const Color(0xFFF7E8BA),
      );
    }

    final coinCenter = Offset(size.width - 52, 82);
    final outer = Rect.fromCircle(center: coinCenter, radius: 34);
    canvas.drawCircle(
      coinCenter,
      37,
      Paint()
        ..color = const Color(0xFFD9B66C).withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawCircle(
      coinCenter,
      34,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFFE7C67E),
            Color(0xFFB98640),
            Color(0xFF6A4120),
          ],
        ).createShader(outer),
    );
    canvas.drawCircle(
      coinCenter,
      34,
      Paint()
        ..color = const Color(0xFFEBD29A).withOpacity(0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      coinCenter,
      26,
      Paint()
        ..color = const Color(0xFFFAE7B2).withOpacity(0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final symbol = TextPainter(
      text: const TextSpan(
        text: '\u2648',
        style: TextStyle(
          color: Color(0xFF4B2C17),
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    symbol.paint(canvas, Offset(coinCenter.dx - 11, coinCenter.dy - 25));

    canvas.drawLine(
      Offset(coinCenter.dx - 18, coinCenter.dy + 1),
      Offset(coinCenter.dx + 18, coinCenter.dy + 1),
      Paint()
        ..color = const Color(0xFFFAE7B2).withOpacity(0.22)
        ..strokeWidth = 1,
    );

    final reps = TextPainter(
      text: const TextSpan(
        text: '24',
        style: TextStyle(
          color: Color(0xFF2D1A0E),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    reps.paint(canvas, Offset(coinCenter.dx - 10, coinCenter.dy + 7));

    final label = TextPainter(
      text: TextSpan(
        text: 'POST-PROCESS PREVIEW',
        style: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset(16, size.height - 24));

    for (var i = 0; i < 14; i++) {
      final dx = 20 + (i * 16.0);
      final dy = 102 + (math.sin(i * 0.7) * 7.0);
      canvas.drawCircle(
        Offset(dx, dy),
        i.isEven ? 1.3 : 0.9,
        Paint()..color = const Color(0xFFFCE7AF).withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
