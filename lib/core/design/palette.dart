import 'package:flutter/material.dart';

import 'tokens.dart';

/// Semantic colours for the custom design system, exposed as a ThemeExtension.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.brightness,
    required this.accent,
    required this.bg,
    required this.surface,
    required this.surfaceRaised,
    required this.glassTint,
    required this.glassBorder,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.separator,
    required this.bubbleIn,
    required this.bubbleInText,
    required this.bubbleOutText,
    required this.success,
    required this.danger,
    required this.warning,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  factory Palette.of(Brightness b, AccentColor accent) {
    final dark = b == Brightness.dark;
    return Palette(
      brightness: b,
      accent: accent,
      bg: dark ? Brand.darkBg : Brand.lightBg,
      surface: dark ? const Color(0xFF13151C) : Colors.white,
      surfaceRaised: dark ? const Color(0xFF1B1E27) : const Color(0xFFF0F2F6),
      glassTint: dark ? const Color(0xB3121419) : const Color(0xC7FFFFFF),
      glassBorder: dark ? const Color(0x1FFFFFFF) : const Color(0x14000000),
      text: dark ? const Color(0xFFF3F5F9) : const Color(0xFF0E1116),
      textMuted: dark ? const Color(0xFF9BA4B4) : const Color(0xFF5E6775),
      textFaint: dark ? const Color(0xFF5F6878) : const Color(0xFF9AA2AF),
      separator: dark ? const Color(0x14FFFFFF) : const Color(0x0F000000),
      bubbleIn: dark ? const Color(0xFF1E222C) : Colors.white,
      bubbleInText: dark ? const Color(0xFFEFF2F7) : const Color(0xFF0E1116),
      bubbleOutText: Colors.white,
      success: const Color(0xFF2FBF71),
      danger: const Color(0xFFE5484D),
      warning: const Color(0xFFF0A63A),
      shimmerBase: dark ? const Color(0xFF181B23) : const Color(0xFFE9ECF1),
      shimmerHighlight: dark ? const Color(0xFF242833) : const Color(0xFFF7F8FA),
    );
  }

  final Brightness brightness;
  final AccentColor accent;
  final Color bg;
  final Color surface;
  final Color surfaceRaised;
  final Color glassTint;
  final Color glassBorder;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color separator;
  final Color bubbleIn;
  final Color bubbleInText;
  final Color bubbleOutText;
  final Color success;
  final Color danger;
  final Color warning;
  final Color shimmerBase;
  final Color shimmerHighlight;

  bool get isDark => brightness == Brightness.dark;
  Color get primary => accent.base;

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: accent.gradient,
      );

  @override
  Palette copyWith({AccentColor? accent}) => Palette.of(brightness, accent ?? this.accent);

  @override
  Palette lerp(Palette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      brightness: t < 0.5 ? brightness : other.brightness,
      accent: t < 0.5 ? accent : other.accent,
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      glassTint: l(glassTint, other.glassTint),
      glassBorder: l(glassBorder, other.glassBorder),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      textFaint: l(textFaint, other.textFaint),
      separator: l(separator, other.separator),
      bubbleIn: l(bubbleIn, other.bubbleIn),
      bubbleInText: l(bubbleInText, other.bubbleInText),
      bubbleOutText: l(bubbleOutText, other.bubbleOutText),
      success: l(success, other.success),
      danger: l(danger, other.danger),
      warning: l(warning, other.warning),
      shimmerBase: l(shimmerBase, other.shimmerBase),
      shimmerHighlight: l(shimmerHighlight, other.shimmerHighlight),
    );
  }
}

extension PaletteContext on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
