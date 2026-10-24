import 'dart:convert';

import 'workout_overlay_customization.dart';

class WorkoutVideoOverlaySample {
  final Duration offset;
  final int repCount;
  final double accuracy;
  final OverlayMovementPhase phase;

  const WorkoutVideoOverlaySample({
    required this.offset,
    required this.repCount,
    required this.accuracy,
    required this.phase,
  });

  Map<String, dynamic> toJson() => {
        'offsetMs': offset.inMilliseconds,
        'repCount': repCount,
        'accuracy': accuracy,
        'phase': phase.storageValue,
      };
}

class WorkoutVideoOverlayTimeline {
  WorkoutVideoOverlayTimeline._(this.startedAt);

  factory WorkoutVideoOverlayTimeline.start() =>
      WorkoutVideoOverlayTimeline._(DateTime.now());

  final DateTime startedAt;
  final List<WorkoutVideoOverlaySample> _samples = <WorkoutVideoOverlaySample>[];

  bool get isEmpty => _samples.isEmpty;

  List<WorkoutVideoOverlaySample> get samples =>
      List<WorkoutVideoOverlaySample>.unmodifiable(_samples);

  void record({
    required int repCount,
    required double accuracy,
    required OverlayMovementPhase phase,
    Duration? offsetOverride,
  }) {
    final offset = offsetOverride ?? DateTime.now().difference(startedAt);
    final normalizedAccuracy = accuracy.clamp(0.0, 1.0).toDouble();

    if (_samples.isNotEmpty) {
      final last = _samples.last;
      final sameState = last.repCount == repCount &&
          (last.accuracy - normalizedAccuracy).abs() < 0.005 &&
          last.phase == phase;
      final tooSoon = offset.inMilliseconds - last.offset.inMilliseconds < 180;
      if (sameState && tooSoon) {
        return;
      }
    }

    _samples.add(
      WorkoutVideoOverlaySample(
        offset: offset,
        repCount: repCount,
        accuracy: normalizedAccuracy,
        phase: phase,
      ),
    );
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(
      <String, dynamic>{
        'startedAt': startedAt.toIso8601String(),
        'samples': _samples.map((sample) => sample.toJson()).toList(),
      },
    );
  }
}
