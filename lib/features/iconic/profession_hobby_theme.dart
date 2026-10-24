import 'package:flutter/material.dart';

import 'world_festival.dart';

const String defaultProfessionThemeKey = 'profession_electrical_engineer';

const List<WorldFestivalVisualStyle> professionHobbyThemes = [
  WorldFestivalVisualStyle(
    storageKey: 'profession_electrical_engineer',
    themeName: 'Voltage Precision Interface',
    label: 'Electrical Engineer',
    subtitle: 'VOLTAGE | SIGNAL | RELAY',
    bannerIcon: 'V',
    cornerIcon: 'ELEC',
    watermarkIcon: 'V+',
    bannerTitle: 'VOLTAGE PRECISION',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF10151F),
    primaryEnd: Color(0xFF1F2A39),
    accent1: Color(0xFF18D8FF),
    accent2: Color(0xFFFFB648),
    glowColor: Color(0xFFA780FF),
    phaseUpColor: Color(0xFF18D8FF),
    phaseDownColor: Color(0xFFFFB648),
    phaseHoldColor: Color(0xFFA780FF),
    ringGradient: [
      Color(0xFF18D8FF),
      Color(0xFFA780FF),
      Color(0xFFFFB648),
      Color(0xFF18D8FF),
    ],
    outerRingWidthAt100: 7.8,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0E121A),
      Color(0xFF11334A),
      Color(0xFF18D8FF),
    ],
    accuracyLowColor: Color(0xFF4E6E82),
    accuracyMidColor: Color(0xFFA780FF),
    accuracyHighColor: Color(0xFF18D8FF),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_mechanical_engineer',
    themeName: 'Torque Calibration Interface',
    label: 'Mechanical Engineer',
    subtitle: 'TORQUE | ALIGNMENT | LOAD',
    bannerIcon: 'TQ',
    cornerIcon: 'MECH',
    watermarkIcon: 'ME',
    bannerTitle: 'TORQUE CALIBRATION',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF1D1F23),
    primaryEnd: Color(0xFF373A40),
    accent1: Color(0xFFC9A257),
    accent2: Color(0xFFD4D8DE),
    glowColor: Color(0xFFB67A32),
    phaseUpColor: Color(0xFFD4D8DE),
    phaseDownColor: Color(0xFFCA4A3D),
    phaseHoldColor: Color(0xFFC9A257),
    ringGradient: [
      Color(0xFFD4D8DE),
      Color(0xFFC9A257),
      Color(0xFF6D727C),
      Color(0xFFD4D8DE),
    ],
    outerRingWidthAt100: 8.1,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF1A1C20),
      Color(0xFF565D66),
      Color(0xFFC9A257),
    ],
    accuracyLowColor: Color(0xFF8A3B36),
    accuracyMidColor: Color(0xFFB67A32),
    accuracyHighColor: Color(0xFFD4D8DE),
    thresholdLineColor: Color(0xFFEFE7D2),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_civil_engineer',
    themeName: 'Blueprint & Precision',
    label: 'Civil Engineer',
    subtitle: 'BLUEPRINT | LEVEL | STRUCTURE',
    bannerIcon: 'CE',
    cornerIcon: 'CIV',
    watermarkIcon: 'GRID',
    bannerTitle: 'BLUEPRINT PRECISION',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF111111),
    primaryEnd: Color(0xFF1A1A1A),
    accent1: Color(0xFFD4AF37),
    accent2: Color(0xFFFF3333),
    glowColor: Color(0xFFFF3333),
    phaseUpColor: Color(0xFFD4AF37),
    phaseDownColor: Color(0xFFFF3333),
    phaseHoldColor: Color(0xFFE2C275),
    ringGradient: [
      Color(0xFFD4AF37),
      Color(0xFFFF3333),
      Color(0xFF2A2A2A),
      Color(0xFFD4AF37),
    ],
    outerRingWidthAt100: 7.4,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0A0A0A),
      Color(0xFF1A1A1A),
      Color(0xFFD4AF37),
    ],
    accuracyLowColor: Color(0xFF333333),
    accuracyMidColor: Color(0xFFFF3333),
    accuracyHighColor: Color(0xFFD4AF37),
    thresholdLineColor: Color(0xFFD4AF37),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_doctor',
    themeName: 'Clinical Vital Matrix',
    label: 'Doctor',
    subtitle: 'VITALS | ECG | DIAGNOSTIC',
    bannerIcon: 'MD',
    cornerIcon: 'DOC',
    watermarkIcon: 'ECG',
    bannerTitle: 'CLINICAL PRECISION',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0E1A2B),
    primaryEnd: Color(0xFF13263D),
    accent1: Color(0xFFDCE6F0),
    accent2: Color(0xFF35BFC8),
    glowColor: Color(0xFFE46D7A),
    phaseUpColor: Color(0xFF35BFC8),
    phaseDownColor: Color(0xFFE46D7A),
    phaseHoldColor: Color(0xFFDCE6F0),
    ringGradient: [
      Color(0xFFDCE6F0),
      Color(0xFF35BFC8),
      Color(0xFF5E7391),
      Color(0xFFDCE6F0),
    ],
    outerRingWidthAt100: 7.8,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0C1421),
      Color(0xFF22384F),
      Color(0xFF35BFC8),
    ],
    accuracyLowColor: Color(0xFF5F748C),
    accuracyMidColor: Color(0xFF35BFC8),
    accuracyHighColor: Color(0xFFDCE6F0),
    thresholdLineColor: Color(0xFFE46D7A),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_nurse',
    themeName: 'Care Monitor Interface',
    label: 'Nurse',
    subtitle: 'CARE | MONITOR | ASSIST',
    bannerIcon: 'RN',
    cornerIcon: 'CARE',
    watermarkIcon: 'HEAL',
    bannerTitle: 'CARE PRECISION',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF10223A),
    primaryEnd: Color(0xFF1A3553),
    accent1: Color(0xFFE3F4FF),
    accent2: Color(0xFF48C1C8),
    glowColor: Color(0xFFFF8F86),
    phaseUpColor: Color(0xFF48C1C8),
    phaseDownColor: Color(0xFFFF8F86),
    phaseHoldColor: Color(0xFFE3F4FF),
    ringGradient: [
      Color(0xFFE3F4FF),
      Color(0xFF48C1C8),
      Color(0xFF4D86BC),
      Color(0xFFE3F4FF),
    ],
    outerRingWidthAt100: 7.6,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0F1A2B),
      Color(0xFF1D4268),
      Color(0xFF48C1C8),
    ],
    accuracyLowColor: Color(0xFF5F7B98),
    accuracyMidColor: Color(0xFF48C1C8),
    accuracyHighColor: Color(0xFFE3F4FF),
    thresholdLineColor: Color(0xFFFFB1AA),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_pharmacist',
    themeName: 'Molecular Dose Matrix',
    label: 'Pharmacist',
    subtitle: 'DOSAGE | LATTICE | CONTROL',
    bannerIcon: 'RX',
    cornerIcon: 'PHARM',
    watermarkIcon: 'LAB',
    bannerTitle: 'MOLECULAR PRECISION',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF111E23),
    primaryEnd: Color(0xFF1C2E35),
    accent1: Color(0xFF56B984),
    accent2: Color(0xFFF0C26E),
    glowColor: Color(0xFFE6EEF4),
    phaseUpColor: Color(0xFF56B984),
    phaseDownColor: Color(0xFFF0C26E),
    phaseHoldColor: Color(0xFFE6EEF4),
    ringGradient: [
      Color(0xFF56B984),
      Color(0xFFE6EEF4),
      Color(0xFF3A545E),
      Color(0xFF56B984),
    ],
    outerRingWidthAt100: 7.8,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF10171B),
      Color(0xFF1D3A35),
      Color(0xFF56B984),
    ],
    accuracyLowColor: Color(0xFF607378),
    accuracyMidColor: Color(0xFF56B984),
    accuracyHighColor: Color(0xFFE6EEF4),
    thresholdLineColor: Color(0xFFF0C26E),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_software_developer',
    themeName: 'Code Flux Interface',
    label: 'Software Developer',
    subtitle: 'CODE | BUILD | DEPLOY',
    bannerIcon: 'DEV',
    cornerIcon: 'CODE',
    watermarkIcon: 'SYS',
    bannerTitle: 'CODE FLUX',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0F172A),
    primaryEnd: Color(0xFF1D2A44),
    accent1: Color(0xFF37D0FF),
    accent2: Color(0xFFB9CBFF),
    glowColor: Color(0xFF59E58C),
    phaseUpColor: Color(0xFF37D0FF),
    phaseDownColor: Color(0xFF59E58C),
    phaseHoldColor: Color(0xFFB9CBFF),
    ringGradient: [
      Color(0xFF37D0FF),
      Color(0xFFB9CBFF),
      Color(0xFF344461),
      Color(0xFF37D0FF),
    ],
    outerRingWidthAt100: 7.5,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0A1120),
      Color(0xFF1A3356),
      Color(0xFF37D0FF),
    ],
    accuracyLowColor: Color(0xFF5F728F),
    accuracyMidColor: Color(0xFF37D0FF),
    accuracyHighColor: Color(0xFF59E58C),
    thresholdLineColor: Color(0xFFB9CBFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_data_scientist',
    themeName: 'Model Insight Matrix',
    label: 'Data Scientist',
    subtitle: 'MODEL | LATENCY | CONFIDENCE',
    bannerIcon: 'DS',
    cornerIcon: 'DATA',
    watermarkIcon: 'ML',
    bannerTitle: 'MODEL INSIGHT',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0A1221),
    primaryEnd: Color(0xFF1A2340),
    accent1: Color(0xFF2FD4FF),
    accent2: Color(0xFFB37CFF),
    glowColor: Color(0xFF8FE3FF),
    phaseUpColor: Color(0xFF2FD4FF),
    phaseDownColor: Color(0xFFB37CFF),
    phaseHoldColor: Color(0xFF8FE3FF),
    ringGradient: [
      Color(0xFF2FD4FF),
      Color(0xFFB37CFF),
      Color(0xFF344873),
      Color(0xFF2FD4FF),
    ],
    outerRingWidthAt100: 7.9,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF08111E),
      Color(0xFF1B2D4A),
      Color(0xFF2FD4FF),
    ],
    accuracyLowColor: Color(0xFF546788),
    accuracyMidColor: Color(0xFF2FD4FF),
    accuracyHighColor: Color(0xFFB37CFF),
    thresholdLineColor: Color(0xFF8FE3FF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_human_resource',
    themeName: 'People Alignment Matrix',
    label: 'Human Resource',
    subtitle: 'CULTURE | ENGAGEMENT | BALANCED',
    bannerIcon: 'HR',
    cornerIcon: 'HR',
    watermarkIcon: 'TEAM',
    bannerTitle: 'PEOPLE ALIGNMENT',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF121A25),
    primaryEnd: Color(0xFF233346),
    accent1: Color(0xFFE5D4AE),
    accent2: Color(0xFF6DC3BE),
    glowColor: Color(0xFF9EB5D8),
    phaseUpColor: Color(0xFF6DC3BE),
    phaseDownColor: Color(0xFF9EB5D8),
    phaseHoldColor: Color(0xFFE5D4AE),
    ringGradient: [
      Color(0xFFE5D4AE),
      Color(0xFF6DC3BE),
      Color(0xFF44566B),
      Color(0xFFE5D4AE),
    ],
    outerRingWidthAt100: 7.3,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF121923),
      Color(0xFF2B3C4F),
      Color(0xFF6DC3BE),
    ],
    accuracyLowColor: Color(0xFF697C93),
    accuracyMidColor: Color(0xFF6DC3BE),
    accuracyHighColor: Color(0xFFE5D4AE),
    thresholdLineColor: Color(0xFF9EB5D8),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_marketing_specialist',
    themeName: 'Conversion Signal Core',
    label: 'Marketing Specialist',
    subtitle: 'ENGAGEMENT | LIVE | CONVERSION',
    bannerIcon: 'MKT',
    cornerIcon: 'MKT',
    watermarkIcon: 'ADS',
    bannerTitle: 'CONVERSION SIGNAL',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF1B0F29),
    primaryEnd: Color(0xFF2D1450),
    accent1: Color(0xFFFF3FA4),
    accent2: Color(0xFF2FE2FF),
    glowColor: Color(0xFFFFC34D),
    phaseUpColor: Color(0xFF2FE2FF),
    phaseDownColor: Color(0xFFFF3FA4),
    phaseHoldColor: Color(0xFFFFC34D),
    ringGradient: [
      Color(0xFFFF3FA4),
      Color(0xFF2FE2FF),
      Color(0xFFFFC34D),
      Color(0xFFFF3FA4),
    ],
    outerRingWidthAt100: 8.0,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF1A1027),
      Color(0xFF3B1564),
      Color(0xFFFF3FA4),
    ],
    accuracyLowColor: Color(0xFF6C4A84),
    accuracyMidColor: Color(0xFFFF3FA4),
    accuracyHighColor: Color(0xFF2FE2FF),
    thresholdLineColor: Color(0xFFFFC34D),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_fashion_designer',
    themeName: 'Atelier Luxe Interface',
    label: 'Fashion Designer',
    subtitle: 'CRAFTED | SILHOUETTE | ATELIER',
    bannerIcon: 'FD',
    cornerIcon: 'ATELIER',
    watermarkIcon: 'STITCH',
    bannerTitle: 'ATELIER LUXE',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF171417),
    primaryEnd: Color(0xFF2A232A),
    accent1: Color(0xFFE7CFA2),
    accent2: Color(0xFFF1DDE6),
    glowColor: Color(0xFFC9BEDF),
    phaseUpColor: Color(0xFFE7CFA2),
    phaseDownColor: Color(0xFFF1DDE6),
    phaseHoldColor: Color(0xFFC9BEDF),
    ringGradient: [
      Color(0xFFE7CFA2),
      Color(0xFFF1DDE6),
      Color(0xFFC9BEDF),
      Color(0xFFE7CFA2),
    ],
    outerRingWidthAt100: 7.1,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF181419),
      Color(0xFF2A2232),
      Color(0xFFE7CFA2),
    ],
    accuracyLowColor: Color(0xFF7B6C7C),
    accuracyMidColor: Color(0xFFF1DDE6),
    accuracyHighColor: Color(0xFFE7CFA2),
    thresholdLineColor: Color(0xFFC9BEDF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_beautician',
    themeName: 'Radiance Glow Console',
    label: 'Beautician',
    subtitle: 'GLOW | BALANCED | RADIANT',
    bannerIcon: 'BEAU',
    cornerIcon: 'GLOW',
    watermarkIcon: 'SKIN',
    bannerTitle: 'RADIANCE GLOW',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF2A1C24),
    primaryEnd: Color(0xFF3A2733),
    accent1: Color(0xFFF0C7B8),
    accent2: Color(0xFFFFDFA8),
    glowColor: Color(0xFFE7A7C2),
    phaseUpColor: Color(0xFFF0C7B8),
    phaseDownColor: Color(0xFFE7A7C2),
    phaseHoldColor: Color(0xFFFFDFA8),
    ringGradient: [
      Color(0xFFF0C7B8),
      Color(0xFFE7A7C2),
      Color(0xFFFFDFA8),
      Color(0xFFF0C7B8),
    ],
    outerRingWidthAt100: 7.2,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF2A1B24),
      Color(0xFF533040),
      Color(0xFFF0C7B8),
    ],
    accuracyLowColor: Color(0xFF8A6674),
    accuracyMidColor: Color(0xFFE7A7C2),
    accuracyHighColor: Color(0xFFF0C7B8),
    thresholdLineColor: Color(0xFFFFDFA8),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_teacher',
    themeName: 'Lecture Flow Interface',
    label: 'Teacher',
    subtitle: 'LESSON | FOCUS | CLARITY',
    bannerIcon: 'TCH',
    cornerIcon: 'CLASS',
    watermarkIcon: 'GRID',
    bannerTitle: 'LECTURE FLOW',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF1A2130),
    primaryEnd: Color(0xFF2D3750),
    accent1: Color(0xFFE6D2A5),
    accent2: Color(0xFF8AC39D),
    glowColor: Color(0xFFCCD8F0),
    phaseUpColor: Color(0xFF8AC39D),
    phaseDownColor: Color(0xFFE6D2A5),
    phaseHoldColor: Color(0xFFCCD8F0),
    ringGradient: [
      Color(0xFFE6D2A5),
      Color(0xFF8AC39D),
      Color(0xFF4C5874),
      Color(0xFFE6D2A5),
    ],
    outerRingWidthAt100: 7.2,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF171E2B),
      Color(0xFF2D3951),
      Color(0xFF8AC39D),
    ],
    accuracyLowColor: Color(0xFF6D7D93),
    accuracyMidColor: Color(0xFF8AC39D),
    accuracyHighColor: Color(0xFFE6D2A5),
    thresholdLineColor: Color(0xFFCCD8F0),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_accountant',
    themeName: 'Ledger Balance Interface',
    label: 'Accountant',
    subtitle: 'AUDITED | BALANCED | VERIFIED',
    bannerIcon: 'ACC',
    cornerIcon: 'AUDIT',
    watermarkIcon: 'LEDGER',
    bannerTitle: 'LEDGER BALANCE',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF131821),
    primaryEnd: Color(0xFF252C37),
    accent1: Color(0xFFD5B06A),
    accent2: Color(0xFF4FA076),
    glowColor: Color(0xFFC8D0D9),
    phaseUpColor: Color(0xFF4FA076),
    phaseDownColor: Color(0xFFD5B06A),
    phaseHoldColor: Color(0xFFC8D0D9),
    ringGradient: [
      Color(0xFFD5B06A),
      Color(0xFF4FA076),
      Color(0xFF576474),
      Color(0xFFD5B06A),
    ],
    outerRingWidthAt100: 7.6,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF12161E),
      Color(0xFF29313D),
      Color(0xFF4FA076),
    ],
    accuracyLowColor: Color(0xFF6D7685),
    accuracyMidColor: Color(0xFF4FA076),
    accuracyHighColor: Color(0xFFD5B06A),
    thresholdLineColor: Color(0xFFC8D0D9),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_musician',
    themeName: 'Concert Stage Interface',
    label: 'Musician',
    subtitle: 'TEMPO | HARMONY | RESONANCE',
    bannerIcon: 'MUS',
    cornerIcon: 'STAGE',
    watermarkIcon: 'HZ',
    bannerTitle: 'CONCERT STAGE',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF080910),
    primaryEnd: Color(0xFF12111E),
    accent1: Color(0xFF00E5FF),
    accent2: Color(0xFFEAC84A),
    glowColor: Color(0xFF9D5CFF),
    phaseUpColor: Color(0xFF00E5FF),
    phaseDownColor: Color(0xFFEAC84A),
    phaseHoldColor: Color(0xFF9D5CFF),
    ringGradient: [
      Color(0xFF00E5FF),
      Color(0xFF9D5CFF),
      Color(0xFFEAC84A),
      Color(0xFF00E5FF),
    ],
    outerRingWidthAt100: 8.0,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF060810),
      Color(0xFF0D1A2E),
      Color(0xFF00E5FF),
    ],
    accuracyLowColor: Color(0xFF3D4A6B),
    accuracyMidColor: Color(0xFF9D5CFF),
    accuracyHighColor: Color(0xFF00E5FF),
    thresholdLineColor: Color(0xFFEAC84A),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_writer',
    themeName: 'Manuscript Studio Interface',
    label: 'Writer',
    subtitle: 'DRAFT | CLARITY | RHYTHM',
    bannerIcon: 'WRT',
    cornerIcon: 'PROSE',
    watermarkIcon: 'INK',
    bannerTitle: 'MANUSCRIPT STUDIO',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF100F0D),
    primaryEnd: Color(0xFF1B1914),
    accent1: Color(0xFFD4B896),
    accent2: Color(0xFFC9A84C),
    glowColor: Color(0xFF8B9BAF),
    phaseUpColor: Color(0xFFD4B896),
    phaseDownColor: Color(0xFFC9A84C),
    phaseHoldColor: Color(0xFF8B9BAF),
    ringGradient: [
      Color(0xFFD4B896),
      Color(0xFFC9A84C),
      Color(0xFF4A5978),
      Color(0xFFD4B896),
    ],
    outerRingWidthAt100: 7.0,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0F0E0C),
      Color(0xFF1E2435),
      Color(0xFFD4B896),
    ],
    accuracyLowColor: Color(0xFF6B6457),
    accuracyMidColor: Color(0xFF8B9BAF),
    accuracyHighColor: Color(0xFFD4B896),
    thresholdLineColor: Color(0xFFC9A84C),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_game_streamer',
    themeName: 'Live Broadcast HUD',
    label: 'Game Streamer',
    subtitle: 'LIVE | LATENCY | BOOST',
    bannerIcon: 'GS',
    cornerIcon: 'LIVE',
    watermarkIcon: 'HUD',
    bannerTitle: 'LIVE BROADCAST',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF04050A),
    primaryEnd: Color(0xFF0B0818),
    accent1: Color(0xFF00C8FF),
    accent2: Color(0xFFFF2D78),
    glowColor: Color(0xFF9F4AFF),
    phaseUpColor: Color(0xFF00C8FF),
    phaseDownColor: Color(0xFFFF2D78),
    phaseHoldColor: Color(0xFF9F4AFF),
    ringGradient: [
      Color(0xFF00C8FF),
      Color(0xFFFF2D78),
      Color(0xFF9F4AFF),
      Color(0xFF00C8FF),
    ],
    outerRingWidthAt100: 8.2,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF040508),
      Color(0xFF0F0B22),
      Color(0xFF00C8FF),
    ],
    accuracyLowColor: Color(0xFF3D3265),
    accuracyMidColor: Color(0xFF9F4AFF),
    accuracyHighColor: Color(0xFF00C8FF),
    thresholdLineColor: Color(0xFFFF2D78),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_social_media_influencer',
    themeName: 'Creator Dashboard Interface',
    label: 'Social Influencer',
    subtitle: 'REACH | BOOST | TRENDING',
    bannerIcon: 'INF',
    cornerIcon: 'TREND',
    watermarkIcon: 'RISE',
    bannerTitle: 'CREATOR DASHBOARD',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF180D15),
    primaryEnd: Color(0xFF1E1128),
    accent1: Color(0xFFE8A4C4),
    accent2: Color(0xFFCCA0F0),
    glowColor: Color(0xFFFFBAD6),
    phaseUpColor: Color(0xFFE8A4C4),
    phaseDownColor: Color(0xFFCCA0F0),
    phaseHoldColor: Color(0xFFF5D6EC),
    ringGradient: [
      Color(0xFFE8A4C4),
      Color(0xFFCCA0F0),
      Color(0xFF7A4A8A),
      Color(0xFFE8A4C4),
    ],
    outerRingWidthAt100: 7.4,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF170C14),
      Color(0xFF2D1835),
      Color(0xFFE8A4C4),
    ],
    accuracyLowColor: Color(0xFF7A5070),
    accuracyMidColor: Color(0xFFCCA0F0),
    accuracyHighColor: Color(0xFFE8A4C4),
    thresholdLineColor: Color(0xFFF5D6EC),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_manager',
    themeName: 'Command Suite Interface',
    label: 'Manager',
    subtitle: 'ALIGNED | ON TRACK | VERIFIED',
    bannerIcon: 'MGR',
    cornerIcon: 'KPI',
    watermarkIcon: 'CMD',
    bannerTitle: 'COMMAND SUITE',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF111520),
    primaryEnd: Color(0xFF182030),
    accent1: Color(0xFFCBAA65),
    accent2: Color(0xFF7DBFC8),
    glowColor: Color(0xFFA8B8C8),
    phaseUpColor: Color(0xFFCBAA65),
    phaseDownColor: Color(0xFF7DBFC8),
    phaseHoldColor: Color(0xFFA8B8C8),
    ringGradient: [
      Color(0xFFCBAA65),
      Color(0xFFA8B8C8),
      Color(0xFF3D5068),
      Color(0xFFCBAA65),
    ],
    outerRingWidthAt100: 7.6,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF10141E),
      Color(0xFF1A2438),
      Color(0xFFCBAA65),
    ],
    accuracyLowColor: Color(0xFF5A6478),
    accuracyMidColor: Color(0xFF7DBFC8),
    accuracyHighColor: Color(0xFFCBAA65),
    thresholdLineColor: Color(0xFFA8B8C8),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_director',
    themeName: 'Authority Frame Interface',
    label: 'Director',
    subtitle: 'DIRECTED | OPTIMAL | APPROVED',
    bannerIcon: 'DIR',
    cornerIcon: 'CUT',
    watermarkIcon: 'SCENE',
    bannerTitle: 'AUTHORITY FRAME',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0C0A0E),
    primaryEnd: Color(0xFF1A1014),
    accent1: Color(0xFFE2C25A),
    accent2: Color(0xFFF2F0EE),
    glowColor: Color(0xFF9B2542),
    phaseUpColor: Color(0xFFE2C25A),
    phaseDownColor: Color(0xFF9B2542),
    phaseHoldColor: Color(0xFFF2F0EE),
    ringGradient: [
      Color(0xFFE2C25A),
      Color(0xFF9B2542),
      Color(0xFF2E1020),
      Color(0xFFE2C25A),
    ],
    outerRingWidthAt100: 7.8,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0A080C),
      Color(0xFF281020),
      Color(0xFFE2C25A),
    ],
    accuracyLowColor: Color(0xFF5E3040),
    accuracyMidColor: Color(0xFF9B2542),
    accuracyHighColor: Color(0xFFE2C25A),
    thresholdLineColor: Color(0xFFF2F0EE),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_cgd',
    themeName: 'Design Studio Interface',
    label: 'CG Designer',
    subtitle: 'ALIGNED | REFINED | RENDER',
    bannerIcon: 'CGD',
    cornerIcon: 'VECT',
    watermarkIcon: 'RGB',
    bannerTitle: 'DESIGN STUDIO',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0D0D12),
    primaryEnd: Color(0xFF14101E),
    accent1: Color(0xFF00EEFF),
    accent2: Color(0xFFFF24CC),
    glowColor: Color(0xFFAA44FF),
    phaseUpColor: Color(0xFF00EEFF),
    phaseDownColor: Color(0xFFFF24CC),
    phaseHoldColor: Color(0xFFAA44FF),
    ringGradient: [
      Color(0xFF00EEFF),
      Color(0xFFFF24CC),
      Color(0xFFAA44FF),
      Color(0xFF00EEFF),
    ],
    outerRingWidthAt100: 8.0,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0A0A10),
      Color(0xFF130E1C),
      Color(0xFF00EEFF),
    ],
    accuracyLowColor: Color(0xFF404060),
    accuracyMidColor: Color(0xFFAA44FF),
    accuracyHighColor: Color(0xFF00EEFF),
    thresholdLineColor: Color(0xFFFF24CC),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_it_engineer',
    themeName: 'System Monitor Interface',
    label: 'IT Engineer',
    subtitle: 'ONLINE | STABLE | SECURE',
    bannerIcon: 'ITE',
    cornerIcon: 'SYS',
    watermarkIcon: 'NET',
    bannerTitle: 'SYSTEM MONITOR',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF060C18),
    primaryEnd: Color(0xFF0A1428),
    accent1: Color(0xFF00D4B0),
    accent2: Color(0xFF9AF09A),
    glowColor: Color(0xFF00BCFF),
    phaseUpColor: Color(0xFF00D4B0),
    phaseDownColor: Color(0xFF9AF09A),
    phaseHoldColor: Color(0xFF00BCFF),
    ringGradient: [
      Color(0xFF00D4B0),
      Color(0xFF00BCFF),
      Color(0xFF1A3858),
      Color(0xFF00D4B0),
    ],
    outerRingWidthAt100: 7.8,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF050C18),
      Color(0xFF0C1E38),
      Color(0xFF00D4B0),
    ],
    accuracyLowColor: Color(0xFF3E5870),
    accuracyMidColor: Color(0xFF00BCFF),
    accuracyHighColor: Color(0xFF00D4B0),
    thresholdLineColor: Color(0xFF9AF09A),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_business_owner',
    themeName: 'Executive Command Interface',
    label: 'Business Owner',
    subtitle: 'GROWTH | BALANCED | ON TRACK',
    bannerIcon: 'CEO',
    cornerIcon: 'EXEC',
    watermarkIcon: '✓',
    bannerTitle: 'EXECUTIVE DASHBOARD',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF12161B),
    primaryEnd: Color(0xFF1A2332),
    accent1: Color(0xFFC8A951),
    accent2: Color(0xFF10B981),
    glowColor: Color(0xFFB8860B),
    phaseUpColor: Color(0xFF10B981),
    phaseDownColor: Color(0xFFC8A951),
    phaseHoldColor: Color(0xFFC0C0C0),
    ringGradient: [
      Color(0xFF10B981),
      Color(0xFFC8A951),
      Color(0xFFC0C0C0),
      Color(0xFF10B981),
    ],
    outerRingWidthAt100: 8.2,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0F1419),
      Color(0xFF1A2F3F),
      Color(0xFF10B981),
    ],
    accuracyLowColor: Color(0xFF6B7280),
    accuracyMidColor: Color(0xFFC8A951),
    accuracyHighColor: Color(0xFF10B981),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_gym_trainer',
    themeName: 'Pro Training Dashboard',
    label: 'Gym Trainer',
    subtitle: 'PACE | FORM | ACTIVE',
    bannerIcon: 'TRN',
    cornerIcon: 'COACH',
    watermarkIcon: '✓',
    bannerTitle: 'PERFORMANCE COACH',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0D0D0D),
    primaryEnd: Color(0xFF1A1A1A),
    accent1: Color(0xFFCCFF00),
    accent2: Color(0xFFFFB020),
    glowColor: Color(0xFFCCFF00),
    phaseUpColor: Color(0xFFCCFF00),
    phaseDownColor: Color(0xFFFFB020),
    phaseHoldColor: Color(0xFFE0E0E0),
    ringGradient: [
      Color(0xFFCCFF00),
      Color(0xFFFFB020),
      Color(0xFFE0E0E0),
      Color(0xFFCCFF00),
    ],
    outerRingWidthAt100: 7.9,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0A0A0A),
      Color(0xFF2A2A2A),
      Color(0xFFCCFF00),
    ],
    accuracyLowColor: Color(0xFF555555),
    accuracyMidColor: Color(0xFFFFB020),
    accuracyHighColor: Color(0xFFCCFF00),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_swimmer',
    themeName: 'Aquatic Telemetry Interface',
    label: 'Swimmer',
    subtitle: 'PACE | FLOW | SYNCED',
    bannerIcon: '🌊',
    cornerIcon: 'SWIM',
    watermarkIcon: '≈',
    bannerTitle: 'AQUATIC PERFORMANCE',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0A192F),
    primaryEnd: Color(0xFF112240),
    accent1: Color(0xFF64FFDA),
    accent2: Color(0xFF8892B0),
    glowColor: Color(0xFF64FFDA),
    phaseUpColor: Color(0xFF64FFDA),
    phaseDownColor: Color(0xFF8892B0),
    phaseHoldColor: Color(0xFFCCD6F6),
    ringGradient: [
      Color(0xFF64FFDA),
      Color(0xFF8892B0),
      Color(0xFFCCD6F6),
      Color(0xFF64FFDA),
    ],
    outerRingWidthAt100: 7.5,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0A192F),
      Color(0xFF112240),
      Color(0xFF64FFDA),
    ],
    accuracyLowColor: Color(0xFF4A5568),
    accuracyMidColor: Color(0xFF8892B0),
    accuracyHighColor: Color(0xFF64FFDA),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_psychologist',
    themeName: 'Mind State Console',
    label: 'Psychologist',
    subtitle: 'STABLE | MINDFUL | ALIGNED',
    bannerIcon: '⚖',
    cornerIcon: 'MIND',
    watermarkIcon: '○',
    bannerTitle: 'COGNITIVE BALANCE',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF161D31),
    primaryEnd: Color(0xFF1E293B),
    accent1: Color(0xFF94A3B8),
    accent2: Color(0xFFC4B5FD),
    glowColor: Color(0xFF64748B),
    phaseUpColor: Color(0xFF5EEAD4),
    phaseDownColor: Color(0xFFC4B5FD),
    phaseHoldColor: Color(0xFFF8FAFC),
    ringGradient: [
      Color(0xFF5EEAD4),
      Color(0xFFC4B5FD),
      Color(0xFF94A3B8),
      Color(0xFF5EEAD4),
    ],
    outerRingWidthAt100: 7.2,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF161D31),
      Color(0xFF1E293B),
      Color(0xFF5EEAD4),
    ],
    accuracyLowColor: Color(0xFF64748B),
    accuracyMidColor: Color(0xFFC4B5FD),
    accuracyHighColor: Color(0xFF5EEAD4),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_philosopher',
    themeName: 'Wisdom Seal Interface',
    label: 'Philosopher',
    subtitle: 'REASON | CLARITY | TRUTH',
    bannerIcon: '◇',
    cornerIcon: 'WISDOM',
    watermarkIcon: '∞',
    bannerTitle: 'CONTEMPLATIVE ALIGNMENT',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0F0F0F),
    primaryEnd: Color(0xFF1A1A1A),
    accent1: Color(0xFFD4AF37),
    accent2: Color(0xFF312E81),
    glowColor: Color(0xFFD4AF37),
    phaseUpColor: Color(0xFFFFF8DC),
    phaseDownColor: Color(0xFFD4AF37),
    phaseHoldColor: Color(0xFFCD853F),
    ringGradient: [
      Color(0xFFFFF8DC),
      Color(0xFFD4AF37),
      Color(0xFF312E81),
      Color(0xFFFFF8DC),
    ],
    outerRingWidthAt100: 7.0,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0F0F0F),
      Color(0xFF1A1A1A),
      Color(0xFFD4AF37),
    ],
    accuracyLowColor: Color(0xFF4B5563),
    accuracyMidColor: Color(0xFFCD853F),
    accuracyHighColor: Color(0xFFD4AF37),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_lawyer',
    themeName: 'Justice Seal Interface',
    label: 'Lawyer',
    subtitle: 'VERIFIED | BALANCED | COMPLIANT',
    bannerIcon: '⚖',
    cornerIcon: 'LAW',
    watermarkIcon: '✓',
    bannerTitle: 'LEGAL ALIGNMENT',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF12161B),
    primaryEnd: Color(0xFF1A2332),
    accent1: Color(0xFFC8A951),
    accent2: Color(0xFFFFFFFF),
    glowColor: Color(0xFFB8860B),
    phaseUpColor: Color(0xFFFFFFFF),
    phaseDownColor: Color(0xFFC8A951),
    phaseHoldColor: Color(0xFFC0C0C0),
    ringGradient: [
      Color(0xFFFFFFFF),
      Color(0xFFC8A951),
      Color(0xFFC0C0C0),
      Color(0xFFFFFFFF),
    ],
    outerRingWidthAt100: 8.0,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0F1419),
      Color(0xFF1A2F3F),
      Color(0xFFFFFFFF),
    ],
    accuracyLowColor: Color(0xFF6B7280),
    accuracyMidColor: Color(0xFFC8A951),
    accuracyHighColor: Color(0xFFFFFFFF),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_business_coach',
    themeName: 'Advisory Roadmap Interface',
    label: 'Business Coach',
    subtitle: 'ALIGNED | GROWTH | MOMENTUM',
    bannerIcon: 'COACH',
    cornerIcon: 'ADVISOR',
    watermarkIcon: '↑',
    bannerTitle: 'STRATEGIC ALIGNMENT',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF161920),
    primaryEnd: Color(0xFF202731),
    accent1: Color(0xFF10B981),
    accent2: Color(0xFFC8A951),
    glowColor: Color(0xFF10B981),
    phaseUpColor: Color(0xFF10B981),
    phaseDownColor: Color(0xFFC8A951),
    phaseHoldColor: Color(0xFF64748B),
    ringGradient: [
      Color(0xFF10B981),
      Color(0xFFC8A951),
      Color(0xFF64748B),
      Color(0xFF10B981),
    ],
    outerRingWidthAt100: 7.8,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF161920),
      Color(0xFF202731),
      Color(0xFF10B981),
    ],
    accuracyLowColor: Color(0xFF475569),
    accuracyMidColor: Color(0xFFC8A951),
    accuracyHighColor: Color(0xFF10B981),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_fashion_model',
    themeName: 'Runway Couture Interface',
    label: 'Fashion Model',
    subtitle: 'POISED | ALIGNED | FLAWLESS',
    bannerIcon: '✦',
    cornerIcon: 'COUTURE',
    watermarkIcon: '◇',
    bannerTitle: 'RUNWAY ALIGNMENT',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0A0A0A),
    primaryEnd: Color(0xFF1A1A1A),
    accent1: Color(0xFFF7E7CE),
    accent2: Color(0xFFFADADD),
    glowColor: Color(0xFFF7E7CE),
    phaseUpColor: Color(0xFFFFFFFF),
    phaseDownColor: Color(0xFFF7E7CE),
    phaseHoldColor: Color(0xFFC0C0C0),
    ringGradient: [
      Color(0xFFFFFFFF),
      Color(0xFFF7E7CE),
      Color(0xFFC0C0C0),
      Color(0xFFFFFFFF),
    ],
    outerRingWidthAt100: 7.3,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0A0A0A),
      Color(0xFF1A1A1A),
      Color(0xFFF7E7CE),
    ],
    accuracyLowColor: Color(0xFF555555),
    accuracyMidColor: Color(0xFFFADADD),
    accuracyHighColor: Color(0xFFF7E7CE),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_actor',
    themeName: 'Cinematic Spotlight Interface',
    label: 'Actor / Actress',
    subtitle: 'READY | TAKE | DRAMATIC',
    bannerIcon: '🎬',
    cornerIcon: 'SCENE',
    watermarkIcon: '★',
    bannerTitle: 'PERFORMANCE CALIBRATION',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0D0D0D),
    primaryEnd: Color(0xFF1A1A1A),
    accent1: Color(0xFF800020),
    accent2: Color(0xFFD4AF37),
    glowColor: Color(0xFF800020),
    phaseUpColor: Color(0xFFFFFFFF),
    phaseDownColor: Color(0xFFD4AF37),
    phaseHoldColor: Color(0xFFC0C0C0),
    ringGradient: [
      Color(0xFFFFFFFF),
      Color(0xFFD4AF37),
      Color(0xFF800020),
      Color(0xFFFFFFFF),
    ],
    outerRingWidthAt100: 7.6,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0D0D0D),
      Color(0xFF1A1A1A),
      Color(0xFF800020),
    ],
    accuracyLowColor: Color(0xFF444444),
    accuracyMidColor: Color(0xFFD4AF37),
    accuracyHighColor: Color(0xFFFFFFFF),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_photographer',
    themeName: 'Lens Calibration Interface',
    label: 'Photographer',
    subtitle: 'SHARP | CENTERED | CALIBRATED',
    bannerIcon: '📷',
    cornerIcon: 'LENS',
    watermarkIcon: '◎',
    bannerTitle: 'EXPOSURE ALIGNMENT',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF121212),
    primaryEnd: Color(0xFF1E1E1E),
    accent1: Color(0xFFB0B0B0),
    accent2: Color(0xFFF59E0B),
    glowColor: Color(0xFFB0B0B0),
    phaseUpColor: Color(0xFF3B82F6),
    phaseDownColor: Color(0xFFF59E0B),
    phaseHoldColor: Color(0xFFB0B0B0),
    ringGradient: [
      Color(0xFF3B82F6),
      Color(0xFFB0B0B0),
      Color(0xFFF59E0B),
      Color(0xFF3B82F6),
    ],
    outerRingWidthAt100: 7.4,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF121212),
      Color(0xFF1E1E1E),
      Color(0xFF3B82F6),
    ],
    accuracyLowColor: Color(0xFF525252),
    accuracyMidColor: Color(0xFFF59E0B),
    accuracyHighColor: Color(0xFFB0B0B0),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_presenter',
    themeName: 'Broadcast Stage Interface',
    label: 'Presenter',
    subtitle: 'CLEAR | LIVE | SYNCED',
    bannerIcon: '🎙',
    cornerIcon: 'ON AIR',
    watermarkIcon: '◉',
    bannerTitle: 'BROADCAST ALIGNMENT',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF0F172A),
    primaryEnd: Color(0xFF1E293B),
    accent1: Color(0xFF22D3EE),
    accent2: Color(0xFFD4AF37),
    glowColor: Color(0xFF22D3EE),
    phaseUpColor: Color(0xFF22D3EE),
    phaseDownColor: Color(0xFFD4AF37),
    phaseHoldColor: Color(0xFFE2E8F0),
    ringGradient: [
      Color(0xFF22D3EE),
      Color(0xFFD4AF37),
      Color(0xFFE2E8F0),
      Color(0xFF22D3EE),
    ],
    outerRingWidthAt100: 7.7,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
      Color(0xFF22D3EE),
    ],
    accuracyLowColor: Color(0xFF475569),
    accuracyMidColor: Color(0xFFD4AF37),
    accuracyHighColor: Color(0xFF22D3EE),
    thresholdLineColor: Color(0xFFFFFFFF),
  ),
  WorldFestivalVisualStyle(
    storageKey: 'profession_chef',
    themeName: 'Culinary Heat Matrix',
    label: 'Professional Chef',
    subtitle: 'SEAR | HEAT | CALIBRATED',
    bannerIcon: 'CHEF',
    cornerIcon: 'HEAT',
    watermarkIcon: '🔥',
    bannerTitle: 'CULINARY PRECISION',
    month: 1,
    day: 1,
    primaryStart: Color(0xFF111111),
    primaryEnd: Color(0xFF1D1D1D),
    accent1: Color(0xFFFF9D00),
    accent2: Color(0xFFC5A017),
    glowColor: Color(0xFFFF4500),
    phaseUpColor: Color(0xFFFF9D00),
    phaseDownColor: Color(0xFFFF4500),
    phaseHoldColor: Color(0xFFC5A017),
    ringGradient: [
      Color(0xFFFF9D00),
      Color(0xFFFF4500),
      Color(0xFFC5A017),
      Color(0xFFFF9D00),
    ],
    outerRingWidthAt100: 8.0,
    showHighlight: true,
    accuracyBarGradient: [
      Color(0xFF111111),
      Color(0xFF2A1600),
      Color(0xFFFF9D00),
    ],
    accuracyLowColor: Color(0xFF555555),
    accuracyMidColor: Color(0xFFFF4500),
    accuracyHighColor: Color(0xFFFF9D00),
    thresholdLineColor: Color(0xFFC5A017),
  ),
];

bool isProfessionThemeKey(String? key) {
  if (key == null || key.trim().isEmpty) {
    return false;
  }
  final value = key.trim();
  return professionHobbyThemes.any((theme) => theme.storageKey == value);
}

WorldFestivalVisualStyle professionThemeByKey(String? key) {
  final value = key?.trim();
  if (value == null || value.isEmpty) {
    return professionHobbyThemes.first;
  }
  return professionHobbyThemes.firstWhere(
    (theme) => theme.storageKey == value,
    orElse: () => professionHobbyThemes.first,
  );
}

String professionPrecisionState(
  String? key, {
  required double accuracy,
}) {
  final safeAccuracy = accuracy.clamp(0.0, 1.0).toDouble();
  final value = key ?? defaultProfessionThemeKey;

  if (safeAccuracy >= 0.86) {
    if (value == 'profession_civil_engineer') return 'OPTIMAL STRUCTURE';
    if (value == 'profession_chef') return 'PERFECT SEAR';
    return 'OPTIMAL';
  }
  if (safeAccuracy >= 0.74) {
    if (value == 'profession_chef') return 'OPTIMAL HEAT';
    return 'CALIBRATED';
  }
  if (safeAccuracy >= 0.62) {
    if (value == 'profession_chef') return 'HEATED';
    return 'STABLE';
  }

  if (value == 'profession_electrical_engineer') {
    return 'SYNCED';
  }
  if (value == 'profession_mechanical_engineer') {
    return 'NOMINAL';
  }
  if (value == 'profession_doctor') {
    return 'DIAGNOSTIC READY';
  }
  if (value == 'profession_nurse') {
    return 'MONITORED';
  }
  if (value == 'profession_pharmacist') {
    return 'DOSING SYNC';
  }
  if (value == 'profession_software_developer') {
    return 'DEPLOYED';
  }
  if (value == 'profession_data_scientist') {
    return 'CONFIDENT';
  }
  if (value == 'profession_human_resource') {
    return 'VERIFIED';
  }
  if (value == 'profession_marketing_specialist') {
    return 'OPTIMIZED';
  }
  if (value == 'profession_fashion_designer') {
    return 'CRAFTED';
  }
  if (value == 'profession_beautician') {
    return 'RADIANT';
  }
  if (value == 'profession_teacher') {
    return 'OPTIMAL FLOW';
  }
  if (value == 'profession_accountant') {
    return 'AUDITED';
  }
  if (value == 'profession_musician') {
    return 'STATIC';
  }
  if (value == 'profession_writer') {
    return 'UNWRITTEN';
  }
  if (value == 'profession_game_streamer') {
    return 'OFFLINE';
  }
  if (value == 'profession_social_media_influencer') {
    return 'IDLE';
  }
  if (value == 'profession_manager') {
    return 'MISALIGNED';
  }
  if (value == 'profession_director') {
    return 'UNCUT';
  }
  if (value == 'profession_cgd') {
    return 'UNFOCUSED';
  }
  if (value == 'profession_it_engineer') {
    return 'DEGRADED';
  }
  if (value == 'profession_business_owner') {
    return 'PROFITABLE';
  }
  if (value == 'profession_gym_trainer') {
    return 'CALIBRATED';
  }
  if (value == 'profession_swimmer') {
    return 'FLOWING';
  }
  if (value == 'profession_psychologist') {
    return 'CENTERED';
  }
  if (value == 'profession_philosopher') {
    return 'CONTEMPLATIVE';
  }
  if (value == 'profession_lawyer') {
    return 'IN ORDER';
  }
  if (value == 'profession_business_coach') {
    return 'ON TRACK';
  }
  if (value == 'profession_fashion_model') {
    return 'POSED';
  }
  if (value == 'profession_actor') {
    return 'IN SCENE';
  }
  if (value == 'profession_photographer') {
    return 'IN FOCUS';
  }
  if (value == 'profession_presenter') {
    return 'ON AIR';
  }
  if (value == 'profession_chef') {
    return 'HEATING';
  }
  return 'ALIGNED';
}

List<String> professionMicroLabels(String? key) {
  switch (key) {
    case 'profession_electrical_engineer':
      return const ['VOLT', 'WAVE', 'POLARITY', 'NODE'];
    case 'profession_mechanical_engineer':
      return const ['TORQUE', 'LOAD', 'TOLERANCE', 'FRICTION'];
    case 'profession_civil_engineer':
      return const ['LEVEL', 'GRID', 'SURVEY', 'STRUCTURE'];
    case 'profession_doctor':
      return const ['VITALS', 'ECG', 'SYNC', 'READY'];
    case 'profession_nurse':
      return const ['CARE', 'STABLE', 'ASSISTED', 'MONITORED'];
    case 'profession_pharmacist':
      return const ['DOSAGE', 'MOLECULE', 'RACK', 'PURITY'];
    case 'profession_software_developer':
      return const ['BUILD', 'RUNTIME', 'MERGE', 'DEPLOY'];
    case 'profession_data_scientist':
      return const ['MODEL', 'LATENCY', 'ACCURACY', 'CONFIDENCE'];
    case 'profession_human_resource':
      return const ['CULTURE', 'ENGAGEMENT', 'VERIFIED', 'BALANCED'];
    case 'profession_marketing_specialist':
      return const ['ENGAGEMENT', 'OPTIMIZED', 'LIVE', 'CVR'];
    case 'profession_fashion_designer':
      return const ['CRAFTED', 'ALIGNED', 'SILHOUETTE', 'ATELIER'];
    case 'profession_beautician':
      return const ['GLOW', 'BALANCED', 'REFRESHED', 'RADIANT'];
    case 'profession_teacher':
      return const ['LESSON', 'FOCUS', 'CLARITY', 'FLOW'];
    case 'profession_accountant':
      return const ['LEDGER', 'BALANCED', 'VERIFIED', 'NOMINAL'];
    case 'profession_musician':
      return const ['TEMPO', 'HARMONY', 'RESONANCE', 'SYNCED'];
    case 'profession_writer':
      return const ['DRAFT', 'CLARITY', 'RHYTHM', 'POLISHED'];
    case 'profession_game_streamer':
      return const ['LIVE', 'LATENCY', 'BOOST', 'ACTIVE'];
    case 'profession_social_media_influencer':
      return const ['REACH', 'BOOST', 'TRENDING', 'OPTIMIZED'];
    case 'profession_manager':
      return const ['ALIGNED', 'ON TRACK', 'VERIFIED', 'BALANCED'];
    case 'profession_director':
      return const ['DIRECTED', 'OPTIMAL', 'SYNCED', 'APPROVED'];
    case 'profession_cgd':
      return const ['ALIGNED', 'REFINED', 'RENDER', 'CALIBRATED'];
    case 'profession_it_engineer':
      return const ['ONLINE', 'STABLE', 'SECURE', 'OPTIMIZED'];
    case 'profession_business_owner':
      return const ['GROWTH', 'BALANCED', 'VERIFIED', 'ON TRACK'];
    case 'profession_gym_trainer':
      return const ['PACE', 'FORM', 'ACTIVE', 'CALIBRATED'];
    case 'profession_swimmer':
      return const ['PACE', 'FLOW', 'STROKE', 'SYNCED'];
    case 'profession_psychologist':
      return const ['STABLE', 'MINDFUL', 'ALIGNED', 'CLEAR'];
    case 'profession_philosopher':
      return const ['REASON', 'CLARITY', 'TRUTH', 'BALANCED'];
    case 'profession_lawyer':
      return const ['VERIFIED', 'BALANCED', 'COMPLIANT', 'STRONG'];
    case 'profession_business_coach':
      return const ['ALIGNED', 'GROWTH', 'MOMENTUM', 'OPTIMIZED'];
    case 'profession_fashion_model':
      return const ['POISED', 'ALIGNED', 'COUTURE', 'FLAWLESS'];
    case 'profession_actor':
      return const ['READY', 'TAKE', 'SYNCED', 'DRAMATIC'];
    case 'profession_photographer':
      return const ['SHARP', 'CENTERED', 'EXPOSED', 'CALIBRATED'];
    case 'profession_presenter':
      return const ['CLEAR', 'LIVE', 'READY', 'SYNCED'];
    case 'profession_chef':
      return const ['SEAR', 'HEAT', 'CALIBRATED', 'PRECISION'];
    default:
      return const ['PRECISION', 'SYSTEM', 'SYNC', 'STATUS'];
  }
}

