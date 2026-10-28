import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Delete animation: the bubble shrinks and fades while a cloud of particles
/// in the bubble's colour drifts up and away.
class Dissolve extends StatefulWidget {
  const Dissolve({super.key, required this.child, required this.color, required this.onDone});

  final Widget child;
  final Color color;
  final VoidCallback onDone;

  @override
  State<Dissolve> createState() => _DissolveState();
}

class _DissolveState extends State<Dissolve> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  final _particles = List.generate(70, (i) => _Particle(math.Random(i)));

  @override
  void initState() {
    super.initState();
    if (WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone());
    } else {
      _c.forward().whenComplete(widget.onDone);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, child) {
      final t = _c.value;
      return CustomPaint(
        foregroundPainter: _ParticlePainter(t, _particles, widget.color),
        child: Opacity(
          opacity: (1 - t * 2.2).clamp(0, 1),
          child: Transform.scale(scale: 1 - 0.15 * t, child: child),
        ),
      );
    },
    child: widget.child,
  );
}

class _Particle {
  _Particle(math.Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      dx = (r.nextDouble() - 0.5) * 60,
      dy = -20 - r.nextDouble() * 70,
      size = 1.2 + r.nextDouble() * 2.6,
      delay = r.nextDouble() * 0.35;

  final double x, y, dx, dy, size, delay;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.t, this.particles, this.color);

  final double t;
  final List<_Particle> particles;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0) return;
    final paint = Paint();
    for (final p in particles) {
      final lt = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (lt <= 0) continue;
      final e = Curves.easeOutCubic.transform(lt);
      paint.color = color.withValues(alpha: (1 - lt) * 0.9);
      canvas.drawCircle(
        Offset(p.x * size.width + p.dx * e, p.y * size.height + p.dy * e),
        p.size * (1 - lt * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}
