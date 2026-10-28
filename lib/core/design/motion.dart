import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Spring presets. Values tuned to feel quick on 120Hz panels.
abstract final class Springs {
  static const snappy = SpringDescription(mass: 1, stiffness: 520, damping: 36);
  static const bouncy = SpringDescription(mass: 1, stiffness: 420, damping: 19);
  static const gentle = SpringDescription(mass: 1, stiffness: 240, damping: 26);
  static const rubber = SpringDescription(mass: 1, stiffness: 700, damping: 42);
}

/// A [Curve] driven by a spring simulation from 0 to 1. Allows overshoot.
class SpringCurve extends Curve {
  SpringCurve(SpringDescription spring, {this.settle = 0.6}) : _sim = SpringSimulation(spring, 0, 1, 0);

  final SpringSimulation _sim;

  /// Simulated seconds mapped onto t ∈ [0, 1].
  final double settle;

  @override
  double transformInternal(double t) => t >= 1 ? 1 : _sim.x(t * settle);
}

abstract final class Motion {
  static final springOut = SpringCurve(Springs.snappy);
  static final bounce = SpringCurve(Springs.bouncy, settle: 0.75);
  static final gentle = SpringCurve(Springs.gentle, settle: 0.9);

  static const fast = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 420);

  /// True when the user asked the OS to reduce motion.
  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Duration that collapses to zero when reduce-motion is on.
  static Duration of(BuildContext context, Duration d) => reduced(context) ? Duration.zero : d;
}

/// Rubber-band resistance used for over-drags (swipe-to-reply, swipe actions).
double rubberBand(double offset, double limit, {double c = 0.55}) {
  if (offset == 0) return 0;
  final sign = offset.sign;
  final x = offset.abs();
  return sign * (1 - (1 / ((x * c / limit) + 1))) * limit;
}
