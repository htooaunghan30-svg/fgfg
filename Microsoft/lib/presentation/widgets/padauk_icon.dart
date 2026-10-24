import 'dart:math' as math;
import 'package:flutter/material.dart';

const String kPadaukBranchIconKey = 'padauk_branch';

bool isPadaukBranchIcon(String icon) => icon == kPadaukBranchIconKey;

class PadaukBranchIcon extends StatelessWidget {
  final double size;
  final double opacity;
  final Color flowerColor;
  final Color branchColor;
  final Color centerColor;

  const PadaukBranchIcon({
    super.key,
    required this.size,
    this.opacity = 1,
    this.flowerColor = const Color(0xFFF4C542),
    this.branchColor = const Color(0xFF6A4A2B),
    this.centerColor = const Color(0xFFFFF1A8),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PadaukBranchPainter(
          flowerColor: flowerColor.withOpacity(opacity),
          branchColor: branchColor.withOpacity(opacity),
          centerColor: centerColor.withOpacity(opacity),
        ),
      ),
    );
  }
}

class _PadaukBranchPainter extends CustomPainter {
  final Color flowerColor;
  final Color branchColor;
  final Color centerColor;

  const _PadaukBranchPainter({
    required this.flowerColor,
    required this.branchColor,
    required this.centerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final branchPaint = Paint()
      ..color = branchColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = shortest * 0.08;

    final branch = Path()
      ..moveTo(size.width * 0.18, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.64,
        size.width * 0.78,
        size.height * 0.24,
      );
    canvas.drawPath(branch, branchPaint);

    void drawLeaf(Offset center, double rotation, double scale) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      final leafPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(
          shortest * 0.10 * scale,
          -shortest * 0.04 * scale,
          shortest * 0.14 * scale,
          0,
        )
        ..quadraticBezierTo(
          shortest * 0.10 * scale,
          shortest * 0.05 * scale,
          0,
          shortest * 0.02 * scale,
        )
        ..quadraticBezierTo(
          -shortest * 0.04 * scale,
          shortest * 0.01 * scale,
          0,
          0,
        );
      canvas.drawPath(
        leafPath,
        Paint()
          ..color = const Color(0xFF6B9256).withOpacity(0.92)
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    }

    void drawFlower(Offset center, double radius) {
      final petalPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            flowerColor.withOpacity(0.98),
            flowerColor.withOpacity(0.88),
            flowerColor.withOpacity(0.74),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      final glowPaint = Paint()
        ..color = flowerColor.withOpacity(0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(center, radius * 1.12, glowPaint);

      for (int i = 0; i < 5; i++) {
        final angle = (-math.pi / 2) + ((math.pi * 2 / 5) * i);
        final petalCenter = Offset(
          center.dx + math.cos(angle) * radius * 0.66,
          center.dy + math.sin(angle) * radius * 0.66,
        );
        canvas.save();
        canvas.translate(petalCenter.dx, petalCenter.dy);
        canvas.rotate(angle);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 0.86,
            height: radius * 1.22,
          ),
          petalPaint,
        );
        canvas.restore();
      }

      canvas.drawCircle(
        center,
        radius * 0.34,
        Paint()..color = centerColor,
      );
      canvas.drawCircle(
        center,
        radius * 0.18,
        Paint()..color = const Color(0xFFB37A12).withOpacity(0.95),
      );
    }

    drawLeaf(Offset(size.width * 0.34, size.height * 0.69), -0.2, 0.9);
    drawLeaf(Offset(size.width * 0.56, size.height * 0.48), 0.55, 0.82);
    drawLeaf(Offset(size.width * 0.66, size.height * 0.38), -0.55, 0.72);

    drawFlower(Offset(size.width * 0.58, size.height * 0.46), shortest * 0.14);
    drawFlower(Offset(size.width * 0.72, size.height * 0.30), shortest * 0.11);
    drawFlower(Offset(size.width * 0.42, size.height * 0.60), shortest * 0.10);
  }

  @override
  bool shouldRepaint(covariant _PadaukBranchPainter oldDelegate) {
    return oldDelegate.flowerColor != flowerColor ||
        oldDelegate.branchColor != branchColor ||
        oldDelegate.centerColor != centerColor;
  }
}
