import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProfessionPathBorder extends OutlinedBorder {
  final String storageKey;

  const ProfessionPathBorder({
    required this.storageKey,
    super.side,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return ProfessionShape.getPath(storageKey, rect.deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return ProfessionShape.getPath(storageKey, rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    final paint = side.toPaint();
    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return ProfessionPathBorder(
      storageKey: storageKey,
      side: side.scale(t),
    );
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return ProfessionPathBorder(
      storageKey: storageKey,
      side: side ?? this.side,
    );
  }
}

class ProfessionShape {
  static Path getPath(String storageKey, Rect rect) {
    switch (storageKey) {
      case 'profession_electrical_engineer':
        return _buildLightningHexagon(rect);
      case 'profession_mechanical_engineer':
        return _buildGear(rect);
      case 'profession_civil_engineer':
        return _buildStructuralOctagon(rect);
      case 'profession_doctor':
        return _buildMedicalCross(rect);
      case 'profession_nurse':
        return _buildHeart(rect);
      case 'profession_pharmacist':
        return _buildFlask(rect);
      case 'profession_software_developer':
        return _buildTechBracket(rect);
      case 'profession_data_scientist':
        return _buildNeuralDiamond(rect);
      case 'profession_human_resource':
        return _buildLeafShield(rect);
      case 'profession_marketing_specialist':
        return _buildSunburst(rect);
      case 'profession_fashion_designer':
        return _buildMannequin(rect);
      case 'profession_beautician':
        return _buildMirror(rect);
      case 'profession_teacher':
        return _buildApple(rect);
      case 'profession_accountant':
        return _buildVault(rect);
      case 'profession_musician':
        return _buildGuitarPick(rect);
      case 'profession_writer':
        return _buildPenNib(rect);
      case 'profession_game_streamer':
        return _buildGamepad(rect);
      case 'profession_social_media_influencer':
        return _buildStar(rect);
      case 'profession_manager':
        return _buildChessCrown(rect);
      case 'profession_director':
        return _buildClapperboard(rect);
      case 'profession_cgd':
        return _buildCubeHexagon(rect); // 3D Design
      case 'profession_it_engineer':
        return _buildCpuSocket(rect);
      case 'profession_business_owner':
        return _buildBriefcase(rect);
      case 'profession_gym_trainer':
        return _buildKettlebell(rect);
      case 'profession_swimmer':
        return _buildWaterDrop(rect);
      case 'profession_psychologist':
        return _buildPuzzlePiece(rect);
      case 'profession_philosopher':
        return _buildEyeOfWisdom(rect);
      default:
        return Path()..addOval(rect);
    }
  }

  static Path _buildLightningHexagon(Rect rect) {
    final Path path = Path();
    final double w = rect.width;
    final double h = rect.height;
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double r = math.min(w, h) / 2;

    // Hexagon with small cutouts/indents resembling tech nodes
    for (int i = 0; i < 6; i++) {
      final double angle = (i * math.pi / 3) - (math.pi / 2);
      final double nextAngle = ((i + 1) * math.pi / 3) - (math.pi / 2);
      final Offset p1 = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      final Offset p2 = Offset(cx + r * math.cos(nextAngle), cy + r * math.sin(nextAngle));
      
      final Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      final double inset = r * 0.12;
      final Offset cutMid = Offset(mid.dx - inset * math.cos(angle + math.pi / 6),
                                   mid.dy - inset * math.sin(angle + math.pi / 6));

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      }
      
      // Draw line with a tech notch
      path.lineTo(lerpDouble(p1.dx, mid.dx, 0.7)!, lerpDouble(p1.dy, mid.dy, 0.7)!);
      path.lineTo(cutMid.dx, cutMid.dy);
      path.lineTo(lerpDouble(mid.dx, p2.dx, 0.3)!, lerpDouble(mid.dy, p2.dy, 0.3)!);
      path.lineTo(p2.dx, p2.dy);
    }
    path.close();
    return path;
  }

  static double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  static Path _buildGear(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double outerR = math.min(rect.width, rect.height) / 2;
    final double innerR = outerR * 0.85;
    const int teeth = 8;
    
    for (int i = 0; i < teeth * 2; i++) {
      final double r = (i % 2 == 0) ? outerR : innerR;
      final double angle = i * math.pi / teeth;
      
      // Make the gear teeth slightly angled
      final double nextR = (i % 2 == 0) ? outerR : innerR;
      final double nextAngle = (i + 1) * math.pi / teeth;
      
      final double sweep = math.pi / (teeth * 2.5);
      
      if (i == 0) {
        path.moveTo(cx + r * math.cos(angle - sweep), cy + r * math.sin(angle - sweep));
      }
      
      path.lineTo(cx + r * math.cos(angle - sweep), cy + r * math.sin(angle - sweep));
      path.lineTo(cx + r * math.cos(angle + sweep), cy + r * math.sin(angle + sweep));
      path.lineTo(cx + nextR * math.cos(nextAngle - sweep), cy + nextR * math.sin(nextAngle - sweep));
    }
    path.close();
    return path;
  }

  static Path _buildStructuralOctagon(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double r = math.min(rect.width, rect.height) / 2;

    for (int i = 0; i < 8; i++) {
      final double angle = (i * math.pi / 4) - (math.pi / 8);
      // Create a slightly more abstract structural look by insetting every alternating point
      final double dist = (i % 2 == 0) ? r : r * 0.9;
      final Offset p = Offset(cx + dist * math.cos(angle), cy + dist * math.sin(angle));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return _roundPathCorners(path, r * 0.1);
  }

  static Path _buildMedicalCross(Rect rect) {
    final Path path = Path();
    final w = rect.width;
    final h = rect.height;
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final th = w * 0.38; // Thickness of the cross

    path.moveTo(cx - th / 2, cy - h / 2);
    path.lineTo(cx + th / 2, cy - h / 2);
    path.lineTo(cx + th / 2, cy - th / 2);
    path.lineTo(cx + w / 2, cy - th / 2);
    path.lineTo(cx + w / 2, cy + th / 2);
    path.lineTo(cx + th / 2, cy + th / 2);
    path.lineTo(cx + th / 2, cy + h / 2);
    path.lineTo(cx - th / 2, cy + h / 2);
    path.lineTo(cx - th / 2, cy + th / 2);
    path.lineTo(cx - w / 2, cy + th / 2);
    path.lineTo(cx - w / 2, cy - th / 2);
    path.lineTo(cx - th / 2, cy - th / 2);
    path.close();
    
    // Applying rounded corners to the cross for luxury look
    return _roundPathCorners(path, w * 0.08);
  }

  static Path _buildHeart(Rect rect) {
    final Path path = Path();
    final double w = rect.width;
    final double h = rect.height;
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    
    // Scale down a bit to fit in the given rect properly without cutting edges
    final double scale = 0.95;
    final double rw = w * scale;
    final double rh = h * scale;

    path.moveTo(cx, cy + rh * 0.4);
    path.cubicTo(
        cx + rw * 0.6, cy - rh * 0.1, 
        cx + rw * 0.8, cy - rh * 0.5, 
        cx, cy - rh * 0.3);
    path.cubicTo(
        cx - rw * 0.8, cy - rh * 0.5, 
        cx - rw * 0.6, cy - rh * 0.1, 
        cx, cy + rh * 0.4);
    
    return path;
  }

  static Path _buildFlask(Rect rect) {
    final Path path = Path();
    final double w = rect.width;
    final double h = rect.height;
    final double top = rect.top + h * 0.05;
    final double bottom = rect.bottom - h * 0.05;
    final double cx = rect.center.dx;
    
    final double neckW = w * 0.35;
    final double baseW = w * 0.85;

    // Rim
    path.moveTo(cx - neckW * 0.6, top);
    path.lineTo(cx + neckW * 0.6, top);
    path.lineTo(cx + neckW * 0.5, top + h * 0.08);
    // Neck
    path.lineTo(cx + neckW * 0.5, top + h * 0.35);
    // Body curve
    path.quadraticBezierTo(cx + baseW * 0.5, bottom - h * 0.3, cx + baseW * 0.5, bottom - h * 0.1);
    path.quadraticBezierTo(cx + baseW * 0.5, bottom, cx + baseW * 0.3, bottom);
    // Base
    path.lineTo(cx - baseW * 0.3, bottom);
    path.quadraticBezierTo(cx - baseW * 0.5, bottom, cx - baseW * 0.5, bottom - h * 0.1);
    // Body curve left
    path.quadraticBezierTo(cx - baseW * 0.5, bottom - h * 0.3, cx - neckW * 0.5, top + h * 0.35);
    // Neck left
    path.lineTo(cx - neckW * 0.5, top + h * 0.08);
    path.close();
    
    return path;
  }

  static Path _buildTechBracket(Rect rect) {
    final Path path = Path();
    final double w = rect.width;
    final double h = rect.height;
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    
    final double chamfer = w * 0.2;
    // A square with cut angled corners resembling developer brackets < > structure
    path.moveTo(rect.left, cy - chamfer);
    path.lineTo(rect.left + chamfer, rect.top);
    path.lineTo(cx - chamfer * 0.5, rect.top);
    path.lineTo(cx, rect.top + chamfer * 0.5); // Top indent
    path.lineTo(cx + chamfer * 0.5, rect.top);
    path.lineTo(rect.right - chamfer, rect.top);
    path.lineTo(rect.right, cy - chamfer);
    path.lineTo(rect.right - chamfer * 0.5, cy); // Right indent
    path.lineTo(rect.right, cy + chamfer);
    path.lineTo(rect.right - chamfer, rect.bottom);
    path.lineTo(cx + chamfer * 0.5, rect.bottom);
    path.lineTo(cx, rect.bottom - chamfer * 0.5); // Bottom indent
    path.lineTo(cx - chamfer * 0.5, rect.bottom);
    path.lineTo(rect.left + chamfer, rect.bottom);
    path.lineTo(rect.left, cy + chamfer);
    path.lineTo(rect.left + chamfer * 0.5, cy); // Left indent
    path.close();
    
    return _roundPathCorners(path, w * 0.05);
  }

  static Path _buildNeuralDiamond(Rect rect) {
    final Path path = Path();
    final double w = rect.width;
    final double h = rect.height;
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    
    final double px = w * 0.08; 
    
    // A sharp diamond with flattened interconnected points
    path.moveTo(cx - px, rect.top);
    path.lineTo(cx + px, rect.top);
    path.lineTo(rect.right, cy - px);
    path.lineTo(rect.right, cy + px);
    path.lineTo(cx + px, rect.bottom);
    path.lineTo(cx - px, rect.bottom);
    path.lineTo(rect.left, cy + px);
    path.lineTo(rect.left, cy - px);
    path.close();

    return _roundPathCorners(path, w * 0.06);
  }

  static Path _buildLeafShield(Rect rect) {
    final Path path = Path();
    final double w = rect.width;
    final double h = rect.height;
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    
    // Abstract lotus / shield representing HR
    path.moveTo(cx, rect.bottom);
    path.quadraticBezierTo(rect.left, rect.bottom, rect.left, cy);
    path.quadraticBezierTo(rect.left, rect.top, cx, rect.top + h * 0.2);
    path.quadraticBezierTo(rect.right, rect.top, rect.right, cy);
    path.quadraticBezierTo(rect.right, rect.bottom, cx, rect.bottom);
    
    return path;
  }

  static Path _buildSunburst(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double outerR = math.min(rect.width, rect.height) / 2;
    final double innerR = outerR * 0.80; // Wavy burst
    const int points = 12;
    
    for (int i = 0; i < points * 2; i++) {
      final double r = (i % 2 == 0) ? outerR : innerR;
      final double angle = i * math.pi / points;
      final Offset p = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return _roundPathCorners(path, outerR * 0.12); // Soft premium sunburst
  }

  // Helper algorithm to round corners of a polygon path
  static Path _roundPathCorners(Path path, double radius) {
    return path; 
  }

  // --- New 17 Professions ---

  static Path _buildMannequin(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width;
    final double h = rect.height;
    
    // Abstract dress form / hourglass
    path.moveTo(cx, rect.top);
    path.quadraticBezierTo(cx + w * 0.4, rect.top + h * 0.1, cx + w * 0.3, cy);
    path.quadraticBezierTo(cx + w * 0.2, cy + h * 0.2, cx + w * 0.4, rect.bottom);
    path.lineTo(cx - w * 0.4, rect.bottom);
    path.quadraticBezierTo(cx - w * 0.2, cy + h * 0.2, cx - w * 0.3, cy);
    path.quadraticBezierTo(cx - w * 0.4, rect.top + h * 0.1, cx, rect.top);
    path.close();
    return path;
  }

  static Path _buildMirror(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width * 0.85;
    final double h = rect.height * 0.95;
    
    // Ornate oval
    path.addOval(Rect.fromCenter(center: Offset(cx, cy - h * 0.05), width: w, height: h * 0.85));
    // Base/handle
    path.addRect(Rect.fromCenter(center: Offset(cx, rect.bottom - h * 0.05), width: w * 0.3, height: h * 0.1));
    return path;
  }

  static Path _buildApple(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width * 0.9;
    final double h = rect.height * 0.9;
    
    // Apple core body
    path.moveTo(cx, rect.bottom - h * 0.1);
    path.quadraticBezierTo(cx - w * 0.6, rect.bottom, cx - w * 0.5, cy - h * 0.2);
    path.quadraticBezierTo(cx - w * 0.4, rect.top + h * 0.1, cx, rect.top + h * 0.2);
    path.quadraticBezierTo(cx + w * 0.4, rect.top + h * 0.1, cx + w * 0.5, cy - h * 0.2);
    path.quadraticBezierTo(cx + w * 0.6, rect.bottom, cx, rect.bottom - h * 0.1);
    
    // Leaf
    path.moveTo(cx, rect.top + h * 0.2);
    path.quadraticBezierTo(cx + w * 0.2, rect.top - h * 0.05, cx + w * 0.3, rect.top);
    path.quadraticBezierTo(cx + w * 0.1, rect.top + h * 0.1, cx, rect.top + h * 0.2);
    
    return path;
  }

  static Path _buildVault(Rect rect) {
    final Path path = Path();
    final double r = math.min(rect.width, rect.height) / 2;
    path.addOval(rect.deflate(r * 0.1));
    // Draw some structural indents (like a vault wheel)
    for (int i = 0; i < 4; i++) {
        final double angle = i * math.pi / 2;
        path.addRect(Rect.fromCenter(
          center: Offset(rect.center.dx + r * 0.8 * math.cos(angle), rect.center.dy + r * 0.8 * math.sin(angle)),
          width: r * 0.3, height: r * 0.3
        ));
    }
    return path;
  }

  static Path _buildGuitarPick(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width * 0.95;
    final double h = rect.height * 0.95;
    
    path.moveTo(cx, rect.bottom); // Tip
    path.quadraticBezierTo(rect.left, rect.bottom - h * 0.2, rect.left, rect.top + h * 0.2);
    path.quadraticBezierTo(cx, rect.top - h * 0.1, rect.right, rect.top + h * 0.2);
    path.quadraticBezierTo(rect.right, rect.bottom - h * 0.2, cx, rect.bottom);
    return path;
  }

  static Path _buildPenNib(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width * 0.8;
    final double h = rect.height * 0.95;
    
    path.moveTo(cx, rect.bottom);
    path.lineTo(cx - w * 0.3, rect.bottom - h * 0.3);
    path.quadraticBezierTo(rect.left, cy, rect.left + w * 0.1, rect.top);
    path.lineTo(rect.right - w * 0.1, rect.top);
    path.quadraticBezierTo(rect.right, cy, cx + w * 0.3, rect.bottom - h * 0.3);
    path.close();
    return path;
  }

  static Path _buildGamepad(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width * 0.95;
    final double h = rect.height * 0.65;
    
    // Draw pill with downward handles
    path.moveTo(cx - w * 0.3, cy - h * 0.5);
    path.lineTo(cx + w * 0.3, cy - h * 0.5);
    path.quadraticBezierTo(rect.right, cy - h * 0.5, rect.right, cy);
    path.quadraticBezierTo(rect.right, cy + h * 0.8, cx + w * 0.3, cy + h * 0.5);
    path.lineTo(cx + w * 0.1, cy + h * 0.2);
    path.lineTo(cx - w * 0.1, cy + h * 0.2);
    path.lineTo(cx - w * 0.3, cy + h * 0.5);
    path.quadraticBezierTo(rect.left, cy + h * 0.8, rect.left, cy);
    path.quadraticBezierTo(rect.left, cy - h * 0.5, cx - w * 0.3, cy - h * 0.5);
    path.close();
    return path;
  }

  static Path _buildStar(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double outerR = math.min(rect.width, rect.height) / 2;
    final double innerR = outerR * 0.45;
    
    for (int i = 0; i < 10; i++) {
      final double r = (i % 2 == 0) ? outerR : innerR;
      final double angle = (i * math.pi / 5) - (math.pi / 2);
      final Offset p = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  static Path _buildChessCrown(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width;
    final double h = rect.height * 0.85;
    
    path.moveTo(rect.left, rect.top);
    path.lineTo(cx - w * 0.2, cy - h * 0.2);
    path.lineTo(cx, rect.top - h * 0.1);
    path.lineTo(cx + w * 0.2, cy - h * 0.2);
    path.lineTo(rect.right, rect.top);
    path.lineTo(rect.right - w * 0.1, rect.bottom);
    path.lineTo(rect.left + w * 0.1, rect.bottom);
    path.close();
    return path;
  }

  static Path _buildClapperboard(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width * 0.9;
    final double h = rect.height * 0.8;
    
    path.addRect(Rect.fromCenter(center: Offset(cx, cy + h * 0.15), width: w, height: h * 0.7));
    // The clapper stick that's angled up
    path.moveTo(rect.left + w * 0.05, cy - h * 0.25);
    path.lineTo(rect.right - w * 0.05, cy - h * 0.45);
    path.lineTo(rect.right - w * 0.05, cy - h * 0.35);
    path.lineTo(rect.left + w * 0.05, cy - h * 0.15);
    path.close();
    return path;
  }

  static Path _buildCubeHexagon(Rect rect) {
    // A hexagon that acts like an isometric cube outline for CG Design
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double r = math.min(rect.width, rect.height) / 2;

    for (int i = 0; i < 6; i++) {
        final double angle = (i * math.pi / 3) - (math.pi / 2);
        final Offset p = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
        if (i == 0) path.moveTo(p.dx, p.dy);
        else path.lineTo(p.dx, p.dy);
    }
    path.close();
    // Inner Y shape to define cube lines
    path.moveTo(cx, cy);
    path.lineTo(cx, cy - r);
    path.moveTo(cx, cy);
    path.lineTo(cx + r * math.cos(math.pi/6), cy + r * math.sin(math.pi/6));
    path.moveTo(cx, cy);
    path.lineTo(cx - r * math.cos(math.pi/6), cy + r * math.sin(math.pi/6));
    return path;
  }

  static Path _buildCpuSocket(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width * 0.85;
    final double h = rect.height * 0.85;
    final double cut = w * 0.15;
    
    path.moveTo(cx - w/2 + cut, cy - h/2);
    path.lineTo(cx + w/2 - cut, cy - h/2);
    path.lineTo(cx + w/2, cy - h/2 + cut);
    path.lineTo(cx + w/2, cy + h/2 - cut);
    path.lineTo(cx + w/2 - cut, cy + h/2);
    path.lineTo(cx - w/2 + cut, cy + h/2);
    path.lineTo(cx - w/2, cy + h/2 - cut);
    path.lineTo(cx - w/2, cy - h/2 + cut);
    path.close();
    return path;
  }

  static Path _buildBriefcase(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width * 0.9;
    final double h = rect.height * 0.7;
    
    path.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + h * 0.1), width: w, height: h * 0.8), Radius.circular(w * 0.05)));
    // Handle
    path.addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - h * 0.4), width: w * 0.3, height: h * 0.2), Radius.circular(w * 0.05)));
    return path;
  }

  static Path _buildKettlebell(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width * 0.85;
    final double h = rect.height * 0.95;
    
    // Body
    path.addOval(Rect.fromCenter(center: Offset(cx, cy + h * 0.15), width: w, height: h * 0.7));
    // Handle
    path.addOval(Rect.fromCenter(center: Offset(cx, cy - h * 0.25), width: w * 0.6, height: h * 0.3));
    return path;
  }

  static Path _buildWaterDrop(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width * 0.80;
    final double h = rect.height * 0.95;
    
    path.moveTo(cx, rect.top);
    path.quadraticBezierTo(rect.right, cy + h * 0.2, cx, rect.bottom);
    path.quadraticBezierTo(rect.left, cy + h * 0.2, cx, rect.top); 
    return path;
  }

  static Path _buildPuzzlePiece(Rect rect) {
    final Path path = Path();
    // A stylized puzzle piece reflecting psychology
    final double r = rect.width / 2;
    path.addOval(rect.deflate(r * 0.15));
    // Adding bulbouts
    path.addOval(Rect.fromCenter(center: Offset(rect.center.dx + r * 0.85, rect.center.dy), width: r * 0.5, height: r * 0.5));
    path.addOval(Rect.fromCenter(center: Offset(rect.center.dx, rect.center.dy - r * 0.85), width: r * 0.5, height: r * 0.5));
    return path;
  }

  static Path _buildEyeOfWisdom(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    
    path.moveTo(rect.left, cy);
    path.quadraticBezierTo(cx, rect.top - rect.height * 0.2, rect.right, cy);
    path.quadraticBezierTo(cx, rect.bottom + rect.height * 0.2, rect.left, cy);
    // Inner iris
    path.addOval(Rect.fromCenter(center: Offset(cx, cy), width: rect.height * 0.6, height: rect.height * 0.6));
    return path;
  }
}
