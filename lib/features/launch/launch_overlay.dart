import 'package:flutter/material.dart';

import '../../core/design/palette.dart';
import '../../core/widgets/logo.dart';

/// Continues the native splash, then morphs the logo into the app: the
/// gradient squircle zooms through the screen and becomes a window onto the
/// chat list underneath.
class LaunchOverlay extends StatefulWidget {
  const LaunchOverlay({super.key, required this.ready, required this.child});

  final bool ready;
  final Widget child;

  @override
  State<LaunchOverlay> createState() => _LaunchOverlayState();
}

class _LaunchOverlayState extends State<LaunchOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 820));
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) setState(() => _done = true);
    });
    if (widget.ready) _start();
  }

  @override
  void didUpdateWidget(LaunchOverlay old) {
    super.didUpdateWidget(old);
    if (widget.ready && !old.ready) _start();
  }

  void _start() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        setState(() => _done = true);
      } else {
        _c.forward();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;
    final bg = context.palette.bg;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(painter: _ZoomThroughPainter(_c.value, bg)),
          ),
        ),
      ],
    );
  }
}

class _ZoomThroughPainter extends CustomPainter {
  _ZoomThroughPainter(this.t, this.bg);

  final double t;
  final Color bg;

  static const _logo = 112.0;

  @override
  void paint(Canvas canvas, Size size) {
    // 0 → 0.22: anticipation (shrink a touch). 0.22 → 1: zoom through.
    final anticipate = Curves.easeInOut.transform((t / 0.22).clamp(0, 1));
    final zoomT = Curves.easeInCubic.transform(((t - 0.22) / 0.78).clamp(0, 1));
    final scale = (1 - 0.1 * anticipate) * (1 + zoomT * 22);
    final side = _logo * scale;
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: side, height: side);

    final hole = LogoPainter.squircle(Size.square(side)).shift(rect.topLeft);
    final screen = Path()..addRect(Offset.zero & size);
    final bgOpacity = (1 - ((t - 0.75) / 0.25).clamp(0.0, 1.0));
    canvas.drawPath(
      Path.combine(PathOperation.difference, screen, hole),
      Paint()..color = bg.withValues(alpha: bgOpacity),
    );

    // The logo itself fades as it grows, revealing the app through the hole.
    final logoOpacity = 1 - ((t - 0.3) / 0.35).clamp(0.0, 1.0);
    if (logoOpacity > 0) {
      canvas.saveLayer(rect, Paint()..color = Color.fromRGBO(0, 0, 0, logoOpacity));
      canvas.translate(rect.left, rect.top);
      LogoPainter().paint(canvas, Size.square(side));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ZoomThroughPainter old) => old.t != t || old.bg != bg;
}
