import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../design/haptics.dart';
import '../design/motion.dart';

class SwipeAction {
  const SwipeAction({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

/// Row with elastic swipe actions on both sides. Actions grow with the drag,
/// a full swipe fires the outermost action (with a haptic tick at the
/// threshold), and everything settles on a spring.
class SwipeActions extends StatefulWidget {
  const SwipeActions({super.key, required this.child, this.leading = const [], this.trailing = const []});

  final Widget child;
  final List<SwipeAction> leading;
  final List<SwipeAction> trailing;

  @override
  State<SwipeActions> createState() => _SwipeActionsState();
}

class _SwipeActionsState extends State<SwipeActions> with SingleTickerProviderStateMixin {
  static const _actionWidth = 76.0;
  late final AnimationController _c = AnimationController.unbounded(vsync: this);
  bool _pastFull = false;

  double get _leadingMax => widget.leading.length * _actionWidth;
  double get _trailingMax => widget.trailing.length * _actionWidth;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _onUpdate(DragUpdateDetails d, double width) {
    var next = _c.value + d.delta.dx;
    if (widget.leading.isEmpty && next > 0) next = 0;
    if (widget.trailing.isEmpty && next < 0) next = 0;
    // Rubber-band beyond the revealed width.
    final max = next > 0 ? _leadingMax : _trailingMax;
    if (next.abs() > max) {
      final over = next.abs() - max;
      next = next.sign * (max + rubberBand(over, width * 0.5, c: 0.9));
    }
    _c.value = next;
    final full = next.abs() > width * 0.55;
    if (full != _pastFull) {
      _pastFull = full;
      Haptics.tick();
    }
  }

  void _settle(double target, double velocity) {
    _c.animateWith(SpringSimulation(Springs.snappy, _c.value, target, velocity));
  }

  void _onEnd(DragEndDetails d, double width) {
    final v = d.velocity.pixelsPerSecond.dx;
    final x = _c.value;
    if (_pastFull) {
      _pastFull = false;
      final action = x > 0 ? widget.leading.first : widget.trailing.last;
      _settle(0, v);
      action.onTap();
      return;
    }
    if (x > 0) {
      _settle((x > _leadingMax / 2 || v > 600) && v > -600 ? _leadingMax : 0, v);
    } else {
      _settle((x < -_trailingMax / 2 || v < -600) && v < 600 ? -_trailingMax : 0, v);
    }
  }

  void close() => _settle(0, 0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (d) => _onUpdate(d, width),
          onHorizontalDragEnd: (d) => _onEnd(d, width),
          child: AnimatedBuilder(
            animation: _c,
            child: widget.child,
            builder: (context, child) {
              final x = _c.value;
              return Stack(
                children: [
                  if (x > 0)
                    Positioned.fill(
                      child: _ActionStrip(
                        actions: widget.leading,
                        extent: x,
                        leading: true,
                        full: _pastFull,
                        onTapped: close,
                      ),
                    ),
                  if (x < 0)
                    Positioned.fill(
                      child: _ActionStrip(
                        actions: widget.trailing,
                        extent: -x,
                        leading: false,
                        full: _pastFull,
                        onTapped: close,
                      ),
                    ),
                  Transform.translate(offset: Offset(x, 0), child: child),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({
    required this.actions,
    required this.extent,
    required this.leading,
    required this.full,
    required this.onTapped,
  });

  final List<SwipeAction> actions;
  final double extent;
  final bool leading;
  final bool full;
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    final each = extent / actions.length;
    final children = <Widget>[
      for (final (i, a) in actions.indexed)
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: full ? (i == (leading ? 0 : actions.length - 1) ? extent : 0) : each,
          color: a.color,
          child: ClipRect(
            child: OverflowBox(
              maxWidth: 76,
              child: Semantics(
                button: true,
                label: a.label,
                child: GestureDetector(
                  onTap: () {
                    Haptics.tap();
                    onTapped();
                    a.onTap();
                  },
                  child: SizedBox(
                    width: 76,
                    height: double.infinity,
                    child: Transform.scale(
                      scale: (each / 76).clamp(0.4, 1.15),
                      child: Icon(a.icon, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
    return Row(mainAxisAlignment: leading ? MainAxisAlignment.start : MainAxisAlignment.end, children: children);
  }
}
