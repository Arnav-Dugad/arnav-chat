import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/design/tokens.dart';
import '../../data/providers.dart';

part 'appearance_controller.g.dart';

@immutable
class Appearance {
  const Appearance({this.mode = ThemeMode.system, this.accent = AccentColor.sapphire});

  final ThemeMode mode;
  final AccentColor accent;
}

@Riverpod(keepAlive: true)
class AppearanceController extends _$AppearanceController {
  static const _modeKey = 'appearance.mode';
  static const _accentKey = 'appearance.accent';

  @override
  Appearance build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return Appearance(
      mode: ThemeMode.values.firstWhere((m) => m.name == prefs.getString(_modeKey), orElse: () => ThemeMode.system),
      accent: AccentColor.fromName(prefs.getString(_accentKey)),
    );
  }

  void setMode(ThemeMode mode) {
    ref.read(sharedPrefsProvider).setString(_modeKey, mode.name);
    state = Appearance(mode: mode, accent: state.accent);
  }

  void setAccent(AccentColor accent) {
    ref.read(sharedPrefsProvider).setString(_accentKey, accent.name);
    state = Appearance(mode: state.mode, accent: accent);
  }
}
