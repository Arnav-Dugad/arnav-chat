import 'package:flutter/widgets.dart';

/// User-selectable accent colours. Sapphire is the brand default.
enum AccentColor {
  sapphire(Color(0xFF2F5BEA), Color(0xFF27B4D9)),
  lagoon(Color(0xFF0E8C94), Color(0xFF3CCFB4)),
  emerald(Color(0xFF15946A), Color(0xFF7BCB5A)),
  amber(Color(0xFFD9861C), Color(0xFFF2C14E)),
  coral(Color(0xFFE0525F), Color(0xFFF59E6C)),
  graphite(Color(0xFF3B4352), Color(0xFF7A8699));

  const AccentColor(this.base, this.end);

  final Color base;
  final Color end;

  List<Color> get gradient => [base, end];

  static AccentColor fromName(String? name) =>
      AccentColor.values.firstWhere((a) => a.name == name, orElse: () => AccentColor.sapphire);
}

abstract final class Radii {
  static const xs = 10.0;
  static const sm = 14.0;
  static const md = 20.0;
  static const lg = 24.0;
  static const xl = 28.0;
  static const bubble = 22.0;
  static const pill = 999.0;
}

abstract final class Gaps {
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
  static const x10 = 40.0;
}

abstract final class Brand {
  static const navy = Color(0xFF0D1A4A);
  static const sapphire = Color(0xFF2350E6);
  static const cyan = Color(0xFF27C1D9);
  static const gradient = [navy, sapphire, cyan];
  static const darkBg = Color(0xFF0A0B10);
  static const lightBg = Color(0xFFF6F7FA);
}
