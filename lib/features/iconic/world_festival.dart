import 'package:flutter/material.dart';

/// Visual style definition for a single World Festival theme.
///
/// Each festival carries its own color palette, phase colors, ring gradient,
/// accuracy bar colors, and banner/overlay metadata so that every UI element
/// (rep counter, accuracy bar, video export overlay) can be swapped in one shot.
class WorldFestivalVisualStyle {
  final String storageKey;
  final String themeName;
  final String label;
  final String subtitle; // e.g. "JAN 01 · WORLDWIDE"
  final String bannerIcon; // emoji or short text for overlay
  final String cornerIcon; // icon for bottom corner card
  final String watermarkIcon; // inner circle background watermark
  final String bannerTitle; // overlay top banner text
  final int month;
  final int day;
  final int? startMonth;
  final int? startDay;
  final int? endMonth;
  final int? endDay;

  // ─── Color Palette ───
  final Color primaryStart;
  final Color primaryEnd;
  final Color accent1;
  final Color accent2;
  final Color glowColor;

  // ─── Phase Colors (Rep Counter) ───
  final Color phaseUpColor;
  final Color phaseDownColor;
  final Color phaseHoldColor;

  // ─── Rep Counter Ring ───
  final List<Color> ringGradient;
  final double outerRingWidthAt100;
  final bool showHighlight;

  // ─── Accuracy Bar ───
  final List<Color> accuracyBarGradient; // background bar hint gradient
  final Color accuracyLowColor; // <60%
  final Color accuracyMidColor; // 60-80%
  final Color accuracyHighColor; // >80%
  final Color thresholdLineColor; // 80% marker

  const WorldFestivalVisualStyle({
    required this.storageKey,
    required this.themeName,
    required this.label,
    required this.subtitle,
    required this.bannerIcon,
    this.cornerIcon = '',
    this.watermarkIcon = '',
    required this.bannerTitle,
    required this.month,
    required this.day,
    this.startMonth,
    this.startDay,
    this.endMonth,
    this.endDay,
    required this.primaryStart,
    required this.primaryEnd,
    required this.accent1,
    required this.accent2,
    required this.glowColor,
    required this.phaseUpColor,
    required this.phaseDownColor,
    required this.phaseHoldColor,
    required this.ringGradient,
    this.outerRingWidthAt100 = 7.0,
    this.showHighlight = true,
    required this.accuracyBarGradient,
    required this.accuracyLowColor,
    required this.accuracyMidColor,
    required this.accuracyHighColor,
    required this.thresholdLineColor,
  });
}

int _festivalStartValue(WorldFestivalVisualStyle festival) {
  final month = festival.startMonth ?? festival.month;
  final day = festival.startDay ?? festival.day;
  return (month * 100) + day;
}

int _festivalEndValue(WorldFestivalVisualStyle festival) {
  final month = festival.endMonth ?? festival.month;
  final day = festival.endDay ?? festival.day;
  return (month * 100) + day;
}

bool _isDateWithinFestival(DateTime date, WorldFestivalVisualStyle festival) {
  final todayValue = (date.month * 100) + date.day;
  final startValue = _festivalStartValue(festival);
  final endValue = _festivalEndValue(festival);

  if (endValue >= startValue) {
    return todayValue >= startValue && todayValue <= endValue;
  }

  return todayValue >= startValue || todayValue <= endValue;
}

bool isWorldFestivalPreviewDay(
  DateTime date,
  WorldFestivalVisualStyle festival,
) {
  return !_isDateWithinFestival(date, festival);
}

String worldFestivalDisplayNameForDate(
  DateTime date,
  WorldFestivalVisualStyle festival,
) {
  final baseName = festival.themeName;
  if (!isWorldFestivalPreviewDay(date, festival)) {
    return baseName;
  }
  return '$baseName (pre-show)';
}

String worldFestivalDisplaySubtitleForDate(
  DateTime date,
  WorldFestivalVisualStyle festival,
) {
  final baseSubtitle = festival.subtitle.isNotEmpty
      ? festival.subtitle
      : (festival.label.isNotEmpty ? festival.label : festival.themeName);
  if (!isWorldFestivalPreviewDay(date, festival)) {
    return baseSubtitle;
  }
  return '$baseSubtitle (pre-show)';
}

String worldFestivalExportTitleForDate(
  DateTime date,
  WorldFestivalVisualStyle festival,
) {
  if (isWorldFestivalPreviewDay(date, festival)) {
    final baseLabel =
        festival.label.isNotEmpty ? festival.label : festival.themeName;
    return '$baseLabel (pre-show)';
  }

  return worldFestivalDisplaySubtitleForDate(date, festival);
}

// ═══════════════════════════════════════════════════════════════════════════════
// 10 WORLD FESTIVAL DEFINITIONS — sorted by month/day
// ═══════════════════════════════════════════════════════════════════════════════

const List<WorldFestivalVisualStyle> worldFestivals = [
  // ──────────────────────────────────────────────────────
  // 🎆 Jan 1 — New Year's Day  ·  "Midnight Bloom"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'new_year',
    themeName: "New Year's Day",
    label: "New Year's Day",
    subtitle: 'JAN 01 · WORLDWIDE',
    bannerIcon: '✦',
    cornerIcon: '🥂',
    watermarkIcon: '26',
    bannerTitle: '✦ NEW YEAR ✦',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0A0E27),
    primaryEnd: Color(0xFF7B2FFF),
    accent1: Color(0xFFF5D67B), // Champagne Gold
    accent2: Color(0xFFE8E8F0), // Platinum Silver
    glowColor: Color(0xFFFF6FD8), // Iridescent confetti
    phaseUpColor: Color(0xFFE8E8F0), // Platinum silver
    phaseDownColor: Color(0xFFB76E79), // Rose gold
    phaseHoldColor: Color(0xFF0A0E27), // Deep navy
    ringGradient: [
      Color(0xFF7B2FFF), // Electric violet
      Color(0xFFF5D67B), // Champagne gold
      Color(0xFFE8E8F0), // Platinum silver
      Color(0xFF7B2FFF),
    ],
    outerRingWidthAt100: 7.4,
    accuracyBarGradient: [
      Color(0xFF0A0E27), // Midnight blue
      Color(0xFF7B2FFF), // Violet
      Color(0xFFF5D67B), // Gold
    ],
    accuracyLowColor: Color(0xFF8B0000), // Deep crimson
    accuracyMidColor: Color(0xFF7B2FFF), // Violet
    accuracyHighColor: Color(0xFFF5D67B), // Champagne gold
    thresholdLineColor: Color(0xFFF5D67B),
  ),

  // ──────────────────────────────────────────────────────
  // 🧊 Jan 5 — Harbin Ice Festival  ·  "Arctic Crystal Palace"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'harbin_ice',
    themeName: 'Harbin Ice Festival',
    label: 'Harbin Ice Festival',
    subtitle: 'JAN 05 · HARBIN, CHINA',
    bannerIcon: '❄',
    cornerIcon: '🧊',
    watermarkIcon: '❆',
    bannerTitle: '❄ HARBIN ICE FESTIVAL ❄',
    month: 1,
    day: 5,
    primaryStart: Color(0xFFF0F8FF), // Arctic White
    primaryEnd: Color(0xFF00B4D8), // Ice Blue
    accent1: Color(0xFF7DF9FF), // Crystal Cyan
    accent2: Color(0xFFB39DDB), // Frozen Lavender
    glowColor: Color(0xFF00FFFF), // Bioluminescent cyan
    phaseUpColor: Color(0xFF00B4D8), // Ice blue
    phaseDownColor: Color(0xFFB39DDB), // Frozen lavender
    phaseHoldColor: Color(0xFFF0F8FF), // Arctic white
    ringGradient: [
      Color(0xFFF0F8FF), // White
      Color(0xFF00B4D8), // Cyan
      Color(0xFF0D1B2A), // Deep blue
      Color(0xFFF0F8FF),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF0D1B2A), // Deep navy
      Color(0xFF00B4D8), // Ice blue
      Color(0xFFF0F8FF), // Crystal white
    ],
    accuracyLowColor: Color(0xFF708090), // Icy grey
    accuracyMidColor: Color(0xFF00B4D8), // Frozen cyan
    accuracyHighColor: Color(0xFFF0F8FF), // Crystal white
    thresholdLineColor: Color(0xFFF0F8FF),
  ),

  // ──────────────────────────────────────────────────────
  // 🎾 Jan 12 — Australian Open  ·  "Melbourne Court Prestige"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'australian_open',
    themeName: 'Australian Open',
    label: 'Australian Open',
    subtitle: 'JAN 12 · MELBOURNE PARK',
    bannerIcon: '🎾',
    cornerIcon: '🏆',
    watermarkIcon: 'AO',
    bannerTitle: 'AUSTRALIAN OPEN',
    month: 1,
    day: 12,
    primaryStart: Color(0xFF0033A0), // Melbourne Blue
    primaryEnd: Color(0xFF001F5B), // Navy
    accent1: Color(0xFFFFD700), // Championship Gold
    accent2: Color(0xFFFFFFFF), // Bright White
    glowColor: Color(0xFFC8FF00), // Electric lime
    phaseUpColor: Color(0xFFC8FF00), // Electric lime
    phaseDownColor: Color(0xFF0033A0), // Royal blue
    phaseHoldColor: Color(0xFFFFD700), // Championship gold
    ringGradient: [
      Color(0xFF0033A0), // Melbourne Blue
      Color(0xFFFFD700), // Championship gold
      Color(0xFF001F5B), // Navy
      Color(0xFF0033A0),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF001F5B), // Navy
      Color(0xFF0033A0), // Court blue
      Color(0xFFC8FF00), // Electric lime
    ],
    accuracyLowColor: Color(0xFFCC0000), // Fault red
    accuracyMidColor: Color(0xFF0033A0), // Court blue
    accuracyHighColor: Color(0xFFFFD700), // Championship gold
    thresholdLineColor: Color(0xFFFFFFFF),
  ),

  // ──────────────────────────────────────────────────────
  // 🎬 Jan 22 — Sundance Film Festival  ·  "Sundance Indie Gold"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'sundance',
    themeName: 'Sundance Film Festival',
    label: 'Sundance Film Festival',
    subtitle: 'JAN 22 · PARK CITY, UTAH',
    bannerIcon: '🎬',
    cornerIcon: '🎞',
    watermarkIcon: 'S',
    bannerTitle: '✦ SUNDANCE',
    month: 1,
    day: 22,
    primaryStart: Color(0xFF8B1A1A), // Sundance Crimson
    primaryEnd: Color(0xFFCC5500), // Burnt Sienna
    accent1: Color(0xFFE8B84B), // Warm Gold
    accent2: Color(0xFFC0C0C0), // Film Reel Silver
    glowColor: Color(0xFFE8B84B),
    phaseUpColor: Color(0xFFE8B84B), // Warm gold
    phaseDownColor: Color(0xFF4A6FA5), // Slate blue
    phaseHoldColor: Color(0xFFF5E6CA), // Parchment white
    ringGradient: [
      Color(0xFF8B1A1A), // Crimson
      Color(0xFFCC5500), // Burnt sienna
      Color(0xFFE8B84B), // Warm gold
      Color(0xFF8B1A1A),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF8B1A1A), // Crimson
      Color(0xFFCC5500), // Burnt sienna
      Color(0xFFE8B84B), // Warm gold
    ],
    accuracyLowColor: Color(0xFF3D0000), // Underexposed dark
    accuracyMidColor: Color(0xFFCC5500), // Film sienna
    accuracyHighColor: Color(0xFFE8B84B), // Projector gold
    thresholdLineColor: Color(0xFFFFFFFF),
  ),

  // ──────────────────────────────────────────────────────
  // 🎭 Jan 31 — Venice Carnival  ·  "Venetian Masquerade Luxe"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'venice_carnival',
    themeName: 'Venice Carnival',
    label: 'Venice Carnival',
    subtitle: 'JAN 31 · VENEZIA, ITALIA',
    bannerIcon: '🎭',
    cornerIcon: '⚜',
    watermarkIcon: 'V',
    bannerTitle: 'VENICE CARNIVAL',
    month: 1,
    day: 31,
    primaryStart: Color(0xFF2D0057), // Venetian Deep Purple
    primaryEnd: Color(0xFF003D3D), // Midnight Teal
    accent1: Color(0xFFC9A84C), // Rich Baroque Gold
    accent2: Color(0xFFB76E79), // Rose Gold
    glowColor: Color(0xFFC9A84C),
    phaseUpColor: Color(0xFFC9A84C), // Baroque gold
    phaseDownColor: Color(0xFF8B0000), // Ruby red
    phaseHoldColor: Color(0xFF0F3460), // Sapphire blue
    ringGradient: [
      Color(0xFF2D0057), // Deep purple
      Color(0xFFC9A84C), // Baroque gold
      Color(0xFFB76E79), // Rose gold
      Color(0xFF2D0057),
    ],
    outerRingWidthAt100: 8.0,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF2D0057), // Purple
      Color(0xFF003D3D), // Teal
      Color(0xFFC9A84C), // Baroque gold
    ],
    accuracyLowColor: Color(0xFF4A0060), // Dark amethyst
    accuracyMidColor: Color(0xFF003D3D), // Venetian teal
    accuracyHighColor: Color(0xFFC9A84C), // Baroque gold
    thresholdLineColor: Color(0xFFF0EAD6), // Pearl white
  ),

  // ──────────────────────────────────────────────────────
  // ❄️ Feb 4 — Sapporo Snow Festival  ·  "Sapporo Yuki Matsuri"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'sapporo_snow',
    themeName: 'Sapporo Snow Festival',
    label: 'Sapporo Snow Festival',
    subtitle: 'FEB 04 · SAPPORO, HOKKAIDO',
    bannerIcon: '❄',
    cornerIcon: '🏔',
    watermarkIcon: '⛄',
    bannerTitle: '雪まつり · SAPPORO SNOW FESTIVAL',
    month: 2,
    day: 4,
    primaryStart: Color(0xFF1B3A6B), // Japanese Indigo
    primaryEnd: Color(0xFFF8F9FF), // Snow White
    accent1: Color(0xFFF2A900), // Warm Lantern Gold
    accent2: Color(0xFFFFB7C5), // Soft Sakura
    glowColor: Color(0xFFA8D8EA), // Crystal Blue
    phaseUpColor: Color(0xFFA8D8EA), // Crystal ice blue
    phaseDownColor: Color(0xFFF2A900), // Lantern gold
    phaseHoldColor: Color(0xFFFFB7C5), // Sakura pink
    ringGradient: [
      Color(0xFF1B3A6B), // Indigo
      Color(0xFFA8D8EA), // Crystal blue
      Color(0xFFF8F9FF), // Moonlight white
      Color(0xFF1B3A6B),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF1B3A6B), // Indigo
      Color(0xFFA8D8EA), // Crystal blue
      Color(0xFFF8F9FF), // White
    ],
    accuracyLowColor: Color(0xFF9BA7B3), // Cool grey
    accuracyMidColor: Color(0xFFA8D8EA), // Ice blue
    accuracyHighColor: Color(0xFFF8F9FF), // Snow white
    thresholdLineColor: Color(0xFFF2A900), // Warm gold
  ),

  // ──────────────────────────────────────────────────────
  // 🏈 Feb 8 — Super Bowl Sunday  ·  "Championship Sunday"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'super_bowl',
    themeName: 'Super Bowl Sunday',
    label: 'Super Bowl Sunday',
    subtitle: 'FEB 08 · USA NATIONWIDE',
    bannerIcon: '🏈',
    cornerIcon: '🏟',
    watermarkIcon: 'LXI',
    bannerTitle: 'SUPER BOWL SUNDAY',
    month: 2,
    day: 8,
    primaryStart: Color(0xFF003087), // NFL Championship Navy
    primaryEnd: Color(0xFFB19557), // Super Bowl Gold
    accent1: Color(0xFFFFD700), // Gold
    accent2: Color(0xFFA8AAAB), // Lombardi Trophy Silver
    glowColor: Color(0xFFB19557),
    phaseUpColor: Color(0xFFFFD700), // Championship gold
    phaseDownColor: Color(0xFFCC0000), // Scarlet
    phaseHoldColor: Color(0xFFA8AAAB), // Silver
    ringGradient: [
      Color(0xFF003087), // Navy
      Color(0xFFB19557), // Gold
      Color(0xFFA8AAAB), // Silver
      Color(0xFF003087),
    ],
    outerRingWidthAt100: 7.6,
    accuracyBarGradient: [
      Color(0xFF003087), // Navy
      Color(0xFFCC0000), // Scarlet
      Color(0xFFFFD700), // Championship gold
    ],
    accuracyLowColor: Color(0xFFCC0000), // Penalty red
    accuracyMidColor: Color(0xFF4A6FA5), // Steel blue
    accuracyHighColor: Color(0xFFFFD700), // Trophy gold
    thresholdLineColor: Color(0xFFFFFFFF),
  ),

  // ──────────────────────────────────────────────────────
  // 🎬 Feb 12 — Berlinale Film Festival  ·  "Berlin Golden Bear"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'berlinale',
    themeName: 'Berlinale Film Festival',
    label: 'Berlinale Film Festival',
    subtitle: 'FEB 12 · BERLIN, GERMANY',
    bannerIcon: '🎬',
    cornerIcon: '🐻',
    watermarkIcon: 'B',
    bannerTitle: 'BERLINALE',
    month: 2,
    day: 12,
    primaryStart: Color(0xFFCC0000), // Berlin Red
    primaryEnd: Color(0xFF2B2B2B), // Charcoal
    accent1: Color(0xFFC5A028), // Berlinale Gold
    accent2: Color(0xFFE8E8E8), // Platinum Silver
    glowColor: Color(0xFFC5A028),
    phaseUpColor: Color(0xFFC5A028), // Berlinale gold
    phaseDownColor: Color(0xFFCC0000), // Berlin red
    phaseHoldColor: Color(0xFF4A6FA5), // Steel blue
    ringGradient: [
      Color(0xFFCC0000), // Berlin red
      Color(0xFF2B2B2B), // Charcoal
      Color(0xFFC5A028), // Berlinale gold
      Color(0xFFCC0000),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF2B2B2B), // Charcoal
      Color(0xFFCC0000), // Berlin red
      Color(0xFFC5A028), // Berlinale gold
    ],
    accuracyLowColor: Color(0xFF708090), // Cold grey
    accuracyMidColor: Color(0xFFCC0000), // Berlin red
    accuracyHighColor: Color(0xFFC5A028), // Berlinale gold
    thresholdLineColor: Color(0xFFE8E8E8), // Platinum white
  ),

  // ──────────────────────────────────────────────────────
  // 🌺 Feb 15 — Rio Carnival  ·  "Rio Sambadrome Royale"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'rio_carnival',
    themeName: 'Rio Carnival',
    label: 'Rio Carnival',
    subtitle: 'FEB 15 · RIO DE JANEIRO, BRASIL',
    bannerIcon: '🌺',
    cornerIcon: '🪶',
    watermarkIcon: '♫',
    bannerTitle: 'RIO CARNIVAL',
    month: 2,
    day: 15,
    primaryStart: Color(0xFF009C3B), // Brazil Green
    primaryEnd: Color(0xFFFFDF00), // Tropical Gold
    accent1: Color(0xFFFF1493), // Hot Magenta
    accent2: Color(0xFF00CED1), // Turquoise
    glowColor: Color(0xFFFF6B00), // Flame Orange
    phaseUpColor: Color(0xFFFFDF00), // Tropical gold
    phaseDownColor: Color(0xFFCC0000), // Samba red
    phaseHoldColor: Color(0xFF002776), // Electric blue
    ringGradient: [
      Color(0xFFCC0000), // Samba red
      Color(0xFFFFDF00), // Carnival gold
      Color(0xFF009C3B), // Brazil green
      Color(0xFF002776), // Electric blue
      Color(0xFFCC0000),
    ],
    outerRingWidthAt100: 7.8,
    accuracyBarGradient: [
      Color(0xFFCC0000), // Red
      Color(0xFFFF6B00), // Orange
      Color(0xFFFFDF00), // Gold
      Color(0xFF009C3B), // Green
      Color(0xFF002776), // Blue
    ],
    accuracyLowColor: Color(0xFF708090), // Dull grey
    accuracyMidColor: Color(0xFFFF6B00), // Carnival mix
    accuracyHighColor: Color(0xFFFFDF00), // Full rainbow gold
    thresholdLineColor: Color(0xFFFFFFFF),
  ),

  // ──────────────────────────────────────────────────────
  // 🏎️ Feb 22 — Daytona 500  ·  "Daytona Speed Royale"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'daytona_500',
    themeName: 'Daytona 500',
    label: 'Daytona 500',
    subtitle: 'FEB 22 · DAYTONA BEACH, FLORIDA',
    bannerIcon: '🏎',
    cornerIcon: '🏁',
    watermarkIcon: '500',
    bannerTitle: 'DAYTONA 500',
    month: 2,
    day: 22,
    primaryStart: Color(0xFF0D0D0D), // Racing Black
    primaryEnd: Color(0xFFF5F5F5), // Checkered White
    accent1: Color(0xFFD4AF37), // Daytona Gold
    accent2: Color(0xFFAAB7B8), // Chrome Silver
    glowColor: Color(0xFFFF6600), // Velocity Orange
    phaseUpColor: Color(0xFFCC0000), // Racing red
    phaseDownColor: Color(0xFFFF6600), // Velocity orange
    phaseHoldColor: Color(0xFFAAB7B8), // Chrome silver
    ringGradient: [
      Color(0xFF0D0D0D), // Black
      Color(0xFFFF6600), // Velocity orange
      Color(0xFFAAB7B8), // Chrome silver
      Color(0xFF0D0D0D),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF0D0D0D), // Black
      Color(0xFFCC0000), // Red
      Color(0xFFFF6600), // Orange
      Color(0xFFAAB7B8), // Chrome
    ],
    accuracyLowColor: Color(0xFFCCCC00), // Pit stop yellow
    accuracyMidColor: Color(0xFFCC0000), // Racing red
    accuracyHighColor: Color(0xFFAAB7B8), // Chrome silver
    thresholdLineColor: Color(0xFFAAB7B8),
  ),
  // ──────────────────────────────────────────────────────
  // 🏃 Mar 01 — Tokyo Marathon  ·  "Neon Samurai Sprint"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'tokyo_marathon',
    themeName: 'Tokyo Marathon',
    label: 'Tokyo Marathon',
    subtitle: 'MAR 01 · TOKYO, JAPAN',
    bannerIcon: '⛩',
    cornerIcon: '🎌',
    watermarkIcon: '頑張れ',
    bannerTitle: '東京マラソン · TOKYO MARATHON',
    month: 3,
    day: 1,
    primaryStart: Color(0xFF0A1628), // Midnight Tokyo
    primaryEnd: Color(0xFF00B4FF), // Electric Neon Blue
    accent1: Color(0xFFC8A96E), // Championship Gold
    accent2: Color(0xFFF0F8FF), // Titanium White
    glowColor: Color(0xFF39FF14), // Cyber Lime
    phaseUpColor: Color(0xFF00B4FF), // Neon blue
    phaseDownColor: Color(0xFFFFB7C5), // Sakura pink
    phaseHoldColor: Color(0xFF39FF14), // Cyber lime
    ringGradient: [
      Color(0xFF0A1628), // Deep navy
      Color(0xFF00B4FF), // Neon blue
      Color(0xFFFFB7C5), // Sakura
      Color(0xFF0A1628),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF0A1628), // Deep navy
      Color(0xFF00B4FF), // Electric blue
      Color(0xFF00FFFF), // Neon cyan
    ],
    accuracyLowColor: Color(0xFF3A4A5A), // Muted steel
    accuracyMidColor: Color(0xFF00B4FF), // Electric blue
    accuracyHighColor: Color(0xFF00FFFF), // Neon cyan blast
    thresholdLineColor: Color(0xFFF0F8FF),
  ),

  // ──────────────────────────────────────────────────────
  // 🏆 Mar 08 — The Oscars  ·  "Hollywood Golden Noir"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'the_oscars',
    themeName: 'The Oscars',
    label: 'The Oscars',
    subtitle: 'MAR 08 · DOLBY THEATRE, HOLLYWOOD',
    bannerIcon: '✧',
    cornerIcon: '🎖',
    watermarkIcon: 'A',
    bannerTitle: '✦ ACADEMY AWARDS ✦',
    month: 3,
    day: 8,
    primaryStart: Color(0xFF0D0D0D), // Oscar Noir
    primaryEnd: Color(0xFF1A0A2A), // Deep Velvet
    accent1: Color(0xFFC8A96E), // Oscar Gold
    accent2: Color(0xFFFFF8F0), // Pearl White
    glowColor: Color(0xFFF5E6CA), // Champagne
    phaseUpColor: Color(0xFFC8A96E), // Oscar gold
    phaseDownColor: Color(0xFF8B0000), // Ruby red
    phaseHoldColor: Color(0xFFFFF8F0), // Pearl white
    ringGradient: [
      Color(0xFF0D0D0D), // Velvet black
      Color(0xFFC8A96E), // Oscar gold
      Color(0xFFE8E8D0), // Warm platinum
      Color(0xFF0D0D0D),
    ],
    outerRingWidthAt100: 7.5,
    accuracyBarGradient: [
      Color(0xFF0D0D0D), // Noir black
      Color(0xFF1A0A2A), // Deep velvet
      Color(0xFFC8A96E), // Oscar gold
      Color(0xFFF5E6CA), // Champagne
    ],
    accuracyLowColor: Color(0xFF1A0A2A), // Underexposed velvet
    accuracyMidColor: Color(0xFF2B2B2B), // Film slate gray
    accuracyHighColor: Color(0xFFC8A96E), // Full gold
    thresholdLineColor: Color(0xFFFFFFFF), // Projector-white beam
  ),

  // ──────────────────────────────────────────────────────
  // 💻 Mar 13 — SXSW Festival  ·  "Digital Frontier Neon"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'sxsw',
    themeName: 'SXSW Festival',
    label: 'SXSW Festival',
    subtitle: 'MAR 13 · AUSTIN, TEXAS',
    bannerIcon: '⎋',
    cornerIcon: '★',
    watermarkIcon: '{ }',
    bannerTitle: 'SXSW · SOUTH BY SOUTHWEST',
    month: 3,
    day: 13,
    primaryStart: Color(0xFF0D0D2B), // Deep Space
    primaryEnd: Color(0xFF7C3AED), // Electric Violet
    accent1: Color(0xFF34D399), // Neon Green
    accent2: Color(0xFF00CED1), // Code Cyan
    glowColor: Color(0xFFF59E0B), // Amber Stage
    phaseUpColor: Color(0xFF34D399), // Neon green
    phaseDownColor: Color(0xFF7C3AED), // Electric violet
    phaseHoldColor: Color(0xFFF59E0B), // Amber
    ringGradient: [
      Color(0xFF0D0D2B), // Deep space navy
      Color(0xFF7C3AED), // Electric violet
      Color(0xFF34D399), // Neon green
      Color(0xFF0D0D2B),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF0D0D2B), // Dark space
      Color(0xFF7C3AED), // Violet
      Color(0xFF34D399), // Neon green
    ],
    accuracyLowColor: Color(0xFFCC2200), // Error red
    accuracyMidColor: Color(0xFF7C3AED), // Loading violet
    accuracyHighColor: Color(0xFF34D399), // Success green
    thresholdLineColor: Color(0xFF34D399),
  ),

  // ──────────────────────────────────────────────────────
  // 🔥 Mar 19 — Las Fallas  ·  "Valencia Inferno Royale"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'las_fallas',
    themeName: 'Las Fallas',
    label: 'Las Fallas',
    subtitle: 'MAR 19 · VALÈNCIA, ESPAÑA',
    bannerIcon: '🔥',
    cornerIcon: '🧨',
    watermarkIcon: '🎇',
    bannerTitle: 'LAS FALLAS',
    month: 3,
    day: 19,
    primaryStart: Color(0xFFCC1100), // Ember Deep
    primaryEnd: Color(0xFFFF3300), // Inferno Core
    accent1: Color(0xFFFFB700), // Amber Glow
    accent2: Color(0xFFFFF5E0), // Ash White
    glowColor: Color(0xFFFF6600), // Fire Orange
    phaseUpColor: Color(0xFFFF6600), // Flame orange
    phaseDownColor: Color(0xFFCC1100), // Ember red
    phaseHoldColor: Color(0xFFFFB700), // Amber glow
    ringGradient: [
      Color(0xFFCC1100), // Ember deep
      Color(0xFFFF6600), // Fire orange
      Color(0xFFFFB700), // Amber glow
      Color(0xFFFFF5E0), // Ash white
      Color(0xFFCC1100),
    ],
    outerRingWidthAt100: 7.4,
    accuracyBarGradient: [
      Color(0xFF3D3D3D), // Dark ash
      Color(0xFFCC1100), // Ember red
      Color(0xFFFF6600), // Flame orange
      Color(0xFFFFB700), // Amber gold
    ],
    accuracyLowColor: Color(0xFF3D3D3D), // Cold ash grey
    accuracyMidColor: Color(0xFFCC1100), // Smoldering ember
    accuracyHighColor: Color(0xFFFF6600), // Full flame
    thresholdLineColor: Color(0xFFFFF5E0), // Ash-white incandescent
  ),

  // ──────────────────────────────────────────────────────
  // 😊 Mar 20 — International Day of Happiness  ·  "Golden Joy Bloom"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'happiness_day',
    themeName: 'International Day of Happiness',
    label: 'International Day of Happiness',
    subtitle: 'MAR 20 · WORLDWIDE — UN INT. DAY',
    bannerIcon: '☀',
    cornerIcon: '😊',
    watermarkIcon: '✿',
    bannerTitle: 'WORLD HAPPINESS DAY',
    month: 3,
    day: 20,
    primaryStart: Color(0xFFFF9500), // Warm Amber
    primaryEnd: Color(0xFFFFD700), // Sunshine Gold
    accent1: Color(0xFFFFFDE7), // Cream White
    accent2: Color(0xFF87CEEB), // Sky Blue
    glowColor: Color(0xFFFFB7C5), // Petal Pink
    phaseUpColor: Color(0xFFFFD700), // Sunshine gold
    phaseDownColor: Color(0xFFFFB7C5), // Petal pink
    phaseHoldColor: Color(0xFF87CEEB), // Sky blue
    ringGradient: [
      Color(0xFF1A1000), // Deep warmth
      Color(0xFFFF9500), // Amber
      Color(0xFFFFD700), // Sunshine gold
      Color(0xFFFFFDE7), // Cream white
      Color(0xFF1A1000),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFFFF9500), // Warm amber
      Color(0xFFFFD700), // Sunshine gold
      Color(0xFFFFFDE7), // Cream white
    ],
    accuracyLowColor: Color(0xFFB0BEC5), // Soft grey-blue
    accuracyMidColor: Color(0xFFFF9500), // Warm amber
    accuracyHighColor: Color(0xFFFFD700), // Full sunshine bloom
    thresholdLineColor: Color(0xFFFFFF00), // Glowing sunshine yellow
  ),

  // ──────────────────────────────────────────────────────
  // 🌸 Mar 25 — Hanami Festival  ·  "Sakura Twilight Luxe"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'hanami',
    themeName: 'Hanami Festival',
    label: 'Hanami Festival',
    subtitle: 'MAR 25 · JAPAN — SAKURA SEASON',
    bannerIcon: '❀',
    cornerIcon: '🌸',
    watermarkIcon: '春',
    bannerTitle: '花見 · HANAMI',
    month: 3,
    day: 25,
    primaryStart: Color(0xFF4A1A6B), // Twilight Purple
    primaryEnd: Color(0xFF7B3F8A), // Dusk Mauve
    accent1: Color(0xFFFFB7C5), // Blossom Pink
    accent2: Color(0xFFFFF8EE), // Ivory Moonlight
    glowColor: Color(0xFFE8789A), // Deep Petal
    phaseUpColor: Color(0xFFFFB7C5), // Sakura pink
    phaseDownColor: Color(0xFF4A1A6B), // Twilight purple
    phaseHoldColor: Color(0xFFFFF8EE), // Ivory moonlight
    ringGradient: [
      Color(0xFF2C1810), // Sumi ink
      Color(0xFF4A1A6B), // Twilight purple
      Color(0xFFFFB7C5), // Blossom Pink
      Color(0xFFFFF0F5), // Petal white
      Color(0xFF2C1810),
    ],
    outerRingWidthAt100: 6.8,
    accuracyBarGradient: [
      Color(0xFF4A1A6B), // Twilight purple
      Color(0xFF7B3F8A), // Dusk mauve
      Color(0xFFFFB7C5), // Blossom pink
      Color(0xFFFFF0F5), // Petal white
    ],
    accuracyLowColor: Color(0xFF6B5A5A), // Bare branch grey
    accuracyMidColor: Color(0xFFFFB7C5), // First bloom pink
    accuracyHighColor: Color(0xFFFFF0F5), // Full sakura peak
    thresholdLineColor: Color(0xFFFFF8EE), // Moonlight ivory glow
  ),

  // ──────────────────────────────────────────────────────
  // 🃏 Apr 01 — April Fools' Day  ·  "Jester's Gold Masquerade"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'april_fools',
    themeName: 'April Fools\' Day',
    label: 'April Fools\' Day',
    subtitle: 'APR 01 · WORLDWIDE',
    bannerIcon: '♦',
    cornerIcon: '🃏',
    watermarkIcon: '?',
    bannerTitle: 'APRIL FOOLS\'',
    month: 4,
    day: 1,
    primaryStart: Color(0xFF1A1A1A), // Jester Black
    primaryEnd: Color(0xFFF59E0B), // Gold
    accent1: Color(0xFF7C3AED), // Royal Purple
    accent2: Color(0xFFCC2200), // Scarlet
    glowColor: Color(0xFFFBBF24), // Electric Yellow
    phaseUpColor: Color(0xFFF59E0B), // Gold
    phaseDownColor: Color(0xFFCC2200), // Scarlet
    phaseHoldColor: Color(0xFFFFFFFF), // White
    ringGradient: [
      Color(0xFFF59E0B), // Gold
      Color(0xFF7C3AED), // Purple
      Color(0xFFCC2200), // Scarlet
      Color(0xFF1A1A1A), // Black
      Color(0xFFF59E0B),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF1A1A1A), // Black
      Color(0xFF7C3AED), // Purple
      Color(0xFFF59E0B), // Gold
    ],
    accuracyLowColor: Color(0xFFCC2200), // Scarlet
    accuracyMidColor: Color(0xFF7C3AED), // Purple
    accuracyHighColor: Color(0xFFF59E0B), // Gold
    thresholdLineColor: Color(0xFFFFFFFF), // White
  ),

  // ──────────────────────────────────────────────────────
  // 🎵 Apr 11 — Coachella Music Festival  ·  "Desert Mirage Luxe"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'coachella',
    themeName: 'Coachella Music Festival',
    label: 'Coachella Music Festival',
    subtitle: 'APR 11 · EMPIRE POLO CLUB, INDIO CA',
    bannerIcon: '🌴',
    cornerIcon: '🎡',
    watermarkIcon: '☼',
    bannerTitle: 'COACHELLA',
    month: 4,
    day: 11,
    primaryStart: Color(0xFFC8A96E), // Desert Dusk
    primaryEnd: Color(0xFFCC5500), // Terracotta
    accent1: Color(0xFFD4A5A5), // Dusty Rose
    accent2: Color(0xFF7A9E7E), // Sage Green
    glowColor: Color(0xFFFFDAB9), // Warm Peach
    phaseUpColor: Color(0xFFFFDAB9), // Golden hour peach
    phaseDownColor: Color(0xFFCC5500), // Terracotta
    phaseHoldColor: Color(0xFF7A9E7E), // Sage green
    ringGradient: [
      Color(0xFF0D0A2B), // Midnight indigo
      Color(0xFFCC5500), // Terracotta
      Color(0xFFC8A96E), // Desert gold
      Color(0xFFFFDAB9), // Peach
      Color(0xFF0D0A2B),
    ],
    outerRingWidthAt100: 7.6,
    accuracyBarGradient: [
      Color(0xFF0D0A2B), // Indigo night
      Color(0xFFCC5500), // Terracotta
      Color(0xFFFFDAB9), // Golden hour peach
    ],
    accuracyLowColor: Color(0xFF8B8B8B), // Desert dust grey
    accuracyMidColor: Color(0xFFCC5500), // Terracotta warmth
    accuracyHighColor: Color(0xFFFFDAB9), // Golden hour peak
    thresholdLineColor: Color(0xFFFFF5EE), // Golden sunlight beam
  ),

  // ──────────────────────────────────────────────────────
  // 🏃 Apr 20 — Boston Marathon  ·  "Patriots' Prestige Run"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'boston_marathon',
    themeName: 'Boston Marathon',
    label: 'Boston Marathon',
    subtitle: 'APR 20 · HOPKINTON → BOSTON, MA',
    bannerIcon: '🦄',
    cornerIcon: '🥇',
    watermarkIcon: '26.2',
    bannerTitle: 'BOSTON MARATHON',
    month: 4,
    day: 20,
    primaryStart: Color(0xFF041E42), // Boston Blue
    primaryEnd: Color(0xFF003087), // Patriot Navy
    accent1: Color(0xFFC8A96E), // Championship Gold
    accent2: Color(0xFF2D7A3A), // Laurel Green
    glowColor: Color(0xFFFFFFFF), // Pure White
    phaseUpColor: Color(0xFFC8A96E), // Championship gold
    phaseDownColor: Color(0xFF003087), // Patriot navy
    phaseHoldColor: Color(0xFF2D7A3A), // Laurel green
    ringGradient: [
      Color(0xFF003087), // Patriot navy
      Color(0xFFC8A96E), // Championship gold
      Color(0xFFF5F0E0), // Colonial cream
      Color(0xFF003087),
    ],
    outerRingWidthAt100: 7.5,
    accuracyBarGradient: [
      Color(0xFFF5F0E0), // Colonial cream
      Color(0xFF2D7A3A), // Laurel green
      Color(0xFFC8A96E), // Championship gold
    ],
    accuracyLowColor: Color(0xFF4A5568), // Endurance grey
    accuracyMidColor: Color(0xFF003087), // Patriot blue
    accuracyHighColor: Color(0xFFC8A96E), // Gold finish
    thresholdLineColor: Color(0xFFFFFFFF), // Finish tape white
  ),

  // ──────────────────────────────────────────────────────
  // 🌍 Apr 22 — Earth Day  ·  "Terra Verde Luxe"
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'earth_day',
    themeName: 'Earth Day',
    label: 'Earth Day',
    subtitle: 'APR 22 · WORLDWIDE — EST. 1970',
    bannerIcon: '🌎',
    cornerIcon: '🌱',
    watermarkIcon: '♼',
    bannerTitle: 'EARTH DAY',
    month: 4,
    day: 22,
    primaryStart: Color(0xFF0A2D0A), // Forest Deep
    primaryEnd: Color(0xFF2D8F2D), // Terra Green
    accent1: Color(0xFF6ECF84), // Leaf Green
    accent2: Color(0xFF0F6E56), // Teal
    glowColor: Color(0xFFF0FFF0), // Bloom White
    phaseUpColor: Color(0xFF6ECF84), // Leaf green
    phaseDownColor: Color(0xFF1A4A7A), // Pacific blue
    phaseHoldColor: Color(0xFF8B4513), // Earth clay
    ringGradient: [
      Color(0xFF0A2D0A), // Forest deep
      Color(0xFF2D8F2D), // Terra green
      Color(0xFF6ECF84), // Leaf bright
      Color(0xFFF0F8FF), // Glacier white
      Color(0xFF0A2D0A),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF0A2D0A), // Deep forest
      Color(0xFF4A7A2A), // Moss
      Color(0xFF2D8F2D), // Terra green
      Color(0xFF6ECF84), // Fresh leaf
    ],
    accuracyLowColor: Color(0xFF5C3D1E), // Barren soil brown
    accuracyMidColor: Color(0xFF4A7A2A), // Growing moss
    accuracyHighColor: Color(0xFF2D8F2D), // Full canopy green
    thresholdLineColor: Color(0xFFF0F8FF), // Glacier white
  ),
  // ──────────────────────────────────────────────────────
  // 🏃 Apr 26 — London Marathon
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'london_marathon',
    themeName: 'London Marathon',
    label: 'London Marathon',
    subtitle: 'APR 26 · LONDON, UK',
    bannerIcon: '🕰',
    cornerIcon: '🇬🇧',
    watermarkIcon: '26.2',
    bannerTitle: 'LONDON MARATHON',
    month: 4,
    day: 26,
    primaryStart: Color(0xFF0B1B3A), // Deep Navy
    primaryEnd: Color(0xFF1E63FF), // Marathon Blue
    accent1: Color(0xFFD62828), // London Red
    accent2: Color(0xFFC8A96E), // Union Gold
    glowColor: Color(0xFFF4F7FB), // Fog White
    phaseUpColor: Color(0xFF1E63FF), // Blue
    phaseDownColor: Color(0xFFD62828), // Red
    phaseHoldColor: Color(0xFFC8A96E), // Gold
    ringGradient: [
      Color(0xFF0B1B3A), // Navy
      Color(0xFF1E63FF), // Marathon blue
      Color(0xFFD62828), // Red highlight
      Color(0xFF0B1B3A),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF0B1B3A), // Navy
      Color(0xFF1E63FF), // Blue
      Color(0xFF00FFFF), // Cyan
    ],
    accuracyLowColor: Color(0xFF2D3642), // Asphalt gray
    accuracyMidColor: Color(0xFF1E63FF), // Marathon blue
    accuracyHighColor: Color(0xFF00FFFF), // Bright cyan
    thresholdLineColor: Color(0xFFFFFFFF), // Finish line white
  ),

  // ──────────────────────────────────────────────────────
  // 💃 Apr 29 — International Dance Day
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'dance_day',
    themeName: 'International Dance Day',
    label: 'International Dance Day',
    subtitle: 'APR 29 · GLOBAL CELEBRATION',
    bannerIcon: '✨',
    cornerIcon: '💃',
    watermarkIcon: '♪',
    bannerTitle: 'INTERNATIONAL DANCE DAY',
    month: 4,
    day: 29,
    primaryStart: Color(0xFF120A2A), // Midnight Violet
    primaryEnd: Color(0xFFFF3DF2), // Electric Magenta
    accent1: Color(0xFF00D7FF), // Neon Cyan
    accent2: Color(0xFFFFD56A), // Spotlight Gold
    glowColor: Color(0xFFF7F7FF), // Soft White
    phaseUpColor: Color(0xFF00D7FF), // Cyan
    phaseDownColor: Color(0xFFFF3DF2), // Magenta
    phaseHoldColor: Color(0xFFFFD56A), // Gold
    ringGradient: [
      Color(0xFF120A2A), // Violet
      Color(0xFFFF3DF2), // Magenta
      Color(0xFF00D7FF), // Cyan
      Color(0xFF120A2A),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF120A2A), // Deep violet
      Color(0xFFFF3DF2), // Magenta
      Color(0xFF00D7FF), // Cyan
    ],
    accuracyLowColor: Color(0xFF4A3B65), // Muted purple-gray
    accuracyMidColor: Color(0xFFFF3DF2), // Magenta
    accuracyHighColor: Color(0xFF00D7FF), // Cyan flare
    thresholdLineColor: Color(0xFFFFFFFF), // Spotlight white
  ),

  // ──────────────────────────────────────────────────────
  // 👗 May 04 — The Met Gala
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'met_gala',
    themeName: 'The Met Gala',
    label: 'The Met Gala',
    subtitle: 'MAY 04 · NEW YORK, USA',
    bannerIcon: '✧',
    cornerIcon: '✨',
    watermarkIcon: 'M',
    bannerTitle: 'THE MET GALA',
    month: 5,
    day: 4,
    primaryStart: Color(0xFF07070B), // Black Velvet
    primaryEnd: Color(0xFFD8B46A), // Champagne Gold
    accent1: Color(0xFFF4F1EA), // Pearl White
    accent2: Color(0xFFB31237), // Ruby Accent
    glowColor: Color(0xFFFFF9F1), // Soft Ivory
    phaseUpColor: Color(0xFFD8B46A), // Gold
    phaseDownColor: Color(0xFFB31237), // Ruby
    phaseHoldColor: Color(0xFFF4F1EA), // Ivory
    ringGradient: [
      Color(0xFF07070B), // Black
      Color(0xFFD8B46A), // Champagne gold
      Color(0xFFF4F1EA), // Ivory
      Color(0xFF07070B),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF07070B), // Deep black
      Color(0xFFD8B46A), // Gold
      Color(0xFFF4F1EA), // Pearl
    ],
    accuracyLowColor: Color(0xFF22242B), // Charcoal / Smoke Gray
    accuracyMidColor: Color(0xFFD8B46A), // Gold
    accuracyHighColor: Color(0xFFF4F1EA), // Pearl flare
    thresholdLineColor: Color(0xFFFFF9F1), // Ivory
  ),

  // ──────────────────────────────────────────────────────
  // 🌵 May 05 — Cinco de Mayo
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'cinco_de_mayo',
    themeName: 'Cinco de Mayo',
    label: 'Cinco de Mayo',
    subtitle: 'MAY 05 · CULTURAL CELEBRATION',
    bannerIcon: '🎉',
    cornerIcon: '🌵',
    watermarkIcon: '🇲🇽',
    bannerTitle: 'CINCO DE MAYO',
    month: 5,
    day: 5,
    primaryStart: Color(0xFFD62828), // Fiesta Red
    primaryEnd: Color(0xFFFFB000), // Marigold
    accent1: Color(0xFF1D4ED8), // Cobalt Blue
    accent2: Color(0xFFA7F432), // Lime Accent
    glowColor: Color(0xFFFFF4E6), // Cream
    phaseUpColor: Color(0xFFD62828), // Red
    phaseDownColor: Color(0xFFFFB000), // Marigold
    phaseHoldColor: Color(0xFF1D4ED8), // Blue
    ringGradient: [
      Color(0xFF1C0F10), // Cocoa
      Color(0xFFD62828), // Red
      Color(0xFFFFB000), // Marigold
      Color(0xFF1C0F10),
    ],
    outerRingWidthAt100: 7.4,
    accuracyBarGradient: [
      Color(0xFF1C0F10), // Dark cocoa
      Color(0xFFD62828), // Red
      Color(0xFFFFB000), // Gold
    ],
    accuracyLowColor: Color(0xFF6A5F5E), // Muted brown-gray
    accuracyMidColor: Color(0xFFD62828), // Red
    accuracyHighColor: Color(0xFFFFB000), // Golden flare
    thresholdLineColor: Color(0xFFFFF4E6), // Cream-white
  ),

  // ──────────────────────────────────────────────────────
  // 🎬 May 13 — Cannes Film Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'cannes',
    themeName: 'Cannes Film Festival',
    label: 'Cannes Film Festival',
    subtitle: 'MAY 13 · CANNES, FRANCE',
    bannerIcon: '🌿',
    cornerIcon: '🌴',
    watermarkIcon: 'C',
    bannerTitle: 'CANNES FILM FESTIVAL',
    month: 5,
    day: 13,
    primaryStart: Color(0xFFB31217), // Cannes Red
    primaryEnd: Color(0xFFC9A66B), // Champagne Gold
    accent1: Color(0xFFF5F1E8), // Ivory White
    accent2: Color(0xFF0A0A0D), // Midnight Black
    glowColor: Color(0xFFFFF9F0), // Soft Pearl
    phaseUpColor: Color(0xFFB31217), // Red
    phaseDownColor: Color(0xFFC9A66B), // Gold
    phaseHoldColor: Color(0xFFF5F1E8), // Ivory
    ringGradient: [
      Color(0xFF0A0A0D), // Black
      Color(0xFFB31217), // Red
      Color(0xFFC9A66B), // Gold
      Color(0xFF0A0A0D),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF0A0A0D), // Black
      Color(0xFFB31217), // Red
      Color(0xFFC9A66B), // Gold
    ],
    accuracyLowColor: Color(0xFF2A2F3A), // Charcoal
    accuracyMidColor: Color(0xFFB31217), // Red
    accuracyHighColor: Color(0xFFC9A66B), // Gold spotlight
    thresholdLineColor: Color(0xFFF5F1E8), // Ivory
  ),

  // ──────────────────────────────────────────────────────
  // 🎤 May 16 — Eurovision Song Contest
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'eurovision',
    themeName: 'Eurovision Song Contest',
    label: 'Eurovision Song Contest',
    subtitle: 'MAY 16 · GRAND FINAL',
    bannerIcon: '★',
    cornerIcon: '💖',
    watermarkIcon: '🎤',
    bannerTitle: 'EUROVISION 2026',
    month: 5,
    day: 16,
    primaryStart: Color(0xFF06152F), // Midnight Blue
    primaryEnd: Color(0xFF7A3CFF), // Electric Purple
    accent1: Color(0xFFFF4FD8), // Neon Pink
    accent2: Color(0xFF00E5FF), // Cyan
    glowColor: Color(0xFFF7FBFF), // White Glow
    phaseUpColor: Color(0xFF00E5FF), // Cyan
    phaseDownColor: Color(0xFFFF4FD8), // Pink
    phaseHoldColor: Color(0xFF7A3CFF), // Purple
    ringGradient: [
      Color(0xFF06152F), // Navy
      Color(0xFF7A3CFF), // Purple
      Color(0xFFFF4FD8), // Pink
      Color(0xFF06152F),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF06152F), // Dark navy
      Color(0xFF7A3CFF), // Purple
      Color(0xFF00E5FF), // Cyan
    ],
    accuracyLowColor: Color(0xFF4B5675), // Slate blue
    accuracyMidColor: Color(0xFF7A3CFF), // Purple
    accuracyHighColor: Color(0xFF00E5FF), // Cyan blast
    thresholdLineColor: Color(0xFFFFFFFF), // Spotlight finish
  ),

  // ──────────────────────────────────────────────────────
  // 🎃 Oct 31 — Halloween
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'halloween',
    themeName: 'Halloween',
    label: 'Halloween',
    subtitle: 'OCT 31 · WORLDWIDE',
    bannerIcon: '🎃',
    cornerIcon: '👻',
    watermarkIcon: 'BOO',
    bannerTitle: 'HALLOWEEN',
    month: 10,
    day: 31,
    primaryStart: Color(0xFF2D1B69), // Midnight Purple
    primaryEnd: Color(0xFFFF6B35), // Pumpkin Orange
    accent1: Color(0xFF000000), // Spooky Black
    accent2: Color(0xFFFFFFFF), // Ghost White
    glowColor: Color(0xFFFFA500), // Lantern Glow
    phaseUpColor: Color(0xFFFF6B35), // Orange
    phaseDownColor: Color(0xFF2D1B69), // Purple
    phaseHoldColor: Color(0xFFFFFFFF), // White
    ringGradient: [
      Color(0xFF000000),
      Color(0xFFFF6B35),
      Color(0xFFFFFFFF),
      Color(0xFF000000),
    ],
    outerRingWidthAt100: 7.6,
    accuracyBarGradient: [
      Color(0xFF0A0A0A), // Haunted Dark
      Color(0xFF2D1B69),
      Color(0xFFFF6B35),
    ],
    accuracyLowColor: Color(0xFF3B2F2F), // Shadow Gray
    accuracyMidColor: Color(0xFF2D1B69),
    accuracyHighColor: Color(0xFFFF6B35),
    thresholdLineColor: Color(0xFFFFA500), // Pumpkin glow
  ),

  // ──────────────────────────────────────────────────────
  // 🦃 Nov 23 — Thanksgiving (USA)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'thanksgiving',
    themeName: 'Thanksgiving',
    label: 'Thanksgiving',
    subtitle: 'NOV 23 · UNITED STATES',
    bannerIcon: '🦃',
    cornerIcon: '🍁',
    watermarkIcon: 'TURKEY',
    bannerTitle: 'THANKSGIVING',
    month: 11,
    day: 23,
    primaryStart: Color(0xFF8B4513), // Autumn Brown
    primaryEnd: Color(0xFFFF8C00), // Harvest Orange
    accent1: Color(0xFFDC143C), // Cranberry Red
    accent2: Color(0xFFFFF8DC), // Cornsilk
    glowColor: Color(0xFFFFD700), // Golden
    phaseUpColor: Color(0xFFFF8C00), // Orange
    phaseDownColor: Color(0xFF8B4513), // Brown
    phaseHoldColor: Color(0xFFFFF8DC), // Cream
    ringGradient: [
      Color(0xFF8B4513),
      Color(0xFFFF8C00),
      Color(0xFFFFF8DC),
      Color(0xFF8B4513),
    ],
    outerRingWidthAt100: 7.4,
    accuracyBarGradient: [
      Color(0xFF2E1B0F), // Deep Harvest
      Color(0xFF8B4513),
      Color(0xFFFF8C00),
    ],
    accuracyLowColor: Color(0xFF5D4E37), // Dusty Brown
    accuracyMidColor: Color(0xFF8B4513),
    accuracyHighColor: Color(0xFFFF8C00),
    thresholdLineColor: Color(0xFFFFF8DC), // Cream line
  ),

  // ──────────────────────────────────────────────────────
  // 🪔 Nov 12 — Diwali (Festival of Lights)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'diwali',
    themeName: 'Diwali',
    label: 'Diwali',
    subtitle: 'NOV 12 · INDIA & WORLDWIDE',
    bannerIcon: '🪔',
    cornerIcon: '✨',
    watermarkIcon: 'दीपावली',
    bannerTitle: 'DIWALI · दीपावली',
    month: 11,
    day: 12,
    primaryStart: Color(0xFF1A1A2E), // Deep Night
    primaryEnd: Color(0xFFFFD700), // Gold Light
    accent1: Color(0xFFFF4500), // Flame Orange
    accent2: Color(0xFFF0E68C), // Khaki
    glowColor: Color(0xFFFFFF99), // Soft Light
    phaseUpColor: Color(0xFFFFD700), // Gold
    phaseDownColor: Color(0xFFFF4500), // Orange
    phaseHoldColor: Color(0xFFF0E68C), // Khaki
    ringGradient: [
      Color(0xFF1A1A2E),
      Color(0xFFFFD700),
      Color(0xFFFF4500),
      Color(0xFF1A1A2E),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF0A0A15), // Festival Night
      Color(0xFF1A1A2E),
      Color(0xFFFFD700),
    ],
    accuracyLowColor: Color(0xFF3B3B4D), // Muted dark
    accuracyMidColor: Color(0xFFFF4500),
    accuracyHighColor: Color(0xFFFFD700),
    thresholdLineColor: Color(0xFFFFFF99), // Light glow
  ),

  // ──────────────────────────────────────────────────────
  // 🎄 Dec 25 — Christmas
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'christmas',
    themeName: 'Christmas',
    label: 'Christmas',
    subtitle: 'DEC 25 · WORLDWIDE',
    bannerIcon: '🎄',
    cornerIcon: '🎅',
    watermarkIcon: 'XMAS',
    bannerTitle: 'CHRISTMAS',
    month: 12,
    day: 25,
    primaryStart: Color(0xFF0F0F23), // Midnight Blue
    primaryEnd: Color(0xFFDC143C), // Crimson Red
    accent1: Color(0xFF228B22), // Forest Green
    accent2: Color(0xFFFFFAF0), // Snow White
    glowColor: Color(0xFFFFD700), // Star Gold
    phaseUpColor: Color(0xFFDC143C), // Red
    phaseDownColor: Color(0xFF228B22), // Green
    phaseHoldColor: Color(0xFFFFFAF0), // White
    ringGradient: [
      Color(0xFF0F0F23),
      Color(0xFFDC143C),
      Color(0xFFFFFAF0),
      Color(0xFF0F0F23),
    ],
    outerRingWidthAt100: 7.8,
    accuracyBarGradient: [
      Color(0xFF050510), // Winter Night
      Color(0xFF0F0F23),
      Color(0xFFDC143C),
    ],
    accuracyLowColor: Color(0xFF4A4A5A), // Frost Gray
    accuracyMidColor: Color(0xFF0F0F23),
    accuracyHighColor: Color(0xFFDC143C),
    thresholdLineColor: Color(0xFFFFD700), // Gold star line
  ),

  // ──────────────────────────────────────────────────────
  // 🎉 Dec 31 — New Year's Eve
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'new_years_eve',
    themeName: 'New Year\'s Eve',
    label: 'New Year\'s Eve',
    subtitle: 'DEC 31 · WORLDWIDE',
    bannerIcon: '🎆',
    cornerIcon: '🥂',
    watermarkIcon: '2025',
    bannerTitle: 'NEW YEAR\'S EVE',
    month: 12,
    day: 31,
    primaryStart: Color(0xFF000080), // Midnight Blue
    primaryEnd: Color(0xFF7B68EE), // Slate Blue
    accent1: Color(0xFFFFD700), // Gold
    accent2: Color(0xFFFFFFFF), // White
    glowColor: Color(0xFF00FFFF), // Electric Cyan
    phaseUpColor: Color(0xFF7B68EE), // Blue
    phaseDownColor: Color(0xFF000080), // Deep Blue
    phaseHoldColor: Color(0xFFFFD700), // Gold
    ringGradient: [
      Color(0xFF000080),
      Color(0xFFFFD700),
      Color(0xFFFFFFFF),
      Color(0xFF000080),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF000020), // Deep Midnight
      Color(0xFF000080),
      Color(0xFF7B68EE),
    ],
    accuracyLowColor: Color(0xFF2E3440), // Dark Slate
    accuracyMidColor: Color(0xFF000080),
    accuracyHighColor: Color(0xFF7B68EE),
    thresholdLineColor: Color(0xFFFFD700), // Golden countdown
  ),


  // ──────────────────────────────────────────────────────
  // 🎾 May 26 — French Open
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'french_open',
    themeName: 'French Open',
    label: 'French Open',
    subtitle: 'MAY 26 · PARIS, FRANCE',
    bannerIcon: '🎾',
    cornerIcon: '🏆',
    watermarkIcon: 'RG',
    bannerTitle: 'FRENCH OPEN',
    month: 5,
    day: 26,
    primaryStart: Color(0xFF1D1E22), // Deep Court
    primaryEnd: Color(0xFFC65A3A), // Clay Red
    accent1: Color(0xFFFFD94A), // Tennis Yellow
    accent2: Color(0xFF163A73), // Navy Blue
    glowColor: Color(0xFFF8FAFC), // White
    phaseUpColor: Color(0xFFFFD94A), // Yellow
    phaseDownColor: Color(0xFFC65A3A), // Clay Red
    phaseHoldColor: Color(0xFF163A73), // Navy
    ringGradient: [
      Color(0xFF1D1E22), // Deep court
      Color(0xFFC65A3A), // Clay red
      Color(0xFFFFD94A), // Tennis yellow
      Color(0xFF1D1E22),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF1D1E22), // Dark court
      Color(0xFFC65A3A), // Clay
      Color(0xFFFFD94A), // Yellow
    ],
    accuracyLowColor: Color(0xFF8B7568), // Muted brown
    accuracyMidColor: Color(0xFFC65A3A), // Clay red
    accuracyHighColor: Color(0xFFFFD94A), // Tennis yellow
    thresholdLineColor: Color(0xFFFFFFFF), // White winning shot
  ),

  // ──────────────────────────────────────────────────────
  // 💡 May 29 — Vivid Sydney
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'vivid_sydney',
    themeName: 'Vivid Sydney',
    label: 'Vivid Sydney',
    subtitle: 'MAY 29 · SYDNEY, AU',
    bannerIcon: '✨',
    cornerIcon: '🎆',
    watermarkIcon: 'V',
    bannerTitle: 'VIVID SYDNEY',
    month: 5,
    day: 29,
    primaryStart: Color(0xFF071526), // Deep Harbor
    primaryEnd: Color(0xFF00B5FF), // Electric Azure
    accent1: Color(0xFF8E5CFF), // Neon Violet
    accent2: Color(0xFFFF6FD8), // Aurora Pink
    glowColor: Color(0xFFF3FAFF), // Ice White
    phaseUpColor: Color(0xFF00B5FF), // Azure
    phaseDownColor: Color(0xFFFF6FD8), // Pink
    phaseHoldColor: Color(0xFF8E5CFF), // Violet
    ringGradient: [
      Color(0xFF071526), // Navy
      Color(0xFF00B5FF), // Azure
      Color(0xFF8E5CFF), // Violet
      Color(0xFF071526),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF071526), // Dark harbor
      Color(0xFF00B5FF), // Azure
      Color(0xFF8E5CFF), // Cyan-violet
    ],
    accuracyLowColor: Color(0xFF2C394F), // Slate navy
    accuracyMidColor: Color(0xFF00B5FF), // Azure
    accuracyHighColor: Color(0xFF8E5CFF), // Neon glow
    thresholdLineColor: Color(0xFFFFFFFF), // Crisp skyline white
  ),

  // ──────────────────────────────────────────────────────
  // 🏃 Jun 03 — Global Running Day
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'global_running_day',
    themeName: 'Global Running Day',
    label: 'Global Running Day',
    subtitle: 'JUN 03 · WORLDWIDE',
    bannerIcon: '🌐',
    cornerIcon: '👟',
    watermarkIcon: 'RUN',
    bannerTitle: 'GLOBAL RUNNING DAY',
    month: 6,
    day: 3,
    primaryStart: Color(0xFF0B1F3A), // Deep Sky
    primaryEnd: Color(0xFF1DA1F2), // Global Blue
    accent1: Color(0xFFFF7A00), // Energy Orange
    accent2: Color(0xFFA7F432), // Lime Pulse
    glowColor: Color(0xFFF5FAFF), // Cloud White
    phaseUpColor: Color(0xFF1DA1F2), // Global Blue
    phaseDownColor: Color(0xFFFF7A00), // Energy Orange
    phaseHoldColor: Color(0xFFA7F432), // Lime Pulse
    ringGradient: [
      Color(0xFF0B1F3A),
      Color(0xFF1DA1F2),
      Color(0xFFA7F432),
      Color(0xFF0B1F3A),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF0B1F3A),
      Color(0xFF1DA1F2),
      Color(0xFF00FFFF),
    ],
    accuracyLowColor: Color(0xFF2A2F38), // Asphalt
    accuracyMidColor: Color(0xFF1DA1F2),
    accuracyHighColor: Color(0xFF00FFFF),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),

  // ──────────────────────────────────────────────────────
  // 🌿 Jun 05 — World Environment Day
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'environment_day',
    themeName: 'World Environment Day',
    label: 'World Environment Day',
    subtitle: 'JUN 05 · WORLDWIDE',
    bannerIcon: '🌱',
    cornerIcon: '🌍',
    watermarkIcon: 'ECO',
    bannerTitle: 'WORLD ENVIRONMENT DAY',
    month: 6,
    day: 5,
    primaryStart: Color(0xFF0B3D2E), // Forest Green
    primaryEnd: Color(0xFF3ED598), // Fresh Green
    accent1: Color(0xFF8B5E3C), // Earth Brown
    accent2: Color(0xFF6EC5FF), // Sky Blue
    glowColor: Color(0xFFE8F5E9), // Eco White
    phaseUpColor: Color(0xFF3ED598), // Fresh Green
    phaseDownColor: Color(0xFF8B5E3C), // Earth Brown
    phaseHoldColor: Color(0xFF6EC5FF), // Sky Blue
    ringGradient: [
      Color(0xFF0B3D2E),
      Color(0xFF3ED598),
      Color(0xFF6EC5FF),
      Color(0xFF0B3D2E),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF04110C), // Deep Eco
      Color(0xFF0B3D2E),
      Color(0xFF3ED598),
    ],
    accuracyLowColor: Color(0xFF3B443F), // Muted branch
    accuracyMidColor: Color(0xFF0B3D2E),
    accuracyHighColor: Color(0xFF3ED598),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),

  // ──────────────────────────────────────────────────────
  // 🌉 Jun 13 — White Nights Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'white_nights',
    themeName: 'White Nights',
    label: 'White Nights',
    subtitle: 'JUN 13 · ST. PETERSBURG',
    bannerIcon: '🏛',
    cornerIcon: '✨',
    watermarkIcon: 'W',
    bannerTitle: 'WHITE NIGHTS FESTIVAL',
    month: 6,
    day: 13,
    primaryStart: Color(0xFF1B1F3B), // Soft Indigo
    primaryEnd: Color(0xFF6EC5FF), // Aurora Blue
    accent1: Color(0xFFF8FBFF), // Pearl White
    accent2: Color(0xFFE6C068), // Gold
    glowColor: Color(0xFFFFFFFF), // Night Glow
    phaseUpColor: Color(0xFF6EC5FF), // Aurora Blue
    phaseDownColor: Color(0xFF1B1F3B), // Indigo
    phaseHoldColor: Color(0xFFE6C068), // Gold
    ringGradient: [
      Color(0xFF1B1F3B),
      Color(0xFF6EC5FF),
      Color(0xFFF8FBFF),
      Color(0xFF1B1F3B),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF070A18), // Night Glow
      Color(0xFF1B1F3B),
      Color(0xFF6EC5FF),
      Color(0xFFF8FBFF),
    ],
    accuracyLowColor: Color(0xFF2C3550),
    accuracyMidColor: Color(0xFF6EC5FF),
    accuracyHighColor: Color(0xFFF8FBFF),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),

  // ──────────────────────────────────────────────────────
  // 🌻 Jun 19 — Midsummer Eve
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'midsummer',
    themeName: 'Midsummer Eve',
    label: 'Midsummer Eve',
    subtitle: 'JUN 19 · NORDIC SUMMER',
    bannerIcon: '🌻',
    cornerIcon: '🌸',
    watermarkIcon: '☼',
    bannerTitle: 'MIDSUMMER EVE',
    month: 6,
    day: 19,
    primaryStart: Color(0xFFFFD166), // Sunset Gold
    primaryEnd: Color(0xFF4CAF50), // Meadow Green
    accent1: Color(0xFF87CEFA), // Sky Blue
    accent2: Color(0xFFFF9AA2), // Floral Pink
    glowColor: Color(0xFFFFF8E1), // Warm Light
    phaseUpColor: Color(0xFFFFD166), // Sunset Gold
    phaseDownColor: Color(0xFF4CAF50), // Meadow Green
    phaseHoldColor: Color(0xFFFF9AA2), // Floral Pink
    ringGradient: [
      Color(0xFF4CAF50),
      Color(0xFFFFD166),
      Color(0xFFFF9AA2),
      Color(0xFF4CAF50),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF0B1A12), // Deep Forest
      Color(0xFF4CAF50),
      Color(0xFFFFD166),
    ],
    accuracyLowColor: Color(0xFF4A5D23), // Moss
    accuracyMidColor: Color(0xFF4CAF50),
    accuracyHighColor: Color(0xFFFFD166),
    thresholdLineColor: Color(0xFFFFFFFF), // Sunlight line
  ),

  // ──────────────────────────────────────────────────────
  // 🧘‍♀️ Jun 21 — International Yoga Day
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'yoga_day',
    themeName: 'International Yoga Day',
    label: 'International Yoga Day',
    subtitle: 'JUN 21 · WORLDWIDE',
    bannerIcon: '🧘',
    cornerIcon: '🪷',
    watermarkIcon: 'OM',
    bannerTitle: 'INTERNATIONAL YOGA DAY',
    month: 6,
    day: 21,
    primaryStart: Color(0xFF1A1A40), // Deep Indigo
    primaryEnd: Color(0xFF4FD1C5), // Calm Cyan
    accent1: Color(0xFFFFB6C1), // Lotus Pink
    accent2: Color(0xFFE6C068), // Soft Gold
    glowColor: Color(0xFFE6F7F5), // Zen Glow
    phaseUpColor: Color(0xFF4FD1C5), // Calm Cyan
    phaseDownColor: Color(0xFFFFB6C1), // Lotus Pink
    phaseHoldColor: Color(0xFFE6C068), // Soft Gold
    ringGradient: [
      Color(0xFF1A1A40),
      Color(0xFF4FD1C5),
      Color(0xFFFFB6C1),
      Color(0xFF1A1A40),
    ],
    outerRingWidthAt100: 6.8, // Smooth, thinner ring
    accuracyBarGradient: [
      Color(0xFF050510), // Zen Dark
      Color(0xFF1A1A40),
      Color(0xFF4FD1C5),
    ],
    accuracyLowColor: Color(0xFF2D3748), // Slate
    accuracyMidColor: Color(0xFF1A1A40),
    accuracyHighColor: Color(0xFF4FD1C5),
    thresholdLineColor: Color(0xFFFFFFFF), // Pure White balance line
  ),

  // ──────────────────────────────────────────────────────
  // 🎸 Jun 26 — Glastonbury Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'glastonbury',
    themeName: 'Glastonbury',
    label: 'Glastonbury',
    subtitle: 'JUN 26 · PILTON, UK',
    bannerIcon: '⛺',
    cornerIcon: '🎸',
    watermarkIcon: 'G',
    bannerTitle: 'GLASTONBURY FESTIVAL',
    month: 6,
    day: 26,
    primaryStart: Color(0xFF2B1E1A), // Dark Mud
    primaryEnd: Color(0xFF8E44FF), // Neon Purple
    accent1: Color(0xFF39FF14), // Acid Green
    accent2: Color(0xFFFF6A00), // Fire Orange
    glowColor: Color(0xFFF3E5F5), // Stage Glow
    phaseUpColor: Color(0xFF8E44FF), // Purple
    phaseDownColor: Color(0xFFFF6A00), // Orange
    phaseHoldColor: Color(0xFF39FF14), // Green
    ringGradient: [
      Color(0xFF2B1E1A),
      Color(0xFF8E44FF),
      Color(0xFF39FF14),
      Color(0xFF2B1E1A),
    ],
    outerRingWidthAt100: 7.6,
    accuracyBarGradient: [
      Color(0xFF050403), // Night Field
      Color(0xFF2B1E1A),
      Color(0xFF8E44FF),
      Color(0xFF39FF14), // Neon
    ],
    accuracyLowColor: Color(0xFF4A3C38), // Mud
    accuracyMidColor: Color(0xFF8E44FF),
    accuracyHighColor: Color(0xFF39FF14),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),

  // ──────────────────────────────────────────────────────
  // 🎾 Jun 30 — Wimbledon
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'wimbledon',
    themeName: 'Wimbledon',
    label: 'Wimbledon',
    subtitle: 'JUN 30 · LONDON, UK',
    bannerIcon: '🎾',
    cornerIcon: '🍓',
    watermarkIcon: 'W',
    bannerTitle: 'WIMBLEDON',
    month: 6,
    day: 30,
    primaryStart: Color(0xFF2E6F40), // Wimbledon Green
    primaryEnd: Color(0xFFF7E45C), // Tennis Yellow
    accent1: Color(0xFF4B2E83), // Royal Purple
    accent2: Color(0xFFFFFFFF), // White
    glowColor: Color(0xFFF0FDF4),
    phaseUpColor: Color(0xFFF7E45C), // Yellow
    phaseDownColor: Color(0xFF2E6F40), // Green
    phaseHoldColor: Color(0xFF4B2E83), // Purple
    ringGradient: [
      Color(0xFF2E6F40),
      Color(0xFFF7E45C),
      Color(0xFF4B2E83),
      Color(0xFF2E6F40),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF0A140F), // Deep Court
      Color(0xFF2E6F40),
      Color(0xFFF7E45C),
    ],
    accuracyLowColor: Color(0xFF3D5245),
    accuracyMidColor: Color(0xFF2E6F40),
    accuracyHighColor: Color(0xFFF7E45C),
    thresholdLineColor: Color(0xFFFFFFFF), // Court line
  ),

  // ──────────────────────────────────────────────────────
  // 🚴 Jul 04 — Tour de France
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'tour_de_france',
    themeName: 'Tour de France',
    label: 'Tour de France',
    subtitle: 'JUL 04 · FRANCE',
    bannerIcon: '🚴',
    cornerIcon: '⛰',
    watermarkIcon: 'TDF',
    bannerTitle: 'TOUR DE FRANCE',
    month: 7,
    day: 4,
    primaryStart: Color(0xFF0B1F3A), // Navy
    primaryEnd: Color(0xFFFFD400), // Yellow Jersey
    accent1: Color(0xFFD62828), // Red
    accent2: Color(0xFF4DA3FF), // Sky Blue
    glowColor: Color(0xFFFFFDE7),
    phaseUpColor: Color(0xFFFFD400), // Yellow
    phaseDownColor: Color(0xFFD62828), // Red
    phaseHoldColor: Color(0xFF4DA3FF), // Sky Blue
    ringGradient: [
      Color(0xFF0B1F3A),
      Color(0xFFFFD400),
      Color(0xFFD62828),
      Color(0xFF0B1F3A),
    ],
    outerRingWidthAt100: 7.4,
    accuracyBarGradient: [
      Color(0xFF05070C), // Road Dark
      Color(0xFF0B1F3A),
      Color(0xFFFFD400),
    ],
    accuracyLowColor: Color(0xFF2D3748), // Asphalt
    accuracyMidColor: Color(0xFF0B1F3A),
    accuracyHighColor: Color(0xFFFFD400),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),

  // ──────────────────────────────────────────────────────
  // 🐂 Jul 07 — San Fermin
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'san_fermin',
    themeName: 'San Fermin',
    label: 'San Fermin',
    subtitle: 'JUL 07 · PAMPLONA, SPAIN',
    bannerIcon: '🐂',
    cornerIcon: '🏃',
    watermarkIcon: 'SF',
    bannerTitle: 'SAN FERMIN',
    month: 7,
    day: 7,
    primaryStart: Color(0xFFB31217), // Deep Red
    primaryEnd: Color(0xFFFFF3E8), // Ivory
    accent1: Color(0xFF111111), // Black
    accent2: Color(0xFFFF4500), // Action Orange
    glowColor: Color(0xFFFFE0D2),
    phaseUpColor: Color(0xFFFFF3E8), // Ivory
    phaseDownColor: Color(0xFFB31217), // Red
    phaseHoldColor: Color(0xFF111111), // Black
    ringGradient: [
      Color(0xFF111111),
      Color(0xFFB31217),
      Color(0xFFFFF3E8),
      Color(0xFF111111),
    ],
    outerRingWidthAt100: 7.8, // Sharp, thick arc
    accuracyBarGradient: [
      Color(0xFF070202), // Night Red
      Color(0xFF4A0A0E),
      Color(0xFFB31217),
    ],
    accuracyLowColor: Color(0xFF333333),
    accuracyMidColor: Color(0xFFB31217),
    accuracyHighColor: Color(0xFFFFF3E8),
    thresholdLineColor: Color(0xFFFFFFFF), // Bright white strike
  ),

  // ──────────────────────────────────────────────────────
  // 🎷 Jul 11 — Montreux Jazz Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'montreux_jazz',
    themeName: 'Montreux Jazz',
    label: 'Montreux Jazz',
    subtitle: 'JUL 11 · MONTREUX, SWITZERLAND',
    bannerIcon: '🎷',
    cornerIcon: '🎹',
    watermarkIcon: 'M',
    bannerTitle: 'MONTREUX JAZZ FESTIVAL',
    month: 7,
    day: 11,
    primaryStart: Color(0xFF0A1A2F), // Deep Blue
    primaryEnd: Color(0xFF6A4CFF), // Jazz Purple
    accent1: Color(0xFFFF4FD8), // Neon Pink
    accent2: Color(0xFFD4AF37), // Gold
    glowColor: Color(0xFFF3E8FF), // Soft Glow
    phaseUpColor: Color(0xFF6A4CFF), // Purple
    phaseDownColor: Color(0xFFFF4FD8), // Pink
    phaseHoldColor: Color(0xFFD4AF37), // Gold
    ringGradient: [
      Color(0xFF0A1A2F),
      Color(0xFF6A4CFF),
      Color(0xFFFF4FD8),
      Color(0xFF0A1A2F),
    ],
    outerRingWidthAt100: 7.0, // Smooth wave ring
    accuracyBarGradient: [
      Color(0xFF04060A), // Night Stage
      Color(0xFF0A1A2F),
      Color(0xFF6A4CFF),
      Color(0xFFFF4FD8),
    ],
    accuracyLowColor: Color(0xFF212A3E),
    accuracyMidColor: Color(0xFF6A4CFF),
    accuracyHighColor: Color(0xFFFF4FD8),
    thresholdLineColor: Color(0xFFFFFFFF), // White spotlight line
  ),

  // ──────────────────────────────────────────────────────
  // 🤠 Jul 12 — Calgary Stampede
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'calgary_stampede',
    themeName: 'Calgary Stampede',
    label: 'Calgary Stampede',
    subtitle: 'JUL 12 · GRAND FINAL',
    bannerIcon: '🤠',
    cornerIcon: '🐎',
    watermarkIcon: 'CS',
    bannerTitle: 'CALGARY STAMPEDE',
    month: 7,
    day: 12,
    primaryStart: Color(0xFF5A2E1F), // Burnt Leather
    primaryEnd: Color(0xFFD4A373), // Desert Gold
    accent1: Color(0xFFA4161A), // Crimson
    accent2: Color(0xFFFFF8E7), // Ivory
    glowColor: Color(0xFFFFD700), // Gold glow
    phaseUpColor: Color(0xFFD4A373), // Desert Gold
    phaseDownColor: Color(0xFFA4161A), // Crimson
    phaseHoldColor: Color(0xFFFFF8E7), // Ivory
    ringGradient: [
      Color(0xFF5A2E1F),
      Color(0xFFD4A373),
      Color(0xFFFFF8E7),
      Color(0xFF5A2E1F),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF050403), // Midnight Ranch
      Color(0xFF5A2E1F),
      Color(0xFFD4A373),
    ],
    accuracyLowColor: Color(0xFF3E2723), // Dark Brown
    accuracyMidColor: Color(0xFF5A2E1F),
    accuracyHighColor: Color(0xFFD4A373),
    thresholdLineColor: Color(0xFFFFF8E7), // Bright ivory
  ),

  // ──────────────────────────────────────────────────────
  // 🦋 Jul 18 — Tomorrowland
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'tomorrowland',
    themeName: 'Tomorrowland',
    label: 'Tomorrowland',
    subtitle: 'MAINSTAGE · JUL 18',
    bannerIcon: '🦋',
    cornerIcon: '🔮',
    watermarkIcon: 'TML',
    bannerTitle: 'TOMORROWLAND',
    month: 7,
    day: 18,
    primaryStart: Color(0xFF0A0F2E), // Deep Indigo
    primaryEnd: Color(0xFF7B2CFF), // Arcane Purple
    accent1: Color(0xFF00F5FF), // Neon Cyan
    accent2: Color(0xFFFFD166), // Fairy Gold
    glowColor: Color(0xFFE0B0FF), // Mauve glow
    phaseUpColor: Color(0xFF00F5FF), // Cyan
    phaseDownColor: Color(0xFF7B2CFF), // Purple
    phaseHoldColor: Color(0xFFFFD166), // Gold
    ringGradient: [
      Color(0xFF0A0F2E),
      Color(0xFF7B2CFF),
      Color(0xFF00F5FF),
      Color(0xFF0A0F2E),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF040612), // Dream Night
      Color(0xFF7B2CFF),
      Color(0xFF00F5FF),
    ],
    accuracyLowColor: Color(0xFF2C1E4A), // Muted Purple
    accuracyMidColor: Color(0xFF7B2CFF),
    accuracyHighColor: Color(0xFF00F5FF),
    thresholdLineColor: Color(0xFFFFFFFF), // Radiant white
  ),

  // ──────────────────────────────────────────────────────
  // 🦸‍♂️ Jul 24 — San Diego Comic-Con
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'comic_con',
    themeName: 'Comic-Con',
    label: 'Comic-Con',
    subtitle: 'JUL 24 · SAN DIEGO',
    bannerIcon: '💬',
    cornerIcon: '💥',
    watermarkIcon: 'SDCC',
    bannerTitle: 'COMIC-CON',
    month: 7,
    day: 24,
    primaryStart: Color(0xFF0A0A0F), // Jet Black
    primaryEnd: Color(0xFFFFD60A), // Electric Yellow
    accent1: Color(0xFF1E90FF), // Comic Blue
    accent2: Color(0xFFFF3B3B), // Neon Red
    glowColor: Color(0xFFFFFFCC), // Light yellow
    phaseUpColor: Color(0xFFFFD60A), // Yellow
    phaseDownColor: Color(0xFFFF3B3B), // Red
    phaseHoldColor: Color(0xFF1E90FF), // Blue
    ringGradient: [
      Color(0xFF0A0A0F),
      Color(0xFFFFD60A),
      Color(0xFFFF3B3B),
      Color(0xFF0A0A0F),
    ],
    outerRingWidthAt100: 7.5,
    accuracyBarGradient: [
      Color(0xFF040404), // Ink Black
      Color(0xFFFFD60A),
      Color(0xFF1E90FF),
    ],
    accuracyLowColor: Color(0xFF2A2A2A), // Dark Gray
    accuracyMidColor: Color(0xFFFFD60A),
    accuracyHighColor: Color(0xFF1E90FF),
    thresholdLineColor: Color(0xFFFFFFFF), // White flash
  ),

  // ──────────────────────────────────────────────────────
  // 🟤 Jul 26 — Boryeong Mud Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'boryeong_mud',
    themeName: 'Boryeong Mud',
    label: 'Boryeong Mud',
    subtitle: 'JUL 26 · FINAL DAY',
    bannerIcon: '🟤',
    cornerIcon: '🌊',
    watermarkIcon: 'MUD',
    bannerTitle: 'MUD FESTIVAL',
    month: 7,
    day: 26,
    primaryStart: Color(0xFF6B4F3A), // Mud Brown
    primaryEnd: Color(0xFF4FD1C5), // Aqua Blue
    accent1: Color(0xFFEADBC8), // Sand Beige
    accent2: Color(0xFF00FFC6), // Neon Teal
    glowColor: Color(0xFFD4F1F4), // Light Aqua
    phaseUpColor: Color(0xFF4FD1C5), // Aqua
    phaseDownColor: Color(0xFF6B4F3A), // Mud
    phaseHoldColor: Color(0xFF00FFC6), // Teal
    ringGradient: [
      Color(0xFF050708),
      Color(0xFF6B4F3A),
      Color(0xFF4FD1C5),
      Color(0xFF050708),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF050708), // Deep Wet
      Color(0xFF6B4F3A),
      Color(0xFF4FD1C5),
    ],
    accuracyLowColor: Color(0xFF382A1D), // Dark Mud
    accuracyMidColor: Color(0xFF6B4F3A),
    accuracyHighColor: Color(0xFF4FD1C5),
    thresholdLineColor: Color(0xFF00FFC6), // Bright waterline
  ),

  // ──────────────────────────────────────────────────────
  // 🎸 Jul 31 — Lollapalooza
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'lollapalooza',
    themeName: 'Lollapalooza',
    label: 'Lollapalooza',
    subtitle: 'DAY 2 · JUL 31',
    bannerIcon: '🎵',
    cornerIcon: '⚡',
    watermarkIcon: 'LOLLA',
    bannerTitle: 'LOLLAPALOOZA',
    month: 7,
    day: 31,
    primaryStart: Color(0xFF050505), // Deep Black
    primaryEnd: Color(0xFFFF2DAF), // Neon Pink
    accent1: Color(0xFF00C2FF), // Electric Blue
    accent2: Color(0xFFB7FF00), // Lime
    glowColor: Color(0xFFFFD1FF), // Soft Pink Glow
    phaseUpColor: Color(0xFFFF2DAF), // Pink
    phaseDownColor: Color(0xFF00C2FF), // Blue
    phaseHoldColor: Color(0xFFB7FF00), // Lime
    ringGradient: [
      Color(0xFF050505),
      Color(0xFFFF2DAF),
      Color(0xFF00C2FF),
      Color(0xFF050505),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF020203), // Stage Night
      Color(0xFFFF2DAF),
      Color(0xFF00C2FF),
    ],
    accuracyLowColor: Color(0xFF2E1A29), // Muted Pink Dark
    accuracyMidColor: Color(0xFFFF2DAF),
    accuracyHighColor: Color(0xFF00C2FF),
    thresholdLineColor: Color(0xFFFFFFFF), // White spotlight line
  ),

  // ──────────────────────────────────────────────────────
  // 🏋️ Aug 05 — CrossFit Games
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'crossfit_games',
    themeName: 'CrossFit Games',
    label: 'CrossFit Games',
    subtitle: 'DAY 2 · ELITE',
    bannerIcon: '🏋️',
    cornerIcon: '⚙',
    watermarkIcon: 'CFG',
    bannerTitle: 'CROSSFIT GAMES',
    month: 8,
    day: 5,
    primaryStart: Color(0xFF0A0A0A), // Steel Black
    primaryEnd: Color(0xFFD90429), // Power Red
    accent1: Color(0xFFC0C0C0), // Chrome Silver
    accent2: Color(0xFFF8F9FA), // Neon White
    glowColor: Color(0xFFFFB3B3), // Red highlight
    phaseUpColor: Color(0xFFF8F9FA), // White
    phaseDownColor: Color(0xFFD90429), // Red
    phaseHoldColor: Color(0xFFC0C0C0), // Silver
    ringGradient: [
      Color(0xFF0A0A0A),
      Color(0xFFD90429),
      Color(0xFFC0C0C0),
      Color(0xFF0A0A0A),
    ],
    outerRingWidthAt100: 8.0, // Heavy metal ring
    accuracyBarGradient: [
      Color(0xFF030303), // Iron Dark
      Color(0xFFD90429),
      Color(0xFFF8F9FA),
    ],
    accuracyLowColor: Color(0xFF3B1E22), // Dark Iron Red
    accuracyMidColor: Color(0xFFD90429),
    accuracyHighColor: Color(0xFFF8F9FA),
    thresholdLineColor: Color(0xFFFFFFFF), // Hard strike
  ),

  // ──────────────────────────────────────────────────────
  // 🍻 Aug 07 — International Beer Day
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'beer_day',
    themeName: 'International Beer Day',
    label: 'International Beer Day',
    subtitle: 'AUG 07 · WORLDWIDE',
    bannerIcon: '🍻',
    cornerIcon: '🍺',
    watermarkIcon: 'IBD',
    bannerTitle: 'INTERNATIONAL BEER DAY',
    month: 8,
    day: 7,
    primaryStart: Color(0xFF3B1F0B), // Dark Malt
    primaryEnd: Color(0xFFF2A900), // Golden Beer
    accent1: Color(0xFFFFF4E0), // Foam White
    accent2: Color(0xFFB87333), // Copper
    glowColor: Color(0xFFFFF8DC), // Cornsilk
    phaseUpColor: Color(0xFFF2A900), // Gold
    phaseDownColor: Color(0xFF3B1F0B), // Malt
    phaseHoldColor: Color(0xFFFFF4E0), // Foam
    ringGradient: [
      Color(0xFF3B1F0B),
      Color(0xFFF2A900),
      Color(0xFFB87333),
      Color(0xFF3B1F0B),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF050302), // Deep Brew
      Color(0xFF3B1F0B),
      Color(0xFFF2A900),
      Color(0xFFFFF4E0),
    ],
    accuracyLowColor: Color(0xFF2E1908), // Dark Stout
    accuracyMidColor: Color(0xFF3B1F0B),
    accuracyHighColor: Color(0xFFF2A900),
    thresholdLineColor: Color(0xFFFFF4E0), // Foam white
  ),

  // ──────────────────────────────────────────────────────
  // 🎭 Aug 15 — Edinburgh Fringe Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'edinburgh_fringe',
    themeName: 'Edinburgh Fringe',
    label: 'Edinburgh Fringe',
    subtitle: 'AUG 15 · SCOTLAND',
    bannerIcon: '🎭',
    cornerIcon: '🎪',
    watermarkIcon: 'EFF',
    bannerTitle: 'FRINGE FESTIVAL',
    month: 8,
    day: 15,
    primaryStart: Color(0xFF2A0A2F), // Deep Plum
    primaryEnd: Color(0xFFD726FF), // Magenta
    accent1: Color(0xFF00D1FF), // Cyan
    accent2: Color(0xFFE6C068), // Gold
    glowColor: Color(0xFFF0D9FF), // Soft Purple Glow
    phaseUpColor: Color(0xFFD726FF), // Magenta
    phaseDownColor: Color(0xFF00D1FF), // Cyan
    phaseHoldColor: Color(0xFFE6C068), // Gold
    ringGradient: [
      Color(0xFF2A0A2F),
      Color(0xFFD726FF),
      Color(0xFF00D1FF),
      Color(0xFF2A0A2F),
    ],
    outerRingWidthAt100: 7.0,
    accuracyBarGradient: [
      Color(0xFF05040A), // Stage Dark
      Color(0xFFD726FF),
      Color(0xFF00D1FF),
    ],
    accuracyLowColor: Color(0xFF1E1430), // Muted Plum
    accuracyMidColor: Color(0xFFD726FF),
    accuracyHighColor: Color(0xFF00D1FF),
    thresholdLineColor: Color(0xFFFFFFFF), // Spotlight white
  ),

  // ──────────────────────────────────────────────────────
  // 🍅 Aug 26 — La Tomatina
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'la_tomatina',
    themeName: 'La Tomatina',
    label: 'La Tomatina',
    subtitle: 'AUG 26 · BUÑOL, SPAIN',
    bannerIcon: '🍅',
    cornerIcon: '💥',
    watermarkIcon: 'TMT',
    bannerTitle: 'LA TOMATINA',
    month: 8,
    day: 26,
    primaryStart: Color(0xFFE63946), // Tomato Red
    primaryEnd: Color(0xFFFF3B3B), // Fresh Red
    accent1: Color(0xFF2ECC71), // Leaf Green
    accent2: Color(0xFFFFF5E6), // Cream
    glowColor: Color(0xFFFFB3B3), // Pinkish red
    phaseUpColor: Color(0xFFFF3B3B), // Fresh Red
    phaseDownColor: Color(0xFFE63946), // Tomato Red
    phaseHoldColor: Color(0xFF2ECC71), // Green
    ringGradient: [
      Color(0xFF050202),
      Color(0xFFE63946),
      Color(0xFFFF3B3B),
      Color(0xFF050202),
    ],
    outerRingWidthAt100: 7.4,
    accuracyBarGradient: [
      Color(0xFF050202), // Deep Red Night
      Color(0xFFE63946),
      Color(0xFFFF3B3B),
    ],
    accuracyLowColor: Color(0xFF3B1515), // Dark brown-red
    accuracyMidColor: Color(0xFFE63946),
    accuracyHighColor: Color(0xFFFF3B3B),
    thresholdLineColor: Color(0xFFFFF5E6), // Cream white
  ),

  // ──────────────────────────────────────────────────────
  // 🦚 Aug 31 — Notting Hill Carnival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'notting_hill',
    themeName: 'Notting Hill Carnival',
    label: 'Notting Hill Carnival',
    subtitle: 'MAIN PARADE · AUG 31',
    bannerIcon: '🦚',
    cornerIcon: '🥁',
    watermarkIcon: 'NHC',
    bannerTitle: 'NOTTING HILL CARNIVAL',
    month: 8,
    day: 31,
    primaryStart: Color(0xFF5A189A), // Royal Purple
    primaryEnd: Color(0xFFFFD166), // Carnival Gold
    accent1: Color(0xFF39FF14), // Neon Green
    accent2: Color(0xFFFF006E), // Hot Pink
    glowColor: Color(0xFFFFEBF3), // Soft festive glow
    phaseUpColor: Color(0xFFFFD166), // Gold
    phaseDownColor: Color(0xFFFF006E), // Pink
    phaseHoldColor: Color(0xFF39FF14), // Green
    ringGradient: [
      Color(0xFF5A189A),
      Color(0xFFFFD166),
      Color(0xFFFF006E),
      Color(0xFF5A189A),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF05030A), // Night Carnival
      Color(0xFF5A189A),
      Color(0xFFFFD166),
      Color(0xFFFF006E),
    ],
    accuracyLowColor: Color(0xFF2B1C4A), // Deep Muted Purple
    accuracyMidColor: Color(0xFF5A189A),
    accuracyHighColor: Color(0xFFFF006E),
    thresholdLineColor: Color(0xFFFFFFFF), // Parade white
  ),

  // ──────────────────────────────────────────────────────
  // 🦁 Sep 02 — Venice Film Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'venice_film_festival',
    themeName: 'Venice Film Festival',
    label: 'Venice Film Festival',
    subtitle: 'OPENING · SEP 02',
    bannerIcon: '🦁',
    cornerIcon: '🎬',
    watermarkIcon: 'VFF',
    bannerTitle: 'VENICE FILM FESTIVAL',
    month: 9,
    day: 2,
    primaryStart: Color(0xFF0B132B), // Midnight Navy
    primaryEnd: Color(0xFFD4AF37), // Venetian Gold
    accent1: Color(0xFF6A040F), // Deep Burgundy
    accent2: Color(0xFFFFF8E7), // Ivory
    glowColor: Color(0xFFFFD700), // Gold
    phaseUpColor: Color(0xFFD4AF37), // Gold
    phaseDownColor: Color(0xFF6A040F), // Burgundy
    phaseHoldColor: Color(0xFFFFF8E7), // Ivory
    ringGradient: [
      Color(0xFF0B132B),
      Color(0xFFD4AF37),
      Color(0xFFFFF8E7),
      Color(0xFF0B132B),
    ],
    outerRingWidthAt100: 7.2,
    accuracyBarGradient: [
      Color(0xFF05070C), // Lagoon Night
      Color(0xFF0B132B),
      Color(0xFFD4AF37),
    ],
    accuracyLowColor: Color(0xFF2A1B38), // Muted dark
    accuracyMidColor: Color(0xFFD4AF37),
    accuracyHighColor: Color(0xFFFFF8E7),
    thresholdLineColor: Color(0xFFFFF8E7), // Ivory premiere line
  ),

  // ──────────────────────────────────────────────────────
  // 🔥 Sep 05 — Burning Man
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'burning_man',
    themeName: 'Burning Man',
    label: 'Burning Man',
    subtitle: 'FINAL BURN · SEP 05',
    bannerIcon: '🔥',
    cornerIcon: '🏜',
    watermarkIcon: 'BM',
    bannerTitle: 'BURNING MAN',
    month: 9,
    day: 5,
    primaryStart: Color(0xFF0D0D0D), // Ash Black
    primaryEnd: Color(0xFFFF6A00), // Fire Orange
    accent1: Color(0xFFD62828), // Ember Red
    accent2: Color(0xFFEED9C4), // Sand Beige
    glowColor: Color(0xFFFF8C00), // Fire glow
    phaseUpColor: Color(0xFFFF6A00), // Orange
    phaseDownColor: Color(0xFFD62828), // Red
    phaseHoldColor: Color(0xFFEED9C4), // Sand
    ringGradient: [
      Color(0xFF0D0D0D),
      Color(0xFFD62828),
      Color(0xFFFF6A00),
      Color(0xFF0D0D0D),
    ],
    outerRingWidthAt100: 7.6, // Rough burned
    accuracyBarGradient: [
      Color(0xFF050403), // Deep Desert Night
      Color(0xFFFF6A00),
      Color(0xFFD62828),
    ],
    accuracyLowColor: Color(0xFF331A1A), // Dark ember
    accuracyMidColor: Color(0xFFFF6A00),
    accuracyHighColor: Color(0xFFD62828),
    thresholdLineColor: Color(0xFFFFDAB9), // Bright flame
  ),

  // ──────────────────────────────────────────────────────
  // 👠 Sep 11 — New York Fashion Week
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'nyfw',
    themeName: 'NYFW',
    label: 'NYFW',
    subtitle: 'HIGHLIGHT · SEP 11',
    bannerIcon: '👠',
    cornerIcon: '✨',
    watermarkIcon: 'NYFW',
    bannerTitle: 'NEW YORK FASHION WEEK',
    month: 9,
    day: 11,
    primaryStart: Color(0xFF050505), // Jet Black
    primaryEnd: Color(0xFFC0C0C0), // Silver Chrome
    accent1: Color(0xFFF8F9FA), // Neon White
    accent2: Color(0xFF3A86FF), // Accent Blue
    glowColor: Color(0xFFE9ECEF), // White glow
    phaseUpColor: Color(0xFFC0C0C0), // Chrome
    phaseDownColor: Color(0xFF050505), // Black
    phaseHoldColor: Color(0xFFF8F9FA), // White
    ringGradient: [
      Color(0xFF050505),
      Color(0xFFC0C0C0),
      Color(0xFFF8F9FA),
      Color(0xFF050505),
    ],
    outerRingWidthAt100: 6.8, // Ultra-clean thin ring
    accuracyBarGradient: [
      Color(0xFF020202), // Runway Dark
      Color(0xFF050505),
      Color(0xFFC0C0C0),
      Color(0xFFF8F9FA),
    ],
    accuracyLowColor: Color(0xFF2B2B2B), // Dark Gray
    accuracyMidColor: Color(0xFFC0C0C0),
    accuracyHighColor: Color(0xFFF8F9FA),
    thresholdLineColor: Color(0xFFFFFFFF), // Sharp runway line
  ),

  // ──────────────────────────────────────────────────────
  // 🥨 Sep 19 — Oktoberfest
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'oktoberfest',
    themeName: 'Oktoberfest',
    label: 'Oktoberfest',
    subtitle: 'OPENING · SEP 19',
    bannerIcon: '🥨',
    cornerIcon: '🍻',
    watermarkIcon: 'WIESN',
    bannerTitle: 'OKTOBERFEST',
    month: 9,
    day: 19,
    primaryStart: Color(0xFF3A2A1D), // Deep Oak
    primaryEnd: Color(0xFFFFB347), // Amber Gold
    accent1: Color(0xFFFFF3E0), // Cream
    accent2: Color(0xFF1E3A8A), // Bavarian Blue
    glowColor: Color(0xFFFFE0B2), // Warm glow
    phaseUpColor: Color(0xFFFFB347), // Amber Gold
    phaseDownColor: Color(0xFF3A2A1D), // Deep Oak
    phaseHoldColor: Color(0xFFFFF3E0), // Cream
    ringGradient: [
      Color(0xFF3A2A1D),
      Color(0xFFFFB347),
      Color(0xFFFFF3E0),
      Color(0xFF3A2A1D),
    ],
    outerRingWidthAt100: 7.4,
    accuracyBarGradient: [
      Color(0xFF050302), // Dark Brew
      Color(0xFF3A2A1D),
      Color(0xFFFFB347),
    ],
    accuracyLowColor: Color(0xFF2E1F14), // Muted dark oak
    accuracyMidColor: Color(0xFFFFB347),
    accuracyHighColor: Color(0xFFFFF3E0), // Cream
    thresholdLineColor: Color(0xFFFFF3E0), // Foam-white line
  ),

  // ──────────────────────────────────────────────────────
  // 👑 Sep 20 — London Fashion Week
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'lfw',
    themeName: 'LFW',
    label: 'LFW',
    subtitle: 'HIGHLIGHT · SEP 20',
    bannerIcon: '👑',
    cornerIcon: '✨',
    watermarkIcon: 'LFW',
    bannerTitle: 'LONDON FASHION WEEK',
    month: 9,
    day: 20,
    primaryStart: Color(0xFF0B1B3A), // Deep Navy
    primaryEnd: Color(0xFFC1121F), // Royal Red
    accent1: Color(0xFFD4AF37), // Gold
    accent2: Color(0xFFFFFFFF), // White
    glowColor: Color(0xFFF1FAEE), // Soft White
    phaseUpColor: Color(0xFFC1121F), // Red
    phaseDownColor: Color(0xFF0B1B3A), // Navy
    phaseHoldColor: Color(0xFFD4AF37), // Gold
    ringGradient: [
      Color(0xFF0B1B3A),
      Color(0xFFC1121F),
      Color(0xFFD4AF37),
      Color(0xFF0B1B3A),
    ],
    outerRingWidthAt100: 7.2, // Elegant structured ring
    accuracyBarGradient: [
      Color(0xFF05080F), // Midnight London
      Color(0xFF0B1B3A),
      Color(0xFFC1121F),
    ],
    accuracyLowColor: Color(0xFF1D2D50), // Steel blue
    accuracyMidColor: Color(0xFFC1121F),
    accuracyHighColor: Color(0xFFD4AF37),
    thresholdLineColor: Color(0xFFFFFFFF), // White prestige line
  ),

  // ──────────────────────────────────────────────────────
  // 🏛️ Sep 23 — Milan Fashion Week
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'mfw',
    themeName: 'MFW',
    label: 'MFW',
    subtitle: 'HIGHLIGHT · SEP 23',
    bannerIcon: '🏛',
    cornerIcon: '✨',
    watermarkIcon: 'MFW',
    bannerTitle: 'MILAN FASHION WEEK',
    month: 9,
    day: 23,
    primaryStart: Color(0xFF050505), // Deep Black
    primaryEnd: Color(0xFFC9A227), // Rich Gold
    accent1: Color(0xFF046307), // Emerald
    accent2: Color(0xFFFFF8E7), // Ivory
    glowColor: Color(0xFFF1E1A6), // Warm Gold
    phaseUpColor: Color(0xFFC9A227), // Gold
    phaseDownColor: Color(0xFF050505), // Black
    phaseHoldColor: Color(0xFFFFF8E7), // Ivory
    ringGradient: [
      Color(0xFF050505),
      Color(0xFFC9A227),
      Color(0xFFFFF8E7),
      Color(0xFF050505),
    ],
    outerRingWidthAt100: 7.4, // Ornate luxury ring
    accuracyBarGradient: [
      Color(0xFF030303), // Milano Night
      Color(0xFF050505),
      Color(0xFFC9A227),
    ],
    accuracyLowColor: Color(0xFF2E2A1D), // Dark bronze
    accuracyMidColor: Color(0xFFC9A227),
    accuracyHighColor: Color(0xFFFFF8E7),
    thresholdLineColor: Color(0xFFFFF8E7), // Ivory line
  ),

  // ──────────────────────────────────────────────────────
  // 🥮 Sep 25 — Mid-Autumn Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'mid_autumn',
    themeName: 'Mid-Autumn Festival',
    label: 'Mid-Autumn Festival',
    subtitle: 'FULL MOON · SEP 25',
    bannerIcon: '🥮',
    cornerIcon: '🌕',
    watermarkIcon: '秋',
    bannerTitle: 'MID-AUTUMN FESTIVAL',
    month: 9,
    day: 25,
    primaryStart: Color(0xFF0A1128), // Midnight Blue
    primaryEnd: Color(0xFFFFD166), // Moon Gold
    accent1: Color(0xFFE63946), // Lantern Red
    accent2: Color(0xFF2ECC71), // Jade
    glowColor: Color(0xFFFFF3B0), // Moonlight
    phaseUpColor: Color(0xFFFFD166), // Gold
    phaseDownColor: Color(0xFFE63946), // Red
    phaseHoldColor: Color(0xFF2ECC71), // Jade
    ringGradient: [
      Color(0xFF0A1128),
      Color(0xFFE63946),
      Color(0xFFFFD166),
      Color(0xFF0A1128),
    ],
    outerRingWidthAt100: 7.2, // Circular moon halo
    accuracyBarGradient: [
      Color(0xFF04060D), // Night Sky
      Color(0xFF0A1128),
      Color(0xFFFFD166),
    ],
    accuracyLowColor: Color(0xFF1D2D50), // Muted dark blue
    accuracyMidColor: Color(0xFFE63946), // Red
    accuracyHighColor: Color(0xFFFFD166), // Gold
    thresholdLineColor: Color(0xFFFFFFFF), // Bright moonline
  ),

  // ──────────────────────────────────────────────────────
  // 🏃‍♂️ Sep 27 — Berlin Marathon
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'berlin_marathon',
    themeName: 'Berlin Marathon',
    label: 'Berlin Marathon',
    subtitle: 'SEP 27 · RACE DAY',
    bannerIcon: '🏃',
    cornerIcon: '🇩🇪',
    watermarkIcon: 'BM',
    bannerTitle: 'BERLIN MARATHON',
    month: 9,
    day: 27,
    primaryStart: Color(0xFF0A0A0A), // Carbon Black
    primaryEnd: Color(0xFF1E90FF), // Electric Blue
    accent1: Color(0xFFF8F9FA), // Neon White
    accent2: Color(0xFF6C757D), // Steel Gray
    glowColor: Color(0xFFE1F5FE), // Cool light
    phaseUpColor: Color(0xFF1E90FF), // Blue
    phaseDownColor: Color(0xFF0A0A0A), // Carbon
    phaseHoldColor: Color(0xFFF8F9FA), // White
    ringGradient: [
      Color(0xFF0A0A0A),
      Color(0xFF1E90FF),
      Color(0xFFF8F9FA),
      Color(0xFF0A0A0A),
    ],
    outerRingWidthAt100: 7.4, // Precision track
    accuracyBarGradient: [
      Color(0xFF050505), // Race Night
      Color(0xFF0A0A0A),
      Color(0xFF1E90FF),
      Color(0xFFF8F9FA),
    ],
    accuracyLowColor: Color(0xFF2A2E33), // Slate gray
    accuracyMidColor: Color(0xFF1E90FF),
    accuracyHighColor: Color(0xFFF8F9FA),
    thresholdLineColor: Color(0xFFFFFFFF), // Finish line glow
  ),

  // ──────────────────────────────────────────────────────
  // 🗼 Sep 30 — Paris Fashion Week
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'pfw',
    themeName: 'PFW',
    label: 'PFW',
    subtitle: 'HIGHLIGHT · SEP 30',
    bannerIcon: '🗼',
    cornerIcon: '✨',
    watermarkIcon: 'PFW',
    bannerTitle: 'PARIS FASHION WEEK',
    month: 9,
    day: 30,
    primaryStart: Color(0xFF0A0A0F), // Soft Black
    primaryEnd: Color(0xFFEAD2AC), // Champagne Gold
    accent1: Color(0xFFF4C2C2), // Blush Pink
    accent2: Color(0xFFFAF9F6), // Pearl White
    glowColor: Color(0xFFFDF6E3), // Soft champagne glow
    phaseUpColor: Color(0xFFEAD2AC), // Champagne
    phaseDownColor: Color(0xFF0A0A0F), // Black
    phaseHoldColor: Color(0xFFF4C2C2), // Pink
    ringGradient: [
      Color(0xFF0A0A0F),
      Color(0xFFEAD2AC),
      Color(0xFFF4C2C2),
      Color(0xFF0A0A0F),
    ],
    outerRingWidthAt100: 7.0, // Soft couture ring
    accuracyBarGradient: [
      Color(0xFF040407), // Paris Night
      Color(0xFF0A0A0F),
      Color(0xFFEAD2AC),
      Color(0xFFF4C2C2),
    ],
    accuracyLowColor: Color(0xFF2B212A), // Muted dark mauve
    accuracyMidColor: Color(0xFFEAD2AC),
    accuracyHighColor: Color(0xFFF4C2C2),
    thresholdLineColor: Color(0xFFFAF9F6), // Pearl white line
  ),

  // ──────────────────────────────────────────────────────
  // ☕ Oct 01 — International Coffee Day
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'coffee_day',
    themeName: 'Coffee Day',
    label: 'Coffee Day',
    subtitle: 'OCT 01 · GLOBAL',
    bannerIcon: '☕',
    cornerIcon: '✨',
    watermarkIcon: 'COFFEE',
    bannerTitle: 'INTERNATIONAL COFFEE DAY',
    month: 10,
    day: 1,
    primaryStart: Color(0xFF2E1A0F), // Espresso
    primaryEnd: Color(0xFFC68E17), // Caramel
    accent1: Color(0xFFFFF3E0), // Cream
    accent2: Color(0xFF1A0F0A), // Dark Roast
    glowColor: Color(0xFFFFE0B2), // Warm cream glow
    phaseUpColor: Color(0xFFC68E17), // Caramel
    phaseDownColor: Color(0xFF2E1A0F), // Espresso
    phaseHoldColor: Color(0xFFFFF3E0), // Cream
    ringGradient: [
      Color(0xFF1A0F0A),
      Color(0xFF2E1A0F),
      Color(0xFFC68E17),
      Color(0xFFFFF3E0),
      Color(0xFF1A0F0A),
    ],
    outerRingWidthAt100: 7.2, // Circular cup rim
    accuracyBarGradient: [
      Color(0xFF040302), // Coffee Night
      Color(0xFF2E1A0F),
      Color(0xFFC68E17),
    ],
    accuracyLowColor: Color(0xFF3E2723), // Macchiato
    accuracyMidColor: Color(0xFFC68E17),
    accuracyHighColor: Color(0xFFFFF3E0), // Cream
    thresholdLineColor: Color(0xFFFFF3E0), // Cream line
  ),

  // ──────────────────────────────────────────────────────
  // 🎈 Oct 04 — Albuquerque Balloon Fiesta
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'balloon_fiesta',
    themeName: 'Balloon Fiesta',
    label: 'Balloon Fiesta',
    subtitle: 'OCT 04 · ALBUQUERQUE',
    bannerIcon: '🎈',
    cornerIcon: '☁️',
    watermarkIcon: 'ABQ',
    bannerTitle: 'BALLOON FIESTA',
    month: 10,
    day: 4,
    primaryStart: Color(0xFF1E3A8A), // Dawn Blue
    primaryEnd: Color(0xFFFFD166), // Sunrise Gold
    accent1: Color(0xFFFF4D4D), // Hot Air Red
    accent2: Color(0xFF6EC5FF), // Sky Cyan
    glowColor: Color(0xFFFFF3E0), // Morning glow
    phaseUpColor: Color(0xFFFFD166), // Sunrise Gold
    phaseDownColor: Color(0xFFFF4D4D), // Red
    phaseHoldColor: Color(0xFF6EC5FF), // Cyan
    ringGradient: [
      Color(0xFF1E3A8A),
      Color(0xFFFFD166),
      Color(0xFF6EC5FF),
      Color(0xFF1E3A8A),
    ],
    outerRingWidthAt100: 7.4, // Soft balloon arc ring
    accuracyBarGradient: [
      Color(0xFF05070C), // Sky Night
      Color(0xFF1E3A8A),
      Color(0xFFFFD166),
    ],
    accuracyLowColor: Color(0xFF2B3A67), // Dark blue
    accuracyMidColor: Color(0xFF1E3A8A),
    accuracyHighColor: Color(0xFFFFD166),
    thresholdLineColor: Color(0xFFFFFFFF), // Bright sunrise line
  ),

  // ──────────────────────────────────────────────────────
  // 🏃‍♀️ Oct 11 — Chicago Marathon
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'chicago_marathon',
    themeName: 'Chicago Marathon',
    label: 'Chicago Marathon',
    subtitle: 'OCT 11 · RACE DAY',
    bannerIcon: '🏃‍♀️',
    cornerIcon: '🏙',
    watermarkIcon: 'CHI',
    bannerTitle: 'CHICAGO MARATHON',
    month: 10,
    day: 11,
    primaryStart: Color(0xFF1F3B73), // Steel Blue
    primaryEnd: Color(0xFF00C2FF), // Electric Cyan
    accent1: Color(0xFFD62828), // Marathon Red
    accent2: Color(0xFFF8F9FA), // White
    glowColor: Color(0xFFE0F7FA), // Cool rush
    phaseUpColor: Color(0xFF00C2FF), // Cyan
    phaseDownColor: Color(0xFFD62828), // Red
    phaseHoldColor: Color(0xFF1F3B73), // Navy
    ringGradient: [
      Color(0xFF1F3B73),
      Color(0xFF00C2FF),
      Color(0xFFF8F9FA),
      Color(0xFF1F3B73),
    ],
    outerRingWidthAt100: 7.2, // Precision track arc
    accuracyBarGradient: [
      Color(0xFF05070C), // City Night
      Color(0xFF1F3B73),
      Color(0xFF00C2FF),
    ],
    accuracyLowColor: Color(0xFF2C3E50), // Muted city blue
    accuracyMidColor: Color(0xFF00C2FF),
    accuracyHighColor: Color(0xFFF8F9FA), // White
    thresholdLineColor: Color(0xFFFFFFFF), // White finish glow
  ),

  // ──────────────────────────────────────────────────────
  // 🍽️ Oct 16 — World Food Day
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'world_food_day',
    themeName: 'World Food Day',
    label: 'World Food Day',
    subtitle: 'OCT 16 · GLOBAL',
    bannerIcon: '🍽',
    cornerIcon: '🌿',
    watermarkIcon: 'FOOD',
    bannerTitle: 'WORLD FOOD DAY',
    month: 10,
    day: 16,
    primaryStart: Color(0xFF556B2F), // Olive Green
    primaryEnd: Color(0xFFD4A373), // Harvest Gold
    accent1: Color(0xFFE63946), // Tomato Red
    accent2: Color(0xFFFFF5E6), // Cream
    glowColor: Color(0xFFFAEDCD), // Warm harvest
    phaseUpColor: Color(0xFFD4A373), // Gold
    phaseDownColor: Color(0xFF556B2F), // Olive
    phaseHoldColor: Color(0xFFE63946), // Red
    ringGradient: [
      Color(0xFF556B2F),
      Color(0xFFD4A373),
      Color(0xFFFFF5E6),
      Color(0xFF556B2F),
    ],
    outerRingWidthAt100: 7.4, // Circular plate form
    accuracyBarGradient: [
      Color(0xFF050403), // Earth Dark
      Color(0xFF556B2F),
      Color(0xFFD4A373),
    ],
    accuracyLowColor: Color(0xFF3E4A29), // Muted olive
    accuracyMidColor: Color(0xFF556B2F),
    accuracyHighColor: Color(0xFFD4A373),
    thresholdLineColor: Color(0xFFFFFFFF), // Clean white line
  ),

  // ──────────────────────────────────────────────────────
  // 🎃 Oct 31 — Halloween
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'halloween',
    themeName: 'Halloween',
    label: 'Halloween',
    subtitle: 'OCT 31 · DARK MODE',
    bannerIcon: '🎃',
    cornerIcon: '💀',
    watermarkIcon: 'BOO',
    bannerTitle: 'HALLOWEEN NIGHT',
    month: 10,
    day: 31,
    primaryStart: Color(0xFF050505), // Midnight Black
    primaryEnd: Color(0xFFFF6A00), // Toxic Orange
    accent1: Color(0xFF7B2CFF), // Neon Purple
    accent2: Color(0xFFF8F9FA), // Ghost White
    glowColor: Color(0xFFFFDAB9), // Eerie glow
    phaseUpColor: Color(0xFFFF6A00), // Orange
    phaseDownColor: Color(0xFF7B2CFF), // Purple
    phaseHoldColor: Color(0xFFF8F9FA), // Ghost White
    ringGradient: [
      Color(0xFF050505),
      Color(0xFFFF6A00),
      Color(0xFF7B2CFF),
      Color(0xFF050505),
    ],
    outerRingWidthAt100: 7.6, // Jagged gothic ring
    accuracyBarGradient: [
      Color(0xFF020202), // Abyss Night
      Color(0xFF050505),
      Color(0xFFFF6A00),
      Color(0xFF7B2CFF),
    ],
    accuracyLowColor: Color(0xFF2E1A33), // Dark purple
    accuracyMidColor: Color(0xFFFF6A00),
    accuracyHighColor: Color(0xFF7B2CFF),
    thresholdLineColor: Color(0xFFF8F9FA), // Ghost white line
  ),

  // ──────────────────────────────────────────────────────
  // 🗽 Nov 01 — New York City Marathon
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'nyc_marathon',
    themeName: 'NYC Marathon',
    label: 'NYC Marathon',
    subtitle: 'NOV 01 · RACE DAY',
    bannerIcon: '🗽',
    cornerIcon: '🏃',
    watermarkIcon: 'NYC',
    bannerTitle: 'NYC MARATHON',
    month: 11,
    day: 1,
    primaryStart: Color(0xFF0B1B3A), // Deep Navy
    primaryEnd: Color(0xFF1E63FF), // Marathon Blue
    accent1: Color(0xFFFFD60A), // NYC Yellow
    accent2: Color(0xFFFFFFFF), // White
    glowColor: Color(0xFFE6F0FF), // Soft City Glow
    phaseUpColor: Color(0xFF1E63FF), // Blue
    phaseDownColor: Color(0xFF0B1B3A), // Navy
    phaseHoldColor: Color(0xFFFFD60A), // Yellow
    ringGradient: [
      Color(0xFF0B1B3A),
      Color(0xFF1E63FF),
      Color(0xFFFFD60A),
      Color(0xFF0B1B3A),
    ],
    outerRingWidthAt100: 7.4, // Road loop arc
    accuracyBarGradient: [
      Color(0xFF05070C), // City Night
      Color(0xFF0B1B3A),
      Color(0xFF1E63FF),
    ],
    accuracyLowColor: Color(0xFF1D2F54), // Muted dark navy
    accuracyMidColor: Color(0xFF1E63FF),
    accuracyHighColor: Color(0xFFFFD60A),
    thresholdLineColor: Color(0xFFFFFFFF), // Bright finish line
  ),

  // ──────────────────────────────────────────────────────
  // 💀 Nov 02 — Day of the Dead
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'day_of_the_dead',
    themeName: 'Day of the Dead',
    label: 'Day of the Dead',
    subtitle: 'NOV 02 · REMEMBRANCE',
    bannerIcon: '💀',
    cornerIcon: '🌼',
    watermarkIcon: 'DOD',
    bannerTitle: 'DAY OF THE DEAD',
    month: 11,
    day: 2,
    primaryStart: Color(0xFF2A0A2F), // Deep Purple
    primaryEnd: Color(0xFFFFB703), // Marigold
    accent1: Color(0xFFC1121F), // Crimson
    accent2: Color(0xFFFFF8E7), // Bone White
    glowColor: Color(0xFFFFEAC4), // Golden ritual glow
    phaseUpColor: Color(0xFFFFB703), // Marigold
    phaseDownColor: Color(0xFFC1121F), // Crimson
    phaseHoldColor: Color(0xFF2A0A2F), // Purple
    ringGradient: [
      Color(0xFF2A0A2F),
      Color(0xFFFFB703),
      Color(0xFFC1121F),
      Color(0xFF2A0A2F),
    ],
    outerRingWidthAt100: 7.6, // Ornamental floral
    accuracyBarGradient: [
      Color(0xFF050204), // Night Ritual
      Color(0xFF2A0A2F),
      Color(0xFFFFB703),
    ],
    accuracyLowColor: Color(0xFF38152B), // Dark plum
    accuracyMidColor: Color(0xFF2A0A2F),
    accuracyHighColor: Color(0xFFFFB703),
    thresholdLineColor: Color(0xFFFFF8E7), // White glow
  ),

  // ──────────────────────────────────────────────────────
  // 🛍️ Nov 11 — Singles' Day
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'singles_day',
    themeName: 'Singles\' Day',
    label: 'Singles\' Day',
    subtitle: 'NOV 11 · GLOBAL SALE',
    bannerIcon: '🛍',
    cornerIcon: '✨',
    watermarkIcon: '11.11',
    bannerTitle: 'SINGLES\' DAY',
    month: 11,
    day: 11,
    primaryStart: Color(0xFF050505), // Jet Black
    primaryEnd: Color(0xFFFF2DAF), // Neon Pink
    accent1: Color(0xFF7B2CFF), // Electric Purple
    accent2: Color(0xFFFFFFFF), // White
    glowColor: Color(0xFFFFD1FF), // Soft neon glow
    phaseUpColor: Color(0xFFFF2DAF), // Pink
    phaseDownColor: Color(0xFF050505), // Black
    phaseHoldColor: Color(0xFF7B2CFF), // Purple
    ringGradient: [
      Color(0xFF050505),
      Color(0xFFFF2DAF),
      Color(0xFF7B2CFF),
      Color(0xFF050505),
    ],
    outerRingWidthAt100: 7.0, // Digital neon ring
    accuracyBarGradient: [
      Color(0xFF020203), // Digital Night
      Color(0xFF050505),
      Color(0xFFFF2DAF),
    ],
    accuracyLowColor: Color(0xFF2A1A33), // Muted dark tech
    accuracyMidColor: Color(0xFFFF2DAF),
    accuracyHighColor: Color(0xFF7B2CFF),
    thresholdLineColor: Color(0xFFFFFFFF), // White neon line
  ),

  // ──────────────────────────────────────────────────────
  // 🪷 Nov 24 — Loy Krathong
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'loy_krathong',
    themeName: 'Loy Krathong',
    label: 'Loy Krathong',
    subtitle: 'NOV 24 · FESTIVAL OF LIGHTS',
    bannerIcon: '🪷',
    cornerIcon: '🕯',
    watermarkIcon: 'LK',
    bannerTitle: 'LOY KRATHONG',
    month: 11,
    day: 24,
    primaryStart: Color(0xFF0A1128), // Deep Indigo
    primaryEnd: Color(0xFFFFD166), // Candle Gold
    accent1: Color(0xFFFF9AA2), // Lotus Pink
    accent2: Color(0xFF2ECC71), // Jade
    glowColor: Color(0xFFFFF3CC), // Candle soft glow
    phaseUpColor: Color(0xFFFFD166), // Gold
    phaseDownColor: Color(0xFF0A1128), // Indigo
    phaseHoldColor: Color(0xFFFF9AA2), // Pink
    ringGradient: [
      Color(0xFF0A1128),
      Color(0xFFFFD166),
      Color(0xFFFF9AA2),
      Color(0xFF0A1128),
    ],
    outerRingWidthAt100: 7.2, // Floating water ripple
    accuracyBarGradient: [
      Color(0xFF04060D), // River Night
      Color(0xFF0A1128),
      Color(0xFFFFD166),
    ],
    accuracyLowColor: Color(0xFF1A2645), // Muted river blue
    accuracyMidColor: Color(0xFF0A1128),
    accuracyHighColor: Color(0xFFFFD166),
    thresholdLineColor: Color(0xFFFFD166), // Candle glow line
  ),

  // ──────────────────────────────────────────────────────
  // 🏷️ Nov 27 — Black Friday
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'black_friday',
    themeName: 'Black Friday',
    label: 'Black Friday',
    subtitle: 'NOV 27 · GLOBAL DEALS',
    bannerIcon: '🏷',
    cornerIcon: '✨',
    watermarkIcon: 'BF',
    bannerTitle: 'BLACK FRIDAY',
    month: 11,
    day: 27,
    primaryStart: Color(0xFF000000), // Pure Black
    primaryEnd: Color(0xFFD4AF37), // Metallic Gold
    accent1: Color(0xFFFFFFFF), // Neon White
    accent2: Color(0xFFFF3B3B), // Red
    glowColor: Color(0xFFEBEBEB), // Clean white reflection
    phaseUpColor: Color(0xFFD4AF37), // Gold
    phaseDownColor: Color(0xFF000000), // Black
    phaseHoldColor: Color(0xFFFFFFFF), // White
    ringGradient: [
      Color(0xFF000000),
      Color(0xFFD4AF37),
      Color(0xFFFFFFFF),
      Color(0xFF000000),
    ],
    outerRingWidthAt100: 7.0, // Clean metallic ring
    accuracyBarGradient: [
      Color(0xFF000000), // Void Black
      Color(0xFF333333), // Dark Gray
      Color(0xFFD4AF37),
    ],
    accuracyLowColor: Color(0xFF222222), // Deep gray
    accuracyMidColor: Color(0xFFD4AF37),
    accuracyHighColor: Color(0xFFFFFFFF),
    thresholdLineColor: Color(0xFFFFFFFF), // White strike line
  ),

  // ──────────────────────────────────────────────────────
  // 🎆 Dec 31 — New Year’s Eve
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'new_year_eve',
    themeName: 'New Year’s Eve',
    label: 'New Year’s Eve',
    subtitle: 'DEC 31 · COUNTDOWN',
    bannerIcon: '🎆',
    cornerIcon: '🥂',
    watermarkIcon: 'NYE',
    bannerTitle: 'NEW YEAR’S EVE',
    month: 12,
    day: 31,
    primaryStart: Color(0xFF0A1128), // Midnight Blue
    primaryEnd: Color(0xFFFFD700), // Celebration Gold
    accent1: Color(0xFFFF4FD8), // Neon Pink
    accent2: Color(0xFFF8F9FA), // Ice White
    glowColor: Color(0xFFFFF9C4), // Golden sparkle
    phaseUpColor: Color(0xFFFFD700), // Gold
    phaseDownColor: Color(0xFF0A1128), // Blue
    phaseHoldColor: Color(0xFFFF4FD8), // Pink
    ringGradient: [
      Color(0xFF0A1128),
      Color(0xFFFFD700),
      Color(0xFFFF4FD8),
      Color(0xFF0A1128),
    ],
    outerRingWidthAt100: 7.6, // Radiant celebration ring
    accuracyBarGradient: [
      Color(0xFF02030A), // New Year Night
      Color(0xFF0A1128),
      Color(0xFFFFD700),
    ],
    accuracyLowColor: Color(0xFF1D2852), // Muted dark blue
    accuracyMidColor: Color(0xFF0A1128),
    accuracyHighColor: Color(0xFFFFD700),
    thresholdLineColor: Color(0xFFFFFFFF), // Bright celebration line
  ),

  // ──────────────────────────────────────────────────────
  // 💦 Apr 15 — Thingyan Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'thingyan_festival',
    themeName: 'Thingyan Festival',
    label: 'Thingyan Festival',
    subtitle: 'APR 13–16 · MYANMAR',
    bannerIcon: '💦',
    cornerIcon: '⛲',
    watermarkIcon: '❀',
    bannerTitle: 'THINGYAN FESTIVAL',
    month: 4,
    day: 15, // Approx middle/peak day
    startMonth: 4,
    startDay: 13,
    endMonth: 4,
    endDay: 16,
    primaryStart: Color(0xFF49C6FF), // Aqua Blue
    primaryEnd: Color(0xFF00E5FF), // Liquid Cyan
    accent1: Color(0xFFF8FBFF), // White Foam
    accent2: Color(0xFFD8B46A), // Gold Spark
    glowColor: Color(0xFFE0F7FA), // Soft cyan glow
    phaseUpColor: Color(0xFF00E5FF), // Liquid Cyan
    phaseDownColor: Color(0xFFFFB7C5), // Lotus Pink
    phaseHoldColor: Color(0xFFD8B46A), // Gold
    ringGradient: [
      Color(0xFF0B4F5C), // Deep Teal
      Color(0xFF49C6FF),
      Color(0xFFF8FBFF),
      Color(0xFF0B4F5C),
    ],
    outerRingWidthAt100: 7.2, // Liquid ripple
    accuracyBarGradient: [
      Color(0xFF050B12), // Night Water
      Color(0xFF0B4F5C),
      Color(0xFF49C6FF),
      Color(0xFF00E5FF),
    ],
    accuracyLowColor: Color(0xFF4A6B7C), // Muted steel blue
    accuracyMidColor: Color(0xFF49C6FF),
    accuracyHighColor: Color(0xFF00E5FF), // Radiant cyan bloom
    thresholdLineColor: Color(0xFFFFFFFF), // Bright white festival line
  ),

  // ──────────────────────────────────────────────────────
  // 🛶 Sep 25 — Boat Racing Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'boat_racing',
    themeName: 'Boat Racing Festival',
    label: 'Boat Racing Festival',
    subtitle: 'SEP 25 · FULL MOON DAY',
    bannerIcon: '🛶',
    cornerIcon: '🌊',
    watermarkIcon: 'RACE',
    bannerTitle: 'BOAT RACING FESTIVAL',
    month: 9,
    day: 25,
    primaryStart: Color(0xFFC8A96E), // Royal Gold
    primaryEnd: Color(0xFF0A3D62), // River Blue
    accent1: Color(0xFFF5F8FC), // Silver White
    accent2: Color(0xFF08121F), // Deep Navy
    glowColor: Color(0xFFFFD46A), // Warm Sunlight
    phaseUpColor: Color(0xFFC8A96E), // Gold
    phaseDownColor: Color(0xFF0A3D62), // River Blue
    phaseHoldColor: Color(0xFF0D8B8C), // Emerald Teal
    ringGradient: [
      Color(0xFF08121F),
      Color(0xFF0A3D62),
      Color(0xFFC8A96E),
      Color(0xFF08121F),
    ],
    outerRingWidthAt100: 7.4, // Boat wake arc
    accuracyBarGradient: [
      Color(0xFF040814), // Midnight River
      Color(0xFF0A3D62),
      Color(0xFFC8A96E),
    ],
    accuracyLowColor: Color(0xFF3B4E63), // Muted slate blue
    accuracyMidColor: Color(0xFF0A3D62),
    accuracyHighColor: Color(0xFFC8A96E),
    thresholdLineColor: Color(0xFFFFFFFF), // Bright white
  ),

  // ──────────────────────────────────────────────────────
  // 🏮 Oct 25 — Lantern Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'lantern_festival_mm',
    themeName: 'Lantern Festival',
    label: 'Lantern Festival',
    subtitle: 'OCT 25 · FULL MOON DAY',
    bannerIcon: '🏮',
    cornerIcon: '✨',
    watermarkIcon: 'FIRE',
    bannerTitle: 'LANTERN FESTIVAL',
    month: 10,
    day: 25,
    primaryStart: Color(0xFFD8A84D), // Lantern Gold
    primaryEnd: Color(0xFFFFB347), // Warm Amber
    accent1: Color(0xFFFFF8E7), // Ivory Light
    accent2: Color(0xFF8F1D21), // Deep Crimson
    glowColor: Color(0xFFFF9F43), // Soft Orange
    phaseUpColor: Color(0xFFFFB347), // Amber
    phaseDownColor: Color(0xFF8F1D21), // Crimson
    phaseHoldColor: Color(0xFFFFF8E7), // Ivory
    ringGradient: [
      Color(0xFF1A0F0A), // Midnight Brown
      Color(0xFFFFB347),
      Color(0xFFFFF8E7),
      Color(0xFF1A0F0A),
    ],
    outerRingWidthAt100: 7.2, // Lantern halo
    accuracyBarGradient: [
      Color(0xFF050402), // Temple Night
      Color(0xFF1A0F0A),
      Color(0xFFFFB347),
      Color(0xFFD8A84D),
    ],
    accuracyLowColor: Color(0xFF4A3421), // Bronze-brown
    accuracyMidColor: Color(0xFFFFB347),
    accuracyHighColor: Color(0xFFD8A84D), // Gold flare
    thresholdLineColor: Color(0xFFFFF8E7), // Ivory line
  ),

  // ──────────────────────────────────────────────────────
  // 📜 Dec 09 — Sarsodaw Pwe
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'sarsodaw_pwe',
    themeName: 'Sarsodaw Pwe',
    label: 'Sarsodaw Pwe',
    subtitle: 'DEC 09 · ROYAL LITERARY DAY',
    bannerIcon: '📜',
    cornerIcon: '🖋️',
    watermarkIcon: 'INK',
    bannerTitle: 'POETS\' FESTIVAL',
    month: 12,
    day: 9,
    primaryStart: Color(0xFF5B1A1A), // Royal Maroon
    primaryEnd: Color(0xFFC8A96E), // Antique Gold
    accent1: Color(0xFFF4E9D6), // Parchment Ivory
    accent2: Color(0xFF1A1A1A), // Ink Black
    glowColor: Color(0xFFE7D8BF), // Old Paper Beige
    phaseUpColor: Color(0xFFC8A96E), // Gold
    phaseDownColor: Color(0xFF5B1A1A), // Maroon
    phaseHoldColor: Color(0xFFF4E9D6), // Ivory
    ringGradient: [
      Color(0xFF5B1A1A),
      Color(0xFF34213D), // Deep Plum
      Color(0xFFC8A96E),
      Color(0xFF5B1A1A),
    ],
    outerRingWidthAt100: 7.0, // Scroll border
    accuracyBarGradient: [
      Color(0xFF050304), // Scholar Night
      Color(0xFF5B1A1A),
      Color(0xFFC8A96E),
      Color(0xFFF4E9D6),
    ],
    accuracyLowColor: Color(0xFF4A2F2F), // Muted brown-maroon
    accuracyMidColor: Color(0xFFC8A96E),
    accuracyHighColor: Color(0xFFF4E9D6), // Ivory flare
    thresholdLineColor: Color(0xFFF4E9D6), // Parchment-white
  ),

  // ──────────────────────────────────────────────────────
  // 🐎 Jan 02 — Horse Parade Festival
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'horse_parade',
    themeName: 'Horse Parade Festival',
    label: 'Horse Parade Festival',
    subtitle: 'JAN 02 · ROYAL PROCESSION',
    bannerIcon: '🐎',
    cornerIcon: '🛡️',
    watermarkIcon: 'RIDE',
    bannerTitle: 'HORSE PARADE',
    month: 1,
    day: 2,
    primaryStart: Color(0xFFD4AF37), // Royal Gold
    primaryEnd: Color(0xFF6B3E26), // Chestnut Brown
    accent1: Color(0xFFFFF8EA), // Ivory White
    accent2: Color(0xFF0A0A0D), // Midnight Black
    glowColor: Color(0xFFFFE0A3), // Warm gold
    phaseUpColor: Color(0xFFD4AF37), // Gold
    phaseDownColor: Color(0xFF9B1C1C), // Crimson
    phaseHoldColor: Color(0xFF4D5563), // Steel Gray
    ringGradient: [
      Color(0xFF6B3E26),
      Color(0xFFD4AF37),
      Color(0xFFFFF8EA),
      Color(0xFF6B3E26),
    ],
    outerRingWidthAt100: 7.6, // Galloping arc
    accuracyBarGradient: [
      Color(0xFF050403), // Parade Night
      Color(0xFF6B3E26),
      Color(0xFFD4AF37),
      Color(0xFFFFF8EA),
    ],
    accuracyLowColor: Color(0xFF4D403A), // Muted brown-gray
    accuracyMidColor: Color(0xFFD4AF37),
    accuracyHighColor: Color(0xFFFFF8EA), // Ivory blast
    thresholdLineColor: Color(0xFFFFFFFF), // White finish
  ),

  // ──────────────────────────────────────────────────────
  // 🍚 Feb 01 — Sticky Rice Festival (Tabaung)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'sticky_rice_festival',
    themeName: 'Sticky Rice Festival',
    label: 'Sticky Rice Festival',
    subtitle: 'FEB 01 · FULL MOON DAY',
    bannerIcon: '🍚',
    cornerIcon: '✨',
    watermarkIcon: 'RICE',
    bannerTitle: 'STICKY RICE FESTIVAL',
    month: 2,
    day: 1,
    primaryStart: Color(0xFF24112D), // Deep Plum
    primaryEnd: Color(0xFF6E44FF), // Gloss Violet
    accent1: Color(0xFFD8B46A), // Silk Gold
    accent2: Color(0xFFF7F1E8), // Cream White
    glowColor: Color(0xFF8B6BFF), // Soft purple glow
    phaseUpColor: Color(0xFF6E44FF), // Violet
    phaseDownColor: Color(0xFF4A2C2A), // Warm Brown
    phaseHoldColor: Color(0xFFD8B46A), // Silk Gold
    ringGradient: [
      Color(0xFF24112D),
      Color(0xFF6E44FF),
      Color(0xFFD8B46A),
      Color(0xFF24112D),
    ],
    outerRingWidthAt100: 7.4, // Viscous fluid circle
    accuracyBarGradient: [
      Color(0xFF040309), // Velvet Night
      Color(0xFF24112D),
      Color(0xFF6E44FF),
      Color(0xFFD8B46A),
    ],
    accuracyLowColor: Color(0xFF33213F), // Charcoal-purple
    accuracyMidColor: Color(0xFF6E44FF),
    accuracyHighColor: Color(0xFFD8B46A), // Gold syrup flare
    thresholdLineColor: Color(0xFFF7F1E8), // Cream-white
  ),

  // ──────────────────────────────────────────────────────
  // 🎭 Mar 03 — Purim (Jewish)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'purim',
    themeName: 'Purim',
    label: 'Purim',
    subtitle: 'MAR 03 · FESTIVAL CELEBRATION',
    bannerIcon: '🎭',
    cornerIcon: '✨',
    watermarkIcon: 'JOY',
    bannerTitle: 'PURIM',
    month: 3,
    day: 3,
    primaryStart: Color(0xFF1E3A8A), // Royal Blue
    primaryEnd: Color(0xFFD4AF37), // Festival Gold
    accent1: Color(0xFFF8F3E7), // Cream Ivory
    accent2: Color(0xFF7A1F2B), // Deep Burgundy
    glowColor: Color(0xFFE6F0FA), // Soft bright glow
    phaseUpColor: Color(0xFFD4AF37), // Gold
    phaseDownColor: Color(0xFF7A1F2B), // Burgundy
    phaseHoldColor: Color(0xFF2C7A7B), // Soft Teal
    ringGradient: [
      Color(0xFF1E3A8A),
      Color(0xFFD4AF37),
      Color(0xFFF8F3E7),
      Color(0xFF1E3A8A),
    ],
    outerRingWidthAt100: 7.2, // Ornate minimal frame
    accuracyBarGradient: [
      Color(0xFF05060A), // Midnight Velvet
      Color(0xFF1E3A8A),
      Color(0xFFD4AF37),
      Color(0xFFF8F3E7),
    ],
    accuracyLowColor: Color(0xFF2C3E50), // Muted slate blue
    accuracyMidColor: Color(0xFFD4AF37),
    accuracyHighColor: Color(0xFFF8F3E7), // Ivory glow
    thresholdLineColor: Color(0xFFFFFFFF), // Bright ivory celebration line
  ),

  // ──────────────────────────────────────────────────────
  // 🎨 Mar 04 — Holi (Hindu)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'holi',
    themeName: 'Holi',
    label: 'Holi',
    subtitle: 'MAR 04 · FESTIVAL OF COLORS',
    bannerIcon: '🎨',
    cornerIcon: '🌸',
    watermarkIcon: 'COLOR',
    bannerTitle: 'HOLI',
    month: 3,
    day: 4,
    primaryStart: Color(0xFFD81B60), // Magenta
    primaryEnd: Color(0xFFF6A623), // Saffron
    accent1: Color(0xFF2EC4C7), // Turquoise
    accent2: Color(0xFFA3E635), // Lime
    glowColor: Color(0xFFFFEBF0), // Soft pink glow
    phaseUpColor: Color(0xFF2EC4C7), // Turquoise
    phaseDownColor: Color(0xFFD81B60), // Magenta
    phaseHoldColor: Color(0xFFF6A623), // Saffron
    ringGradient: [
      Color(0xFF7C3AED), // Violet
      Color(0xFFD81B60), // Magenta
      Color(0xFFF6A623), // Saffron
      Color(0xFFA3E635), // Lime
    ],
    outerRingWidthAt100: 7.6, // Color burst halo
    accuracyBarGradient: [
      Color(0xFF050408), // Deep Night
      Color(0xFF4A148C), // Deep Indigo
      Color(0xFFD81B60),
      Color(0xFFF6A623),
    ],
    accuracyLowColor: Color(0xFF4A235A), // Muted plum
    accuracyMidColor: Color(0xFFD81B60),
    accuracyHighColor: Color(0xFFF6A623), // Radiant saffron
    thresholdLineColor: Color(0xFFFFFFFF), // Bright ivory-white
  ),

  // ──────────────────────────────────────────────────────
  // ☘️ Mar 17 — St. Patrick’s Day (Irish/Christian)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'st_patricks_day',
    themeName: 'St. Patrick’s Day',
    label: 'St. Patrick’s Day',
    subtitle: 'MAR 17 · IRISH CELEBRATION',
    bannerIcon: '☘️',
    cornerIcon: '✨',
    watermarkIcon: 'LUCK',
    bannerTitle: 'ST. PATRICK’S DAY',
    month: 3,
    day: 17,
    primaryStart: Color(0xFF0F7B3A), // Emerald Green
    primaryEnd: Color(0xFF2ECC71), // Shamrock Green
    accent1: Color(0xFFD4AF37), // Gold
    accent2: Color(0xFFF7F3E8), // Cream White
    glowColor: Color(0xFFE8F8F5), // Soft green glow
    phaseUpColor: Color(0xFF0F7B3A), // Emerald
    phaseDownColor: Color(0xFFD4AF37), // Gold
    phaseHoldColor: Color(0xFFF7F3E8), // Cream
    ringGradient: [
      Color(0xFF123524), // Forest
      Color(0xFF0F7B3A), // Emerald
      Color(0xFFD4AF37), // Gold
      Color(0xFF123524),
    ],
    outerRingWidthAt100: 7.2, // Celtic ring
    accuracyBarGradient: [
      Color(0xFF050A08), // Midnight Clover
      Color(0xFF123524), // Forest
      Color(0xFF0F7B3A), // Emerald
      Color(0xFFD4AF37), // Gold
    ],
    accuracyLowColor: Color(0xFF2E4035), // Muted green-gray
    accuracyMidColor: Color(0xFF0F7B3A),
    accuracyHighColor: Color(0xFFD4AF37), // Gold glow
    thresholdLineColor: Color(0xFFF7F3E8), // Cream-white
  ),

  // ──────────────────────────────────────────────────────
  // 🌙 Mar 20 — Eid al-Fitr (Muslim)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'eid_al_fitr',
    themeName: 'Eid al-Fitr',
    label: 'Eid al-Fitr',
    subtitle: 'MAR 20 · CELEBRATION OF JOY',
    bannerIcon: '🌙',
    cornerIcon: '✨',
    watermarkIcon: 'EID',
    bannerTitle: 'EID AL-FITR',
    month: 3,
    day: 20,
    primaryStart: Color(0xFFD6B15E), // Crescent Gold
    primaryEnd: Color(0xFF102A43), // Midnight Blue
    accent1: Color(0xFFFFF8E7), // Ivory
    accent2: Color(0xFF2E8B57), // Emerald
    glowColor: Color(0xFFFDFBF7), // Warm light
    phaseUpColor: Color(0xFFD6B15E), // Gold
    phaseDownColor: Color(0xFF2E8B57), // Emerald
    phaseHoldColor: Color(0xFFFFF8E7), // Ivory
    ringGradient: [
      Color(0xFF102A43),
      Color(0xFFD6B15E),
      Color(0xFFFFF8E7),
      Color(0xFF102A43),
    ],
    outerRingWidthAt100: 7.0, // Geometric halo
    accuracyBarGradient: [
      Color(0xFF050814), // Ramadan Night
      Color(0xFF102A43), // Navy
      Color(0xFFD6B15E), // Gold
      Color(0xFFFFF8E7), // Ivory
    ],
    accuracyLowColor: Color(0xFF2B3A50), // Muted slate blue
    accuracyMidColor: Color(0xFFD6B15E),
    accuracyHighColor: Color(0xFFFFF8E7), // Ivory shine
    thresholdLineColor: Color(0xFFFFFFFF), // Bright ivory
  ),

  // ──────────────────────────────────────────────────────
  // 🥚 Apr 05 — Easter (Christian)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'easter',
    themeName: 'Easter',
    label: 'Easter',
    subtitle: 'APR 05 · SPRING CELEBRATION',
    bannerIcon: '🥚',
    cornerIcon: '🐰',
    watermarkIcon: '✝',
    bannerTitle: 'EASTER',
    month: 4,
    day: 5,
    primaryStart: Color(0xFFD7B56D), // Soft Gold
    primaryEnd: Color(0xFF7EC8E3), // Sky Blue
    accent1: Color(0xFFFFF9F1), // Ivory White
    accent2: Color(0xFFF4B6C2), // Pastel Pink
    glowColor: Color(0xFFF0F8FF), // Soft sky glow
    phaseUpColor: Color(0xFF7EC8E3), // Sky Blue
    phaseDownColor: Color(0xFFF4B6C2), // Pastel Pink
    phaseHoldColor: Color(0xFFD7B56D), // Gold
    ringGradient: [
      Color(0xFF7EC8E3),
      Color(0xFFD7B56D),
      Color(0xFFFFF9F1),
      Color(0xFF7EC8E3),
    ],
    outerRingWidthAt100: 7.2, // Spring wreath
    accuracyBarGradient: [
      Color(0xFF05070D), // Midnight Spring
      Color(0xFF7EC8E3), // Blue
      Color(0xFFD7B56D), // Gold
      Color(0xFFFFF9F1), // Ivory
    ],
    accuracyLowColor: Color(0xFF3B4E63), // Muted blue-gray
    accuracyMidColor: Color(0xFFD7B56D),
    accuracyHighColor: Color(0xFFFFF9F1), // Ivory bloom
    thresholdLineColor: Color(0xFFFFFFFF), // Bright ivory spring
  ),

  // ──────────────────────────────────────────────────────
  // 🌾 Apr 14 — Vaisakhi (Sikh)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'vaisakhi',
    themeName: 'Vaisakhi',
    label: 'Vaisakhi',
    subtitle: 'APR 14 · HARVEST CELEBRATION',
    bannerIcon: '🌾',
    cornerIcon: '✨',
    watermarkIcon: 'HARVEST',
    bannerTitle: 'VAISAKHI',
    month: 4,
    day: 14,
    primaryStart: Color(0xFFD4AF37), // Harvest Gold
    primaryEnd: Color(0xFFE8A317), // Deep Saffron
    accent1: Color(0xFF1E3A8A), // Royal Blue
    accent2: Color(0xFFFFF8EA), // Ivory
    glowColor: Color(0xFFFFF9E6), // Warm harvest
    phaseUpColor: Color(0xFFD4AF37), // Gold
    phaseDownColor: Color(0xFF1E3A8A), // Blue
    phaseHoldColor: Color(0xFF2E8B57), // Green
    ringGradient: [
      Color(0xFF1E3A8A),
      Color(0xFFD4AF37),
      Color(0xFFFFF8EA),
      Color(0xFF1E3A8A),
    ],
    outerRingWidthAt100: 7.4, // Wheat wreath
    accuracyBarGradient: [
      Color(0xFF050605), // Midnight Harvest
      Color(0xFF1E3A8A),
      Color(0xFFD4AF37),
      Color(0xFFFFF8EA),
    ],
    accuracyLowColor: Color(0xFF2A3C59), // Muted blue-gray
    accuracyMidColor: Color(0xFFD4AF37),
    accuracyHighColor: Color(0xFFFFF8EA), // Ivory bloom
    thresholdLineColor: Color(0xFFFFFFFF), // Ivory harvest line
  ),

  // ──────────────────────────────────────────────────────
  // 🕌 May 27 — Eid al-Adha (Muslim)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'eid_al_adha',
    themeName: 'Eid al-Adha',
    label: 'Eid al-Adha',
    subtitle: 'MAY 27 · SACRED CELEBRATION',
    bannerIcon: '🕌',
    cornerIcon: '✨',
    watermarkIcon: 'EID',
    bannerTitle: 'EID AL-ADHA',
    month: 5,
    day: 27,
    primaryStart: Color(0xFF0E223D), // Midnight Blue
    primaryEnd: Color(0xFFD8B46A), // Gold Sand
    accent1: Color(0xFFFFF9F0), // Ivory
    accent2: Color(0xFF2F6B4F), // Deep Green
    glowColor: Color(0xFFF5F1E9), // Clean soft glow
    phaseUpColor: Color(0xFFD8B46A), // Gold
    phaseDownColor: Color(0xFF2F6B4F), // Green
    phaseHoldColor: Color(0xFFFFF9F0), // Ivory
    ringGradient: [
      Color(0xFF0E223D), // Midnight Blue
      Color(0xFFD8B46A), // Gold Sand
      Color(0xFFFFF9F0), // Ivory
      Color(0xFF0E223D),
    ],
    outerRingWidthAt100: 7.0, // Geometric halo
    accuracyBarGradient: [
      Color(0xFF040812), // Sacred Night
      Color(0xFF0E223D),
      Color(0xFFD8B46A),
      Color(0xFFFFF9F0),
    ],
    accuracyLowColor: Color(0xFF293B4D), // Slate blue-gray
    accuracyMidColor: Color(0xFFD8B46A),
    accuracyHighColor: Color(0xFFFFF9F0), // Ivory flare
    thresholdLineColor: Color(0xFFFFFFFF), // Sacred line
  ),

  // ──────────────────────────────────────────────────────
  // 🪔 Nov 08 — Diwali (Hindu)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'diwali',
    themeName: 'Diwali',
    label: 'Diwali',
    subtitle: 'NOV 08 · FESTIVAL OF LIGHTS',
    bannerIcon: '🪔',
    cornerIcon: '✨',
    watermarkIcon: 'LIGHT',
    bannerTitle: 'DIWALI',
    month: 11,
    day: 8,
    primaryStart: Color(0xFFB35C1E), // Deep Amber
    primaryEnd: Color(0xFFF4C542), // Festival Gold
    accent1: Color(0xFFA61E4D), // Crimson
    accent2: Color(0xFFFFF8E8), // Ivory
    glowColor: Color(0xFFFFF1CC), // Warm flame glow
    phaseUpColor: Color(0xFFF4C542), // Gold
    phaseDownColor: Color(0xFFA61E4D), // Crimson
    phaseHoldColor: Color(0xFF5B2C83), // Violet
    ringGradient: [
      Color(0xFF1A0A05), // Temple Night basis
      Color(0xFFB35C1E), // Amber
      Color(0xFFF4C542), // Gold
      Color(0xFFFFF8E8), // Ivory
    ],
    outerRingWidthAt100: 7.4, // Light point halo
    accuracyBarGradient: [
      Color(0xFF050307), // Temple Night
      Color(0xFFB35C1E), // Amber
      Color(0xFFF4C542), // Gold
      Color(0xFFFFF8E8), // Ivory
    ],
    accuracyLowColor: Color(0xFF4A2E1A), // Muted brown-amber
    accuracyMidColor: Color(0xFFF4C542),
    accuracyHighColor: Color(0xFFFFF8E8), // Ivory glow
    thresholdLineColor: Color(0xFFFFFFFF), // Flame line
  ),

  // ──────────────────────────────────────────────────────
  // 🕎 Dec 05 — Hanukkah (Jewish)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'hanukkah',
    themeName: 'Hanukkah',
    label: 'Hanukkah',
    subtitle: 'DEC 05 · FESTIVAL OF LIGHTS',
    bannerIcon: '🕎',
    cornerIcon: '✨',
    watermarkIcon: 'GLOW',
    bannerTitle: 'HANUKKAH',
    month: 12,
    day: 5,
    primaryStart: Color(0xFF12315B), // Midnight Blue
    primaryEnd: Color(0xFFD4AF37), // Candle Gold
    accent1: Color(0xFFFFF8EA), // Ivory
    accent2: Color(0xFFC0C7D1), // Silver
    glowColor: Color(0xFFE8F0FA), // Soft blue-gold light
    phaseUpColor: Color(0xFFD4AF37), // Gold
    phaseDownColor: Color(0xFF4EA8A3), // Teal
    phaseHoldColor: Color(0xFFFFF8EA), // Ivory
    ringGradient: [
      Color(0xFF081423), // Deep Navy
      Color(0xFF12315B), // Navy
      Color(0xFFD4AF37), // Gold
      Color(0xFFFFF8EA), // Ivory
    ],
    outerRingWidthAt100: 7.2, // Candle halo
    accuracyBarGradient: [
      Color(0xFF040815), // Night Light
      Color(0xFF12315B),
      Color(0xFFD4AF37),
      Color(0xFFFFF8EA),
    ],
    accuracyLowColor: Color(0xFF293B52), // Muted slate blue
    accuracyMidColor: Color(0xFFD4AF37),
    accuracyHighColor: Color(0xFFFFF8EA), // Ivory shine
    thresholdLineColor: Color(0xFFFFFFFF), // Light line
  ),

  // ──────────────────────────────────────────────────────
  // 🎄 Dec 25 — Christmas (Christian)
  // ──────────────────────────────────────────────────────
  WorldFestivalVisualStyle(
    storageKey: 'christmas',
    themeName: 'Christmas',
    label: 'Christmas',
    subtitle: 'DEC 25 · HOLIDAY CELEBRATION',
    bannerIcon: '🎄',
    cornerIcon: '❄️',
    watermarkIcon: 'XMAS',
    bannerTitle: 'CHRISTMAS',
    month: 12,
    day: 25,
    primaryStart: Color(0xFF1F5E3B), // Pine Green
    primaryEnd: Color(0xFFB22234), // Holiday Red
    accent1: Color(0xFFD4AF37), // Gold
    accent2: Color(0xFFF8F7F2), // Snow Ivory
    glowColor: Color(0xFFFFF8ED), // Soft holiday glow
    phaseUpColor: Color(0xFFD4AF37), // Gold
    phaseDownColor: Color(0xFF8A1538), // Berry Red
    phaseHoldColor: Color(0xFFF8F7F2), // Snow Ivory
    ringGradient: [
      Color(0xFF1F5E3B), // Pine Green
      Color(0xFFB22234), // Holiday Red
      Color(0xFFD4AF37), // Gold
      Color(0xFFF8F7F2), // Ivory
    ],
    outerRingWidthAt100: 7.4, // Evergreen wreath
    accuracyBarGradient: [
      Color(0xFF05070D), // Winter Night
      Color(0xFF1F5E3B), // Pine
      Color(0xFFD4AF37), // Gold
      Color(0xFFF8F7F2), // Ivory
    ],
    accuracyLowColor: Color(0xFF2C3E34), // Muted forest gray
    accuracyMidColor: Color(0xFFD4AF37),
    accuracyHighColor: Color(0xFFF8F7F2), // Ivory glow
    thresholdLineColor: Color(0xFFFFFFFF), // Winter line
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// DATE-BASED RESOLVER
// ═══════════════════════════════════════════════════════════════════════════════

/// Returns the World Festival theme that should be active for the given [date].
///
/// Logic:
/// 1. If today IS a festival day → return that festival.
/// 2. Otherwise find the nearest upcoming festival. If the gap between the
///    previous festival and the next is small enough, "pre-show" the next one
///    on the intervening days.
/// 3. Wraps around across the year boundary (Dec → Jan).
WorldFestivalVisualStyle worldFestivalForDate(DateTime date) {
  if (worldFestivals.isEmpty) {
    throw StateError('No world festivals defined');
  }

  final todayValue = date.month * 100 + date.day;
  final sortedFestivals = [...worldFestivals]
    ..sort((a, b) => _festivalStartValue(a).compareTo(_festivalStartValue(b)));

  // Check for an exact or date-range match first.
  for (final festival in sortedFestivals) {
    if (_isDateWithinFestival(date, festival)) {
      return festival;
    }
  }

  // Build sorted day-of-year values for binary-style search.
  final festivalValues = sortedFestivals
      .map(_festivalStartValue)
      .toList(growable: false);

  // Find the next upcoming festival (wrapping at year boundary).
  int nextIndex = -1;
  for (int i = 0; i < festivalValues.length; i++) {
    if (festivalValues[i] > todayValue) {
      nextIndex = i;
      break;
    }
  }
  // If no future festival found this year, wrap to first festival next year.
  if (nextIndex == -1) {
    nextIndex = 0;
  }

  return sortedFestivals[nextIndex];
}

/// Convenience helper: returns the visual style if the user has selected the
/// World Festival program, otherwise null.
WorldFestivalVisualStyle? worldFestivalVisualStyleForDate(DateTime date) {
  return worldFestivalForDate(date);
}
