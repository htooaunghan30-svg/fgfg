enum ZodiacSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces,
}

class ZodiacVisualStyle {
  final ZodiacSign sign;
  final String storageKey;
  final String label;
  final String symbol;
  final String title;

  const ZodiacVisualStyle({
    required this.sign,
    required this.storageKey,
    required this.label,
    required this.symbol,
    required this.title,
  });
}

const Map<ZodiacSign, ZodiacVisualStyle> zodiacVisualStyles =
    <ZodiacSign, ZodiacVisualStyle>{
  ZodiacSign.aries: ZodiacVisualStyle(
    sign: ZodiacSign.aries,
    storageKey: 'aries',
    label: 'Aries',
    symbol: '\u2648',
    title: 'Aries Ember Gratitude',
  ),
  ZodiacSign.taurus: ZodiacVisualStyle(
    sign: ZodiacSign.taurus,
    storageKey: 'taurus',
    label: 'Taurus',
    symbol: '\u2649',
    title: 'Taurus Velvet Abundance',
  ),
  ZodiacSign.gemini: ZodiacVisualStyle(
    sign: ZodiacSign.gemini,
    storageKey: 'gemini',
    label: 'Gemini',
    symbol: '\u264A',
    title: 'Gemini Celestial Echo',
  ),
  ZodiacSign.cancer: ZodiacVisualStyle(
    sign: ZodiacSign.cancer,
    storageKey: 'cancer',
    label: 'Cancer',
    symbol: '\u264B',
    title: 'Cancer Moonlit Blessing',
  ),
  ZodiacSign.leo: ZodiacVisualStyle(
    sign: ZodiacSign.leo,
    storageKey: 'leo',
    label: 'Leo',
    symbol: '\u264C',
    title: 'Leo Solar Majesty',
  ),
  ZodiacSign.virgo: ZodiacVisualStyle(
    sign: ZodiacSign.virgo,
    storageKey: 'virgo',
    label: 'Virgo',
    symbol: '\u264D',
    title: 'Virgo Verdant Devotion',
  ),
  ZodiacSign.libra: ZodiacVisualStyle(
    sign: ZodiacSign.libra,
    storageKey: 'libra',
    label: 'Libra',
    symbol: '\u264E',
    title: 'Libra Rose Harmony',
  ),
  ZodiacSign.scorpio: ZodiacVisualStyle(
    sign: ZodiacSign.scorpio,
    storageKey: 'scorpio',
    label: 'Scorpio',
    symbol: '\u264F',
    title: 'Scorpio Nocturne Grace',
  ),
  ZodiacSign.sagittarius: ZodiacVisualStyle(
    sign: ZodiacSign.sagittarius,
    storageKey: 'sagittarius',
    label: 'Sagittarius',
    symbol: '\u2650',
    title: 'Sagittarius Golden Horizon',
  ),
  ZodiacSign.capricorn: ZodiacVisualStyle(
    sign: ZodiacSign.capricorn,
    storageKey: 'capricorn',
    label: 'Capricorn',
    symbol: '\u2651',
    title: 'Capricorn Regal Ascent',
  ),
  ZodiacSign.aquarius: ZodiacVisualStyle(
    sign: ZodiacSign.aquarius,
    storageKey: 'aquarius',
    label: 'Aquarius',
    symbol: '\u2652',
    title: 'Aquarius Starlit Vision',
  ),
  ZodiacSign.pisces: ZodiacVisualStyle(
    sign: ZodiacSign.pisces,
    storageKey: 'pisces',
    label: 'Pisces',
    symbol: '\u2653',
    title: 'Pisces Dreamwater Reverie',
  ),
};

ZodiacSign zodiacSignForDate(DateTime date) {
  final value = (date.month * 100) + date.day;

  if (value >= 321 && value <= 419) return ZodiacSign.aries;
  if (value >= 420 && value <= 520) return ZodiacSign.taurus;
  if (value >= 521 && value <= 620) return ZodiacSign.gemini;
  if (value >= 621 && value <= 722) return ZodiacSign.cancer;
  if (value >= 723 && value <= 822) return ZodiacSign.leo;
  if (value >= 823 && value <= 922) return ZodiacSign.virgo;
  if (value >= 923 && value <= 1022) return ZodiacSign.libra;
  if (value >= 1023 && value <= 1121) return ZodiacSign.scorpio;
  if (value >= 1122 && value <= 1221) return ZodiacSign.sagittarius;
  if (value >= 1222 || value <= 119) return ZodiacSign.capricorn;
  if (value >= 120 && value <= 218) return ZodiacSign.aquarius;
  return ZodiacSign.pisces;
}

ZodiacVisualStyle zodiacVisualStyleForDate(DateTime date) {
  return zodiacVisualStyles[zodiacSignForDate(date)]!;
}
