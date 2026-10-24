import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/themes/color_scheme.dart';
import '../../features/iconic/world_festival.dart';
import '../../data/models/badge_achievement.dart';
import 'padauk_icon.dart';

enum RepCounterBadgeLevel {
  none,
  firstSteps,
  prep,
  bronze,
  silver,
  gold,
  platinum,
}

class RepCounterBadgeLevelResolver {
  static const String _firstWorkoutBadgeId = 'first_workout';
  static const String _prepBadgeId = 'prep_phase_15_v2';
  static const String _month1BronzeBadgeId = 'month_1_bronze';
  static const String _month2SilverBadgeId = 'month_2_silver';
  static const String _month3GoldBadgeId = 'month_3_gold';

  static RepCounterBadgeLevel fromBadges(Iterable<BadgeAchievement> badges) {
    final unlocked = badges.where((b) => b.isUnlocked);

    bool hasBadgeId(String id) => unlocked.any((b) => b.badgeId == id);

    if (unlocked.any((b) => b.tier == BadgeTier.platinum)) {
      return RepCounterBadgeLevel.platinum;
    }

    if (hasBadgeId(_month3GoldBadgeId) ||
        unlocked.any((b) => b.tier == BadgeTier.gold)) {
      return RepCounterBadgeLevel.gold;
    }

    if (hasBadgeId(_month2SilverBadgeId) ||
        unlocked.any((b) => b.tier == BadgeTier.silver)) {
      return RepCounterBadgeLevel.silver;
    }

    if (hasBadgeId(_month1BronzeBadgeId)) {
      return RepCounterBadgeLevel.bronze;
    }

    if (hasBadgeId(_prepBadgeId)) {
      return RepCounterBadgeLevel.prep;
    }

    if (hasBadgeId(_firstWorkoutBadgeId)) {
      return RepCounterBadgeLevel.firstSteps;
    }

    // Treat "no unlocked badges yet" as the First Steps baseline so the UI
    // always starts at the first level in this app.
    return RepCounterBadgeLevel.firstSteps;
  }
}

class RepCounter extends StatelessWidget {
  final int count;
  final String phase;
  final Color? color;
  final double size;
  final RepCounterBadgeLevel badgeLevel;
  final Duration? holdDuration; // ✅ Static exercise များအတွက်
  final bool isStaticExercise; // ✅ Exercise type ခွဲခြားရန်
  final WorldFestivalVisualStyle? festivalStyle;

  const RepCounter({
    super.key,
    required this.count,
    required this.phase,
    this.color,
    this.size = 100,
    this.badgeLevel = RepCounterBadgeLevel.none,
    this.holdDuration, // ✅ Optional parameter
    this.isStaticExercise = false, // ✅ Default အနေနဲ့ false
    this.festivalStyle,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Static exercise ဖြစ်ပြီး hold အနေအထားဆိုရင် time ပြမယ်
    final bool isHolding = phase.toLowerCase() == 'hold';
    final bool showTime = isStaticExercise && isHolding && holdDuration != null;

    final phaseColor = _getPhaseColor();
    final visuals = festivalStyle != null
        ? _RepCounterBadgeVisuals.forFestival(festivalStyle!)
        : _RepCounterBadgeVisuals.forLevel(badgeLevel);
    final bool hasBadgeRing =
        festivalStyle != null || badgeLevel != RepCounterBadgeLevel.none;
    final double outerRingWidth = !hasBadgeRing
        ? 0
        : (visuals.outerRingWidthAt100 * (size / 100)).clamp(3.0, 14.0);
    final double innerSize =
        !hasBadgeRing ? size : (size - (outerRingWidth * 2)).clamp(0.0, size);
    final contentSize = innerSize;

    final base = ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            // Premium glassmorphism effect
            color: Theme.of(context).colorScheme.surface.withOpacity(0.35),
            shape: BoxShape.circle,
            border: Border.all(
              color: phaseColor.withOpacity(0.8),
              width: 3, // slightly thinner, more elegant border
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
              // Inner glow simulation
              BoxShadow(
                color: phaseColor.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: -5,
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (festivalStyle != null &&
                  festivalStyle!.watermarkIcon.isNotEmpty)
                Positioned.fill(
                  child: ClipOval(
                    child: _DynamicWatermark(
                      icon: festivalStyle!.watermarkIcon,
                      color: visuals.glowColor,
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Main Display - Static exercise ဖြစ်ရင် time, မဟုတ်ရင် rep count
                  if (showTime)
                    Text(
                      '${holdDuration!.inSeconds}s',
                      style: TextStyle(
                        fontSize: contentSize * 0.35,
                        fontWeight: FontWeight.bold,
                        color: _getHoldColor(holdDuration!),
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: contentSize * 0.4,
                        fontWeight: FontWeight.bold,
                        color: phaseColor,
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),

                  // Phase Label
                  Text(
                    phase.toUpperCase(),
                    style: TextStyle(
                      fontSize: contentSize * 0.12,
                      fontWeight: FontWeight.w600,
                      color: phaseColor.withOpacity(0.8),
                    ),
                  ),

                  // ✅ Dynamic Label - Static/Dynamic ပေါ်မူတည်ပြီး ပြောင်းမယ်
                  Text(
                    showTime ? context.l10n.t('exercise.seconds_held') : context.l10n.t('progress.reps_short'),
                    style: TextStyle(
                      fontSize: contentSize * 0.1,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!hasBadgeRing) {
      return base;
    }

    return _buildBadgeFrame(
      context: context,
      base: base,
      visuals: visuals,
      outerRingWidth: outerRingWidth,
    );
  }

  Widget _buildBadgeFrame({
    required BuildContext context,
    required Widget base,
    required _RepCounterBadgeVisuals visuals,
    required double outerRingWidth,
  }) {
    final theme = Theme.of(context);

    double scaled(double valueAt100) =>
        (valueAt100 * (size / 100)).clamp(0.0, 40.0);

    final outerShadow = <BoxShadow>[
      // Ambient large luxury glow
      BoxShadow(
        color: visuals.glowColor.withOpacity(0.40),
        blurRadius: scaled(32),
        spreadRadius: scaled(4.0),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(
          theme.brightness == Brightness.dark ? 0.40 : 0.25,
        ),
        blurRadius: scaled(24),
        spreadRadius: scaled(2.0),
        offset: Offset(0, scaled(8)),
      ),
    ];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: _AuroraRing(
              colors: visuals.ringGradient,
              outerShadow: outerShadow,
            ),
          ),
          if (visuals.showHighlight)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(outerRingWidth),
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.55, -0.75),
                        radius: 1.05,
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.62],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          base,
        ],
      ),
    );
  }

  Color _getPhaseColor() {
    if (festivalStyle != null) {
      switch (phase.toLowerCase()) {
        case 'up':
          return festivalStyle!.phaseUpColor;
        case 'down':
          return festivalStyle!.phaseDownColor;
        case 'hold':
          return festivalStyle!.phaseHoldColor;
        default:
          return festivalStyle!.phaseUpColor;
      }
    }
    if (color != null) {
      return color!;
    }
    switch (phase.toLowerCase()) {
      case 'up':
        return Colors.green;
      case 'down':
        return Colors.orange;
      case 'hold':
        return Colors.blue;
      default:
        return color ?? AppColorScheme.primary;
    }
  }

  // ✅ Hold time ပေါ်မူတည်ပြီး color ပြောင်းခြင်း
  Color _getHoldColor(Duration duration) {
    if (festivalStyle != null) {
      return festivalStyle!.phaseHoldColor;
    }
    if (color != null) {
      return color!;
    }
    final seconds = duration.inSeconds;

    if (seconds >= 120) return Colors.purple; // 2 minutes
    if (seconds >= 60) return Colors.blue; // 1 minute
    if (seconds >= 30) return Colors.green; // 30 seconds
    return Colors.orange; // Under 30 seconds
  }
}

class AnimatedRepCounter extends StatefulWidget {
  final int count;
  final String phase;
  final Duration animationDuration;
  final Color? color;
  final RepCounterBadgeLevel badgeLevel;
  final Duration? holdDuration; // ✅ Static exercise များအတွက်
  final bool isStaticExercise; // ✅ Exercise type ခွဲခြားရန်
  final WorldFestivalVisualStyle? festivalStyle;

  const AnimatedRepCounter({
    super.key,
    required this.count,
    required this.phase,
    this.animationDuration = const Duration(milliseconds: 300),
    this.color,
    this.badgeLevel = RepCounterBadgeLevel.none,
    this.holdDuration, // ✅ Optional
    this.isStaticExercise = false, // ✅ Default
    this.festivalStyle,
  });

  @override
  State<AnimatedRepCounter> createState() => _AnimatedRepCounterState();
}

class _AnimatedRepCounterState extends State<AnimatedRepCounter>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late AnimationController _burstController;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();

    _previousCount = widget.count;

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _burstController = AnimationController(
      duration: _RepCounterCountBurstSpec.forLevel(widget.badgeLevel).duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 0.5,
      ),
    ]).animate(_controller);

    _startAnimation();
  }

  @override
  void didUpdateWidget(AnimatedRepCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ Count, phase သို့မဟုတ် hold duration ပြောင်းရင် animation စမယ်
    final countChanged = widget.count != oldWidget.count;
    final phaseChanged = widget.phase != oldWidget.phase;
    final holdDurationChanged = widget.holdDuration != oldWidget.holdDuration;
    final badgeLevelChanged = widget.badgeLevel != oldWidget.badgeLevel;

    if (countChanged || phaseChanged || holdDurationChanged) {
      _startAnimation();
    }

    if (badgeLevelChanged) {
      _burstController.duration =
          _RepCounterCountBurstSpec.forLevel(widget.badgeLevel).duration;
    }

    if (countChanged) {
      final shouldBurst = widget.badgeLevel != RepCounterBadgeLevel.none &&
          widget.count != _previousCount;
      if (shouldBurst) {
        _burstController.forward(from: 0);
      }
      _previousCount = widget.count;
    }
  }

  void _startAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _burstController]),
      builder: (context, child) {
        final counter = RepCounter(
          count: widget.count,
          phase: widget.phase,
          size: 100,
          color: widget.color,
          holdDuration: widget.holdDuration,
          isStaticExercise: widget.isStaticExercise,
          badgeLevel: widget.badgeLevel,
          festivalStyle: widget.festivalStyle,
        );

        final showBurst = (widget.festivalStyle != null ||
                widget.badgeLevel != RepCounterBadgeLevel.none) &&
            (_burstController.isAnimating || _burstController.value > 0);

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              counter,
              if (showBurst)
                IgnorePointer(
                  child: ClipOval(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: const Size.square(100),
                        painter: _RepCounterCountBurstPainter(
                          progress: _burstController.value,
                          level: widget.badgeLevel,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RepCounterCountBurstSpec {
  final int ringCount;
  final int sparkleCount;
  final double shimmerStrength;
  final double maxRingOpacity;
  final Duration duration;

  const _RepCounterCountBurstSpec({
    required this.ringCount,
    required this.sparkleCount,
    required this.shimmerStrength,
    required this.maxRingOpacity,
    required this.duration,
  });

  static _RepCounterCountBurstSpec forLevel(RepCounterBadgeLevel level) {
    switch (level) {
      case RepCounterBadgeLevel.none:
        return const _RepCounterCountBurstSpec(
          ringCount: 0,
          sparkleCount: 0,
          shimmerStrength: 0,
          maxRingOpacity: 0,
          duration: Duration(milliseconds: 1),
        );
      case RepCounterBadgeLevel.firstSteps:
        return const _RepCounterCountBurstSpec(
          ringCount: 1,
          sparkleCount: 4,
          shimmerStrength: 0.65,
          maxRingOpacity: 0.40,
          duration: Duration(milliseconds: 360),
        );
      case RepCounterBadgeLevel.prep:
        return const _RepCounterCountBurstSpec(
          ringCount: 1,
          sparkleCount: 6,
          shimmerStrength: 0.75,
          maxRingOpacity: 0.44,
          duration: Duration(milliseconds: 400),
        );
      case RepCounterBadgeLevel.bronze:
        return const _RepCounterCountBurstSpec(
          ringCount: 2,
          sparkleCount: 8,
          shimmerStrength: 0.85,
          maxRingOpacity: 0.48,
          duration: Duration(milliseconds: 460),
        );
      case RepCounterBadgeLevel.silver:
        return const _RepCounterCountBurstSpec(
          ringCount: 2,
          sparkleCount: 10,
          shimmerStrength: 0.92,
          maxRingOpacity: 0.52,
          duration: Duration(milliseconds: 500),
        );
      case RepCounterBadgeLevel.gold:
        return const _RepCounterCountBurstSpec(
          ringCount: 3,
          sparkleCount: 12,
          shimmerStrength: 0.105,
          maxRingOpacity: 0.60,
          duration: Duration(milliseconds: 560),
        );
      case RepCounterBadgeLevel.platinum:
        return const _RepCounterCountBurstSpec(
          ringCount: 3,
          sparkleCount: 14,
          shimmerStrength: 0.115,
          maxRingOpacity: 0.64,
          duration: Duration(milliseconds: 600),
        );
    }
  }
}

class _RepCounterCountBurstPainter extends CustomPainter {
  final double progress;
  final RepCounterBadgeLevel level;

  const _RepCounterCountBurstPainter({
    required this.progress,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (level == RepCounterBadgeLevel.none) {
      return;
    }

    final visuals = _RepCounterBadgeVisuals.forLevel(level);
    final spec = _RepCounterCountBurstSpec.forLevel(level);
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final t = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final ringWidth = (visuals.outerRingWidthAt100).clamp(3.0, 12.0);

    // Shimmer sweep around the ring.
    if (spec.shimmerStrength > 0) {
      final shimmerOpacity =
          (1.0 - t) * (0.55 * spec.shimmerStrength).clamp(0.0, 0.55);
      final shimmerRotation = progress * math.pi * 2.0 * 0.95;
      final shimmerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth * 0.95
        ..shader = SweepGradient(
          startAngle: shimmerRotation,
          endAngle: shimmerRotation + (math.pi * 2),
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(shimmerOpacity),
            visuals.glowColor.withOpacity(shimmerOpacity * 0.80),
            Colors.transparent,
          ],
          stops: const [0.42, 0.49, 0.54, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(
        center,
        radius - (ringWidth * 0.55),
        shimmerPaint,
      );
    }

    // Expanding rings.
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < spec.ringCount; i++) {
      final ringDelay = i * 0.12;
      final ringProgressRaw = (progress - ringDelay) / (1.0 - ringDelay);
      if (ringProgressRaw <= 0) continue;

      final ringT = Curves.easeOutCubic.transform(
        ringProgressRaw.clamp(0.0, 1.0),
      );

      final ringOpacity = (1.0 - ringT) *
          (spec.maxRingOpacity * (1.0 - (i * 0.14))).clamp(0.0, 0.65);

      final ringStrokeWidth =
          (ringWidth * (1.25 - (ringT * 0.75))).clamp(1.2, 14.0);

      final ringRadius =
          (radius * (0.38 + (0.62 * ringT))) - (i * ringWidth * 0.15);

      ringPaint
        ..strokeWidth = ringStrokeWidth
        ..color = visuals.glowColor.withOpacity(ringOpacity);

      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // Sparkles/rays.
    if (spec.sparkleCount > 0) {
      final sparkleBaseOpacity =
          ((1.0 - t) * 0.55 * (0.6 + spec.shimmerStrength)).clamp(0.0, 0.7);

      final sparklePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < spec.sparkleCount; i++) {
        final angle = (i / spec.sparkleCount) * math.pi * 2.0 +
            (progress * math.pi * 2.0 * 0.35);

        final unit = Offset(math.cos(angle), math.sin(angle));
        final start = center + unit * (radius * 0.64);
        final end = center + unit * (radius * (0.64 + 0.28 * (1.0 - t)));

        final local = (math.sin((progress * 6.0) + (i * 0.9)) * 0.5 + 0.5);
        final opacity = sparkleBaseOpacity * (0.65 + (local * 0.35));

        sparklePaint
          ..strokeWidth = (ringWidth * 0.18 + 0.9).clamp(1.2, 3.0)
          ..color = Colors.white.withOpacity(opacity);

        canvas.drawLine(start, end, sparklePaint);
      }
    }

    // Inner flash for higher tiers (subtle).
    if (spec.shimmerStrength >= 0.55 && progress <= 0.55) {
      final flashOpacity = ((0.55 - progress) / 0.55) *
          (0.18 * spec.shimmerStrength).clamp(0.0, 0.22);

      final flashPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(flashOpacity),
            Colors.transparent,
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.95));

      canvas.drawCircle(center, radius * 0.95, flashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RepCounterCountBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.level != level;
  }
}

class _RepCounterBadgeVisuals {
  final List<Color> ringGradient;
  final Color glowColor;
  final double outerRingWidthAt100;
  final bool showHighlight;

  const _RepCounterBadgeVisuals({
    required this.ringGradient,
    required this.glowColor,
    required this.outerRingWidthAt100,
    required this.showHighlight,
  });

  static _RepCounterBadgeVisuals forFestival(WorldFestivalVisualStyle style) {
    return _RepCounterBadgeVisuals(
      ringGradient: style.ringGradient,
      glowColor: style.glowColor,
      outerRingWidthAt100: style.outerRingWidthAt100,
      showHighlight: style.showHighlight,
    );
  }

  static _RepCounterBadgeVisuals forLevel(RepCounterBadgeLevel level) {
    switch (level) {
      case RepCounterBadgeLevel.firstSteps:
        return const _RepCounterBadgeVisuals(
          ringGradient: [
            Color(0xFF9BE7FF),
            Color(0xFF4CA4FF),
            Color(0xFF2E6BFF),
            Color(0xFF9BE7FF),
          ],
          glowColor: Color(0xFF4CA4FF),
          outerRingWidthAt100: 4.5,
          showHighlight: false,
        );
      case RepCounterBadgeLevel.prep:
        return const _RepCounterBadgeVisuals(
          ringGradient: [
            Color(0xFF7CFFB3),
            Color(0xFF2EE6A6),
            Color(0xFF1DB59A),
            Color(0xFF7CFFB3),
          ],
          glowColor: Color(0xFF2EE6A6),
          outerRingWidthAt100: 5.4,
          showHighlight: false,
        );
      case RepCounterBadgeLevel.bronze:
        return const _RepCounterBadgeVisuals(
          ringGradient: [
            Color(0xFFE0A25B),
            Color(0xFFCD7F32),
            Color(0xFF8C5A2B),
            Color(0xFFE0A25B),
          ],
          glowColor: Color(0xFFCD7F32),
          outerRingWidthAt100: 6.2,
          showHighlight: true,
        );
      case RepCounterBadgeLevel.silver:
        return const _RepCounterBadgeVisuals(
          ringGradient: [
            Color(0xFFF2F2F2),
            Color(0xFFCFCFCF),
            Color(0xFF9E9E9E),
            Color(0xFFF2F2F2),
          ],
          glowColor: Color(0xFFCFCFCF),
          outerRingWidthAt100: 7.0,
          showHighlight: true,
        );
      case RepCounterBadgeLevel.gold:
        return const _RepCounterBadgeVisuals(
          ringGradient: [
            AppColorScheme.goldStart,
            AppColorScheme.goldMid,
            AppColorScheme.goldEnd,
            AppColorScheme.goldStart,
          ],
          glowColor: AppColorScheme.goldMid,
          outerRingWidthAt100: 7.8,
          showHighlight: true,
        );
      case RepCounterBadgeLevel.platinum:
        return const _RepCounterBadgeVisuals(
          ringGradient: [
            Color(0xFFD7D2FF),
            Color(0xFFB8A7FF),
            Color(0xFF7C5CFF),
            Color(0xFFD7D2FF),
          ],
          glowColor: Color(0xFFB8A7FF),
          outerRingWidthAt100: 8.4,
          showHighlight: true,
        );
      case RepCounterBadgeLevel.none:
        return const _RepCounterBadgeVisuals(
          ringGradient: [Colors.transparent, Colors.transparent],
          glowColor: Colors.transparent,
          outerRingWidthAt100: 0,
          showHighlight: false,
        );
    }
  }
}

class _DynamicWatermark extends StatefulWidget {
  final String icon;
  final Color color;

  const _DynamicWatermark({required this.icon, required this.color});

  @override
  State<_DynamicWatermark> createState() => _DynamicWatermarkState();
}

class _DynamicWatermarkState extends State<_DynamicWatermark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.15); // breathe 1.0 to 1.15
        return Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: 0.15 + (_controller.value * 0.1), // 0.15 to 0.25 opacity
              child: isPadaukBranchIcon(widget.icon)
                  ? PadaukBranchIcon(
                      size: 64,
                      opacity: 0.58,
                      flowerColor: const Color(0xFFF4C542),
                      branchColor: const Color(0xFF7A5530),
                      centerColor: const Color(0xFFFFF0B2),
                    )
                  : Text(
                      widget.icon,
                      style: TextStyle(
                        fontSize: 55, // large watermark
                        color: widget.color.withOpacity(0.5),
                        shadows: [
                          Shadow(
                            color: widget.color,
                            blurRadius: 20 * _controller.value,
                          )
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _AuroraRing extends StatefulWidget {
  final List<Color> colors;
  final List<BoxShadow> outerShadow;

  const _AuroraRing({
    required this.colors,
    required this.outerShadow,
  });

  @override
  State<_AuroraRing> createState() => _AuroraRingState();
}

class _AuroraRingState extends State<_AuroraRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: widget.colors,
              transform: GradientRotation(_controller.value * math.pi * 2),
            ),
            boxShadow: widget.outerShadow,
          ),
        );
      },
    );
  }
}
