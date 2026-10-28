import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'palette.dart';
import 'tokens.dart';

abstract final class AppTheme {
  static const font = 'Inter';

  static ThemeData build(Brightness brightness, AccentColor accent) {
    final p = Palette.of(brightness, accent);
    final scheme = ColorScheme.fromSeed(
      seedColor: accent.base,
      brightness: brightness,
    ).copyWith(primary: accent.base, onPrimary: Colors.white, surface: p.surface, onSurface: p.text, error: p.danger);

    final text = _textTheme(p);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: font,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      textTheme: text,
      extensions: [p],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      dividerColor: p.separator,
      iconTheme: IconThemeData(color: p.text, size: 24),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent.base,
        selectionColor: accent.base.withValues(alpha: 0.28),
        selectionHandleColor: accent.base,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleMedium,
        foregroundColor: p.text,
        systemOverlayStyle: overlayStyle(brightness),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          // iOS-style parallax slide + interactive back swipe everywhere.
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
        },
      ),
      cupertinoOverrideTheme: CupertinoThemeData(brightness: brightness, primaryColor: accent.base),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent.base : p.surfaceRaised,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.isDark ? const Color(0xFF262A35) : const Color(0xFF1B1E26),
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        shape: const StadiumBorder(),
        elevation: 0,
      ),
    );
  }

  static SystemUiOverlayStyle overlayStyle(Brightness b) => SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    statusBarIconBrightness: b == Brightness.dark ? Brightness.light : Brightness.dark,
    statusBarBrightness: b,
    systemNavigationBarIconBrightness: b == Brightness.dark ? Brightness.light : Brightness.dark,
  );

  static TextTheme _textTheme(Palette p) {
    TextStyle s(double size, FontWeight w, double tracking, {double height = 1.3, Color? c}) => TextStyle(
      fontFamily: font,
      fontSize: size,
      fontWeight: w,
      letterSpacing: tracking,
      height: height,
      color: c ?? p.text,
    );
    return TextTheme(
      displaySmall: s(32, FontWeight.w700, -0.9, height: 1.12),
      headlineSmall: s(26, FontWeight.w700, -0.6, height: 1.15),
      titleLarge: s(22, FontWeight.w700, -0.45, height: 1.2),
      titleMedium: s(17, FontWeight.w600, -0.25),
      titleSmall: s(15, FontWeight.w600, -0.15),
      bodyLarge: s(16, FontWeight.w400, -0.2, height: 1.38),
      bodyMedium: s(15, FontWeight.w400, -0.15, height: 1.36),
      bodySmall: s(13, FontWeight.w400, -0.05, c: p.textMuted),
      labelLarge: s(15, FontWeight.w600, -0.15),
      labelMedium: s(13, FontWeight.w500, -0.05, c: p.textMuted),
      labelSmall: s(11.5, FontWeight.w600, 0.1, c: p.textMuted),
    );
  }
}

/// Default radius used on cards and sheets.
const kCardRadius = BorderRadius.all(Radius.circular(Radii.lg));

/// Emoji glyphs must come from the colour emoji font: Inter has a monochrome
/// U+2764 (heart) that would otherwise win.
const kEmojiFonts = ['Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji'];
TextStyle emojiStyle(double size) =>
    TextStyle(fontSize: size, fontFamily: kEmojiFonts.first, fontFamilyFallback: kEmojiFonts, height: 1.1);
