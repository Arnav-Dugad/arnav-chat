import 'dart:ui';

import 'package:flutter/material.dart';

import '../design/palette.dart';
import '../design/tokens.dart';

/// Frosted glass surface: backdrop blur + translucent tint + 1px light border.
///
/// Wrapped in a [RepaintBoundary] so the blur only re-rasterises when the
/// content behind it changes. Prefer few, large glass layers over many small.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = Radii.lg,
    this.blur = 28,
    this.tint,
    this.padding,
    this.border = true,
    this.pill = false,
  });

  final Widget child;
  final double radius;
  final double blur;
  final Color? tint;
  final EdgeInsetsGeometry? padding;
  final bool border;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final side = border ? BorderSide(color: p.glassBorder, width: 1) : BorderSide.none;
    final ShapeBorder shape = pill
        ? StadiumBorder(side: side)
        : RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(radius), side: side);
    final content = DecoratedBox(
      decoration: ShapeDecoration(color: tint ?? p.glassTint, shape: shape),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
    final filtered = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: content,
    );
    return RepaintBoundary(
      child: pill
          ? ClipPath(
              clipper: const ShapeBorderClipper(shape: StadiumBorder()),
              child: filtered,
            )
          : ClipRSuperellipse(borderRadius: BorderRadius.circular(radius), child: filtered),
    );
  }
}

/// Glass bar that spans the full width (app bars, bottom bars).
class GlassBar extends StatelessWidget {
  const GlassBar({super.key, required this.child, this.top = false});

  final Widget child;

  /// Border on the bottom edge when placed at the top, else on the top edge.
  final bool top;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final edge = BorderSide(color: p.glassBorder, width: 0.6);
    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: p.glassTint,
              border: top ? Border(bottom: edge) : Border(top: edge),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Squircle (continuous corner) clip + optional fill. Used for cards.
class Squircle extends StatelessWidget {
  const Squircle({super.key, required this.child, this.radius = Radii.lg, this.color, this.border});

  final Widget child;
  final double radius;
  final Color? color;
  final BorderSide? border;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedSuperellipseBorder(borderRadius: r, side: border ?? BorderSide.none),
      ),
      child: ClipRSuperellipse(borderRadius: r, child: child),
    );
  }
}
