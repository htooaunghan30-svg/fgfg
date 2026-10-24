import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../features/iconic/iconic_program.dart';
import '../../features/iconic/profession_hobby_theme.dart';
import '../../features/iconic/world_festival.dart';
import '../../features/iconic/world_festival_overlay_theme.dart';
import '../providers/user_provider.dart';
import 'premium_activation_screen.dart';
import 'workout_overlay_customizer_screen.dart';

class IconicProgramsScreen extends StatelessWidget {
  const IconicProgramsScreen({super.key});

  Future<bool> _requirePremiumAccess(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final hasAccess = await userProvider.ensurePremiumAccess();
    if (hasAccess || !context.mounted) {
      return hasAccess;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('premium.menu_only')),
        action: SnackBarAction(
          label: context.tr('settings.upgrade_to_premium'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PremiumActivationScreen(),
              ),
            );
          },
        ),
      ),
    );
    return false;
  }

  Future<void> _selectProgram(
    BuildContext context,
    IconicProgram program,
  ) async {
    if (program != IconicProgram.none && !await _requirePremiumAccess(context)) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await context.read<UserProvider>().setIconicProgram(program);
  }

  Future<void> _openStudio(BuildContext context) async {
    if (!await _requirePremiumAccess(context)) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WorkoutOverlayCustomizerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

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
                onTap: () {
                  unawaited(_selectProgram(context, IconicProgram.zodiac));
                },
                accentColors: const [
                  Color(0xFF1E2D57),
                  Color(0xFFD9B66C),
                  Color(0xFF8C6931),
                ],
                eyebrow: l10n.t('iconic.program.zodiac.eyebrow'),
        title: l10n.t('iconic.program.zodiac.title'),
                description: l10n.t('iconic.program.zodiac.description'),
                tags: [
                  l10n.t('iconic.program.zodiac.tag.sign_themes'),
                  l10n.t('iconic.program.zodiac.tag.luxury_capsule'),
                  l10n.t('iconic.program.zodiac.tag.embossed_coin'),
                ],
                preview: const _AriesPreview(),
                footer: l10n.t('iconic.program.zodiac.footer'),
              ),
              const SizedBox(height: 16),
              _ProgramCard(
                selected: selectedProgram == IconicProgram.worldFestival,
                onTap: () {
                  unawaited(
                    _selectProgram(context, IconicProgram.worldFestival),
                  );
                },
                accentColors: const [
                  Color(0xFF3A1026),
                  Color(0xFFEDB65B),
                  Color(0xFF632D4A),
                ],
                eyebrow: l10n.t('iconic.program.festival.eyebrow'),
        title: l10n.t('iconic.program.festival.title'),
                description: l10n.t('iconic.program.festival.description'),
                tags: [
                  l10n.t('iconic.program.festival.tag.festivals'),
                  l10n.t('iconic.program.festival.tag.date_aware'),
                  l10n.t('iconic.program.festival.tag.luxury_overlay'),
                ],
                preview: const _FestivalPreview(),
                footer: l10n.t('iconic.program.festival.footer'),
              ),
              const SizedBox(height: 16),
              _ProgramCard(
                selected: selectedProgram == IconicProgram.professionHobby,
                onTap: () {
                  unawaited(
                    _selectProgram(context, IconicProgram.professionHobby),
                  );
                },
                accentColors: const [
                  Color(0xFF0E1F2D),
                  Color(0xFF23C5E8),
                  Color(0xFF27384A),
                ],
                eyebrow: 'Profession & Creative Theme Pack',
                title: 'Profession / Hobby',
                description:
                    'Choose a profession-grade dashboard skin. Name bar, rep counter, and accuracy bar switch together — from engineers to musicians, writers, designers, and managers.',
                tags: const [
                  '20 profession cards',
                  'Precision states',
                  'Low-overhead visuals',
                ],
                preview: _ProfessionThemePreview(
                  selectedThemeKey: userProvider.professionThemeKey,
                  onSelectTheme: (themeKey) {
                    unawaited(
                      context.read<UserProvider>().setProfessionThemeKey(
                        themeKey,
                      ),
                    );
                  },
                ),
                footer:
                    'Premium HUD set with synchronized status ribbon, precision microtext, and compact hero counter — tailored for every profession and creative lifestyle.',
              ),
              const SizedBox(height: 16),
              _ProgramCard(
                selected: selectedProgram == IconicProgram.luxuryStudio,
                onTap: () {
                  unawaited(
                    _selectProgram(context, IconicProgram.luxuryStudio),
                  );
                },
                accentColors: const [
                  Color(0xFF1B1028),
                  Color(0xFFE4BE74),
                  Color(0xFF5B2336),
                ],
                eyebrow: l10n.t('iconic.program.studio.eyebrow'),
        title: l10n.t('iconic.program.studio.title'),
                description: l10n.t('iconic.program.studio.description'),
                tags: [
                  l10n.t('iconic.program.studio.tag.custom_program'),
                  l10n.t('iconic.program.studio.tag.luxury_editor'),
                  l10n.t('iconic.program.studio.tag.premium_control'),
                ],
                preview: const _LuxuryStudioPreview(),
                footer: l10n.t('iconic.program.studio.footer'),
                actionLabel: l10n.t('iconic.program.studio.action'),
                onAction: () {
                  unawaited(_openStudio(context));
                },
              ),
              const SizedBox(height: 16),
              _ProgramCard(
                selected: selectedProgram == IconicProgram.none,
                onTap: () {
                  unawaited(_selectProgram(context, IconicProgram.none));
                },
                accentColors: const [
                  Color(0xFF17202B),
                  Color(0xFF64748B),
                  Color(0xFF1F2937),
                ],
                eyebrow: l10n.t('iconic.program.standard.eyebrow'),
        title: l10n.t('iconic.program.standard.title'),
                description: l10n.t('iconic.program.standard.description'),
                tags: [
                  l10n.t('iconic.program.standard.tag.default'),
                  l10n.t('iconic.program.standard.tag.minimal'),
                  l10n.t('iconic.program.standard.tag.fast_export'),
                ],
                preview: const _StandardPreview(),
                footer: l10n.t('iconic.program.standard.footer'),
              ),
              const SizedBox(height: 18),
              _InfoPanel(
                title: l10n.t('iconic.info.title'),
                lines: [
                  l10n.t('iconic.info.step1'),
                  l10n.t('iconic.info.step2'),
                  l10n.t('iconic.info.step3'),
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
    final l10n = context.l10n;
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
              Expanded(
                child: Text(
                  l10n.t('iconic.menu.title'),
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
            l10n.t('iconic.menu.subtitle'),
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
  final String? actionLabel;
  final VoidCallback? onAction;

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
    this.actionLabel,
    this.onAction,
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
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(actionLabel!),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColors[1],
                      foregroundColor: const Color(0xFF1A120A),
                    ),
                  ),
                ),
              ],
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
    final l10n = context.l10n;
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
        painter: _AriesPreviewPainter(
          previewLabel: l10n.t('iconic.preview.post_process'),
        ),
      ),
    );
  }
}

class _FestivalPreview extends StatelessWidget {
  const _FestivalPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final festival = worldFestivalForDate(now);
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
        painter: _FestivalPreviewPainter(
          festival,
          worldFestivalDisplaySubtitleForDate(now, festival),
          l10n.t('iconic.preview.post_process'),
        ),
      ),
    );
  }
}

class _FestivalPreviewPainter extends CustomPainter {
  final WorldFestivalVisualStyle festival;
  final String displaySubtitle;
  final String previewLabel;

  const _FestivalPreviewPainter(
    this.festival,
    this.displaySubtitle,
    this.previewLabel,
  );

  @override
  void paint(Canvas canvas, Size size) {

    // ─── Subtitle (date + location) ───
    final subtitleStyle = TextStyle(
      color: festival.accent2.withOpacity(0.72),
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    );
    final subtitle = TextPainter(
      text: TextSpan(text: displaySubtitle, style: subtitleStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    subtitle.paint(canvas, const Offset(16, 16));

    // ─── Accuracy bar preview ───
    final art = festival.barArtDirection;
    final resolvedBarRect = Rect.fromLTWH(16, 44, size.width - 120, 26);
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
    final displayIcon = festival.bannerIcon == 'padauk_branch' ? '' : festival.bannerIcon;
    final iconPainter = TextPainter(
      text: TextSpan(
        text: displayIcon,
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
    final swatchY = 92.0;
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
        text: previewLabel,
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

class _ProfessionThemePreview extends StatelessWidget {
  final String selectedThemeKey;
  final ValueChanged<String> onSelectTheme;

  const _ProfessionThemePreview({
    required this.selectedThemeKey,
    required this.onSelectTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: professionHobbyThemes.map((theme) {
        final isSelected = theme.storageKey == selectedThemeKey;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelectTheme(theme.storageKey),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    theme.primaryStart.withOpacity(isSelected ? 0.96 : 0.84),
                    theme.primaryEnd.withOpacity(isSelected ? 0.96 : 0.84),
                  ],
                ),
                border: Border.all(
                  color: isSelected
                      ? theme.accent1.withOpacity(0.96)
                      : Colors.white.withOpacity(0.14),
                  width: isSelected ? 1.4 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? theme.glowColor.withOpacity(0.20)
                        : Colors.black.withOpacity(0.12),
                    blurRadius: isSelected ? 14 : 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.22),
                      border: Border.all(
                        color: theme.accent2.withOpacity(0.45),
                      ),
                    ),
                    child: Text(
                      theme.bannerIcon,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          theme.themeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? theme.accent1
                          : Colors.white.withOpacity(0.10),
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.circle_outlined,
                      size: 13,
                      color: isSelected
                          ? const Color(0xFF0A121A)
                          : Colors.white.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StandardPreview extends StatelessWidget {
  const _StandardPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
      child: Center(
        child: Text(
          l10n.t('iconic.preview.standard.caption'),
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

class _LuxuryStudioPreview extends StatelessWidget {
  const _LuxuryStudioPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1526),
            Color(0xFF2A1532),
            Color(0xFF5B2336),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: CustomPaint(
        painter: _LuxuryStudioPreviewPainter(
          editableLuxeLabel: l10n.t('iconic.preview.editable_luxe'),
        ),
      ),
    );
  }
}

class _LuxuryStudioPreviewPainter extends CustomPainter {
  final String editableLuxeLabel;

  const _LuxuryStudioPreviewPainter({
    required this.editableLuxeLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Removed repetitive title as requested
    
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(16, 52, size.width - 124, 28),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      barRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF2A1532),
            Color(0xFF5B2336),
            Color(0xFFE4BE74),
          ],
        ).createShader(barRect.outerRect),
    );
    canvas.drawRRect(
      barRect,
      Paint()
        ..color = const Color(0x66FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final fillRect = Rect.fromLTWH(18, 54, (size.width - 128) * 0.82, 24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fillRect, const Radius.circular(14)),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFF2E7C8),
            Color(0xFFE4BE74),
            Color(0xFFD16A58),
          ],
        ).createShader(fillRect),
    );

    final thresholdX = 16 + ((size.width - 124) * 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(thresholdX - 1.8, 55, 3.6, 22),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFFF6E5B7),
    );

    final spillPath = Path()
      ..moveTo(thresholdX, 80)
      ..cubicTo(
        thresholdX - 10,
        94,
        thresholdX + 4,
        112,
        thresholdX - 2,
        130,
      )
      ..cubicTo(
        thresholdX + 12,
        114,
        thresholdX + 10,
        96,
        thresholdX + 6,
        80,
      )
      ..close();
    canvas.drawPath(
      spillPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7E7BA),
            Color(0xFFE19A66),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(thresholdX - 14, 80, 28, 54)),
    );

    final ringRect = Rect.fromCircle(
      center: Offset(size.width - 54, 90),
      radius: 34,
    );
    canvas.drawCircle(
      ringRect.center,
      37,
      Paint()
        ..color = const Color(0xFFE4BE74).withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(
      ringRect.center,
      34,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFF3E0AE),
            Color(0xFFD16A58),
            Color(0xFF5B2336),
            Color(0xFFF3E0AE),
          ],
        ).createShader(ringRect),
    );
    canvas.drawCircle(
      ringRect.center,
      27,
      Paint()..color = const Color(0xFF1A2234).withOpacity(0.92),
    );

    final repText = TextPainter(
      text: const TextSpan(
        text: '24',
        style: TextStyle(
          color: Color(0xFFF8E9C5),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    repText.paint(
      canvas,
      Offset(ringRect.center.dx - (repText.width / 2), ringRect.center.dy - 12),
    );

    final badge = TextPainter(
      text: TextSpan(
        text: editableLuxeLabel,
        style: TextStyle(
          color: Colors.white.withOpacity(0.68),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    badge.paint(canvas, Offset(16, size.height - 24));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  final String previewLabel;

  const _AriesPreviewPainter({
    this.previewLabel = 'POST-PROCESS PREVIEW',
  });

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
        text: previewLabel,
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

