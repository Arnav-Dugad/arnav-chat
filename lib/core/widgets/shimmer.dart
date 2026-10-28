import 'package:flutter/material.dart';

import '../design/palette.dart';
import '../design/tokens.dart';

/// One shared animation sweeps a highlight across every skeleton below it.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            final dx = (_c.value * 2.4 - 1.2) * rect.width;
            return LinearGradient(
              colors: [p.shimmerBase, p.shimmerHighlight, p.shimmerBase],
              stops: const [0.35, 0.5, 0.65],
              transform: _Slide(dx),
            ).createShader(rect);
          },
          child: child,
        ),
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.dx);
  final double dx;
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(dx, 0, 0);
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = Radii.xs, this.circle = false});

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
        width: circle ? height : width,
        height: height,
        decoration: BoxDecoration(
          color: context.palette.shimmerBase,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
      );
}

/// Skeleton rows matching the chat list layout exactly (no layout shift).
class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) => Shimmer(
        child: Column(
          children: [
            for (var i = 0; i < count; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gaps.x4, vertical: 10),
                child: Row(
                  children: [
                    const SkeletonBox(height: 54, circle: true),
                    const SizedBox(width: Gaps.x3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 120.0 + (i * 37 % 80), height: 14),
                          const SizedBox(height: 8),
                          SkeletonBox(width: 180.0 + (i * 53 % 90), height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}
