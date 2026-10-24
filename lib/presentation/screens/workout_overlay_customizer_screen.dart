import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
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
    final l10n = context.l10n;
    switch (shape) {
      case OverlayCounterShape.circle:
        return l10n.t('overlay.studio.enum.counter_shape.circle');
      case OverlayCounterShape.arc:
        return l10n.t('overlay.studio.enum.counter_shape.arc');
      case OverlayCounterShape.hex:
        return l10n.t('overlay.studio.enum.counter_shape.hex');
      case OverlayCounterShape.octagon:
        return l10n.t('overlay.studio.enum.counter_shape.octagon');
      case OverlayCounterShape.shield:
        return l10n.t('overlay.studio.enum.counter_shape.shield');
      case OverlayCounterShape.diamond:
        return l10n.t('overlay.studio.enum.counter_shape.diamond');
      case OverlayCounterShape.flower:
        return l10n.t('overlay.studio.enum.counter_shape.flower');
      case OverlayCounterShape.lotus:
        return l10n.t('overlay.studio.enum.counter_shape.lotus');
      case OverlayCounterShape.crown:
        return l10n.t('overlay.studio.enum.counter_shape.crown');
      case OverlayCounterShape.star:
        return l10n.t('overlay.studio.enum.counter_shape.star');
    }
  }

  String _accuracyStyleLabel(OverlayAccuracyBarStyle style) {
    final l10n = context.l10n;
    switch (style) {
      case OverlayAccuracyBarStyle.gradient:
        return l10n.t('overlay.studio.enum.accuracy_style.gradient');
      case OverlayAccuracyBarStyle.segmented:
        return l10n.t('overlay.studio.enum.accuracy_style.segmented');
      case OverlayAccuracyBarStyle.flat:
        return l10n.t('overlay.studio.enum.accuracy_style.flat');
      case OverlayAccuracyBarStyle.glass:
        return l10n.t('overlay.studio.enum.accuracy_style.glass');
      case OverlayAccuracyBarStyle.neon:
        return l10n.t('overlay.studio.enum.accuracy_style.neon');
      case OverlayAccuracyBarStyle.prism:
        return l10n.t('overlay.studio.enum.accuracy_style.prism');
      case OverlayAccuracyBarStyle.velvet:
        return l10n.t('overlay.studio.enum.accuracy_style.velvet');
    }
  }

  String _accuracyShapeLabel(OverlayAccuracyBarShape shape) {
    final l10n = context.l10n;
    switch (shape) {
      case OverlayAccuracyBarShape.capsule:
        return l10n.t('overlay.studio.enum.accuracy_shape.capsule');
      case OverlayAccuracyBarShape.beveled:
        return l10n.t('overlay.studio.enum.accuracy_shape.beveled');
      case OverlayAccuracyBarShape.prism:
        return l10n.t('overlay.studio.enum.accuracy_shape.prism');
      case OverlayAccuracyBarShape.crest:
        return l10n.t('overlay.studio.enum.accuracy_shape.crest');
      case OverlayAccuracyBarShape.ribbon:
        return l10n.t('overlay.studio.enum.accuracy_shape.ribbon');
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
        SnackBar(
          content: Text(
            context.l10n.t(
              'overlay.studio.save_failed',
              params: {'error': '$error'},
            ),
          ),
        ),
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
    final l10n = context.l10n;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.t('overlay.studio.title')),
          actions: [
            if (_saving)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(child: Text(l10n.t('overlay.studio.saving'))),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Text(
                    _hasUnsavedChanges
                        ? l10n.t('overlay.studio.saving_soon')
                        : l10n.t('overlay.studio.saved'),
                  ),
                ),
              ),
            TextButton(
              onPressed: _saving ? null : _reset,
              child: Text(l10n.t('overlay.studio.reset')),
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
                  SizedBox(
                    height: 220,
                    child: LuxuryOverlayPreview(
                      customization: _draft,
                      phase: _previewPhase,
                      minHeight: 220,
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
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                children: [
                  _SectionCard(
                    title: l10n.t('overlay.studio.preview_phase'),
                    subtitle: l10n.t('overlay.studio.preview_phase_subtitle'),
                    child: Wrap(
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
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
              title: l10n.t('overlay.studio.master_mode'),
              subtitle: l10n.t('overlay.studio.master_mode_subtitle'),
              child: Column(
                children: [
                  _SegmentRow<OverlayPerformanceMode>(
                    label: l10n.t('overlay.studio.performance_mode'),
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
                          child: Text(l10n.t('overlay.studio.apply_festival_luxe')),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _draft = _draft.removeWorldFestivalLuxuryPreset();
                            });
                          },
                          child: Text(l10n.t('overlay.studio.remove_festival_luxe')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
              title: l10n.t('overlay.studio.text_branding'),
              subtitle: l10n.t('overlay.studio.text_branding_subtitle'),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.t('overlay.studio.show_branding_bar')),
                    subtitle: Text(
                      l10n.t('overlay.studio.show_branding_bar_subtitle'),
                    ),
                    value: _draft.showBranding,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(showBranding: value);
                      });
                    },
                  ),
                  const Divider(),
                  _TextFieldTile(
                    label: l10n.t('overlay.studio.title_field'),
                    initialValue: _draft.title,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(title: value);
                      });
                    },
                  ),
                  _TextFieldTile(
                    label: l10n.t('overlay.studio.subtitle_field'),
                    initialValue: _draft.subtitle,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(subtitle: value);
                      });
                    },
                  ),
                  _TextFieldTile(
                    label: l10n.t('overlay.studio.branding_field'),
                    initialValue: _draft.brandingText,
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(brandingText: value);
                      });
                    },
                  ),
                  const Divider(),
                  _GradientBorderEditor(
                    label: l10n.t('overlay.studio.banner_border'),
                    config: _draft.bannerGradientBorder,
                    subtitle: l10n.t('overlay.studio.banner_border_subtitle'),
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
              title: l10n.t('overlay.studio.narrative_flow'),
              subtitle: l10n.t('overlay.studio.narrative_flow_subtitle'),
              child: Column(
                children: [
                  _NarrativeCueEditor(
                    label: l10n.t(
                      'overlay.studio.cue_label',
                      params: {'number': '1'},
                    ),
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
                    label: l10n.t(
                      'overlay.studio.cue_label',
                      params: {'number': '2'},
                    ),
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
                    label: l10n.t(
                      'overlay.studio.cue_label',
                      params: {'number': '3'},
                    ),
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
                    label: l10n.t(
                      'overlay.studio.cue_label',
                      params: {'number': '4'},
                    ),
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
              title: l10n.t('overlay.studio.icon_system'),
              subtitle: l10n.t('overlay.studio.icon_system_subtitle'),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _draft.icons.autoSwitch,
                    title: Text(l10n.t('overlay.studio.auto_switch_icon')),
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          icons: _draft.icons.copyWith(autoSwitch: value),
                        );
                      });
                    },
                  ),
                  _IconSlotEditor(
                    title: l10n.t('overlay.studio.default_slot'),
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
                    title: l10n.t('overlay.studio.up_phase'),
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
                    title: l10n.t('overlay.studio.down_phase'),
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
              title: l10n.t('overlay.studio.color_system'),
              subtitle: l10n.t('overlay.studio.color_system_subtitle'),
              child: Column(
                children: [
                  _ColorTile(
                    label: l10n.t('overlay.studio.primary_color'),
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
                    label: l10n.t('overlay.studio.secondary_color'),
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
                    label: l10n.t('overlay.studio.accent_color'),
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
                    label: l10n.t('overlay.studio.up_phase'),
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
                    label: l10n.t('overlay.studio.down_phase'),
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
              title: l10n.t('overlay.studio.rep_counter_style'),
              subtitle:
                  l10n.t('overlay.studio.rep_counter_style_subtitle'),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.t('overlay.studio.show_rep_counter')),
                    subtitle: Text(
                      l10n.t('overlay.studio.show_rep_counter_subtitle'),
                    ),
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
                    label: l10n.t('overlay.studio.counter_ring_thickness'),
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
                    label: l10n.t('overlay.studio.counter_shape'),
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
                    label: l10n.t('overlay.studio.counter_contour_softness'),
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
                    label: l10n.t('overlay.studio.counter_glow'),
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
                    label: l10n.t('overlay.studio.counter_surface_depth'),
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
                    label: l10n.t('overlay.studio.counter_orbit_intensity'),
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
                    label: l10n.t('overlay.studio.counter_bevel_shine'),
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
                    label: l10n.t('overlay.studio.counter_halo_spread'),
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
                    label: l10n.t('overlay.studio.counter_core_cut'),
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
                    label: l10n.t('overlay.studio.counter_jewel_sparkle'),
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
                    label: l10n.t('overlay.studio.counter_animation'),
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
                    label: l10n.t('overlay.studio.counter_border'),
                    subtitle: l10n.t('overlay.studio.counter_border_subtitle'),
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
              title: l10n.t('overlay.studio.accuracy_bar'),
              subtitle:
                  l10n.t('overlay.studio.accuracy_bar_subtitle'),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.t('overlay.studio.show_accuracy_bar')),
                    subtitle: Text(
                      l10n.t('overlay.studio.show_accuracy_bar_subtitle'),
                    ),
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
                    label: l10n.t('overlay.studio.accuracy_style'),
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
                    label: l10n.t('overlay.studio.accuracy_shape'),
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
                    label: l10n.t('overlay.studio.accuracy_style_intensity'),
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
                    label: l10n.t('overlay.studio.accuracy_frame_depth'),
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
                    label: l10n.t('overlay.studio.accuracy_gloss_veil'),
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
                    label: l10n.t('overlay.studio.accuracy_jewel_inset'),
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
                    label: l10n.t('overlay.studio.accuracy_flare_bloom'),
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
                    title: Text(l10n.t('overlay.studio.show_threshold_line')),
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
                    label: l10n.t('overlay.studio.accuracy_marker_density'),
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
                    label: l10n.t('overlay.studio.accuracy_bar_glow'),
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
                    label: l10n.t('overlay.studio.accuracy_spill_length'),
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
                    label: l10n.t('overlay.studio.accuracy_spill_width'),
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
                    label: l10n.t('overlay.studio.accuracy_threshold_glow'),
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
                    label: l10n.t('overlay.studio.accuracy_liquid_motion'),
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
                    label: l10n.t('overlay.studio.accuracy_border'),
                    subtitle: l10n.t('overlay.studio.accuracy_border_subtitle'),
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
              title: l10n.t('overlay.studio.layout_control'),
              subtitle: l10n.t('overlay.studio.layout_control_subtitle'),
              child: Column(
                children: [
                  _SegmentRow<OverlaySlotPosition>(
                    label: l10n.t('overlay.studio.counter_cluster'),
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
                    label: l10n.t('overlay.studio.stats_card_slot'),
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
                    label: l10n.t('overlay.studio.global_scale'),
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
                    label: l10n.t('overlay.studio.overlay_opacity'),
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
              title: l10n.t('overlay.studio.luxe_finish'),
              subtitle: l10n.t('overlay.studio.luxe_finish_subtitle'),
              child: Column(
                children: [
                  _SliderTile(
                    label: l10n.t('overlay.studio.vignette_focus'),
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
                    label: l10n.t('overlay.studio.bloom_glow'),
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
                    label: l10n.t('overlay.studio.sparkle_field'),
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
                    label: l10n.t('overlay.studio.sheen_sweep'),
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
  final String subtitle;
  final OverlayGradientBorderConfiguration config;
  final ValueChanged<OverlayGradientBorderConfiguration> onChanged;

  const _GradientBorderEditor({
    required this.label,
    required this.subtitle,
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
          subtitle: Text(subtitle),
          value: config.enabled,
          onChanged: (value) => onChanged(config.copyWith(enabled: value)),
        ),
        if (config.enabled) ...[
          _SliderTile(
            label: context.l10n.t('overlay.studio.border_width'),
            value: config.width,
            min: 1,
            max: 8,
            divisions: 14,
            suffix: config.width.toStringAsFixed(1),
            onChanged: (value) => onChanged(config.copyWith(width: value)),
          ),
          _SliderTile(
            label: context.l10n.t('overlay.studio.rotation'),
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
            context.l10n.t(
              'overlay.studio.colors',
              params: {'count': '${config.colors.length}'},
            ),
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
          Text(
            context.l10n.t('overlay.studio.presets'),
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
    final l10n = context.l10n;
    // Reuse the existing _SectionCard or dialog logic if available
    // But since _ColorTile has a private _showHexDialog, I'll need to replicate or make it accessible.
    // For now, I'll just use the logic from _ColorTile._showHexDialog
    showDialog<void>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(
            text: '#${current.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}');
        return AlertDialog(
          title: Text(l10n.t('overlay.studio.select_color')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '#RRGGBB',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.t('common.cancel')),
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
              child: Text(l10n.t('overlay.studio.apply')),
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
    final l10n = context.l10n;
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
                    decoration: InputDecoration(
                      labelText: l10n.t('overlay.studio.rep_no'),
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
                labelText: l10n.t(
                  'overlay.studio.cue_text_label',
                  params: {'label': label},
                ),
                border: const OutlineInputBorder(),
                helperText: l10n.t('overlay.studio.cue_helper'),
              ),
            ),
            const SizedBox(height: 10),
            _ColorTile(
              label: l10n.t(
                'overlay.studio.cue_gradient_start',
                params: {'label': label},
              ),
              color: initialTextColor,
              presets: colorPresets,
              onColorChanged: onTextColorChanged,
            ),
            _ColorTile(
              label: l10n.t(
                'overlay.studio.cue_gradient_end',
                params: {'label': label},
              ),
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
        SnackBar(
          content: Text(
            context.l10n.t(
              'overlay.studio.svg_import_failed',
              params: {'error': '$error'},
            ),
          ),
        ),
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
    final l10n = context.l10n;
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
                            hasSvg
                                ? svgName
                                : l10n.t('overlay.studio.no_svg_selected'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasSvg
                                ? l10n.t('overlay.studio.svg_description_selected')
                                : l10n.t('overlay.studio.svg_description_empty'),
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: Colors.white.withOpacity(0.68),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.t(
                              'overlay.studio.fallback_badge',
                              params: {'glyph': widget.slot.glyph},
                            ),
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
                            ? l10n.t('overlay.studio.importing')
                            : hasSvg
                                ? l10n.t('overlay.studio.replace_svg')
                                : l10n.t('overlay.studio.choose_svg'),
                      ),
                    ),
                    if (hasSvg)
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _removeSvg,
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: Text(l10n.t('common.remove')),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('overlay.studio.supported_input'),
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
    final l10n = context.l10n;
    final controller = TextEditingController(text: _hexLabel(current));
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.t('overlay.studio.custom_color')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '#F3D28A',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.t('common.cancel')),
            ),
            FilledButton(
              onPressed: () {
                final parsed = _parseHexColor(controller.text);
                if (parsed != null) {
                  onColorChanged(parsed);
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.t('overlay.studio.apply')),
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
