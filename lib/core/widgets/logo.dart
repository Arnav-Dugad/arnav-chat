import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// The Arnav Chat mark, drawn in code so it can be animated (launch morph,
/// pull-to-refresh). Geometry mirrors assets/brand/logo.svg (1024 units).
class LogoMark extends StatelessWidget {
  const LogoMark({
    super.key,
    this.size = 96,
    this.withBackground = true,
    this.markColor = Colors.white,
    this.progress = 1,
  });

  final double size;
  final bool withBackground;
  final Color markColor;

  /// 0..1 — how much of the "A" stroke is drawn (used by pull-to-refresh).
  final double progress;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: LogoPainter(withBackground: withBackground, markColor: markColor, progress: progress),
    ),
  );
}

class LogoPainter extends CustomPainter {
  LogoPainter({this.withBackground = true, this.markColor = Colors.white, this.progress = 1, this.markScale = 0.78});

  final bool withBackground;
  final Color markColor;
  final double progress;
  final double markScale;

  static Path squircle(Size size, {double n = 5}) {
    final r = size.width / 2;
    final path = Path();
    const steps = 160;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps * math.pi * 2;
      final c = math.cos(t), s = math.sin(t);
      final x = r + r * c.sign * math.pow(c.abs(), 2 / n);
      final y = r + r * s.sign * math.pow(s.abs(), 2 / n);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  /// Union of circle + tail. Combined explicitly: their opposite winding
  /// would otherwise punch a hole where they overlap.
  static Path bubble() => Path.combine(
    PathOperation.union,
    Path()..addOval(Rect.fromCircle(center: const Offset(512, 488), radius: 318)),
    Path()
      ..moveTo(232, 560)
      ..cubicTo(230, 700, 232, 800, 176, 852)
      ..cubicTo(278, 858, 362, 828, 440, 768)
      ..close(),
  );

  static Path letterA() => Path()
    ..moveTo(400, 650)
    ..lineTo(512, 360)
    ..lineTo(624, 650);

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 1024;
    if (withBackground) {
      final sq = squircle(size);
      canvas.drawPath(
        sq,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Brand.gradient,
            stops: [0, 0.55, 1],
          ).createShader(Offset.zero & size),
      );
      canvas.drawPath(
        sq,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.44, -0.64),
            radius: 0.75,
            colors: [const Color(0xFF9FD8FF).withValues(alpha: 0.16), const Color(0x00FFFFFF)],
          ).createShader(Offset.zero & size),
      );
    }

    canvas.save();
    final s = (withBackground ? markScale : 1.0) * unit;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);
    canvas.translate(-512, withBackground ? -505 : -512);

    canvas.saveLayer(const Rect.fromLTWH(0, 0, 1024, 1024), Paint());
    canvas.drawPath(bubble(), Paint()..color = markColor);
    final cut = Paint()
      ..blendMode = BlendMode.dstOut
      ..style = PaintingStyle.stroke
      ..strokeWidth = 74
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final a = letterA();
    if (progress >= 1) {
      canvas.drawPath(a, cut);
    } else {
      for (final m in a.computeMetrics()) {
        canvas.drawPath(m.extractPath(0, m.length * progress.clamp(0, 1)), cut);
      }
    }
    if (progress > 0.85) {
      canvas.drawCircle(
        const Offset(512, 574),
        29 * ((progress - 0.85) / 0.15).clamp(0, 1),
        Paint()..blendMode = BlendMode.dstOut,
      );
    }
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(LogoPainter old) =>
      old.progress != progress || old.markColor != markColor || old.withBackground != withBackground;
}
