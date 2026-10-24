import 'dart:math' as math;
import 'package:flutter/material.dart';

class FestivalPathBorder extends OutlinedBorder {
  final String storageKey;

  const FestivalPathBorder({
    required this.storageKey,
    super.side,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return FestivalShape.getShapeForFestival(storageKey, rect.deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return FestivalShape.getShapeForFestival(storageKey, rect);
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
    return FestivalPathBorder(
      storageKey: storageKey,
      side: side.scale(t),
    );
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return FestivalPathBorder(
      storageKey: storageKey,
      side: side ?? this.side,
    );
  }
}

class FestivalShape {
  static const Map<String, _FestivalShapeKind> _exactShapeByStorageKey = {
    'new_year': _FestivalShapeKind.lotusFlower,
    'new_year_eve': _FestivalShapeKind.lotusFlower,
    'new_years_eve': _FestivalShapeKind.lotusFlower,
    'harbin_ice': _FestivalShapeKind.snowflake,
    'sapporo_snow': _FestivalShapeKind.snowflake,
    'australian_open': _FestivalShapeKind.tournamentShield,
    'french_open': _FestivalShapeKind.tournamentShield,
    'wimbledon': _FestivalShapeKind.tournamentShield,
    'super_bowl': _FestivalShapeKind.tournamentShield,
    'daytona_500': _FestivalShapeKind.tournamentShield,
    'tour_de_france': _FestivalShapeKind.tournamentShield,
    'crossfit_games': _FestivalShapeKind.tournamentShield,
    'tokyo_marathon': _FestivalShapeKind.athleticHexagon,
    'boston_marathon': _FestivalShapeKind.athleticHexagon,
    'london_marathon': _FestivalShapeKind.athleticHexagon,
    'berlin_marathon': _FestivalShapeKind.athleticHexagon,
    'chicago_marathon': _FestivalShapeKind.athleticHexagon,
    'nyc_marathon': _FestivalShapeKind.athleticHexagon,
    'global_running_day': _FestivalShapeKind.athleticHexagon,
    'boat_racing': _FestivalShapeKind.dropletSplash,
    'sundance': _FestivalShapeKind.filmReel,
    'berlinale': _FestivalShapeKind.filmReel,
    'cannes': _FestivalShapeKind.filmReel,
    'venice_film_festival': _FestivalShapeKind.filmReel,
    'the_oscars': _FestivalShapeKind.filmReel,
    'sxsw': _FestivalShapeKind.vinylRecord,
    'coachella': _FestivalShapeKind.vinylRecord,
    'glastonbury': _FestivalShapeKind.vinylRecord,
    'tomorrowland': _FestivalShapeKind.vinylRecord,
    'lollapalooza': _FestivalShapeKind.vinylRecord,
    'montreux_jazz': _FestivalShapeKind.vinylRecord,
    'eurovision': _FestivalShapeKind.vinylRecord,
    'dance_day': _FestivalShapeKind.vinylRecord,
    'vivid_sydney': _FestivalShapeKind.vinylRecord,
    'white_nights': _FestivalShapeKind.vinylRecord,
    'venice_carnival': _FestivalShapeKind.sunburst,
    'rio_carnival': _FestivalShapeKind.sunburst,
    'las_fallas': _FestivalShapeKind.sunburst,
    'cinco_de_mayo': _FestivalShapeKind.sunburst,
    'notting_hill': _FestivalShapeKind.sunburst,
    'la_tomatina': _FestivalShapeKind.sunburst,
    'san_fermin': _FestivalShapeKind.sunburst,
    'holi': _FestivalShapeKind.sunburst,
    'april_fools': _FestivalShapeKind.sunburst,
    'happiness_day': _FestivalShapeKind.heart,
    'yoga_day': _FestivalShapeKind.heart,
    'hanami': _FestivalShapeKind.lotusFlower,
    'earth_day': _FestivalShapeKind.lotusFlower,
    'environment_day': _FestivalShapeKind.lotusFlower,
    'midsummer': _FestivalShapeKind.lotusFlower,
    'mid_autumn': _FestivalShapeKind.lotusFlower,
    'sticky_rice_festival': _FestivalShapeKind.lotusFlower,
    'thingyan_festival': _FestivalShapeKind.dropletSplash,
    'boryeong_mud': _FestivalShapeKind.dropletSplash,
    'day_of_the_dead': _FestivalShapeKind.flameCrest,
    'burning_man': _FestivalShapeKind.flameCrest,
    'diwali': _FestivalShapeKind.flameCrest,
    'st_patricks_day': _FestivalShapeKind.cloverBadge,
    'easter': _FestivalShapeKind.lanternBadge,
    'vaisakhi': _FestivalShapeKind.lanternBadge,
    'eid_al_fitr': _FestivalShapeKind.lanternBadge,
    'eid_al_adha': _FestivalShapeKind.lanternBadge,
    'hanukkah': _FestivalShapeKind.lanternBadge,
    'purim': _FestivalShapeKind.lanternBadge,
    'lantern_festival_mm': _FestivalShapeKind.lanternBadge,
    'loy_krathong': _FestivalShapeKind.lanternBadge,
    'sarsodaw_pwe': _FestivalShapeKind.ribbonSeal,
    'comic_con': _FestivalShapeKind.ticketStub,
    'edinburgh_fringe': _FestivalShapeKind.ticketStub,
    'met_gala': _FestivalShapeKind.ticketStub,
    'nyfw': _FestivalShapeKind.ticketStub,
    'lfw': _FestivalShapeKind.ticketStub,
    'mfw': _FestivalShapeKind.ticketStub,
    'pfw': _FestivalShapeKind.ticketStub,
    'black_friday': _FestivalShapeKind.tagBadge,
    'singles_day': _FestivalShapeKind.tagBadge,
    'balloon_fiesta': _FestivalShapeKind.lanternBadge,
    'calgary_stampede': _FestivalShapeKind.horseshoe,
    'horse_parade': _FestivalShapeKind.horseshoe,
    'oktoberfest': _FestivalShapeKind.tagBadge,
    'beer_day': _FestivalShapeKind.tagBadge,
    'coffee_day': _FestivalShapeKind.tagBadge,
    'world_food_day': _FestivalShapeKind.tagBadge,
    'christmas': _FestivalShapeKind.lotusFlower,
    'thanksgiving': _FestivalShapeKind.lotusFlower,
  };

  static Path getShapeForFestival(String storageKey, Rect rect) {
    final key = storageKey.toLowerCase();

    final exactShape = _exactShapeByStorageKey[key];
    if (exactShape != null) {
      return _buildShape(exactShape, rect);
    }

    // Safe fallback for future festival keys that are not listed yet.
    if (key.contains('film') ||
        key.contains('oscar') ||
        key.contains('cannes') ||
        key.contains('sundance') ||
        key.contains('berlinale') ||
        key.contains('tiff')) {
      return _buildFilmReel(rect);
    }

    if (key.contains('ice') || key.contains('snow') || key.contains('winter')) {
      return _buildSnowflake(rect);
    }

    if (key.contains('open') ||
        key.contains('bowl') ||
        key.contains('500') ||
        key.contains('wimbledon') ||
        key.contains('tour_de_france') ||
        key.contains('cup') || key.contains('olympic')) {
      return _buildTournamentShield(rect);
    }

    if (key.contains('marathon') || key.contains('race') || key.contains('sprint')) {
      return _buildAthleticHexagon(rect);
    }

    if (key.contains('music') ||
        key.contains('lollapalooza') ||
        key.contains('glastonbury') ||
        key.contains('coachella') || key.contains('tomorrowland') || key.contains('sxsw')) {
      return _buildVinylRecord(rect);
    }

    if (key.contains('carnival') || key.contains('mardi_gras') || key.contains('fallas')) {
      return _buildSunburst(rect);
    }

    if (key.contains('hanami') ||
        key.contains('earth') ||
        key.contains('autumn') ||
        key.contains('new_year') ||
        key.contains('christmas') ||
        key.contains('thanksgiving') ||
        key.contains('halloween')) {
      return _buildLotusFlower(rect);
    }

    if (key.contains('valentine') || key.contains('happiness') || key.contains('yoga')) {
      return _buildHeart(rect);
    }

    return _buildPremiumStar(rect);
  }

  static Path _buildShape(_FestivalShapeKind kind, Rect rect) {
    switch (kind) {
      case _FestivalShapeKind.filmReel:
        return _buildFilmReel(rect);
      case _FestivalShapeKind.snowflake:
        return _buildSnowflake(rect);
      case _FestivalShapeKind.tournamentShield:
        return _buildTournamentShield(rect);
      case _FestivalShapeKind.athleticHexagon:
        return _buildAthleticHexagon(rect);
      case _FestivalShapeKind.vinylRecord:
        return _buildVinylRecord(rect);
      case _FestivalShapeKind.sunburst:
        return _buildSunburst(rect);
      case _FestivalShapeKind.lotusFlower:
        return _buildLotusFlower(rect);
      case _FestivalShapeKind.heart:
        return _buildHeart(rect);
      case _FestivalShapeKind.lanternBadge:
        return _buildLanternBadge(rect);
      case _FestivalShapeKind.flameCrest:
        return _buildFlameCrest(rect);
      case _FestivalShapeKind.ticketStub:
        return _buildTicketStub(rect);
      case _FestivalShapeKind.cloverBadge:
        return _buildCloverBadge(rect);
      case _FestivalShapeKind.horseshoe:
        return _buildHorseshoe(rect);
      case _FestivalShapeKind.tagBadge:
        return _buildTagBadge(rect);
      case _FestivalShapeKind.dropletSplash:
        return _buildDropletSplash(rect);
      case _FestivalShapeKind.ribbonSeal:
        return _buildRibbonSeal(rect);
      case _FestivalShapeKind.premiumStar:
        return _buildPremiumStar(rect);
    }
  }

  static Path _buildFilmReel(Rect rect) {
    final Path path = Path();
    final double r = math.min(rect.width, rect.height) / 2;
    path.addOval(rect);
    // Cut out 4 smaller circles around the edge
    for(int i = 0; i < 4; i++) {
        final double angle = i * math.pi / 2 + (math.pi / 4);
        final cutRect = Rect.fromCenter(
            center: Offset(rect.center.dx + r * 0.65 * math.cos(angle), rect.center.dy + r * 0.65 * math.sin(angle)),
            width: r * 0.5,
            height: r * 0.5
        );
        path.addOval(cutRect);
    }
    return path..fillType = PathFillType.evenOdd;
  }

  static Path _buildSnowflake(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double outerR = math.min(rect.width, rect.height) / 2;
    final double innerR = outerR * 0.75;
    final double starR = outerR * 0.45;
    
    for (int i = 0; i < 12; i++) {
      double r;
      if (i % 2 == 0) r = outerR;
      else if (i % 4 == 1) r = innerR;
      else r = starR;
      
      final double angle = i * math.pi / 6;
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

  static Path _buildTournamentShield(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double w = rect.width * 0.95;
    final double h = rect.height * 0.95;
    
    path.moveTo(rect.left, rect.top + h * 0.1);
    path.quadraticBezierTo(cx, rect.top - h * 0.05, rect.right, rect.top + h * 0.1);
    path.lineTo(rect.right, rect.top + h * 0.5);
    path.quadraticBezierTo(rect.right, rect.bottom - h * 0.1, cx, rect.bottom);
    path.quadraticBezierTo(rect.left, rect.bottom - h * 0.1, rect.left, rect.top + h * 0.5);
    path.close();
    return path;
  }

  static Path _buildAthleticHexagon(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double r = math.min(rect.width, rect.height) / 2;

    for (int i = 0; i < 6; i++) {
        final double angle = (i * math.pi / 3); // Flat top
        final Offset p = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
        if (i == 0) path.moveTo(p.dx, p.dy);
        else path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  static Path _buildVinylRecord(Rect rect) {
    final Path path = Path();
    final double r = math.min(rect.width, rect.height) / 2;
    path.addOval(rect);
    // Draw an inner groove
    path.addOval(rect.deflate(r * 0.8));
    return path..fillType = PathFillType.evenOdd;
  }

  static Path _buildSunburst(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double outerR = math.min(rect.width, rect.height) / 2;
    final double innerR = outerR * 0.82;
    const int points = 16;
    
    for (int i = 0; i < points * 2; i++) {
      final double r = (i % 2 == 0) ? outerR : innerR;
      final double angle = i * math.pi / points;
      final Offset p = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      if (i == 0) path.moveTo(p.dx, p.dy);
      else path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  static Path _buildLotusFlower(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double w = rect.width;
    final double h = rect.height;
    
    path.moveTo(rect.left, cy);
    path.quadraticBezierTo(rect.left, rect.top, cx, rect.top + h * 0.2);
    path.quadraticBezierTo(rect.right, rect.top, rect.right, cy);
    path.quadraticBezierTo(rect.right, rect.bottom, cx, rect.bottom - h * 0.2);
    path.quadraticBezierTo(rect.left, rect.bottom, rect.left, cy);
    
    return path;
  }

  static Path _buildHeart(Rect rect) {
    final Path path = Path();
    final double w = rect.width;
    final double h = rect.height;
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
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

  static Path _buildPremiumStar(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double outerR = math.min(rect.width, rect.height) / 2;
    // 8-point sophisticated star
    final double innerR = outerR * 0.65;
    
    for (int i = 0; i < 16; i++) {
        final double r = (i % 2 == 0) ? outerR : innerR;
        final double angle = (i * math.pi / 8) - (math.pi / 2);
        final Offset p = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
        if (i == 0) path.moveTo(p.dx, p.dy);
        else path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  static Path _buildLanternBadge(Rect rect) {
    final Path path = Path();
    final double w = rect.width;
    final double h = rect.height;
    final double inset = w * 0.12;

    path.moveTo(rect.left + inset, rect.top + h * 0.18);
    path.quadraticBezierTo(
      rect.left,
      rect.center.dy,
      rect.left + inset,
      rect.bottom - h * 0.18,
    );
    path.lineTo(rect.right - inset, rect.bottom - h * 0.18);
    path.quadraticBezierTo(
      rect.right,
      rect.center.dy,
      rect.right - inset,
      rect.top + h * 0.18,
    );
    path.close();
    return path;
  }

  static Path _buildFlameCrest(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double w = rect.width;
    final double h = rect.height;

    path.moveTo(cx, top + h * 0.05);
    path.cubicTo(
      cx + w * 0.32,
      top + h * 0.18,
      cx + w * 0.42,
      top + h * 0.46,
      cx + w * 0.20,
      top + h * 0.74,
    );
    path.cubicTo(
      cx + w * 0.10,
      bottom - h * 0.02,
      cx - w * 0.10,
      bottom - h * 0.02,
      cx - w * 0.20,
      top + h * 0.74,
    );
    path.cubicTo(
      cx - w * 0.42,
      top + h * 0.46,
      cx - w * 0.32,
      top + h * 0.18,
      cx,
      top + h * 0.05,
    );
    path.close();
    return path;
  }

  static Path _buildTicketStub(Rect rect) {
    final Path path = Path();
    final double bite = rect.height * 0.16;
    final double corner = rect.height * 0.18;
    final RRect base = RRect.fromRectAndRadius(rect, Radius.circular(corner));

    path.addRRect(base);
    path.addOval(
      Rect.fromCircle(
        center: Offset(rect.left, rect.center.dy),
        radius: bite,
      ),
    );
    path.addOval(
      Rect.fromCircle(
        center: Offset(rect.right, rect.center.dy),
        radius: bite,
      ),
    );
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  static Path _buildCloverBadge(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double r = math.min(rect.width, rect.height) * 0.24;

    path.addOval(Rect.fromCircle(center: Offset(cx, cy - r), radius: r));
    path.addOval(Rect.fromCircle(center: Offset(cx - r, cy), radius: r));
    path.addOval(Rect.fromCircle(center: Offset(cx + r, cy), radius: r));
    path.addOval(Rect.fromCircle(center: Offset(cx, cy + r * 0.95), radius: r));
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, rect.bottom - r * 0.28),
          width: r * 0.62,
          height: r * 1.05,
        ),
        Radius.circular(r * 0.25),
      ),
    );
    return path;
  }

  static Path _buildHorseshoe(Rect rect) {
    final Path outer = Path()
      ..addOval(rect);
    final Path inner = Path()
      ..addOval(rect.deflate(math.min(rect.width, rect.height) * 0.24));
    final Path gap = Path()
      ..addRect(
        Rect.fromLTRB(
          rect.left + rect.width * 0.25,
          rect.bottom - rect.height * 0.28,
          rect.right - rect.width * 0.25,
          rect.bottom + rect.height * 0.1,
        ),
      );

    return Path.combine(
      PathOperation.difference,
      Path.combine(PathOperation.difference, outer, inner),
      gap,
    );
  }

  static Path _buildTagBadge(Rect rect) {
    final Path path = Path();
    final double notch = rect.width * 0.24;
    final double corner = rect.height * 0.18;
    final RRect body = RRect.fromRectAndRadius(
      Rect.fromLTRB(rect.left + notch, rect.top, rect.right, rect.bottom),
      Radius.circular(corner),
    );

    path.addRRect(body);
    path.moveTo(rect.left + notch, rect.top);
    path.lineTo(rect.left, rect.center.dy);
    path.lineTo(rect.left + notch, rect.bottom);
    path.close();
    return path;
  }

  static Path _buildDropletSplash(Rect rect) {
    final Path path = Path();
    final double cx = rect.center.dx;
    final double top = rect.top;
    final double w = rect.width;
    final double h = rect.height;

    path.moveTo(cx, top + h * 0.02);
    path.cubicTo(
      cx + w * 0.42,
      top + h * 0.24,
      cx + w * 0.36,
      top + h * 0.72,
      cx,
      rect.bottom,
    );
    path.cubicTo(
      cx - w * 0.36,
      top + h * 0.72,
      cx - w * 0.42,
      top + h * 0.24,
      cx,
      top + h * 0.02,
    );
    path.close();
    return path;
  }

  static Path _buildRibbonSeal(Rect rect) {
    final Path path = Path();
    final double ribbonTop = rect.top + rect.height * 0.52;
    final double wing = rect.width * 0.28;
    final double sealRadius = math.min(rect.width, rect.height) * 0.34;

    path.addOval(
      Rect.fromCircle(
        center: Offset(rect.center.dx, rect.top + rect.height * 0.34),
        radius: sealRadius,
      ),
    );
    path.moveTo(rect.center.dx - wing, ribbonTop);
    path.lineTo(rect.center.dx - wing * 0.48, rect.bottom);
    path.lineTo(rect.center.dx, ribbonTop + rect.height * 0.22);
    path.close();
    path.moveTo(rect.center.dx + wing, ribbonTop);
    path.lineTo(rect.center.dx + wing * 0.48, rect.bottom);
    path.lineTo(rect.center.dx, ribbonTop + rect.height * 0.22);
    path.close();
    return path;
  }
}

enum _FestivalShapeKind {
  filmReel,
  snowflake,
  tournamentShield,
  athleticHexagon,
  vinylRecord,
  sunburst,
  lotusFlower,
  heart,
  lanternBadge,
  flameCrest,
  ticketStub,
  cloverBadge,
  horseshoe,
  tagBadge,
  dropletSplash,
  ribbonSeal,
  premiumStar,
}
