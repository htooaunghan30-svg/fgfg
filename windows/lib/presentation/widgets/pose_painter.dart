// lib/presentation/widgets/pose_painter.dart
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../features/iconic/world_festival.dart';

class PosePainter extends CustomPainter {
  static const double _landmarkRenderMinLikelihood = 0.0;

  final Pose pose;
  final double accuracy;
  final Map<PoseLandmarkType, Offset> landmarkOverrides;
  final bool showLandmarks;
  final bool showConnections;
  final bool showAngles;
  final Color angleTextColor;
  final AnalysisPreview? preview;
  final AnalysisImage? analysisImage;
  final Size? previewSize;
  final Size? imageSize;
  final bool isFrontCamera;
  final WorldFestivalVisualStyle? festivalStyle;

  PosePainter({
    required this.pose,
    required this.accuracy,
    this.landmarkOverrides = const {},
    this.preview,
    this.analysisImage,
    this.previewSize,
    this.imageSize,
    this.showLandmarks = true,
    this.showConnections = true,
    this.showAngles = false,
    this.angleTextColor = Colors.white,
    this.isFrontCamera = false,
    this.festivalStyle,
  }) : assert(
          (preview != null && analysisImage != null) ||
              (previewSize != null && imageSize != null),
          'Provide either (preview, analysisImage) or (previewSize, imageSize).',
        );

  Offset _imageOffsetForLandmark(PoseLandmarkType type) {
    final override = landmarkOverrides[type];
    if (override != null) {
      return override;
    }

    final landmark = pose.landmarks[type];
    if (landmark == null) {
      return Offset.zero;
    }

    return Offset(landmark.x, landmark.y);
  }

  bool _poseHasExplicitLikelihoods() {
    return pose.landmarks.values.any((landmark) => landmark.likelihood > 0.0);
  }

  bool _shouldRenderLandmark(
    PoseLandmark? landmark,
    bool hasExplicitLikelihoods,
  ) {
    if (landmark == null) {
      return false;
    }

    if (!hasExplicitLikelihoods) {
      return true;
    }

    return landmark.likelihood >= _landmarkRenderMinLikelihood;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final hasAnalysisMapping = preview != null && analysisImage != null;
    final hasExplicitLikelihoods = _poseHasExplicitLikelihoods();
    final Size effectivePreviewSize =
        hasAnalysisMapping ? preview!.previewSize : previewSize!;
    final Size effectiveImageSize =
        hasAnalysisMapping ? analysisImage!.size : imageSize!;

    if (effectiveImageSize.width == 0 || effectiveImageSize.height == 0) {
      return;
    }
    if (effectivePreviewSize.width == 0 || effectivePreviewSize.height == 0) {
      return;
    }

    CanvasTransformation? canvasTransformation;
    if (hasAnalysisMapping) {
      canvasTransformation = analysisImage!.getCanvasTransformation(preview!);
      if (canvasTransformation != null) {
        canvas.save();
        canvas.applyTransformation(canvasTransformation, size);
      }
    } else if (isFrontCamera) {
      canvas.save();
      canvas.scale(-1.0, 1.0);
      canvas.translate(-effectivePreviewSize.width, 0);
    }

    final paint = Paint()
      ..color = festivalStyle?.accent1 ?? Colors.green
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = festivalStyle?.accent2 ?? Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0
      ..style = PaintingStyle.fill;

    // Draw connections
    if (hasAnalysisMapping) {
      if (showConnections) {
        _drawConnectionsWithPreview(canvas, paint, hasExplicitLikelihoods);
      }
      if (showLandmarks) {
        _drawLandmarksWithPreview(
          canvas,
          jointPaint,
          effectivePreviewSize,
          hasExplicitLikelihoods,
        );
      }
      if (showAngles) {
        _drawAnglesWithPreview(
          canvas,
          effectivePreviewSize,
          hasExplicitLikelihoods,
        );
      }
    } else {
      final scaleX = effectivePreviewSize.width / effectiveImageSize.width;
      final scaleY = effectivePreviewSize.height / effectiveImageSize.height;
      final scale = scaleX < scaleY ? scaleX : scaleY;
      final offsetX =
          (effectivePreviewSize.width - (effectiveImageSize.width * scale)) / 2;
      final offsetY =
          (effectivePreviewSize.height - (effectiveImageSize.height * scale)) /
              2;

      if (showConnections) {
        _drawConnectionsWithScale(
          canvas,
          paint,
          scale,
          offsetX,
          offsetY,
          hasExplicitLikelihoods,
        );
      }
      if (showLandmarks) {
        _drawLandmarksWithScale(
          canvas,
          jointPaint,
          scale,
          offsetX,
          offsetY,
          effectivePreviewSize,
          hasExplicitLikelihoods,
        );
      }
      if (showAngles) {
        _drawAnglesWithScale(
          canvas,
          scale,
          offsetX,
          offsetY,
          effectivePreviewSize,
          hasExplicitLikelihoods,
        );
      }
    }

    if (canvasTransformation != null ||
        (!hasAnalysisMapping && isFrontCamera)) {
      canvas.restore();
    }
  }

  void _drawConnectionsWithPreview(
    Canvas canvas,
    Paint paint,
    bool hasExplicitLikelihoods,
  ) {
    final connections = [
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    ];

    for (final connection in connections) {
      final startLandmark = pose.landmarks[connection[0]];
      final endLandmark = pose.landmarks[connection[1]];

      if (startLandmark == null ||
          endLandmark == null ||
          !_shouldRenderLandmark(startLandmark, hasExplicitLikelihoods) ||
          !_shouldRenderLandmark(endLandmark, hasExplicitLikelihoods)) {
        continue;
      }

      final startOffset = preview!.convertFromImage(
        _imageOffsetForLandmark(connection[0]),
        analysisImage!,
      );
      final endOffset = preview!.convertFromImage(
        _imageOffsetForLandmark(connection[1]),
        analysisImage!,
      );

      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  void _drawLandmarksWithPreview(
    Canvas canvas,
    Paint jointPaint,
    Size previewSize,
    bool hasExplicitLikelihoods,
  ) {
    for (final entry in pose.landmarks.entries) {
      final landmark = entry.value;
      if (_shouldRenderLandmark(landmark, hasExplicitLikelihoods)) {
        final offset = preview!.convertFromImage(
          _imageOffsetForLandmark(entry.key),
          analysisImage!,
        );

        // Draw joint circle
        canvas.drawCircle(offset, 6.0, jointPaint);

        // Draw joint name (for major joints only)
        if (_isMajorJoint(entry.key)) {
          _drawJointLabel(canvas, offset, entry.key, previewSize);
        }
      }
    }
  }

  void _drawConnectionsWithScale(
    Canvas canvas,
    Paint paint,
    double scale,
    double offsetX,
    double offsetY,
    bool hasExplicitLikelihoods,
  ) {
    final connections = [
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    ];

    for (final connection in connections) {
      final startLandmark = pose.landmarks[connection[0]];
      final endLandmark = pose.landmarks[connection[1]];
      if (startLandmark == null ||
          endLandmark == null ||
          !_shouldRenderLandmark(startLandmark, hasExplicitLikelihoods) ||
          !_shouldRenderLandmark(endLandmark, hasExplicitLikelihoods)) {
        continue;
      }

      final startOffset = Offset(
        (_imageOffsetForLandmark(connection[0]).dx * scale) + offsetX,
        (_imageOffsetForLandmark(connection[0]).dy * scale) + offsetY,
      );
      final endOffset = Offset(
        (_imageOffsetForLandmark(connection[1]).dx * scale) + offsetX,
        (_imageOffsetForLandmark(connection[1]).dy * scale) + offsetY,
      );
      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  void _drawLandmarksWithScale(
    Canvas canvas,
    Paint jointPaint,
    double scale,
    double offsetX,
    double offsetY,
    Size previewSize,
    bool hasExplicitLikelihoods,
  ) {
    for (final entry in pose.landmarks.entries) {
      final landmark = entry.value;
      if (_shouldRenderLandmark(landmark, hasExplicitLikelihoods)) {
        final offset = Offset(
          (_imageOffsetForLandmark(entry.key).dx * scale) + offsetX,
          (_imageOffsetForLandmark(entry.key).dy * scale) + offsetY,
        );
        canvas.drawCircle(offset, 6.0, jointPaint);
        if (_isMajorJoint(entry.key)) {
          _drawJointLabel(canvas, offset, entry.key, previewSize);
        }
      }
    }
  }

  bool _isMajorJoint(PoseLandmarkType type) {
    return [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ].contains(type);
  }

  void _drawJointLabel(
    Canvas canvas,
    Offset position,
    PoseLandmarkType type,
    Size previewSize,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getJointLabel(type),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final labelOffset = Offset(position.dx + 8, position.dy - 15);
    if (isFrontCamera) {
      canvas.save();
      canvas.scale(-1.0, 1.0);
      canvas.translate(-previewSize.width, 0);
      final unmirroredOffset = Offset(
        previewSize.width - labelOffset.dx,
        labelOffset.dy,
      );
      textPainter.paint(canvas, unmirroredOffset);
      canvas.restore();
    } else {
      textPainter.paint(canvas, labelOffset);
    }
  }

  void _drawAnglesWithPreview(
    Canvas canvas,
    Size previewSize,
    bool hasExplicitLikelihoods,
  ) {
    _drawAngleForJoint(
      canvas,
      previewSize,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
      hasExplicitLikelihoods: hasExplicitLikelihoods,
    );
    _drawAngleForJoint(
      canvas,
      previewSize,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
      hasExplicitLikelihoods: hasExplicitLikelihoods,
    );
    _drawAngleForJoint(
      canvas,
      previewSize,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
      hasExplicitLikelihoods: hasExplicitLikelihoods,
    );
    _drawAngleForJoint(
      canvas,
      previewSize,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
      hasExplicitLikelihoods: hasExplicitLikelihoods,
    );
  }

  void _drawAnglesWithScale(
    Canvas canvas,
    double scale,
    double offsetX,
    double offsetY,
    Size previewSize,
    bool hasExplicitLikelihoods,
  ) {
    _drawAngleForJoint(
      canvas,
      previewSize,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
      hasExplicitLikelihoods: hasExplicitLikelihoods,
    );
    _drawAngleForJoint(
      canvas,
      previewSize,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
      hasExplicitLikelihoods: hasExplicitLikelihoods,
    );
    _drawAngleForJoint(
      canvas,
      previewSize,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
      hasExplicitLikelihoods: hasExplicitLikelihoods,
    );
    _drawAngleForJoint(
      canvas,
      previewSize,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
      hasExplicitLikelihoods: hasExplicitLikelihoods,
    );
  }

  void _drawAngleForJoint(
    Canvas canvas,
    Size previewSize,
    PoseLandmarkType parent,
    PoseLandmarkType joint,
    PoseLandmarkType child, {
    double? scale,
    double? offsetX,
    double? offsetY,
    required bool hasExplicitLikelihoods,
  }) {
    final parentLandmark = pose.landmarks[parent];
    final jointLandmark = pose.landmarks[joint];
    final childLandmark = pose.landmarks[child];
    if (parentLandmark == null ||
        jointLandmark == null ||
        childLandmark == null) {
      return;
    }
    if (!_shouldRenderLandmark(parentLandmark, hasExplicitLikelihoods) ||
        !_shouldRenderLandmark(jointLandmark, hasExplicitLikelihoods) ||
        !_shouldRenderLandmark(childLandmark, hasExplicitLikelihoods)) {
      return;
    }

    final angle = _calculateAngle(
      _imageOffsetForLandmark(parent),
      _imageOffsetForLandmark(joint),
      _imageOffsetForLandmark(child),
    );

    Offset jointOffset;
    if (preview != null && analysisImage != null) {
      jointOffset = preview!.convertFromImage(
        _imageOffsetForLandmark(joint),
        analysisImage!,
      );
    } else if (scale != null && offsetX != null && offsetY != null) {
      jointOffset = Offset(
        (_imageOffsetForLandmark(joint).dx * scale) + offsetX,
        (_imageOffsetForLandmark(joint).dy * scale) + offsetY,
      );
    } else {
      return;
    }

    _drawAngleLabel(canvas, jointOffset, angle, previewSize);
  }

  double _calculateAngle(Offset a, Offset b, Offset c) {
    final ab = Offset(a.dx - b.dx, a.dy - b.dy);
    final cb = Offset(c.dx - b.dx, c.dy - b.dy);
    final dot = (ab.dx * cb.dx) + (ab.dy * cb.dy);
    final abMag = sqrt((ab.dx * ab.dx) + (ab.dy * ab.dy));
    final cbMag = sqrt((cb.dx * cb.dx) + (cb.dy * cb.dy));
    if (abMag == 0 || cbMag == 0) {
      return 0.0;
    }
    final cosTheta = (dot / (abMag * cbMag)).clamp(-1.0, 1.0);
    return (acos(cosTheta) * 180.0) / pi;
  }

  void _drawAngleLabel(
    Canvas canvas,
    Offset position,
    double angle,
    Size previewSize,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${angle.toStringAsFixed(0)}Â°',
        style: TextStyle(
          color: angleTextColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Colors.black,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final labelOffset = Offset(position.dx + 6, position.dy - 12);
    if (isFrontCamera) {
      canvas.save();
      canvas.scale(-1.0, 1.0);
      canvas.translate(-previewSize.width, 0);
      final unmirroredOffset = Offset(
        previewSize.width - labelOffset.dx,
        labelOffset.dy,
      );
      textPainter.paint(canvas, unmirroredOffset);
      canvas.restore();
    } else {
      textPainter.paint(canvas, labelOffset);
    }
  }

  String _getJointLabel(PoseLandmarkType type) {
    switch (type) {
      case PoseLandmarkType.leftShoulder:
        return isFrontCamera ? 'R Shoulder' : 'L Shoulder';
      case PoseLandmarkType.rightShoulder:
        return isFrontCamera ? 'L Shoulder' : 'R Shoulder';
      case PoseLandmarkType.leftElbow:
        return isFrontCamera ? 'R Elbow' : 'L Elbow';
      case PoseLandmarkType.rightElbow:
        return isFrontCamera ? 'L Elbow' : 'R Elbow';
      case PoseLandmarkType.leftHip:
        return isFrontCamera ? 'R Hip' : 'L Hip';
      case PoseLandmarkType.rightHip:
        return isFrontCamera ? 'L Hip' : 'R Hip';
      case PoseLandmarkType.leftKnee:
        return isFrontCamera ? 'R Knee' : 'L Knee';
      case PoseLandmarkType.rightKnee:
        return isFrontCamera ? 'L Knee' : 'R Knee';
      default:
        return '';
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return pose != oldDelegate.pose ||
        accuracy != oldDelegate.accuracy ||
        landmarkOverrides != oldDelegate.landmarkOverrides ||
        showLandmarks != oldDelegate.showLandmarks ||
        showConnections != oldDelegate.showConnections ||
        showAngles != oldDelegate.showAngles ||
        isFrontCamera != oldDelegate.isFrontCamera ||
        festivalStyle != oldDelegate.festivalStyle ||
        (preview?.previewSize != oldDelegate.preview?.previewSize) ||
        (analysisImage?.size != oldDelegate.analysisImage?.size) ||
        previewSize != oldDelegate.previewSize ||
        imageSize != oldDelegate.imageSize;
  }
}
