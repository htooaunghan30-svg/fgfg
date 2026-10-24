import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/premium/overlay_svg_icon_import_service.dart';
import '../../features/premium/workout_overlay_customization.dart';
import '../providers/user_provider.dart';
import '../widgets/luxury_overlay_preview.dart';

class WorkoutOverlayCustomizerScreen extends StatefulWidget {
  const WorkoutOverlayCustomizerScreen({super.key});

  @override
  State<WorkoutOverlayCustomizerScreen> createState() =>
      _WorkoutOverlayCustomizerScreenState();
}

class _WorkoutOverlayCustomizerScreenState
    extends State<WorkoutOverlayCustomizerScreen>
    with WidgetsBindingObserver {
  static const Duration _autoSaveDelay = Duration(milliseconds: 1200);
  static const List<OverlayMovementPhase> _studioPreviewPhases = <OverlayMovementPhase>[
    OverlayMovementPhase.up,
    OverlayMovementPhase.down,
    OverlayMovementPhase.idle,
  ];
  static const List<Color> _colorPresets = <Color>[
    Color(0xFF111827),
    Color(0xFF172033),
    Color(0xFF2A1F3D),
    Color(0xFF4A0F1C),
    Color(0xFF7A1E2C),
    Color(0xFFA62C3C),
    Color(0xFFD14B5A),
    Color(0xFF7C5C2E),
    Color(0xFFF3D28A),
    Color(0xFFDA8E52),
    Color(0xFFE9EEF7),
    Color(0xFF74C0B8),
    Color(0xFFB76E79),
    Color(0xFFCDE4FF),
  ];

  late WorkoutOverlayCustomization _draft;
  late WorkoutOverlayCustomization _savedCustomization;
  OverlayMovementPhase _previewPhase = OverlayMovementPhase.up;
  bool _initialized = false;
  bool _saving = false;
  Timer? _autoSaveTimer;
  Future<void>? _activeSave;
  bool _saveQueued = false;

  String _counterShapeLabel(OverlayCounterShape shape) {
    switch (shape) {
      case OverlayCounterShape.circle:
        return 'Circle';
      case OverlayCounterShape.arc:
        return 'Arc';
      case OverlayCounterShape.hex:
        return 'Hex Luxe';
      case OverlayCounterShape.octagon:
        return 'Octagon';
      case OverlayCounterShape.shield:
        return 'Shield Crest';
      case OverlayCounterShape.diamond:
        return 'Diamond Cut';
      case OverlayCounterShape.flower:
        return 'Flower';
      case OverlayCounterShape.lotus:
        return 'Lotus';
      case OverlayCounterShape.crown:
        return 'Crown';
      case OverlayCounterShape.star:
        return 'Starburst';
    }
  }

  String _accuracyStyleLabel(OverlayAccuracyBarStyle style) {
    switch (style) {
      case OverlayAccuracyBarStyle.gradient:
        return 'Gradient';
      case OverlayAccuracyBarStyle.segmented:
        return 'Segmented';
      case OverlayAccuracyBarStyle.flat:
        return 'Flat';
      case OverlayAccuracyBarStyle.glass:
        return 'Glass';
      case OverlayAccuracyBarStyle.neon:
        return 'Neon';
      case OverlayAccuracyBarStyle.prism:
        return 'Prism';
      case OverlayAccuracyBarStyle.velvet:
        return 'Velvet';
    }
  }

  String _accuracyShapeLabel(OverlayAccuracyBarShape shape) {
    switch (shape) {
      case OverlayAccuracyBarShape.capsule:
        return 'Capsule';
      case OverlayAccuracyBarShape.beveled:
        return 'Beveled';
      case OverlayAccuracyBarShape.prism:
        return 'Prism Cut';
      case OverlayAccuracyBarShape.crest:
        return 'Royal Crest';
      case OverlayAccuracyBarShape.ribbon:
        return 'Ribbon Luxe';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    WidgetsBinding.instance.addObserver(this);
    _draft = context.read<UserProvider>().workoutOverlayCustomization;
    _savedCustomization = _draft;
    _initialized = true;
  }

  @override
  void setState(VoidCallback fn) {
    final draftBefore = _initialized ? _draft : null;
    super.setState(fn);
    if (!_initialized || draftBefore == null) {
      return;
    }
    if (!identical(draftBefore, _draft)) {
      _scheduleAutoSave();
    }
  }

  bool get _hasUnsavedChanges =>
      _draft.toJsonString() != _savedCustomization.toJsonString();

  void _scheduleAutoSave({bool immediate = false}) {
    _autoSaveTimer?.cancel();
    if (!_hasUnsavedChanges) {
      return;
    }
    if (immediate) {
      unawaited(_save());
      return;
    }
    _autoSaveTimer = Timer(_autoSaveDelay, () {
      unawaited(_save());
    });
  }

  Future<void> _save() async {
    if (!_hasUnsavedChanges) {
      return _activeSave ?? Future<void>.value();
    }
    final inFlight = _activeSave;
    if (inFlight != null) {
      _saveQueued = true;
      await inFlight;
      if (!_hasUnsavedChanges) {
        return;
      }
    }

    final saveFuture = _performSave();
    _activeSave = saveFuture;
    try {
      await saveFuture;
    } finally {
      if (identical(_activeSave, saveFuture)) {
        _activeSave = null;
      }
    }

    if (_saveQueued) {
      _saveQueued = false;
      if (_hasUnsavedChanges) {
        await _save();
      }
    }
  }

  Future<void> _performSave() async {
    if (mounted) {
      super.setState(() {
        _saving = true;
      });
    }
    try {
      final previousCustomization = _savedCustomization;
      final nextCustomization = _draft;
      await context
          .read<UserProvider>()
          .setWorkoutOverlayCustomization(nextCustomization);
      await _cleanupRemovedSvgAssets(
        previous: previousCustomization.icons,
        current: nextCustomization.icons,
      );
      if (!mounted) return;
      super.setState(() {
        _saving = false;
        _savedCustomization = nextCustomization;
      });
    } catch (error) {
      if (!mounted) return;
      super.setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save overlay settings: $error')),
      );
    }
  }

  void _reset() {
    setState(() {
      _draft = WorkoutOverlayCustomization.defaults();
    });
  }

  Future<bool> _handleWillPop() async {
    _autoSaveTimer?.cancel();
    await _save();
    return true;
  }

  Future<void> _cleanupRemovedSvgAssets({
    required OverlayIconConfiguration previous,
    required OverlayIconConfiguration current,
  }) async {
    final previousPaths = <String>{
      if ((previous.defaultIcon.svgPath ?? '').trim().isNotEmpty)
        previous.defaultIcon.svgPath!.trim(),
      if ((previous.upIcon.svgPath ?? '').trim().isNotEmpty)
        previous.upIcon.svgPath!.trim(),
      if ((previous.downIcon.svgPath ?? '').trim().isNotEmpty)
        previous.downIcon.svgPath!.trim(),
      if ((previous.holdIcon.svgPath ?? '').trim().isNotEmpty)
        previous.holdIcon.svgPath!.trim(),
    };
    final currentPaths = <String>{
      if ((current.defaultIcon.svgPath ?? '').trim().isNotEmpty)
        current.defaultIcon.svgPath!.trim(),
      if ((current.upIcon.svgPath ?? '').trim().isNotEmpty)
        current.upIcon.svgPath!.trim(),
      if ((current.downIcon.svgPath ?? '').trim().isNotEmpty)
        current.downIcon.svgPath!.trim(),
      if ((current.holdIcon.svgPath ?? '').trim().isNotEmpty)
        current.holdIcon.svgPath!.trim(),
    };

    for (final stalePath in previousPaths.difference(currentPaths)) {
      await OverlaySvgIconImportService.removeImportedSvg(stalePath);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _autoSaveTimer?.cancel();
      unawaited(_save());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _draft.palette;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Luxury Overlay Studio'),
          actions: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Center(child: Text('Saving...')),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Text(
                    _hasUnsavedChanges ? 'Saving soon...' : 'Saved',
                  ),
                ),
              ),
            TextButton(
              onPressed: _saving ? null : _reset,
              child: const Text('Reset'),
            ),
          ],
        ),
        body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              Color.lerp(
                      theme.scaffoldBackgroundColor, palette.primary, 0.12) ??
                  theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LuxuryOverlayPreview(
                    customization: _draft,
                    phase: _previewPhase,
                    onToggleBranding: () {
                      setState(() {
                        _draft = _draft.copyWith(
                          showBranding: !_draft.showBranding,
                        );
                      });
                    },
                    onToggleAccuracy: () {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar: _draft.accuracyBar.copyWith(
                            show: !_draft.accuracyBar.show,
                          ),
                        );
                      });
                    },
                    onToggleRepCounter: () {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter: _draft.repCounter.copyWith(
                            show: !_draft.repCounter.show,
                          ),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _studioPreviewPhases.map((phase) {
                      return ChoiceChip(
                        label: Text(phase.storageValue.toUpperCase()),
                        selected: _previewPhase == phase,
                        onSelected: (_) {
                          setState(() {
                            _previewPhase = phase;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                children: [
                  _SectionCard(
              title: 'Master Mode',
              subtitle:
                  'Switch between preset festival export and your custom luxury system.',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _draft.customModeEnabled,
                    title: const Text('Enable custom post-process overlay'),
                    subtitle: const Text(
                      'When disabled, the existing preset exporter stays in control.',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(customModeEnabled: value);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _SegmentRow<OverlayPerformanceMode>(
                    label: 'Performance mode',
                    value: _draft.performanceMode,
                    values: OverlayPerformanceMode.values,
                    labelBuilder: (value) => value.storageValue.toUpperCase(),
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(performanceMode: value);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _draft = _draft.applyWorldFestivalLuxuryPreset();
                            });
                          },
                          child: const Text('Apply World Festival Luxe'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _draft = _draft.removeWorldFestivalLuxuryPreset();
                            });
                          },
                          child: const Text('Remove World Festival Luxe'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
              title: 'Text & Branding',
              subtitle: 'Luxury naming, subtitle tone, and signature line.',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show branding bar'),
                    subtitle: const Text('Toggle the top logo and text bar.'),
                    value: _draft.showBranding,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(showBranding: value);
                      });
                    },
                  ),
                  const Divider(),
                  _TextFieldTile(
                    label: 'Title',
                    initialValue: _draft.title,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(title: value);
                      });
                    },
                  ),
                  _TextFieldTile(
                    label: 'Subtitle',
                    initialValue: _draft.subtitle,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(subtitle: value);
                      });
                    },
                  ),
                  _TextFieldTile(
                    label: 'Branding',
                    initialValue: _draft.brandingText,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(brandingText: value);
                      });
                    },
                  ),
                  const Divider(),
                  _GradientBorderEditor(
                    label: 'Banner Border',
                    config: _draft.bannerGradientBorder,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(bannerGradientBorder: value);
                      });
                    },
                  ),
                ],
              ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
              title: 'Narrative Flow',
              subtitle:
                  'These 4 text cues appear only in post-process. Set the rep number beside each text. The text reveals only when that exact rep reaches 80% accuracy.',
              child: Column(
                children: [
                  _NarrativeCueEditor(
                    label: 'Cue 1',
                    initialValue: _draft.narrative.firstFlowText,
                    initialRepTarget: _draft.narrative.firstFlowRep,
                    initialTextColor: _draft.narrative.firstFlowTextColor,
                    initialTextColorSecondary:
                        _draft.narrative.firstFlowTextColorSecondary,
                    colorPresets: _colorPresets,
                    onTextChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            firstFlowText: value,
                          ),
                        );
                      });
                    },
                    onTextColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            firstFlowTextColor: color,
                          ),
                        );
                      });
                    },
                    onTextSecondaryColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            firstFlowTextColorSecondary: color,
                          ),
                        );
                      });
                    },
                    onRepChanged: (rep) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            firstFlowRep: rep,
                          ),
                        );
                      });
                    },
                  ),
                  _NarrativeCueEditor(
                    label: 'Cue 2',
                    initialValue: _draft.narrative.secondFlowText,
                    initialRepTarget: _draft.narrative.secondFlowRep,
                    initialTextColor: _draft.narrative.secondFlowTextColor,
                    initialTextColorSecondary:
                        _draft.narrative.secondFlowTextColorSecondary,
                    colorPresets: _colorPresets,
                    onTextChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            secondFlowText: value,
                          ),
                        );
                      });
                    },
                    onTextColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            secondFlowTextColor: color,
                          ),
                        );
                      });
                    },
                    onTextSecondaryColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            secondFlowTextColorSecondary: color,
                          ),
                        );
                      });
                    },
                    onRepChanged: (rep) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            secondFlowRep: rep,
                          ),
                        );
                      });
                    },
                  ),
                  _NarrativeCueEditor(
                    label: 'Cue 3',
                    initialValue: _draft.narrative.thirdFlowText,
                    initialRepTarget: _draft.narrative.thirdFlowRep,
                    initialTextColor: _draft.narrative.thirdFlowTextColor,
                    initialTextColorSecondary:
                        _draft.narrative.thirdFlowTextColorSecondary,
                    colorPresets: _colorPresets,
                    onTextChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            thirdFlowText: value,
                          ),
                        );
                      });
                    },
                    onTextColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            thirdFlowTextColor: color,
                          ),
                        );
                      });
                    },
                    onTextSecondaryColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            thirdFlowTextColorSecondary: color,
                          ),
                        );
                      });
                    },
                    onRepChanged: (rep) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            thirdFlowRep: rep,
                          ),
                        );
                      });
                    },
                  ),
                  _NarrativeCueEditor(
                    label: 'Cue 4',
                    initialValue: _draft.narrative.fourthFlowText,
                    initialRepTarget: _draft.narrative.fourthFlowRep,
                    initialTextColor: _draft.narrative.fourthFlowTextColor,
                    initialTextColorSecondary:
                        _draft.narrative.fourthFlowTextColorSecondary,
                    colorPresets: _colorPresets,
                    onTextChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            fourthFlowText: value,
                          ),
                        );
                      });
                    },
                    onTextColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            fourthFlowTextColor: color,
                          ),
                        );
                      });
                    },
                    onTextSecondaryColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            fourthFlowTextColorSecondary: color,
                          ),
                        );
                      });
                    },
                    onRepChanged: (rep) {
                      setState(() {
                        _draft = _draft.copyWith(
                          narrative: _draft.narrative.copyWith(
                            fourthFlowRep: rep,
                          ),
                        );
                      });
                    },
                  ),
                ],
              ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
              title: 'Icon System',
              subtitle:
                  'Import SVG icons per phase. We clean white backdrops, tighten rough bounds, and keep export output polished.',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _draft.icons.autoSwitch,
                    title: const Text('Auto switch icon based on movement'),
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          icons: _draft.icons.copyWith(autoSwitch: value),
                        );
                      });
                    },
                  ),
                  _IconSlotEditor(
                    title: 'Default',
                    slotKey: 'default',
                    slot: _draft.icons.defaultIcon,
                    onChanged: (slot) {
                      setState(() {
                        _draft = _draft.copyWith(
                          icons: _draft.icons.copyWith(defaultIcon: slot),
                        );
                      });
                    },
                  ),
                  _IconSlotEditor(
                    title: 'UP phase',
                    slotKey: 'up',
                    slot: _draft.icons.upIcon,
                    onChanged: (slot) {
                      setState(() {
                        _draft = _draft.copyWith(
                          icons: _draft.icons.copyWith(upIcon: slot),
                        );
                      });
                    },
                  ),
                  _IconSlotEditor(
                    title: 'DOWN phase',
                    slotKey: 'down',
                    slot: _draft.icons.downIcon,
                    onChanged: (slot) {
                      setState(() {
                        _draft = _draft.copyWith(
                          icons: _draft.icons.copyWith(downIcon: slot),
                        );
                      });
                    },
                  ),
                ],
              ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
              title: 'Color System',
              subtitle:
                  'Primary, metallic accent, and phase-specific color control.',
              child: Column(
                children: [
                  _ColorTile(
                    label: 'Primary',
                    color: _draft.palette.primary,
                    presets: _colorPresets,
                    onColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          palette: _draft.palette.copyWith(primary: color),
                        );
                      });
                    },
                  ),
                  _ColorTile(
                    label: 'Secondary',
                    color: _draft.palette.secondary,
                    presets: _colorPresets,
                    onColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          palette: _draft.palette.copyWith(secondary: color),
                        );
                      });
                    },
                  ),
                  _ColorTile(
                    label: 'Accent',
                    color: _draft.palette.accent,
                    presets: _colorPresets,
                    onColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          palette: _draft.palette.copyWith(accent: color),
                        );
                      });
                    },
                  ),
                  _ColorTile(
                    label: 'UP phase',
                    color: _draft.palette.phaseUp,
                    presets: _colorPresets,
                    onColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          palette: _draft.palette.copyWith(phaseUp: color),
                        );
                      });
                    },
                  ),
                  _ColorTile(
                    label: 'DOWN phase',
                    color: _draft.palette.phaseDown,
                    presets: _colorPresets,
                    onColorChanged: (color) {
                      setState(() {
                        _draft = _draft.copyWith(
                          palette: _draft.palette.copyWith(phaseDown: color),
                        );
                      });
                    },
                  ),
                ],
              ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
              title: 'Rep Counter Style',
              subtitle:
                  'Choose a silhouette, then tune softness, glow, depth, orbit energy, and animation with sliders.',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show rep counter'),
                    subtitle: const Text('Toggle the circular rep counter UI.'),
                    value: _draft.repCounter.show,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter: _draft.repCounter.copyWith(show: value),
                        );
                      });
                    },
                  ),
                  const Divider(),
                  _SliderTile(
                    label: 'Ring thickness',
                    value: _draft.repCounter.ringThickness,
                    min: 4,
                    max: 16,
                    divisions: 12,
                    suffix: _draft.repCounter.ringThickness.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter:
                              _draft.repCounter.copyWith(ringThickness: value),
                        );
                      });
                    },
                  ),
                  _SegmentRow<OverlayCounterShape>(
                    label: 'Shape',
                    value: _draft.repCounter.shape,
                    values: OverlayCounterShape.values,
                    labelBuilder: _counterShapeLabel,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter: _draft.repCounter.copyWith(shape: value),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SliderTile(
                    label: 'Contour softness',
                    value: _draft.repCounter.contourSoftness,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.repCounter.contourSoftness * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter: _draft.repCounter.copyWith(
                            contourSoftness: value,
                          ),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Counter glow',
                    value: _draft.repCounter.glowIntensity,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.repCounter.glowIntensity * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter:
                              _draft.repCounter.copyWith(glowIntensity: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Surface depth',
                    value: _draft.repCounter.surfaceDepth,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.repCounter.surfaceDepth * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter:
                              _draft.repCounter.copyWith(surfaceDepth: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Orbit intensity',
                    value: _draft.repCounter.orbitIntensity,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.repCounter.orbitIntensity * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter:
                              _draft.repCounter.copyWith(orbitIntensity: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Bevel shine',
                    value: _draft.repCounter.bevelIntensity,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.repCounter.bevelIntensity * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter:
                              _draft.repCounter.copyWith(bevelIntensity: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Halo spread',
                    value: _draft.repCounter.haloSpread,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.repCounter.haloSpread * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter:
                              _draft.repCounter.copyWith(haloSpread: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Core cut',
                    value: _draft.repCounter.coreRadius,
                    min: 0.38,
                    max: 0.82,
                    divisions: 11,
                    suffix:
                        '${(_draft.repCounter.coreRadius * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter:
                              _draft.repCounter.copyWith(coreRadius: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Jewel sparkle',
                    value: _draft.repCounter.jewelSparkle,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.repCounter.jewelSparkle * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter:
                              _draft.repCounter.copyWith(jewelSparkle: value),
                        );
                      });
                    },
                  ),
                  _SegmentRow<OverlayAnimationStyle>(
                    label: 'Animation',
                    value: _draft.repCounter.animationStyle,
                    values: OverlayAnimationStyle.values,
                    labelBuilder: (value) => value.storageValue.toUpperCase(),
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter: _draft.repCounter.copyWith(
                            animationStyle: value,
                          ),
                        );
                      });
                    },
                  ),
                  const Divider(),
                  _GradientBorderEditor(
                    label: 'Counter Border',
                    config: _draft.repCounter.gradientBorder,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          repCounter:
                              _draft.repCounter.copyWith(gradientBorder: value),
                        );
                      });
                    },
                  ),
                ],
              ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
              title: 'Accuracy Bar',
              subtitle:
                  'Pick a visual language, then sculpt intensity, markers, spill behavior, and liquid glow with sliders.',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show accuracy bar'),
                    subtitle: const Text('Toggle the horizontal accuracy indicator.'),
                    value: _draft.accuracyBar.show,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar: _draft.accuracyBar.copyWith(show: value),
                        );
                      });
                    },
                  ),
                  const Divider(),
                  _SegmentRow<OverlayAccuracyBarStyle>(
                    label: 'Style',
                    value: _draft.accuracyBar.style,
                    values: OverlayAccuracyBarStyle.values,
                    labelBuilder: _accuracyStyleLabel,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(style: value),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SegmentRow<OverlayAccuracyBarShape>(
                    label: 'Shape',
                    value: _draft.accuracyBar.shape,
                    values: OverlayAccuracyBarShape.values,
                    labelBuilder: _accuracyShapeLabel,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(shape: value),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SliderTile(
                    label: 'Style intensity',
                    value: _draft.accuracyBar.styleIntensity,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.accuracyBar.styleIntensity * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar: _draft.accuracyBar.copyWith(
                            styleIntensity: value,
                          ),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Frame depth',
                    value: _draft.accuracyBar.frameDepth,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.accuracyBar.frameDepth * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(frameDepth: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Gloss veil',
                    value: _draft.accuracyBar.glossAmount,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.accuracyBar.glossAmount * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(glossAmount: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Jewel inset',
                    value: _draft.accuracyBar.jewelInset,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.accuracyBar.jewelInset * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(jewelInset: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Flare bloom',
                    value: _draft.accuracyBar.flareAmount,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.accuracyBar.flareAmount * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(flareAmount: value),
                        );
                      });
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _draft.accuracyBar.showThresholdLine,
                    title: const Text('Show threshold line'),
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar: _draft.accuracyBar.copyWith(
                            showThresholdLine: value,
                          ),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Marker density',
                    value: _draft.accuracyBar.markerDensity,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.accuracyBar.markerDensity * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(markerDensity: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Bar glow',
                    value: _draft.accuracyBar.glowIntensity,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.accuracyBar.glowIntensity * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(glowIntensity: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Spill length',
                    value: _draft.accuracyBar.spillLength,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.accuracyBar.spillLength * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(spillLength: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Spill width',
                    value: _draft.accuracyBar.spillWidth,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix: '${(_draft.accuracyBar.spillWidth * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(spillWidth: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Threshold glow',
                    value: _draft.accuracyBar.thresholdGlow,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.accuracyBar.thresholdGlow * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(thresholdGlow: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Liquid motion',
                    value: _draft.accuracyBar.liquidMotion,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.accuracyBar.liquidMotion * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(liquidMotion: value),
                        );
                      });
                    },
                  ),
                  const Divider(),
                  _GradientBorderEditor(
                    label: 'Bar Border',
                    config: _draft.accuracyBar.gradientBorder,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          accuracyBar:
                              _draft.accuracyBar.copyWith(gradientBorder: value),
                        );
                      });
                    },
                  ),
                ],
              ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
              title: 'Layout Control',
              subtitle:
                  'Move the accuracy and rep cluster, keep the branding bar stable, and tune overall scale.',
              child: Column(
                children: [
                  _SegmentRow<OverlaySlotPosition>(
                    label: 'Counter cluster',
                    value: _draft.layout.counterClusterPosition,
                    values: const [
                      OverlaySlotPosition.top,
                      OverlaySlotPosition.left,
                      OverlaySlotPosition.right,
                    ],
                    labelBuilder: (value) => value.storageValue.toUpperCase(),
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          layout: _draft.layout.copyWith(
                            counterClusterPosition: value,
                          ),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SegmentRow<OverlaySlotPosition>(
                    label: 'Stats card slot',
                    value: _draft.layout.statsCardPosition,
                    values: const [
                      OverlaySlotPosition.none,
                      OverlaySlotPosition.top,
                      OverlaySlotPosition.center,
                      OverlaySlotPosition.bottom,
                    ],
                    labelBuilder: (value) => value.storageValue.toUpperCase(),
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          layout:
                              _draft.layout.copyWith(statsCardPosition: value),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SliderTile(
                    label: 'Global scale',
                    value: _draft.layout.globalScale,
                    min: 0.8,
                    max: 1.2,
                    divisions: 8,
                    suffix: _draft.layout.globalScale.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          layout: _draft.layout.copyWith(globalScale: value),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Overlay opacity',
                    value: _draft.layout.opacity,
                    min: 0.5,
                    max: 1.0,
                    divisions: 10,
                    suffix: '${(_draft.layout.opacity * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          layout: _draft.layout.copyWith(opacity: value),
                        );
                      });
                    },
                  ),
                ],
              ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
              title: 'Luxe Finish',
              subtitle:
                  'Add premium atmosphere without changing your existing theme system.',
              child: Column(
                children: [
                  _SliderTile(
                    label: 'Vignette focus',
                    value: _draft.finish.vignetteStrength,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.finish.vignetteStrength * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          finish: _draft.finish.copyWith(
                            vignetteStrength: value,
                          ),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Bloom glow',
                    value: _draft.finish.bloomIntensity,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.finish.bloomIntensity * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          finish: _draft.finish.copyWith(
                            bloomIntensity: value,
                          ),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Sparkle field',
                    value: _draft.finish.sparkleDensity,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix:
                        '${(_draft.finish.sparkleDensity * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          finish: _draft.finish.copyWith(
                            sparkleDensity: value,
                          ),
                        );
                      });
                    },
                  ),
                  _SliderTile(
                    label: 'Sheen sweep',
                    value: _draft.finish.sheenSweep,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    suffix: '${(_draft.finish.sheenSweep * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          finish: _draft.finish.copyWith(sheenSweep: value),
                        );
                      });
                    },
                  ),
                ],
              ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.68),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _TextFieldTile extends StatelessWidget {
  final String label;
  final String initialValue;
  final int minLines;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _TextFieldTile({
    required this.label,
    required this.initialValue,
    this.minLines = 1,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        minLines: minLines,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}


class _GradientBorderEditor extends StatelessWidget {
  final String label;
  final OverlayGradientBorderConfiguration config;
  final ValueChanged<OverlayGradientBorderConfiguration> onChanged;

  const _GradientBorderEditor({
    required this.label,
    required this.config,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          subtitle: const Text('TikTok-style multi-color gradient border.'),
          value: config.enabled,
          onChanged: (value) => onChanged(config.copyWith(enabled: value)),
        ),
        if (config.enabled) ...[
          _SliderTile(
            label: 'Border width',
            value: config.width,
            min: 1,
            max: 8,
            divisions: 14,
            suffix: config.width.toStringAsFixed(1),
            onChanged: (value) => onChanged(config.copyWith(width: value)),
          ),
          _SliderTile(
            label: 'Rotation',
            value: config.rotationTurns,
            min: 0,
            max: 1,
            divisions: 20,
            suffix: '${(config.rotationTurns * 360).round()}°',
            onChanged: (value) =>
                onChanged(config.copyWith(rotationTurns: value)),
          ),
          const SizedBox(height: 12),
          Text(
            'Colors (${config.colors.length})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...config.colors.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final color = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showColorPickerDialog(context, color, (newColor) {
                              final newColors = List<Color>.from(config.colors);
                              newColors[idx] = newColor;
                              onChanged(config.copyWith(colors: newColors));
                            });
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(color: Colors.white24),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (config.colors.length > 2)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: GestureDetector(
                              onTap: () {
                                final newColors =
                                    List<Color>.from(config.colors);
                                newColors.removeAt(idx);
                                onChanged(config.copyWith(colors: newColors));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                IconButton(
                  onPressed: () {
                    final newColors = List<Color>.from(config.colors);
                    newColors.add(newColors.last);
                    onChanged(config.copyWith(colors: newColors));
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Presets',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: OverlayGradientBorderPreset.values.map((preset) {
              return ActionChip(
                label: Text(preset.label, style: const TextStyle(fontSize: 11)),
                onPressed: () => onChanged(config.copyWith(colors: preset.colors)),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    Color current,
    ValueChanged<Color> onColorChanged,
  ) {
    // Reuse the existing _SectionCard or dialog logic if available
    // But since _ColorTile has a private _showHexDialog, I'll need to replicate or make it accessible.
    // For now, I'll just use the logic from _ColorTile._showHexDialog
    showDialog<void>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(
            text: '#${current.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}');
        return AlertDialog(
          title: const Text('Select Color'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '#RRGGBB',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final normalized =
                    controller.text.trim().replaceFirst('#', '');
                if (normalized.length == 6 || normalized.length == 8) {
                  final val = int.tryParse(normalized, radix: 16);
                  if (val != null) {
                    onColorChanged(
                        Color(normalized.length == 6 ? 0xFF000000 | val : val));
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}

class _NarrativeCueEditor extends StatelessWidget {
  final String label;
  final String initialValue;
  final int initialRepTarget;
  final Color initialTextColor;
  final Color initialTextColorSecondary;
  final List<Color> colorPresets;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<Color> onTextColorChanged;
  final ValueChanged<Color> onTextSecondaryColorChanged;
  final ValueChanged<int> onRepChanged;

  const _NarrativeCueEditor({
    required this.label,
    required this.initialValue,
    required this.initialRepTarget,
    required this.initialTextColor,
    required this.initialTextColorSecondary,
    required this.colorPresets,
    required this.onTextChanged,
    required this.onTextColorChanged,
    required this.onTextSecondaryColorChanged,
    required this.onRepChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextFormField(
                    initialValue: '$initialRepTarget',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rep No.',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value.trim());
                      if (parsed != null && parsed > 0) {
                        onRepChanged(parsed);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: initialValue,
              minLines: 4,
              maxLines: 7,
              onChanged: onTextChanged,
              decoration: InputDecoration(
                labelText: '$label Text',
                border: const OutlineInputBorder(),
                helperText: 'This text appears after the selected rep reaches 80% accuracy.',
              ),
            ),
            const SizedBox(height: 10),
            _ColorTile(
              label: '$label Gradient Start',
              color: initialTextColor,
              presets: colorPresets,
              onColorChanged: onTextColorChanged,
            ),
            _ColorTile(
              label: '$label Gradient End',
              color: initialTextColorSecondary,
              presets: colorPresets,
              onColorChanged: onTextSecondaryColorChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              suffix,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.72),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SegmentRow<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  const _SegmentRow({
    required this.label,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((entry) {
            return ChoiceChip(
              label: Text(labelBuilder(entry)),
              selected: value == entry,
              onSelected: (_) => onChanged(entry),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _IconSlotEditor extends StatefulWidget {
  final String title;
  final String slotKey;
  final OverlayPhaseIconSlot slot;
  final ValueChanged<OverlayPhaseIconSlot> onChanged;

  const _IconSlotEditor({
    required this.title,
    required this.slotKey,
    required this.slot,
    required this.onChanged,
  });

  @override
  State<_IconSlotEditor> createState() => _IconSlotEditorState();
}

class _IconSlotEditorState extends State<_IconSlotEditor> {
  bool _busy = false;

  Future<void> _pickSvg() async {
    setState(() {
      _busy = true;
    });
    try {
      final imported = await OverlaySvgIconImportService.pickAndImportSvg(
        slotKey: widget.slotKey,
      );
      if (!mounted || imported == null) {
        return;
      }
      widget.onChanged(
        widget.slot.copyWith(svgPath: imported.svgPath),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(imported.summary)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SVG import failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _removeSvg() async {
    setState(() {
      _busy = true;
    });
    try {
      widget.onChanged(widget.slot.copyWith(clearSvgPath: true));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final svgName =
        OverlaySvgIconImportService.displayNameForPath(widget.slot.svgPath);
    final hasSvg = (widget.slot.svgPath ?? '').trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.04),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: hasSvg
                            ? Colors.tealAccent.withOpacity(0.12)
                            : Colors.white.withOpacity(0.06),
                        border: Border.all(
                          color: hasSvg
                              ? Colors.tealAccent.withOpacity(0.34)
                              : Colors.white.withOpacity(0.08),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        hasSvg ? 'SVG' : widget.slot.glyph,
                        style: TextStyle(
                          color: hasSvg ? Colors.tealAccent.shade100 : Colors.white70,
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
                            hasSvg ? svgName : 'No SVG selected yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasSvg
                                ? 'Export uses this sanitized SVG. White backgrounds and rough bounds are cleaned automatically.'
                                : 'SVG only. Pick a file and we will sanitize it for cleaner export badges.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: Colors.white.withOpacity(0.68),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fallback badge: ${widget.slot.glyph}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.44),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _busy ? null : _pickSvg,
                      icon: const Icon(Icons.upload_file_rounded),
                      label: Text(
                        _busy
                            ? 'Importing...'
                            : hasSvg
                                ? 'Replace SVG'
                                : 'Choose SVG',
                      ),
                    ),
                    if (hasSvg)
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _removeSvg,
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Remove'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Supported input: `.svg` files only.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.60),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final String label;
  final Color color;
  final List<Color> presets;
  final ValueChanged<Color> onColorChanged;

  const _ColorTile({
    required this.label,
    required this.color,
    required this.presets,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => _showHexDialog(context, color, onColorChanged),
                child: Text(_hexLabel(color)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((preset) {
              final selected = preset.value == color.value;
              return GestureDetector(
                onTap: () => onColorChanged(preset),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: preset,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: preset.withOpacity(0.24),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _showHexDialog(
    BuildContext context,
    Color current,
    ValueChanged<Color> onColorChanged,
  ) async {
    final controller = TextEditingController(text: _hexLabel(current));
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom color'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '#F3D28A',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = _parseHexColor(controller.text);
                if (parsed != null) {
                  onColorChanged(parsed);
                  Navigator.pop(context);
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  static String _hexLabel(Color color) {
    final value = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${value.substring(2)}';
  }

  static Color? _parseHexColor(String raw) {
    final normalized = raw.trim().replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) {
      return null;
    }
    final value = int.tryParse(normalized, radix: 16);
    if (value == null) {
      return null;
    }
    return Color(normalized.length == 6 ? 0xFF000000 | value : value);
  }
}
