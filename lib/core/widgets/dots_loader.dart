import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Three smoothly bouncing dots. Used for busy buttons and the typing bubble.
class DotsLoader extends StatefulWidget {
  const DotsLoader({super.key, required this.color, this.size = 7, this.gap = 5, this.amplitude = 4});

  final Color color;
  final double size;
  final double gap;
  final double amplitude;

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[if (i > 0) SizedBox(width: widget.gap), _dot(i, reduced)],
          ],
        ),
      ),
    );
  }

  Widget _dot(int i, bool reduced) {
    final phase = (_c.value - i * 0.16) % 1.0;
    // A smooth hump in the first 55% of the cycle, rest in the remainder.
    final t = phase < 0.55 ? math.sin(phase / 0.55 * math.pi) : 0.0;
    return Transform.translate(
      offset: Offset(0, reduced ? 0 : -widget.amplitude * t),
      child: Opacity(
        opacity: 0.45 + 0.55 * t,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
