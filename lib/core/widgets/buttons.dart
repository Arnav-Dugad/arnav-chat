import 'package:flutter/material.dart';

import '../design/palette.dart';
import '../design/tokens.dart';
import 'dots_loader.dart';
import 'glass.dart';
import 'pressable.dart';

enum PillStyle { primary, secondary, ghost, danger }

/// Pill-shaped button. Shows bouncing dots instead of a spinner while busy.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.style = PillStyle.primary,
    this.busy = false,
    this.expand = true,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PillStyle style;
  final bool busy;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onPressed != null && !busy;
    final fg = switch (style) {
      PillStyle.primary => Colors.white,
      PillStyle.danger => p.danger,
      _ => p.text,
    };
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: busy
          ? [DotsLoader(color: fg)]
          : [
              if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 10)],
              Text(label, style: context.text.labelLarge?.copyWith(color: fg)),
            ],
    );

    final Widget body = switch (style) {
      PillStyle.primary => DecoratedBox(
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          gradient: p.accentGradient,
          shadows: [
            BoxShadow(
              color: p.primary.withValues(alpha: 0.32),
              blurRadius: 22,
              offset: const Offset(0, 8),
              spreadRadius: -6,
            ),
          ],
        ),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.x6),
            child: content,
          ),
        ),
      ),
      PillStyle.secondary => Glass(
        pill: true,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.x6),
            child: content,
          ),
        ),
      ),
      _ => SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.x4),
          child: content,
        ),
      ),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: onPressed == null ? 0.45 : 1,
        child: Pressable(onTap: enabled ? onPressed : null, haptic: true, child: body),
      ),
    );
  }
}

/// Round glass icon button (app bar actions, input bar).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.size = 40,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String label;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onPressed,
    haptic: true,
    semanticLabel: label,
    scale: 0.9,
    child: SizedBox.square(
      dimension: size,
      child: Icon(icon, size: size * 0.55, color: color ?? context.palette.text),
    ),
  );
}
