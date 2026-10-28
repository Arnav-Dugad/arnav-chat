import 'package:flutter/services.dart';

abstract final class Haptics {
  static void tap() => HapticFeedback.lightImpact();
  static void select() => HapticFeedback.selectionClick();
  static void tick() => HapticFeedback.selectionClick();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void success() => HapticFeedback.mediumImpact();
}
