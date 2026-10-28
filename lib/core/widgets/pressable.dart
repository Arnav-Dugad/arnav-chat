import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../design/haptics.dart';
import '../design/motion.dart';

/// Press-and-scale feedback driven by a spring. Replaces ink ripples.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.scale = 0.965,
    this.haptic = false,
    this.semanticLabel,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final double scale;
  final bool haptic;
  final String? semanticLabel;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController.unbounded(vsync: this, value: 1);

  void _to(double target) {
    if (Motion.reduced(context)) {
      _c.value = target;
      return;
    }
    _c.animateWith(SpringSimulation(Springs.snappy, _c.value, target, _c.velocity));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null || widget.onDoubleTap != null;
    return Semantics(
      button: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: enabled ? (_) => _to(widget.scale) : null,
        onTapUp: enabled ? (_) => _to(1) : null,
        onTapCancel: enabled ? () => _to(1) : null,
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.haptic) Haptics.tap();
                widget.onTap!();
              },
        onDoubleTap: widget.onDoubleTap,
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _to(1);
                Haptics.medium();
                widget.onLongPress!();
              },
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) => Transform.scale(scale: _c.value, child: child),
          child: widget.child,
        ),
      ),
    );
  }
}
