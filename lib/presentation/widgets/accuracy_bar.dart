import 'dart:ui';
import 'package:flutter/material.dart';
import '../../features/iconic/world_festival.dart';
import 'padauk_icon.dart';

class AccuracyBar extends StatefulWidget {
  final double accuracy; // 0.0 to 1.0
  final bool animate;
  final bool simplified;
  final WorldFestivalVisualStyle? festivalStyle;

  // New: allow using a pre-rendered static track background image (lighter for video overlays)
  final bool usePreRenderedBackground;
  final ImageProvider? preRenderedBackground;

  const AccuracyBar({
    super.key,
    required this.accuracy,
    this.animate = true,
    this.simplified = false,
    this.festivalStyle,
    this.usePreRenderedBackground = false,
    this.preRenderedBackground,
  });

  @override
  State<AccuracyBar> createState() => _AccuracyBarState();
}

class _AccuracyBarState extends State<AccuracyBar> {
  double _previousAccuracy = 0.0;

  @override
  void didUpdateWidget(AccuracyBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousAccuracy = oldWidget.accuracy;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      final percentage = (widget.accuracy * 100).clamp(0.0, 100.0);
      final color = _getColorForAccuracy(widget.accuracy);
      return _buildBar(
        context,
        animatedAccuracy: widget.accuracy,
        percentage: percentage,
        color: color,
        simplified: widget.simplified,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: _previousAccuracy,
        end: widget.accuracy,
      ),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedAccuracy, child) {
        final percentage = (animatedAccuracy * 100).clamp(0.0, 100.0);
        final color = _getColorForAccuracy(animatedAccuracy);
        return _buildBar(
          context,
          animatedAccuracy: animatedAccuracy,
          percentage: percentage,
          color: color,
          simplified: widget.simplified,
        );
      },
    );
  }

  Widget _buildBar(
    BuildContext context, {
    required double animatedAccuracy,
    required double percentage,
    required Color color,
    required bool simplified,
  }) {
    final barHeight = simplified ? 24.0 : 28.0;
    final borderRadius = BorderRadius.circular(simplified ? 12 : 14);
    final trackWidth =
        (MediaQuery.of(context).size.width - 40).clamp(0.0, double.infinity);
    final progressWidth = trackWidth * animatedAccuracy;

    // Fast path: when a pre-rendered track image is provided, render a lightweight track
    if (widget.usePreRenderedBackground && widget.preRenderedBackground != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              image: DecorationImage(
                image: widget.preRenderedBackground!,
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(
              children: [
                // simple progress overlay without heavy gradients or blurs
                AnimatedContainer(
                  duration: simplified
                      ? const Duration(milliseconds: 120)
                      : const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: progressWidth,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: color.withOpacity(0.92),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getAccuracyIcon(animatedAccuracy),
                        color: Colors.white,
                        size: simplified ? 14 : 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: simplified ? 13 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                // Premium glassmorphism track
                color: Colors.black.withOpacity(simplified ? 0.20 : 0.30),
                borderRadius: borderRadius,
                border: Border.all(
                    color: Colors.white.withOpacity(simplified ? 0.15 : 0.25)),
                boxShadow: simplified
                    ? const []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        colors: widget.festivalStyle != null
                            ? widget.festivalStyle!.accuracyBarGradient
                                .map((c) =>
                                    c.withOpacity(simplified ? 0.14 : 0.2))
                                .toList()
                            : [
                                Colors.red.withOpacity(simplified ? 0.14 : 0.2),
                                Colors.orange
                                    .withOpacity(simplified ? 0.14 : 0.2),
                                Colors.green
                                    .withOpacity(simplified ? 0.14 : 0.2),
                              ],
                        stops: widget.festivalStyle != null
                            ? _buildEvenStops(widget
                                .festivalStyle!.accuracyBarGradient.length)
                            : const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: simplified
                        ? const Duration(milliseconds: 180)
                        : const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    width: progressWidth,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.9),
                          color.withOpacity(simplified ? 0.82 : 0.7),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getAccuracyIcon(animatedAccuracy),
                          color: Colors.white,
                          size: simplified ? 14 : 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: simplified ? 13 : 14,
                            shadows: simplified
                                ? const []
                                : const [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 3,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: trackWidth * 0.8 - 2,
                    top: 4,
                    bottom: 4,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: widget.festivalStyle != null
                            ? widget.festivalStyle!.thresholdLineColor
                                .withOpacity(
                                simplified ? 0.8 : 1.0,
                              )
                            : Colors.white.withOpacity(simplified ? 0.8 : 1.0),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: simplified
                            ? const []
                            : [
                                BoxShadow(
                                  color: widget.festivalStyle != null
                                      ? widget.festivalStyle!.thresholdLineColor
                                          .withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5),
                                  blurRadius: 2,
                                ),
                              ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.festivalStyle != null &&
            widget.festivalStyle!.cornerIcon.isNotEmpty)
          AnimatedPositioned(
            duration: simplified
                ? const Duration(milliseconds: 180)
                : const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            left: (progressWidth - 12).clamp(0.0, trackWidth),
            top: -14,
            child: _FloatingAccuracyIcon(
              icon: widget.festivalStyle!.cornerIcon,
              color: color,
            ),
          ),
      ],
    );
  }

  Color _getColorForAccuracy(double accuracy) {
    if (widget.festivalStyle != null) {
      if (accuracy >= 0.8) return widget.festivalStyle!.accuracyHighColor;
      if (accuracy >= 0.6) return widget.festivalStyle!.accuracyMidColor;
      return widget.festivalStyle!.accuracyLowColor;
    }
    if (accuracy >= 0.8) return const Color(0xFF4CAF50); // Green
    if (accuracy >= 0.6) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  IconData _getAccuracyIcon(double accuracy) {
    if (accuracy >= 0.8) return Icons.check_circle;
    if (accuracy >= 0.6) return Icons.warning;
    return Icons.error;
  }

  /// Builds evenly distributed stops for [count] gradient colors.
  static List<double> _buildEvenStops(int count) {
    if (count <= 1) return const [0.0];
    return List<double>.generate(
      count,
      (i) => i / (count - 1),
      growable: false,
    );
  }
}

class _FloatingAccuracyIcon extends StatefulWidget {
  final String icon;
  final Color color;

  const _FloatingAccuracyIcon({required this.icon, required this.color});

  @override
  State<_FloatingAccuracyIcon> createState() => _FloatingAccuracyIconState();
}

class _FloatingAccuracyIconState extends State<_FloatingAccuracyIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
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
        final floatOffset = -4.0 * _controller.value;
        return Transform.translate(
          offset: Offset(0, floatOffset), // bob up and down
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Premium Halo Glow behind the icon
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color
                          .withOpacity(0.4 + (0.2 * _controller.value)),
                      blurRadius: 10 + (5 * _controller.value),
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
              if (isPadaukBranchIcon(widget.icon))
                const PadaukBranchIcon(size: 24)
              else
                Text(
                  widget.icon,
                  style: TextStyle(
                    fontSize: 22,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
