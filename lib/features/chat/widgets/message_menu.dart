import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/design/haptics.dart';
import '../../../core/design/palette.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/pressable.dart';

const kQuickReactions = ['❤️', '😂', '😮', '😢', '🙏', '👍'];

class MenuAction {
  const MenuAction(this.id, this.label, this.icon, {this.destructive = false});
  final String id;
  final String label;
  final IconData icon;
  final bool destructive;
}

sealed class MenuResult {
  const MenuResult();
}

class ReactResult extends MenuResult {
  const ReactResult(this.emoji);
  final String emoji;
}

class ActionResult extends MenuResult {
  const ActionResult(this.id);
  final String id;
}

/// iMessage/Telegram-style context menu: the screen blurs, the bubble lifts
/// in place, the reaction bar pops in above it and actions unfold below.
Future<MenuResult?> showMessageMenu(
  BuildContext context, {
  required GlobalKey bubbleKey,
  required Widget bubble,
  required bool mine,
  required List<MenuAction> actions,
  String? myReaction,
}) {
  final box = bubbleKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return Future.value();
  final rect = box.localToGlobal(Offset.zero) & box.size;
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<MenuResult>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, a, _) =>
          _MessageMenu(animation: a, rect: rect, bubble: bubble, mine: mine, actions: actions, myReaction: myReaction),
    ),
  );
}

class _MessageMenu extends StatelessWidget {
  const _MessageMenu({
    required this.animation,
    required this.rect,
    required this.bubble,
    required this.mine,
    required this.actions,
    this.myReaction,
  });

  final Animation<double> animation;
  final Rect rect;
  final Widget bubble;
  final bool mine;
  final List<MenuAction> actions;
  final String? myReaction;

  static const _barHeight = 56.0;
  static const _rowHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final screen = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final menuHeight = actions.length * _rowHeight + 12;

    // Shift the lifted bubble so the reaction bar and menu stay on screen.
    final minTop = pad.top + _barHeight + 16;
    final maxBottom = screen.height - pad.bottom - menuHeight - 16;
    var top = rect.top;
    final bubbleH = rect.height.clamp(0.0, screen.height * 0.45);
    if (top < minTop) top = minTop;
    if (top + bubbleH > maxBottom) {
      top = (maxBottom - bubbleH).clamp(minTop, double.infinity);
    }
    final shifted = Rect.fromLTWH(rect.left, top, rect.width, bubbleH);
    final align = mine ? Alignment.topRight : Alignment.topLeft;
    final horizontal = mine
        ? EdgeInsets.only(right: screen.width - shifted.right)
        : EdgeInsets.only(left: shifted.left);

    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeIn);

    // Material gives text a proper DefaultTextStyle inside this bare route.
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: AnimatedBuilder(
                animation: curved,
                builder: (context, _) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16 * curved.value, sigmaY: 16 * curved.value),
                  child: ColoredBox(color: Colors.black.withValues(alpha: (p.isDark ? 0.45 : 0.22) * curved.value)),
                ),
              ),
            ),
          ),
          // Lifted bubble.
          AnimatedBuilder(
            animation: curved,
            builder: (context, child) {
              final r = Rect.lerp(rect, shifted, curved.value)!;
              return Positioned(
                left: r.left,
                top: r.top,
                width: r.width,
                child: Transform.scale(scale: 1 + 0.03 * curved.value, child: child),
              );
            },
            child: IgnorePointer(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: screen.height * 0.45),
                child: ClipRect(child: bubble),
              ),
            ),
          ),
          // Reaction bar.
          Positioned(
            top: shifted.top - _barHeight - 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: horizontal.add(const EdgeInsets.symmetric(horizontal: 0)),
              child:
                  Align(
                        alignment: align,
                        child: Glass(
                          pill: true,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: SizedBox(
                            height: _barHeight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final (i, e) in kQuickReactions.indexed)
                                  Pressable(
                                        scale: 0.8,
                                        onTap: () {
                                          Haptics.tap();
                                          Navigator.of(context).pop(ReactResult(e));
                                        },
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          alignment: Alignment.center,
                                          decoration: e == myReaction
                                              ? BoxDecoration(
                                                  color: p.primary.withValues(alpha: 0.18),
                                                  shape: BoxShape.circle,
                                                )
                                              : null,
                                          child: Text(e, style: emojiStyle(26)),
                                        ),
                                      )
                                      .animate()
                                      .scale(
                                        begin: const Offset(0.2, 0.2),
                                        delay: (30 * i).ms,
                                        duration: 380.ms,
                                        curve: Curves.elasticOut,
                                      )
                                      .fadeIn(delay: (30 * i).ms, duration: 120.ms),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .scaleXY(begin: 0.6, alignment: align, duration: 300.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 140.ms),
            ),
          ),
          // Actions.
          Positioned(
            top: shifted.bottom + 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: horizontal,
              child: Align(
                alignment: align,
                child:
                    SizedBox(
                          width: 230,
                          child: Glass(
                            radius: Radii.md,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final (i, a) in actions.indexed)
                                  _MenuRow(
                                        action: a,
                                        onTap: () {
                                          Haptics.select();
                                          Navigator.of(context).pop(ActionResult(a.id));
                                        },
                                      )
                                      .animate()
                                      .fadeIn(delay: (20 * i + 60).ms, duration: 160.ms)
                                      .moveY(begin: -6, end: 0, curve: Curves.easeOutCubic),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .scaleXY(begin: 0.85, alignment: align, duration: 280.ms, curve: Curves.easeOutBack)
                        .fadeIn(duration: 120.ms),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.action, required this.onTap});

  final MenuAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = action.destructive ? p.danger : p.text;
    return Pressable(
      scale: 0.97,
      onTap: onTap,
      semanticLabel: action.label,
      child: SizedBox(
        height: _MessageMenu._rowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(action.label, style: context.text.bodyLarge?.copyWith(color: color)),
              ),
              Icon(action.icon, size: 20, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
