import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design/icons.dart';

/// Instagram-style double-tap heart: pops, wobbles and bursts into sparks.
class HeartBurst extends StatefulWidget {
  const HeartBurst({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<HeartBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final pop = Curves.elasticOut.transform((t / 0.55).clamp(0, 1));
          final fade = 1 - Curves.easeIn.transform(((t - 0.6) / 0.4).clamp(0, 1));
          return CustomPaint(
            painter: _SparkPainter(t),
            child: Center(
              child: Opacity(
                opacity: fade,
                child: Transform.scale(
                  scale: 0.2 + pop * 0.9,
                  child: Transform.rotate(
                    angle: math.sin(t * math.pi * 3) * 0.12 * (1 - t),
                    child: const Icon(
                      AppIcons.heartFill,
                      size: 64,
                      color: Color(0xFFFF3B5C),
                      shadows: [Shadow(color: Color(0x66FF3B5C), blurRadius: 24)],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t < 0.15) return;
    final p = ((t - 0.15) / 0.85).clamp(0.0, 1.0);
    final c = size.center(Offset.zero);
    final paint = Paint()..color = const Color(0xFFFF6B81).withValues(alpha: 1 - p);
    for (var i = 0; i < 10; i++) {
      final a = i / 10 * math.pi * 2;
      final r = 30 + Curves.easeOutCubic.transform(p) * 46;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, 3.4 * (1 - p) + 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.t != t;
}
