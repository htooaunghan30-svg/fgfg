import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import '../iconic/world_festival.dart';
import '../iconic/world_festival_overlay_theme.dart';
import '../../data/services/video_recording_storage.dart';
import '../iconic/iconic_program.dart';
import 'workout_overlay_customization.dart';
import 'workout_video_overlay_timeline.dart';

class WorkoutVideoExportResult {
  final String videoPath;
  final String? timelinePath;
  final bool usedRawFallback;
  final String? exportError;

  const WorkoutVideoExportResult({
    required this.videoPath,
    required this.timelinePath,
    required this.usedRawFallback,
    this.exportError,
  });
}

class WorkoutVideoExportService {
  static const MethodChannel _channel = MethodChannel('hf.video.export');

  Future<WorkoutVideoExportResult> exportVideoWithOverlay({
    required String rawVideoPath,
    required String exerciseId,
    required WorkoutVideoOverlayTimeline timeline,
    required WorkoutOverlayCustomization customization,
    IconicProgram iconicProgram = IconicProgram.none,
    String? zodiacSignKey,
    WorldFestivalVisualStyle? worldFestivalTheme,
    String? overlayTitle,
  }) async {
    final timelineForExport = timeline.isEmpty
        ? (WorkoutVideoOverlayTimeline.start()
          ..record(
            repCount: 0,
            accuracy: 0.0,
            phase: OverlayMovementPhase.idle,
          ))
        : timeline;

    String? nativeOutputPath;
    String? savedOverlayPath;
    String? timelinePath;
    String? exportError;
    try {
      nativeOutputPath = await _exportVideoNatively(
        rawVideoPath: rawVideoPath,
        timeline: timelineForExport,
        customization: customization,
        iconicProgram: iconicProgram,
        zodiacSignKey: zodiacSignKey,
        worldFestivalTheme: worldFestivalTheme,
        overlayTitle: overlayTitle,
      );

      if (nativeOutputPath != null && nativeOutputPath.isNotEmpty) {
        savedOverlayPath = await VideoRecordingStorage.saveVideoFile(
          XFile(nativeOutputPath),
          exerciseId: exerciseId,
        );
        timelinePath = await _writeTimelineSidecar(
          savedOverlayPath,
          timelineForExport,
        );
        await _safeDeleteFile(rawVideoPath);
        await _safeDeleteFile(nativeOutputPath);
        return WorkoutVideoExportResult(
          videoPath: savedOverlayPath,
          timelinePath: timelinePath,
          usedRawFallback: false,
          exportError: null,
        );
      }
    } catch (error) {
      exportError = '$error';
      if (savedOverlayPath != null && savedOverlayPath.isNotEmpty) {
        await _safeDeleteFile(rawVideoPath);
        if (nativeOutputPath != null &&
            nativeOutputPath.isNotEmpty &&
            nativeOutputPath != rawVideoPath) {
          await _safeDeleteFile(nativeOutputPath);
        }
        return WorkoutVideoExportResult(
          videoPath: savedOverlayPath,
          timelinePath: timelinePath,
          usedRawFallback: false,
          exportError: null,
        );
      }
    }

    final fallbackPath = await VideoRecordingStorage.saveVideoFile(
      XFile(rawVideoPath),
      exerciseId: exerciseId,
    );
    timelinePath = await _writeTimelineSidecar(
      fallbackPath,
      timelineForExport,
    );
    if (nativeOutputPath != null &&
        nativeOutputPath.isNotEmpty &&
        nativeOutputPath != rawVideoPath) {
      await _safeDeleteFile(nativeOutputPath);
    }
    return WorkoutVideoExportResult(
      videoPath: fallbackPath,
      timelinePath: timelinePath,
      usedRawFallback: true,
      exportError: exportError,
    );
  }

  Future<String?> _exportVideoNatively({
    required String rawVideoPath,
    required WorkoutVideoOverlayTimeline timeline,
    required WorkoutOverlayCustomization customization,
    required IconicProgram iconicProgram,
    String? zodiacSignKey,
    WorldFestivalVisualStyle? worldFestivalTheme,
    String? overlayTitle,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return null;
    }

    final response = await _channel.invokeMapMethod<String, dynamic>(
      'exportWorkoutVideo',
      <String, dynamic>{
      'rawVideoPath': rawVideoPath,
      'iconicProgram': iconicProgram.storageValue,
      'zodiacSignKey': zodiacSignKey,
        'worldFestivalTheme': worldFestivalTheme?.toOverlayThemeMap(
          date: DateTime.now(),
        ),
      'overlayTitle': overlayTitle,
      'overlayCustomization': customization.toChannelMap(),
      'samples': timeline.samples
            .map(
              (sample) => <String, dynamic>{
                'offsetMs': sample.offset.inMilliseconds,
                'repCount': sample.repCount,
                'accuracy': sample.accuracy,
                'phase': sample.phase.storageValue,
              },
            )
            .toList(),
      },
    );

    return response?['outputPath'] as String?;
  }

  Future<String> _writeTimelineSidecar(
    String videoPath,
    WorkoutVideoOverlayTimeline timeline,
  ) async {
    final timelinePath = videoPath.replaceFirst(RegExp(r'\.mp4$'), '.json');
    await File(timelinePath)
        .writeAsString(timeline.toJsonString(), flush: true);
    return timelinePath;
  }

  Future<void> _safeDeleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore cleanup failures so a successful export does not fall back
      // and create a duplicate raw recording in the app library.
    }
  }
}
