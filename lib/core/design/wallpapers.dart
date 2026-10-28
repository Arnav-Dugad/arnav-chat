import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'palette.dart';

/// Built-in chat wallpapers. Painted (not images) so they cost no download,
/// stay crisp at any density and adapt to light/dark.
enum Wallpaper {
  glow('Glow'),
  aurora('Aurora'),
  dusk('Dusk'),
  ocean('Ocean'),
  forest('Forest'),
  dots('Dots'),
  grid('Grid'),
  plain('Plain');

  const Wallpaper(this.label);
  final String label;

  static Wallpaper fromName(String? n) => Wallpaper.values.firstWhere((w) => w.name == n, orElse: () => Wallpaper.glow);
}

class ChatWallpaper extends StatelessWidget {
  const ChatWallpaper({super.key, required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: _WallpaperPainter(wallpaper, context.palette), size: Size.infinite),
  );
}

class _WallpaperPainter extends CustomPainter {
  _WallpaperPainter(this.w, this.p);

  final Wallpaper w;
  final Palette p;

  void _radial(Canvas c, Rect r, Alignment center, double radius, Color color) => c.drawRect(
    r,
    Paint()
      ..shader = RadialGradient(
        center: center,
        radius: radius,
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(r),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..color = p.bg);
    final a = p.isDark ? 1.0 : 0.7;
    switch (w) {
      case Wallpaper.plain:
        break;
      case Wallpaper.glow:
        _radial(canvas, r, const Alignment(0.9, -1.1), 1.4, p.primary.withValues(alpha: 0.10 * a));
      case Wallpaper.aurora:
        _radial(canvas, r, const Alignment(-0.8, -0.9), 1.0, p.accent.base.withValues(alpha: 0.22 * a));
        _radial(canvas, r, const Alignment(1.0, 0.1), 0.9, p.accent.end.withValues(alpha: 0.18 * a));
        _radial(canvas, r, const Alignment(-0.3, 1.2), 1.0, p.accent.base.withValues(alpha: 0.14 * a));
      case Wallpaper.dusk:
        canvas.drawRect(
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF3B1F5C).withValues(alpha: 0.55 * a), const Color(0xFFE0525F).withValues(alpha: 0.18 * a)],
            ).createShader(r),
        );
      case Wallpaper.ocean:
        canvas.drawRect(
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF0B3D5C).withValues(alpha: 0.6 * a), const Color(0xFF27C1D9).withValues(alpha: 0.18 * a)],
            ).createShader(r),
        );
      case Wallpaper.forest:
        canvas.drawRect(
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF0F3D2E).withValues(alpha: 0.6 * a), const Color(0xFF7BCB5A).withValues(alpha: 0.14 * a)],
            ).createShader(r),
        );
      case Wallpaper.dots:
        _radial(canvas, r, const Alignment(0.9, -1.1), 1.4, p.primary.withValues(alpha: 0.08 * a));
        final paint = Paint()..color = p.text.withValues(alpha: p.isDark ? 0.06 : 0.07);
        const step = 22.0;
        for (var y = 0.0; y < size.height; y += step) {
          final offset = (y / step).floor().isEven ? 0.0 : step / 2;
          for (var x = offset; x < size.width; x += step) {
            canvas.drawCircle(Offset(x, y), 1.4, paint);
          }
        }
      case Wallpaper.grid:
        final paint = Paint()
          ..color = p.text.withValues(alpha: p.isDark ? 0.05 : 0.06)
          ..strokeWidth = 0.7;
        const step = 28.0;
        for (var x = 0.0; x < size.width; x += step) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (var y = 0.0; y < size.height; y += step) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        _radial(canvas, r, Alignment(math.cos(1.0) * 0.8, -1), 1.2, p.primary.withValues(alpha: 0.10 * a));
    }
  }

  @override
  bool shouldRepaint(_WallpaperPainter old) => old.w != w || old.p != p;
}
