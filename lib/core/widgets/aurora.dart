import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/palette.dart';

/// Slow-drifting soft colour fields behind glass (auth/onboarding backdrop).
class Aurora extends StatefulWidget {
  const Aurora({super.key});

  @override
  State<Aurora> createState() => _AuroraState();
}

class _AuroraState extends State<Aurora> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _AuroraPainter(reduced ? 0 : _c.value, p.accent.gradient, p.bg, p.isDark),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t, this.colors, this.bg, this.dark);

  final double t;
  final List<Color> colors;
  final Color bg;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    final a = t * math.pi * 2;
    final blobs = [
      (Offset(size.width * (0.2 + 0.12 * math.sin(a)), size.height * (0.18 + 0.06 * math.cos(a))), colors.first, 0.75),
      (
        Offset(size.width * (0.85 + 0.1 * math.cos(a * 1.3)), size.height * (0.32 + 0.08 * math.sin(a))),
        colors.last,
        0.6,
      ),
      (
        Offset(size.width * (0.5 + 0.15 * math.sin(a * 0.7)), size.height * (0.95 + 0.05 * math.cos(a))),
        colors.first,
        0.7,
      ),
    ];
    for (final (c, color, r) in blobs) {
      final radius = size.width * r;
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: dark ? 0.38 : 0.26),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t || old.colors != colors || old.bg != bg;
}
