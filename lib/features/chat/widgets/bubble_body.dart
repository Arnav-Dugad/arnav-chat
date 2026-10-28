import 'package:flutter/material.dart';

import '../../../core/design/icons.dart';
import '../../../core/design/palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/time_format.dart';
import '../../../core/widgets/glass.dart';
import '../../../data/models/message.dart';
import '../../../data/models/message_payload.dart';
import 'media_content.dart';
import 'receipt_ticks.dart';

/// Visual bubble (no gestures) — reused by the context menu "lifted" copy.
class BubbleBody extends StatelessWidget {
  const BubbleBody({
    super.key,
    required this.message,
    required this.mine,
    required this.receipt,
    this.first = true,
    this.last = true,
    this.replyAuthor,
  });

  final Message message;
  final bool mine;
  final Receipt receipt;
  final bool first;
  final bool last;
  final String? replyAuthor;

  BorderRadius get radius {
    const big = Radius.circular(Radii.bubble);
    const mid = Radius.circular(8);
    const tail = Radius.circular(6);
    return mine
        ? BorderRadius.only(topLeft: big, bottomLeft: big, topRight: first ? big : mid, bottomRight: last ? tail : mid)
        : BorderRadius.only(topRight: big, bottomRight: big, topLeft: first ? big : mid, bottomLeft: last ? tail : mid);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final payload = message.payload;
    final fg = mine ? p.bubbleOutText : p.bubbleInText;
    final sub = mine ? Colors.white.withValues(alpha: 0.72) : p.textFaint;
    final mediaOnly =
        (payload.kind == MessageKind.image || payload.kind == MessageKind.video) &&
        (payload.text?.isEmpty ?? true) &&
        message.reply == null &&
        !message.forwarded;

    final meta = _Meta(message: message, mine: mine, receipt: receipt, color: sub);

    if (mediaOnly) {
      final inner = BorderRadius.only(
        topLeft: radius.topLeft,
        topRight: radius.topRight,
        bottomLeft: radius.bottomLeft,
        bottomRight: radius.bottomRight,
      );
      return Stack(
        children: [
          payload.kind == MessageKind.image
              ? ImageContent(message: message, radius: inner)
              : VideoContent(message: message, radius: inner),
          Positioned(
            right: 8,
            bottom: 8,
            child: Glass(
              pill: true,
              border: false,
              tint: Colors.black.withValues(alpha: 0.32),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              child: _Meta(message: message, mine: mine, receipt: receipt, color: Colors.white, onAccent: true),
            ),
          ),
        ],
      );
    }

    final children = <Widget>[
      if (message.forwarded)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.forward, size: 13, color: sub),
              const SizedBox(width: 4),
              Text(
                'Forwarded',
                style: context.text.labelSmall?.copyWith(color: sub, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      if (message.reply != null) _ReplyQuote(reply: message.reply!, mine: mine, author: replyAuthor),
      ..._content(context, payload, fg, sub, meta),
    ];

    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(borderRadius: radius),
        color: mine ? null : p.bubbleIn,
        gradient: mine ? p.accentGradient : null,
        shadows: mine
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: p.isDark ? 0 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          payload.hasMedia && payload.kind != MessageKind.audio && payload.kind != MessageKind.file ? 4 : 12,
          payload.hasMedia && payload.kind != MessageKind.audio && payload.kind != MessageKind.file ? 4 : 8,
          payload.hasMedia && payload.kind != MessageKind.audio && payload.kind != MessageKind.file ? 4 : 12,
          8,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  List<Widget> _content(BuildContext context, MessagePayload payload, Color fg, Color sub, Widget meta) {
    final textStyle = context.text.bodyLarge!.copyWith(color: fg, height: 1.32);
    final inner = BorderRadius.circular(Radii.bubble - 4);
    Widget textWithMeta(String text) => Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  child: LinkifiedText(
                    text,
                    style: textStyle,
                    linkColor: mine ? Colors.white : context.palette.primary,
                  ),
                ),
                WidgetSpan(child: SizedBox(width: _Meta.width(message, mine), height: 12)),
              ],
            ),
          ),
        ),
        Positioned(right: 0, bottom: 0, child: meta),
      ],
    );

    switch (payload.kind) {
      case MessageKind.deleted:
        return [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.trash, size: 15, color: sub),
              const SizedBox(width: 6),
              Text(
                'Message deleted',
                style: textStyle.copyWith(color: sub, fontStyle: FontStyle.italic),
              ),
              const SizedBox(width: 8),
              meta,
            ],
          ),
        ];
      case MessageKind.text:
        return [
          if (payload.link != null) LinkCard(link: payload.link!, mine: mine),
          ConstrainedBox(constraints: const BoxConstraints(minWidth: 40), child: textWithMeta(payload.text ?? '')),
        ];
      case MessageKind.image:
      case MessageKind.video:
        return [
          payload.kind == MessageKind.image
              ? ImageContent(message: message, radius: inner)
              : VideoContent(message: message, radius: inner),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: SizedBox(width: kBubbleMaxMediaWidth - 16, child: textWithMeta(payload.text ?? '')),
          ),
        ];
      case MessageKind.audio:
        return [
          VoiceContent(message: message, mine: mine),
          Align(alignment: Alignment.centerRight, widthFactor: 1, child: meta),
        ];
      case MessageKind.file:
        return [
          FileContent(message: message, mine: mine),
          const SizedBox(height: 4),
          Align(alignment: Alignment.centerRight, widthFactor: 1, child: meta),
        ];
    }
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.message,
    required this.mine,
    required this.receipt,
    required this.color,
    this.onAccent = false,
  });

  final Message message;
  final bool mine;
  final Receipt receipt;
  final Color color;
  final bool onAccent;

  static double width(Message m, bool mine) => (m.editedAt != null ? 44 : 0) + 38 + (mine ? 20 : 0);

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: color,
      fontSize: 11.5,
      fontWeight: FontWeight.w500,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.starred)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Icon(AppIcons.starFill, size: 11, color: color),
          ),
        if (message.editedAt != null && !message.deletedForEveryone) Text('edited ', style: style),
        Text(TimeFormat.bubble(message.createdAt), style: style),
        if (mine) ...[const SizedBox(width: 3), ReceiptTicks(receipt: receipt, size: 15, onAccent: mine || onAccent)],
      ],
    );
  }
}

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({required this.reply, required this.mine, this.author});

  final ReplyRef reply;
  final bool mine;
  final String? author;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bar = mine ? Colors.white : p.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: ShapeDecoration(
        color: mine ? Colors.white.withValues(alpha: 0.16) : p.primary.withValues(alpha: 0.08),
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(color: bar, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    author ?? '',
                    style: context.text.labelMedium?.copyWith(color: bar, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    reply.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: mine ? Colors.white.withValues(alpha: 0.85) : p.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
