import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/localization/app_localizations.dart';
import '../../presentation/widgets/pose_painter.dart';
import '../../data/services/video_recording_storage.dart';

class VideoRecorderService {
  final CameraController cameraController;
  bool _isRecording = false;
  String? _currentVideoPath;

  VideoRecorderService({required this.cameraController});

  bool get isRecording => _isRecording;
  String? get currentVideoPath => _currentVideoPath;

  Future<void> startRecording({
    required Function(String) onRecordingStarted,
    required Function(String) onRecordingCompleted,
  }) async {
    if (_isRecording) {
      throw Exception('Already recording');
    }

    try {
      final directory = await VideoRecordingStorage.getRecordingsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // We don't pass the path into camera plugin directly, but we keep
      // a logical path here so the caller knows where the processed file
      // will be stored.
      final videoPath = '${directory.path}/workout_$timestamp.mp4';

      // Start recording using the camera plugin's standard API.
      await cameraController.startVideoRecording();

      _isRecording = true;
      _currentVideoPath = videoPath;

      onRecordingStarted(videoPath);
    } catch (e) {
      _isRecording = false;
      _currentVideoPath = null;
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    try {
      final XFile videoFile = await cameraController.stopVideoRecording();
      _isRecording = false;

      // Save/process the recorded video file
      final savedPath = await _saveVideoFile(videoFile);
      _currentVideoPath = savedPath;

      return savedPath;
    } catch (e) {
      _isRecording = false;
      _currentVideoPath = null;
      rethrow;
    }
  }

  Future<String> _saveVideoFile(XFile videoFile) async {
    final directory = await VideoRecordingStorage.getRecordingsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = '${directory.path}/workout_processed_$timestamp.mp4';

    // Copy file to new location
    await videoFile.saveTo(newPath);

    // Process video to add overlay (this would be done in background)
    await _processVideoWithOverlay(newPath);

    return newPath;
  }

  Future<void> _processVideoWithOverlay(String videoPath) async {
    // This would process the video to add pose landmarks overlay
    // For now, just return the original path
    // Implementation would use FFmpeg or similar library
  }

  Future<void> dispose() async {
    if (_isRecording) {
      await stopRecording();
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final List<Pose>? poseData;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    this.poseData,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        if (_isPlaying) {
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('recordings.player_title')),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showOverlay = !_showOverlay;
              });
            },
            icon: Icon(
              _showOverlay ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Video Player
          Positioned.fill(
            child: _controller.value.isInitialized
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final videoSize = _controller.value.size;
                      if (videoSize.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return FittedBox(
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: videoSize.width,
                          height: videoSize.height,
                          child: VideoPlayer(_controller),
                        ),
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // Controls
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                      if (_isPlaying) {
                        _controller.play();
                      } else {
                        _controller.pause();
                      }
                    });
                  },
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
              ],
            ),
          ),

          // Pose Overlay
          if (_showOverlay && widget.poseData != null)
            Positioned.fill(
              child: _PoseOverlay(
                controller: _controller,
                poseData: widget.poseData!,
              ),
            ),
        ],
      ),
    );
  }
}

class _PoseOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final List<Pose> poseData;

  const _PoseOverlay({
    required this.controller,
    required this.poseData,
  });

  @override
  State<_PoseOverlay> createState() => _PoseOverlayState();
}

class _PoseOverlayState extends State<_PoseOverlay> {
  Pose? _currentPose;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updatePose);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePose);
    super.dispose();
  }

  void _updatePose() {
    final position = widget.controller.value.position;
    final totalDuration = widget.controller.value.duration;

    if (totalDuration.inMilliseconds == 0) return;

    final progress = position.inMilliseconds / totalDuration.inMilliseconds;
    final index = (progress * widget.poseData.length).floor();

    if (index < widget.poseData.length) {
      setState(() {
        _currentPose = widget.poseData[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewSize = MediaQuery.of(context).size;
    final videoSize = widget.controller.value.size; // Add this

    if (_currentPose == null) return const SizedBox();

    return CustomPaint(
      painter: PosePainter(
        pose: _currentPose!,
        accuracy: 0.8,
        showLandmarks: true,
        showConnections: true,
        previewSize: previewSize,
        imageSize: videoSize, // Add this
      ),
    );
  }
}
