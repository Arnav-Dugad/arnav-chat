import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../design/palette.dart';
import '../design/tokens.dart';

/// Small illustration + at most three words.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.label, this.action});

  final IconData icon;
  final String label;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [p.primary.withValues(alpha: 0.18), p.primary.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: ShapeDecoration(
                        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.md)),
                        gradient: p.accentGradient,
                      ),
                      child: Icon(icon, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -6, duration: 1800.ms, curve: Curves.easeInOut),
          const SizedBox(height: Gaps.x4),
          Text(label, style: context.text.titleSmall?.copyWith(color: p.textMuted)),
          if (action != null) ...[const SizedBox(height: Gaps.x5), action!],
        ],
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack),
    );
  }
}
