import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../design/icons.dart';
import '../design/palette.dart';

/// Gradient progress ring whose value glides between updates.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress, this.size = 88, this.done = false});

  final double progress;
  final double size;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: progress),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(v, p.accent.gradient, p.surfaceRaised),
          child: Center(
            child: done
                ? Icon(AppIcons.check, color: p.primary, size: size * 0.34).animate().scale(curve: Curves.easeOutBack)
                : Text(
                    '${(v * 100).round()}',
                    style: context.text.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.colors, this.track);

  final double v;
  final List<Color> colors;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    canvas.drawArc(
      arc,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (v <= 0) return;
    canvas.drawArc(
      arc,
      -math.pi / 2,
      math.pi * 2 * v,
      false,
      Paint()
        ..shader = SweepGradient(
          colors: [...colors, colors.first],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.v != v || old.colors != colors;
}
