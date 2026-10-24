import 'dart:convert';

import 'package:flutter/material.dart';

const Object _unsetValue = Object();

enum OverlayMovementPhase {
  idle('idle'),
  up('up'),
  down('down'),
  hold('hold');

  const OverlayMovementPhase(this.storageValue);

  final String storageValue;

  static OverlayMovementPhase fromStorage(String? raw) {
    return OverlayMovementPhase.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => OverlayMovementPhase.idle,
    );
  }
}

enum OverlayPerformanceMode {
  auto('auto'),
  balanced('balanced'),
  low('low');

  const OverlayPerformanceMode(this.storageValue);

  final String storageValue;

  static OverlayPerformanceMode fromStorage(String? raw) {
    return OverlayPerformanceMode.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => OverlayPerformanceMode.auto,
    );
  }
}

enum OverlayCounterShape {
  circle('circle'),
  arc('arc'),
  hex('hex'),
  shield('shield'),
  diamond('diamond'),
  flower('flower');

  const OverlayCounterShape(this.storageValue);

  final String storageValue;

  static OverlayCounterShape fromStorage(String? raw) {
    return OverlayCounterShape.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => OverlayCounterShape.circle,
    );
  }
}

enum OverlayAnimationStyle {
  pulse('pulse'),
  ripple('ripple'),
  minimal('minimal');

  const OverlayAnimationStyle(this.storageValue);

  final String storageValue;

  static OverlayAnimationStyle fromStorage(String? raw) {
    return OverlayAnimationStyle.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => OverlayAnimationStyle.pulse,
    );
  }
}

enum OverlayAccuracyBarStyle {
  gradient('gradient'),
  segmented('segmented'),
  flat('flat'),
  glass('glass'),
  neon('neon'),
  prism('prism'),
  velvet('velvet');

  const OverlayAccuracyBarStyle(this.storageValue);

  final String storageValue;

  static OverlayAccuracyBarStyle fromStorage(String? raw) {
    return OverlayAccuracyBarStyle.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => OverlayAccuracyBarStyle.gradient,
    );
  }
}

enum OverlaySlotPosition {
  top('top'),
  center('center'),
  bottom('bottom'),
  left('left'),
  right('right');

  const OverlaySlotPosition(this.storageValue);

  final String storageValue;

  static OverlaySlotPosition fromStorage(String? raw) {
    return OverlaySlotPosition.values.firstWhere(
      (value) => value.storageValue == raw,
      orElse: () => OverlaySlotPosition.top,
    );
  }
}

@immutable
class WorkoutOverlayCustomization {
  final bool customModeEnabled;
  final OverlayPerformanceMode performanceMode;
  final String title;
  final String subtitle;
  final String brandingText;
  final OverlayPaletteConfiguration palette;
  final OverlayIconConfiguration icons;
  final OverlayNarrativeConfiguration narrative;
  final OverlayRepCounterConfiguration repCounter;
  final OverlayAccuracyBarConfiguration accuracyBar;
  final OverlayLayoutConfiguration layout;
  final OverlayFinishConfiguration finish;
  final bool showBranding;

  const WorkoutOverlayCustomization({
    required this.customModeEnabled,
    required this.performanceMode,
    required this.title,
    required this.subtitle,
    required this.brandingText,
    required this.palette,
    required this.icons,
    required this.narrative,
    required this.repCounter,
    required this.accuracyBar,
    required this.layout,
    required this.finish,
    required this.showBranding,
  });

  factory WorkoutOverlayCustomization.defaults() {
    return WorkoutOverlayCustomization(
      customModeEnabled: false,
      performanceMode: OverlayPerformanceMode.auto,
      title: 'Pulse Atelier',
      subtitle: 'Luxury motion overlay',
      brandingText: 'H&F Signature',
      palette: OverlayPaletteConfiguration.defaults(),
      icons: OverlayIconConfiguration.defaults(),
      narrative: OverlayNarrativeConfiguration.defaults(),
      repCounter: OverlayRepCounterConfiguration.defaults(),
      accuracyBar: OverlayAccuracyBarConfiguration.defaults(),
      layout: OverlayLayoutConfiguration.defaults(),
      finish: OverlayFinishConfiguration.defaults(),
      showBranding: true,
    );
  }

  factory WorkoutOverlayCustomization.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return WorkoutOverlayCustomization.defaults();
    }

    return WorkoutOverlayCustomization(
      customModeEnabled: _readBool(map['customModeEnabled'], false),
      performanceMode: OverlayPerformanceMode.fromStorage(
        _readString(map['performanceMode']),
      ),
      title: _readString(map['title'], fallback: 'Pulse Atelier'),
      subtitle: _readString(
        map['subtitle'],
        fallback: 'Luxury motion overlay',
      ),
      brandingText: _readString(map['brandingText'], fallback: 'H&F Signature'),
      palette: OverlayPaletteConfiguration.fromMap(
        _readMap(map['palette']),
      ),
      icons: OverlayIconConfiguration.fromMap(
        _readMap(map['icons']),
      ),
      narrative: OverlayNarrativeConfiguration.fromMap(
        _readMap(map['narrative']),
      ),
      repCounter: OverlayRepCounterConfiguration.fromMap(
        _readMap(map['repCounter']),
      ),
      accuracyBar: OverlayAccuracyBarConfiguration.fromMap(
        _readMap(map['accuracyBar']),
      ),
      layout: OverlayLayoutConfiguration.fromMap(
        _readMap(map['layout']),
      ),
      finish: OverlayFinishConfiguration.fromMap(
        _readMap(map['finish']),
      ),
      showBranding: _readBool(map['showBranding'], true),
    );
  }

  factory WorkoutOverlayCustomization.fromJsonString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return WorkoutOverlayCustomization.defaults();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return WorkoutOverlayCustomization.fromMap(decoded);
      }
      if (decoded is Map) {
        return WorkoutOverlayCustomization.fromMap(
          decoded.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        );
      }
    } catch (_) {
      // Fall back to defaults when older or corrupted settings exist.
    }
    return WorkoutOverlayCustomization.defaults();
  }

  WorkoutOverlayCustomization copyWith({
    bool? customModeEnabled,
    OverlayPerformanceMode? performanceMode,
    String? title,
    String? subtitle,
    String? brandingText,
    OverlayPaletteConfiguration? palette,
    OverlayIconConfiguration? icons,
    OverlayNarrativeConfiguration? narrative,
    OverlayRepCounterConfiguration? repCounter,
    OverlayAccuracyBarConfiguration? accuracyBar,
    OverlayLayoutConfiguration? layout,
    OverlayFinishConfiguration? finish,
    bool? showBranding,
  }) {
    return WorkoutOverlayCustomization(
      customModeEnabled: customModeEnabled ?? this.customModeEnabled,
      performanceMode: performanceMode ?? this.performanceMode,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      brandingText: brandingText ?? this.brandingText,
      palette: palette ?? this.palette,
      icons: icons ?? this.icons,
      narrative: narrative ?? this.narrative,
      repCounter: repCounter ?? this.repCounter,
      accuracyBar: accuracyBar ?? this.accuracyBar,
      layout: layout ?? this.layout,
      finish: finish ?? this.finish,
      showBranding: showBranding ?? this.showBranding,
    );
  }

  WorkoutOverlayCustomization applyWorldFestivalLuxuryPreset() {
    return copyWith(
      performanceMode: OverlayPerformanceMode.auto,
      repCounter: repCounter.copyWith(
        glowIntensity: 0.78,
        surfaceDepth: 0.72,
        orbitIntensity: 0.68,
        animationStyle: OverlayAnimationStyle.ripple,
        opacity: 0.97,
      ),
      accuracyBar: accuracyBar.copyWith(
        style: OverlayAccuracyBarStyle.gradient,
        markerDensity: 0.46,
        glowIntensity: 0.80,
        spillLength: 0.66,
        spillWidth: 0.58,
        thresholdGlow: 0.76,
        liquidMotion: 0.70,
      ),
      layout: layout.copyWith(
        globalScale: 1.0,
        opacity: 0.97,
      ),
      finish: finish.copyWith(
        vignetteStrength: 0.44,
        bloomIntensity: 0.58,
        sparkleDensity: 0.46,
        sheenSweep: 0.52,
      ),
    );
  }

  Color phaseColorFor(OverlayMovementPhase phase) {
    switch (phase) {
      case OverlayMovementPhase.up:
        return palette.phaseUp;
      case OverlayMovementPhase.down:
        return palette.phaseDown;
      case OverlayMovementPhase.hold:
        return palette.phaseHold;
      case OverlayMovementPhase.idle:
        return palette.textSecondary;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'customModeEnabled': customModeEnabled,
      'performanceMode': performanceMode.storageValue,
      'title': title,
      'subtitle': subtitle,
      'brandingText': brandingText,
      'palette': palette.toMap(),
      'icons': icons.toMap(),
      'narrative': narrative.toMap(),
      'repCounter': repCounter.toMap(),
      'accuracyBar': accuracyBar.toMap(),
      'layout': layout.toMap(),
      'finish': finish.toMap(),
      'showBranding': showBranding,
    };
  }

  Map<String, dynamic> toChannelMap() => toMap();

  String toJsonString() => jsonEncode(toMap());
}

@immutable
class OverlayNarrativeConfiguration {
  final String firstFlowText;
  final int firstFlowRep;
  final Color firstFlowTextColor;
  final Color firstFlowTextColorSecondary;
  final String secondFlowText;
  final int secondFlowRep;
  final Color secondFlowTextColor;
  final Color secondFlowTextColorSecondary;
  final String thirdFlowText;
  final int thirdFlowRep;
  final Color thirdFlowTextColor;
  final Color thirdFlowTextColorSecondary;
  final String fourthFlowText;
  final int fourthFlowRep;
  final Color fourthFlowTextColor;
  final Color fourthFlowTextColorSecondary;

  const OverlayNarrativeConfiguration({
    required this.firstFlowText,
    required this.firstFlowRep,
    required this.firstFlowTextColor,
    required this.firstFlowTextColorSecondary,
    required this.secondFlowText,
    required this.secondFlowRep,
    required this.secondFlowTextColor,
    required this.secondFlowTextColorSecondary,
    required this.thirdFlowText,
    required this.thirdFlowRep,
    required this.thirdFlowTextColor,
    required this.thirdFlowTextColorSecondary,
    required this.fourthFlowText,
    required this.fourthFlowRep,
    required this.fourthFlowTextColor,
    required this.fourthFlowTextColorSecondary,
  });

  factory OverlayNarrativeConfiguration.defaults() {
    return const OverlayNarrativeConfiguration(
      firstFlowText: '',
      firstFlowRep: 1,
      firstFlowTextColor: Color(0xFFF9F4E8),
      firstFlowTextColorSecondary: Color(0xFFF3D28A),
      secondFlowText: '',
      secondFlowRep: 3,
      secondFlowTextColor: Color(0xFFF9F4E8),
      secondFlowTextColorSecondary: Color(0xFFF3D28A),
      thirdFlowText: '',
      thirdFlowRep: 5,
      thirdFlowTextColor: Color(0xFFF9F4E8),
      thirdFlowTextColorSecondary: Color(0xFFF3D28A),
      fourthFlowText: '',
      fourthFlowRep: 7,
      fourthFlowTextColor: Color(0xFFF9F4E8),
      fourthFlowTextColorSecondary: Color(0xFFF3D28A),
    );
  }

  factory OverlayNarrativeConfiguration.fromMap(Map<String, dynamic>? map) {
    final defaults = OverlayNarrativeConfiguration.defaults();
    return OverlayNarrativeConfiguration(
      firstFlowText: _readString(
        map?['firstFlowText'],
        fallback: defaults.firstFlowText,
      ),
      firstFlowRep: _readInt(
        map?['firstFlowRep'],
        defaults.firstFlowRep,
      ).clamp(1, 999),
      firstFlowTextColor: _readColor(
        map?['firstFlowTextColor'],
        defaults.firstFlowTextColor,
      ),
      firstFlowTextColorSecondary: _readColor(
        map?['firstFlowTextColorSecondary'],
        defaults.firstFlowTextColorSecondary,
      ),
      secondFlowText: _readString(
        map?['secondFlowText'],
        fallback: defaults.secondFlowText,
      ),
      secondFlowRep: _readInt(
        map?['secondFlowRep'],
        defaults.secondFlowRep,
      ).clamp(1, 999),
      secondFlowTextColor: _readColor(
        map?['secondFlowTextColor'],
        defaults.secondFlowTextColor,
      ),
      secondFlowTextColorSecondary: _readColor(
        map?['secondFlowTextColorSecondary'],
        defaults.secondFlowTextColorSecondary,
      ),
      thirdFlowText: _readString(
        map?['thirdFlowText'],
        fallback: defaults.thirdFlowText,
      ),
      thirdFlowRep: _readInt(
        map?['thirdFlowRep'],
        defaults.thirdFlowRep,
      ).clamp(1, 999),
      thirdFlowTextColor: _readColor(
        map?['thirdFlowTextColor'],
        defaults.thirdFlowTextColor,
      ),
      thirdFlowTextColorSecondary: _readColor(
        map?['thirdFlowTextColorSecondary'],
        defaults.thirdFlowTextColorSecondary,
      ),
      fourthFlowText: _readString(
        map?['fourthFlowText'],
        fallback: defaults.fourthFlowText,
      ),
      fourthFlowRep: _readInt(
        map?['fourthFlowRep'],
        defaults.fourthFlowRep,
      ).clamp(1, 999),
      fourthFlowTextColor: _readColor(
        map?['fourthFlowTextColor'],
        defaults.fourthFlowTextColor,
      ),
      fourthFlowTextColorSecondary: _readColor(
        map?['fourthFlowTextColorSecondary'],
        defaults.fourthFlowTextColorSecondary,
      ),
    );
  }

  OverlayNarrativeConfiguration copyWith({
    String? firstFlowText,
    int? firstFlowRep,
    Color? firstFlowTextColor,
    Color? firstFlowTextColorSecondary,
    String? secondFlowText,
    int? secondFlowRep,
    Color? secondFlowTextColor,
    Color? secondFlowTextColorSecondary,
    String? thirdFlowText,
    int? thirdFlowRep,
    Color? thirdFlowTextColor,
    Color? thirdFlowTextColorSecondary,
    String? fourthFlowText,
    int? fourthFlowRep,
    Color? fourthFlowTextColor,
    Color? fourthFlowTextColorSecondary,
  }) {
    return OverlayNarrativeConfiguration(
      firstFlowText: firstFlowText ?? this.firstFlowText,
      firstFlowRep: firstFlowRep ?? this.firstFlowRep,
      firstFlowTextColor: firstFlowTextColor ?? this.firstFlowTextColor,
      firstFlowTextColorSecondary:
          firstFlowTextColorSecondary ?? this.firstFlowTextColorSecondary,
      secondFlowText: secondFlowText ?? this.secondFlowText,
      secondFlowRep: secondFlowRep ?? this.secondFlowRep,
      secondFlowTextColor: secondFlowTextColor ?? this.secondFlowTextColor,
      secondFlowTextColorSecondary:
          secondFlowTextColorSecondary ?? this.secondFlowTextColorSecondary,
      thirdFlowText: thirdFlowText ?? this.thirdFlowText,
      thirdFlowRep: thirdFlowRep ?? this.thirdFlowRep,
      thirdFlowTextColor: thirdFlowTextColor ?? this.thirdFlowTextColor,
      thirdFlowTextColorSecondary:
          thirdFlowTextColorSecondary ?? this.thirdFlowTextColorSecondary,
      fourthFlowText: fourthFlowText ?? this.fourthFlowText,
      fourthFlowRep: fourthFlowRep ?? this.fourthFlowRep,
      fourthFlowTextColor: fourthFlowTextColor ?? this.fourthFlowTextColor,
      fourthFlowTextColorSecondary:
          fourthFlowTextColorSecondary ?? this.fourthFlowTextColorSecondary,
    );
  }

  List<OverlayNarrativeCueConfig> get cues => <OverlayNarrativeCueConfig>[
        OverlayNarrativeCueConfig(
          text: firstFlowText,
          repTarget: firstFlowRep,
          textColor: firstFlowTextColor,
          textColorSecondary: firstFlowTextColorSecondary,
        ),
        OverlayNarrativeCueConfig(
          text: secondFlowText,
          repTarget: secondFlowRep,
          textColor: secondFlowTextColor,
          textColorSecondary: secondFlowTextColorSecondary,
        ),
        OverlayNarrativeCueConfig(
          text: thirdFlowText,
          repTarget: thirdFlowRep,
          textColor: thirdFlowTextColor,
          textColorSecondary: thirdFlowTextColorSecondary,
        ),
        OverlayNarrativeCueConfig(
          text: fourthFlowText,
          repTarget: fourthFlowRep,
          textColor: fourthFlowTextColor,
          textColorSecondary: fourthFlowTextColorSecondary,
        ),
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firstFlowText': firstFlowText,
      'firstFlowRep': firstFlowRep,
      'firstFlowTextColor': firstFlowTextColor.value,
      'firstFlowTextColorSecondary': firstFlowTextColorSecondary.value,
      'secondFlowText': secondFlowText,
      'secondFlowRep': secondFlowRep,
      'secondFlowTextColor': secondFlowTextColor.value,
      'secondFlowTextColorSecondary': secondFlowTextColorSecondary.value,
      'thirdFlowText': thirdFlowText,
      'thirdFlowRep': thirdFlowRep,
      'thirdFlowTextColor': thirdFlowTextColor.value,
      'thirdFlowTextColorSecondary': thirdFlowTextColorSecondary.value,
      'fourthFlowText': fourthFlowText,
      'fourthFlowRep': fourthFlowRep,
      'fourthFlowTextColor': fourthFlowTextColor.value,
      'fourthFlowTextColorSecondary': fourthFlowTextColorSecondary.value,
    };
  }
}

@immutable
class OverlayNarrativeCueConfig {
  final String text;
  final int repTarget;
  final Color textColor;
  final Color textColorSecondary;

  const OverlayNarrativeCueConfig({
    required this.text,
    required this.repTarget,
    required this.textColor,
    required this.textColorSecondary,
  });
}

@immutable
class OverlayPaletteConfiguration {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color phaseUp;
  final Color phaseDown;
  final Color phaseHold;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;

  const OverlayPaletteConfiguration({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.phaseUp,
    required this.phaseDown,
    required this.phaseHold,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
  });

  factory OverlayPaletteConfiguration.defaults() {
    return const OverlayPaletteConfiguration(
      primary: Color(0xFF111827),
      secondary: Color(0xFF7C5C2E),
      accent: Color(0xFFF3D28A),
      phaseUp: Color(0xFFF3D28A),
      phaseDown: Color(0xFFDA8E52),
      phaseHold: Color(0xFFE9EEF7),
      surface: Color(0xCC101824),
      textPrimary: Color(0xFFF9F4E8),
      textSecondary: Color(0xFFCFD5E3),
    );
  }

  factory OverlayPaletteConfiguration.fromMap(Map<String, dynamic>? map) {
    final defaults = OverlayPaletteConfiguration.defaults();
    if (map == null || map.isEmpty) {
      return defaults;
    }
    return OverlayPaletteConfiguration(
      primary: _readColor(map['primary'], defaults.primary),
      secondary: _readColor(map['secondary'], defaults.secondary),
      accent: _readColor(map['accent'], defaults.accent),
      phaseUp: _readColor(map['phaseUp'], defaults.phaseUp),
      phaseDown: _readColor(map['phaseDown'], defaults.phaseDown),
      phaseHold: _readColor(map['phaseHold'], defaults.phaseHold),
      surface: _readColor(map['surface'], defaults.surface),
      textPrimary: _readColor(map['textPrimary'], defaults.textPrimary),
      textSecondary: _readColor(map['textSecondary'], defaults.textSecondary),
    );
  }

  OverlayPaletteConfiguration copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? phaseUp,
    Color? phaseDown,
    Color? phaseHold,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return OverlayPaletteConfiguration(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      phaseUp: phaseUp ?? this.phaseUp,
      phaseDown: phaseDown ?? this.phaseDown,
      phaseHold: phaseHold ?? this.phaseHold,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'primary': primary.value,
      'secondary': secondary.value,
      'accent': accent.value,
      'phaseUp': phaseUp.value,
      'phaseDown': phaseDown.value,
      'phaseHold': phaseHold.value,
      'surface': surface.value,
      'textPrimary': textPrimary.value,
      'textSecondary': textSecondary.value,
    };
  }
}

@immutable
class OverlayPhaseIconSlot {
  final String glyph;
  final String? svgPath;

  const OverlayPhaseIconSlot({
    required this.glyph,
    required this.svgPath,
  });

  factory OverlayPhaseIconSlot.defaults({
    required String glyph,
  }) {
    return OverlayPhaseIconSlot(
      glyph: glyph,
      svgPath: null,
    );
  }

  factory OverlayPhaseIconSlot.fromMap(
    Map<String, dynamic>? map, {
    required String fallbackGlyph,
  }) {
    return OverlayPhaseIconSlot(
      glyph: _readString(map?['glyph'], fallback: fallbackGlyph),
      svgPath: _readNullableString(map?['svgPath']),
    );
  }

  OverlayPhaseIconSlot copyWith({
    String? glyph,
    Object? svgPath = _unsetValue,
    bool clearSvgPath = false,
  }) {
    return OverlayPhaseIconSlot(
      glyph: glyph ?? this.glyph,
      svgPath: clearSvgPath
          ? null
          : identical(svgPath, _unsetValue)
              ? this.svgPath
              : svgPath as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'glyph': glyph,
      'svgPath': svgPath,
    };
  }
}

@immutable
class OverlayIconConfiguration {
  final bool autoSwitch;
  final OverlayPhaseIconSlot defaultIcon;
  final OverlayPhaseIconSlot upIcon;
  final OverlayPhaseIconSlot downIcon;
  final OverlayPhaseIconSlot holdIcon;

  const OverlayIconConfiguration({
    required this.autoSwitch,
    required this.defaultIcon,
    required this.upIcon,
    required this.downIcon,
    required this.holdIcon,
  });

  factory OverlayIconConfiguration.defaults() {
    return OverlayIconConfiguration(
      autoSwitch: true,
      defaultIcon: OverlayPhaseIconSlot.defaults(glyph: 'D'),
      upIcon: OverlayPhaseIconSlot.defaults(glyph: '^'),
      downIcon: OverlayPhaseIconSlot.defaults(glyph: 'v'),
      holdIcon: OverlayPhaseIconSlot.defaults(glyph: 'o'),
    );
  }

  factory OverlayIconConfiguration.fromMap(Map<String, dynamic>? map) {
    final defaults = OverlayIconConfiguration.defaults();
    return OverlayIconConfiguration(
      autoSwitch: _readBool(map?['autoSwitch'], defaults.autoSwitch),
      defaultIcon: OverlayPhaseIconSlot.fromMap(
        _readMap(map?['default']),
        fallbackGlyph: defaults.defaultIcon.glyph,
      ),
      upIcon: OverlayPhaseIconSlot.fromMap(
        _readMap(map?['up']),
        fallbackGlyph: defaults.upIcon.glyph,
      ),
      downIcon: OverlayPhaseIconSlot.fromMap(
        _readMap(map?['down']),
        fallbackGlyph: defaults.downIcon.glyph,
      ),
      holdIcon: OverlayPhaseIconSlot.fromMap(
        _readMap(map?['hold']),
        fallbackGlyph: defaults.holdIcon.glyph,
      ),
    );
  }

  OverlayIconConfiguration copyWith({
    bool? autoSwitch,
    OverlayPhaseIconSlot? defaultIcon,
    OverlayPhaseIconSlot? upIcon,
    OverlayPhaseIconSlot? downIcon,
    OverlayPhaseIconSlot? holdIcon,
  }) {
    return OverlayIconConfiguration(
      autoSwitch: autoSwitch ?? this.autoSwitch,
      defaultIcon: defaultIcon ?? this.defaultIcon,
      upIcon: upIcon ?? this.upIcon,
      downIcon: downIcon ?? this.downIcon,
      holdIcon: holdIcon ?? this.holdIcon,
    );
  }

  OverlayPhaseIconSlot iconForPhase(OverlayMovementPhase phase) {
    if (!autoSwitch) {
      return defaultIcon;
    }
    switch (phase) {
      case OverlayMovementPhase.up:
        return upIcon;
      case OverlayMovementPhase.down:
        return downIcon;
      case OverlayMovementPhase.hold:
        return holdIcon;
      case OverlayMovementPhase.idle:
        return defaultIcon;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'autoSwitch': autoSwitch,
      'default': defaultIcon.toMap(),
      'up': upIcon.toMap(),
      'down': downIcon.toMap(),
      'hold': holdIcon.toMap(),
    };
  }
}

@immutable
class OverlayRepCounterConfiguration {
  final double ringThickness;
  final OverlayCounterShape shape;
  final double contourSoftness;
  final double glowIntensity;
  final double surfaceDepth;
  final double orbitIntensity;
  final OverlayAnimationStyle animationStyle;
  final double scale;
  final double opacity;
  final bool show;

  const OverlayRepCounterConfiguration({
    required this.ringThickness,
    required this.shape,
    required this.contourSoftness,
    required this.glowIntensity,
    required this.surfaceDepth,
    required this.orbitIntensity,
    required this.animationStyle,
    required this.scale,
    required this.opacity,
    required this.show,
  });

  factory OverlayRepCounterConfiguration.defaults() {
    return const OverlayRepCounterConfiguration(
      ringThickness: 8,
      shape: OverlayCounterShape.circle,
      contourSoftness: 0.55,
      glowIntensity: 0.78,
      surfaceDepth: 0.72,
      orbitIntensity: 0.68,
      animationStyle: OverlayAnimationStyle.ripple,
      scale: 1.0,
      opacity: 0.97,
      show: true,
    );
  }

  factory OverlayRepCounterConfiguration.fromMap(Map<String, dynamic>? map) {
    final defaults = OverlayRepCounterConfiguration.defaults();
    return OverlayRepCounterConfiguration(
      ringThickness: _readDouble(
        map?['ringThickness'],
        defaults.ringThickness,
      ).clamp(4.0, 16.0),
      shape: OverlayCounterShape.fromStorage(_readString(map?['shape'])),
      contourSoftness: _readDouble(
        map?['contourSoftness'],
        defaults.contourSoftness,
      ).clamp(0.0, 1.0),
      glowIntensity: _readDouble(
        map?['glowIntensity'],
        defaults.glowIntensity,
      ).clamp(0.0, 1.0),
      surfaceDepth: _readDouble(
        map?['surfaceDepth'],
        defaults.surfaceDepth,
      ).clamp(0.0, 1.0),
      orbitIntensity: _readDouble(
        map?['orbitIntensity'],
        defaults.orbitIntensity,
      ).clamp(0.0, 1.0),
      animationStyle: OverlayAnimationStyle.fromStorage(
        _readString(map?['animationStyle']),
      ),
      scale: _readDouble(map?['scale'], defaults.scale).clamp(0.75, 1.3),
      opacity: _readDouble(map?['opacity'], defaults.opacity).clamp(0.4, 1.0),
      show: _readBool(map?['show'], true),
    );
  }

  OverlayRepCounterConfiguration copyWith({
    double? ringThickness,
    OverlayCounterShape? shape,
    double? contourSoftness,
    double? glowIntensity,
    double? surfaceDepth,
    double? orbitIntensity,
    OverlayAnimationStyle? animationStyle,
    double? scale,
    double? opacity,
    bool? show,
  }) {
    return OverlayRepCounterConfiguration(
      ringThickness: ringThickness ?? this.ringThickness,
      shape: shape ?? this.shape,
      contourSoftness: contourSoftness ?? this.contourSoftness,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      surfaceDepth: surfaceDepth ?? this.surfaceDepth,
      orbitIntensity: orbitIntensity ?? this.orbitIntensity,
      animationStyle: animationStyle ?? this.animationStyle,
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
      show: show ?? this.show,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ringThickness': ringThickness,
      'shape': shape.storageValue,
      'contourSoftness': contourSoftness,
      'glowIntensity': glowIntensity,
      'surfaceDepth': surfaceDepth,
      'orbitIntensity': orbitIntensity,
      'animationStyle': animationStyle.storageValue,
      'scale': scale,
      'opacity': opacity,
      'show': show,
    };
  }
}

@immutable
class OverlayAccuracyBarConfiguration {
  final OverlayAccuracyBarStyle style;
  final double styleIntensity;
  final bool showThresholdLine;
  final double markerDensity;
  final double glowIntensity;
  final double spillLength;
  final double spillWidth;
  final double thresholdGlow;
  final double liquidMotion;
  final bool show;

  const OverlayAccuracyBarConfiguration({
    required this.style,
    required this.styleIntensity,
    required this.showThresholdLine,
    required this.markerDensity,
    required this.glowIntensity,
    required this.spillLength,
    required this.spillWidth,
    required this.thresholdGlow,
    required this.liquidMotion,
    required this.show,
  });

  factory OverlayAccuracyBarConfiguration.defaults() {
    return const OverlayAccuracyBarConfiguration(
      style: OverlayAccuracyBarStyle.gradient,
      styleIntensity: 0.62,
      showThresholdLine: true,
      markerDensity: 0.46,
      glowIntensity: 0.80,
      spillLength: 0.66,
      spillWidth: 0.58,
      thresholdGlow: 0.76,
      liquidMotion: 0.70,
      show: true,
    );
  }

  factory OverlayAccuracyBarConfiguration.fromMap(Map<String, dynamic>? map) {
    final defaults = OverlayAccuracyBarConfiguration.defaults();
    return OverlayAccuracyBarConfiguration(
      style: OverlayAccuracyBarStyle.fromStorage(_readString(map?['style'])),
      styleIntensity: _readDouble(
        map?['styleIntensity'],
        defaults.styleIntensity,
      ).clamp(0.0, 1.0),
      showThresholdLine: _readBool(
        map?['showThresholdLine'],
        defaults.showThresholdLine,
      ),
      markerDensity: _readDouble(
        map?['markerDensity'],
        defaults.markerDensity,
      ).clamp(0.0, 1.0),
      glowIntensity: _readDouble(
        map?['glowIntensity'],
        defaults.glowIntensity,
      ).clamp(0.0, 1.0),
      spillLength: _readDouble(
        map?['spillLength'],
        defaults.spillLength,
      ).clamp(0.0, 1.0),
      spillWidth: _readDouble(
        map?['spillWidth'],
        defaults.spillWidth,
      ).clamp(0.0, 1.0),
      thresholdGlow: _readDouble(
        map?['thresholdGlow'],
        defaults.thresholdGlow,
      ).clamp(0.0, 1.0),
      liquidMotion: _readDouble(
        map?['liquidMotion'],
        defaults.liquidMotion,
      ).clamp(0.0, 1.0),
      show: _readBool(map?['show'], true),
    );
  }

  OverlayAccuracyBarConfiguration copyWith({
    OverlayAccuracyBarStyle? style,
    double? styleIntensity,
    bool? showThresholdLine,
    double? markerDensity,
    double? glowIntensity,
    double? spillLength,
    double? spillWidth,
    double? thresholdGlow,
    double? liquidMotion,
    bool? show,
  }) {
    return OverlayAccuracyBarConfiguration(
      style: style ?? this.style,
      styleIntensity: styleIntensity ?? this.styleIntensity,
      showThresholdLine: showThresholdLine ?? this.showThresholdLine,
      markerDensity: markerDensity ?? this.markerDensity,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      spillLength: spillLength ?? this.spillLength,
      spillWidth: spillWidth ?? this.spillWidth,
      thresholdGlow: thresholdGlow ?? this.thresholdGlow,
      liquidMotion: liquidMotion ?? this.liquidMotion,
      show: show ?? this.show,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'style': style.storageValue,
      'styleIntensity': styleIntensity,
      'showThresholdLine': showThresholdLine,
      'markerDensity': markerDensity,
      'glowIntensity': glowIntensity,
      'spillLength': spillLength,
      'spillWidth': spillWidth,
      'thresholdGlow': thresholdGlow,
      'liquidMotion': liquidMotion,
      'show': show,
    };
  }
}

@immutable
class OverlayLayoutConfiguration {
  final OverlaySlotPosition bannerPosition;
  final OverlaySlotPosition statsCardPosition;
  final double globalScale;
  final double opacity;

  const OverlayLayoutConfiguration({
    required this.bannerPosition,
    required this.statsCardPosition,
    required this.globalScale,
    required this.opacity,
  });

  factory OverlayLayoutConfiguration.defaults() {
    return const OverlayLayoutConfiguration(
      bannerPosition: OverlaySlotPosition.top,
      statsCardPosition: OverlaySlotPosition.bottom,
      globalScale: 1.0,
      opacity: 0.97,
    );
  }

  factory OverlayLayoutConfiguration.fromMap(Map<String, dynamic>? map) {
    final defaults = OverlayLayoutConfiguration.defaults();
    return OverlayLayoutConfiguration(
      bannerPosition: OverlaySlotPosition.fromStorage(
        _readString(map?['bannerPosition']),
      ),
      statsCardPosition: OverlaySlotPosition.fromStorage(
        _readString(map?['statsCardPosition'], fallback: 'bottom'),
      ),
      globalScale: _readDouble(
        map?['globalScale'],
        defaults.globalScale,
      ).clamp(0.8, 1.2),
      opacity: _readDouble(
        map?['opacity'],
        defaults.opacity,
      ).clamp(0.4, 1.0),
    );
  }

  OverlayLayoutConfiguration copyWith({
    OverlaySlotPosition? bannerPosition,
    OverlaySlotPosition? statsCardPosition,
    double? globalScale,
    double? opacity,
  }) {
    return OverlayLayoutConfiguration(
      bannerPosition: bannerPosition ?? this.bannerPosition,
      statsCardPosition: statsCardPosition ?? this.statsCardPosition,
      globalScale: globalScale ?? this.globalScale,
      opacity: opacity ?? this.opacity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bannerPosition': bannerPosition.storageValue,
      'statsCardPosition': statsCardPosition.storageValue,
      'globalScale': globalScale,
      'opacity': opacity,
    };
  }
}

@immutable
class OverlayFinishConfiguration {
  final double vignetteStrength;
  final double bloomIntensity;
  final double sparkleDensity;
  final double sheenSweep;

  const OverlayFinishConfiguration({
    required this.vignetteStrength,
    required this.bloomIntensity,
    required this.sparkleDensity,
    required this.sheenSweep,
  });

  factory OverlayFinishConfiguration.defaults() {
    return const OverlayFinishConfiguration(
      vignetteStrength: 0.34,
      bloomIntensity: 0.42,
      sparkleDensity: 0.28,
      sheenSweep: 0.36,
    );
  }

  factory OverlayFinishConfiguration.fromMap(Map<String, dynamic>? map) {
    final defaults = OverlayFinishConfiguration.defaults();
    return OverlayFinishConfiguration(
      vignetteStrength: _readDouble(
        map?['vignetteStrength'],
        defaults.vignetteStrength,
      ).clamp(0.0, 1.0),
      bloomIntensity: _readDouble(
        map?['bloomIntensity'],
        defaults.bloomIntensity,
      ).clamp(0.0, 1.0),
      sparkleDensity: _readDouble(
        map?['sparkleDensity'],
        defaults.sparkleDensity,
      ).clamp(0.0, 1.0),
      sheenSweep: _readDouble(
        map?['sheenSweep'],
        defaults.sheenSweep,
      ).clamp(0.0, 1.0),
    );
  }

  OverlayFinishConfiguration copyWith({
    double? vignetteStrength,
    double? bloomIntensity,
    double? sparkleDensity,
    double? sheenSweep,
  }) {
    return OverlayFinishConfiguration(
      vignetteStrength: vignetteStrength ?? this.vignetteStrength,
      bloomIntensity: bloomIntensity ?? this.bloomIntensity,
      sparkleDensity: sparkleDensity ?? this.sparkleDensity,
      sheenSweep: sheenSweep ?? this.sheenSweep,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'vignetteStrength': vignetteStrength,
      'bloomIntensity': bloomIntensity,
      'sparkleDensity': sparkleDensity,
      'sheenSweep': sheenSweep,
    };
  }
}

Map<String, dynamic>? _readMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }
  return null;
}

String _readString(dynamic raw, {String fallback = ''}) {
  return raw is String && raw.trim().isNotEmpty ? raw.trim() : fallback;
}

String? _readNullableString(dynamic raw) {
  if (raw is! String) {
    return null;
  }
  final normalized = raw.trim();
  return normalized.isEmpty ? null : normalized;
}

bool _readBool(dynamic raw, bool fallback) {
  return raw is bool ? raw : fallback;
}

int _readInt(dynamic raw, int fallback) {
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }
  if (raw is String) {
    return int.tryParse(raw) ?? fallback;
  }
  return fallback;
}

double _readDouble(dynamic raw, double fallback) {
  if (raw is num) {
    return raw.toDouble();
  }
  if (raw is String) {
    return double.tryParse(raw) ?? fallback;
  }
  return fallback;
}

Color _readColor(dynamic raw, Color fallback) {
  if (raw is int) {
    return Color(raw);
  }
  if (raw is num) {
    return Color(raw.toInt());
  }
  if (raw is String) {
    final normalized = raw.replaceFirst('#', '');
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed != null) {
      if (normalized.length <= 6) {
        return Color(0xFF000000 | parsed);
      }
      return Color(parsed);
    }
  }
  return fallback;
}
