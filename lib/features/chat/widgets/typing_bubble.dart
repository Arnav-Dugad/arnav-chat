import 'package:flutter/material.dart';

import '../../../core/design/palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/dots_loader.dart';

/// Incoming-side bubble that morphs open (size + corner) and bounces 3 dots.
class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      liveRegion: true,
      label: visible ? 'Typing' : null,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        alignment: Alignment.bottomLeft,
        child: !visible
            ? const SizedBox(width: double.infinity)
            : Align(
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.3, end: 1),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.elasticOut,
                  builder: (context, t, child) =>
                      Transform.scale(alignment: Alignment.bottomLeft, scale: t, child: child),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(Gaps.x3, 4, 0, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: ShapeDecoration(
                      color: p.bubbleIn,
                      shape: const RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(Radii.bubble),
                          topRight: Radius.circular(Radii.bubble),
                          bottomRight: Radius.circular(Radii.bubble),
                          bottomLeft: Radius.circular(6),
                        ),
                      ),
                    ),
                    child: DotsLoader(color: p.textMuted, size: 7, gap: 4, amplitude: 4),
                  ),
                ),
              ),
      ),
    );
  }
}
