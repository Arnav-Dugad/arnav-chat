import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';

/// iOS-style large title that collapses into a frosted compact bar.
class LargeTitleHeader extends StatelessWidget {
  const LargeTitleHeader({super.key, required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(title: title, actions: actions, topPadding: top),
    );
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  _Delegate({required this.title, required this.actions, required this.topPadding});

  final String title;
  final List<Widget> actions;
  final double topPadding;

  static const _compact = 52.0;
  static const _large = 104.0;

  @override
  double get minExtent => topPadding + _compact;

  @override
  double get maxExtent => topPadding + _large;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final p = context.palette;
    final t = (shrinkOffset / (_large - _compact)).clamp(0.0, 1.0);
    final glass = (shrinkOffset > 0 || overlapsContent) ? ((shrinkOffset) / 24).clamp(0.0, 1.0) : 0.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (glass > 0)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30 * glass, sigmaY: 30 * glass),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: p.glassTint.withValues(alpha: p.glassTint.a * glass),
                  border: Border(
                    bottom: BorderSide(color: p.glassBorder.withValues(alpha: p.glassBorder.a * glass), width: 0.6),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: topPadding,
          left: 0,
          right: 0,
          height: _compact,
          child: Row(
            children: [
              const SizedBox(width: Gaps.x4),
              Expanded(
                child: Opacity(
                  opacity: Curves.easeIn.transform(((t - 0.6) / 0.4).clamp(0, 1)),
                  child: Center(child: Text(title, style: context.text.titleMedium)),
                ),
              ),
              ...actions,
              const SizedBox(width: Gaps.x2),
            ],
          ),
        ),
        Positioned(
          left: Gaps.x5,
          bottom: 8,
          child: Opacity(
            opacity: 1 - Curves.easeOut.transform((t / 0.6).clamp(0, 1)),
            child: Transform.scale(
              alignment: Alignment.bottomLeft,
              scale: 1 - 0.1 * t,
              child: Text(title, style: context.text.displaySmall),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_Delegate old) => old.title != title || old.actions != actions || old.topPadding != topPadding;
}
