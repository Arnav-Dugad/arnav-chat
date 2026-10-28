import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../core/design/haptics.dart';
import '../../../core/design/icons.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/palette.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../data/models/message.dart';
import 'bubble_body.dart';
import 'dissolve.dart';
import 'heart_burst.dart';

/// A message row: alignment, gestures and entrance/exit animations around a
/// [BubbleBody].
class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.mine,
    required this.receipt,
    required this.myUid,
    required this.first,
    required this.last,
    required this.animateIn,
    required this.onReply,
    required this.onLongPress,
    required this.onDoubleTap,
    required this.onReact,
    required this.onRetry,
    this.dissolving = false,
    this.onDissolved,
    this.replyAuthor,
    this.senderName,
    this.senderColor,
    this.avatar,
    this.onVote,
  });

  final Message message;
  final bool mine;
  final Receipt receipt;
  final String myUid;
  final bool first;
  final bool last;
  final bool animateIn;
  final bool dissolving;
  final String? replyAuthor;

  /// Groups: sender label (first bubble of a run) and avatar slot (incoming).
  final String? senderName;
  final Color? senderColor;
  final Widget? avatar;
  final void Function(String optionId)? onVote;
  final VoidCallback onReply;
  final void Function(GlobalKey bubbleKey) onLongPress;
  final VoidCallback onDoubleTap;
  final void Function(String emoji) onReact;
  final VoidCallback onRetry;
  final VoidCallback? onDissolved;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> with TickerProviderStateMixin {
  static const _replyThreshold = 64.0;
  final _bubbleKey = GlobalKey();
  late final AnimationController _drag = AnimationController.unbounded(vsync: this);
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  bool _armed = false;
  bool _heart = false;
  double _raw = 0;

  /// Theirs swipe right, mine swipe left (towards the free side).
  double get _dir => widget.mine ? -1 : 1;

  @override
  void initState() {
    super.initState();
    if (widget.animateIn) {
      _enter.forward();
    } else {
      _enter.value = 1;
    }
  }

  @override
  void dispose() {
    _drag.dispose();
    _enter.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _raw = (_raw + d.delta.dx * _dir).clamp(0, 400);
    _drag.value = rubberBand(_raw, 110, c: 0.9);
    final armed = _drag.value >= _replyThreshold;
    if (armed != _armed) {
      _armed = armed;
      if (armed) Haptics.tick();
      setState(() {});
    }
  }

  void _onDragEnd(DragEndDetails _) {
    if (_armed) widget.onReply();
    _armed = false;
    _raw = 0;
    _drag.animateWith(SpringSimulation(Springs.rubber, _drag.value, 0, 0));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final m = widget.message;
    final maxW = MediaQuery.sizeOf(context).width * 0.78;

    Widget bubble = KeyedSubtree(
      key: _bubbleKey,
      child: BubbleBody(
        message: m,
        mine: widget.mine,
        receipt: widget.receipt,
        first: widget.first,
        last: widget.last,
        replyAuthor: widget.replyAuthor,
        senderName: widget.first ? widget.senderName : null,
        senderColor: widget.senderColor,
        myUid: widget.myUid,
        onVote: widget.onVote,
      ),
    );

    if (_heart) {
      bubble = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          bubble,
          Positioned.fill(
            child: OverflowBox(
              maxWidth: 200,
              maxHeight: 200,
              child: HeartBurst(onDone: () => setState(() => _heart = false)),
            ),
          ),
        ],
      );
    }

    final reactions = m.reactionCounts;
    final column = Column(
      crossAxisAlignment: widget.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: bubble,
        ),
        if (reactions.isNotEmpty)
          Transform.translate(
            offset: const Offset(0, -6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 4,
                children: [
                  for (final r in reactions)
                    _ReactionChip(
                      emoji: r.key,
                      count: r.value,
                      mineSelected: m.reactions[widget.myUid] == r.key,
                      onTap: () => widget.onReact(r.key),
                    ),
                ],
              ),
            ),
          ),
        if (widget.receipt == Receipt.failed)
          GestureDetector(
            onTap: widget.onRetry,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.warning, size: 14, color: p.danger),
                  const SizedBox(width: 4),
                  Text('Retry', style: context.text.labelMedium?.copyWith(color: p.danger)),
                ],
              ),
            ),
          ),
      ],
    );

    Widget row = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: m.deletedForEveryone ? null : _onDragUpdate,
      onHorizontalDragEnd: m.deletedForEveryone ? null : _onDragEnd,
      onLongPress: () {
        Haptics.medium();
        widget.onLongPress(_bubbleKey);
      },
      onDoubleTap: m.deletedForEveryone
          ? null
          : () {
              Haptics.tap();
              setState(() => _heart = true);
              widget.onDoubleTap();
            },
      child: AnimatedBuilder(
        animation: _drag,
        builder: (context, child) {
          final x = _drag.value;
          final t = (x / _replyThreshold).clamp(0.0, 1.0);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (x > 2)
                Positioned(
                  left: widget.mine ? null : 8,
                  right: widget.mine ? 8 : null,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: widget.mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Opacity(
                      opacity: t,
                      child: Transform.scale(
                        scale: 0.5 + 0.5 * t + (_armed ? 0.12 : 0),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: p.surfaceRaised, shape: BoxShape.circle),
                          child: Icon(AppIcons.reply, size: 18, color: _armed ? p.primary : p.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.translate(offset: Offset(x * _dir, 0), child: child),
            ],
          );
        },
        child: Align(alignment: widget.mine ? Alignment.centerRight : Alignment.centerLeft, child: column),
      ),
    );

    // Spring in from the input bar (mine) or from the left edge (theirs).
    row = AnimatedBuilder(
      animation: _enter,
      child: row,
      builder: (context, child) {
        final v = Motion.bounce.transform(_enter.value);
        final o = Curves.easeOut.transform((_enter.value * 2).clamp(0, 1));
        return Opacity(
          opacity: o,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 46),
            child: Transform.scale(
              alignment: widget.mine ? Alignment.bottomRight : Alignment.bottomLeft,
              scale: 0.72 + 0.28 * v,
              child: child,
            ),
          ),
        );
      },
    );

    if (widget.dissolving) {
      row = Dissolve(color: widget.mine ? p.primary : p.textMuted, onDone: widget.onDissolved ?? () {}, child: row);
    }

    if (widget.avatar != null && !widget.mine) {
      // Avatar sits beside the last bubble of an incoming run; earlier
      // bubbles keep the same indent so the column stays aligned.
      row = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: 30, child: widget.last ? widget.avatar : null),
          const SizedBox(width: 6),
          Expanded(child: row),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: Gaps.x3, right: Gaps.x3, top: widget.first ? 6 : 1.5, bottom: widget.last ? 2 : 0),
      child: row,
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({required this.emoji, required this.count, required this.mineSelected, required this.onTap});

  final String emoji;
  final int count;
  final bool mineSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        key: ValueKey('$emoji$count'),
        tween: Tween(begin: 1.35, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.elasticOut,
        builder: (context, s, child) => Transform.scale(scale: s, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: ShapeDecoration(
            shape: StadiumBorder(side: BorderSide(color: mineSelected ? p.primary : p.bg, width: 1.5)),
            color: p.surfaceRaised,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: emojiStyle(14)),
              if (count > 1) ...[
                const SizedBox(width: 3),
                Text('$count', style: context.text.labelMedium?.copyWith(color: p.text)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
