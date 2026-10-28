import 'package:flutter/material.dart';

import '../design/palette.dart';

/// Unread counter that pops in/out and rolls its digits when the count changes.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, this.muted = false});

  final int count;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final label = count > 99 ? '99+' : '$count';
    return AnimatedScale(
      scale: count > 0 ? 1 : 0,
      duration: const Duration(milliseconds: 320),
      curve: count > 0 ? Curves.easeOutBack : Curves.easeIn,
      child: Container(
        constraints: const BoxConstraints(minWidth: 22),
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: muted ? p.textFaint : null,
          gradient: muted ? null : p.accentGradient,
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          transitionBuilder: (child, a) => SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.6),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: a, child: child),
          ),
          child: Text(
            label,
            key: ValueKey(label),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          ),
        ),
      ),
    );
  }
}
