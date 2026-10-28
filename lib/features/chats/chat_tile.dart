import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/count_badge.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/swipe_actions.dart';
import '../../core/widgets/toast.dart';
import '../../data/models/chat.dart';
import '../../data/models/message.dart';
import '../../data/models/message_payload.dart';
import '../../data/providers.dart';
import '../chat/widgets/receipt_ticks.dart';
import 'chat_avatar.dart';
import 'chat_providers.dart';

class ChatTile extends ConsumerWidget {
  const ChatTile({super.key, required this.chat});

  final ChatSummary chat;

  static Object heroAvatar(String chatId) => 'avatar-$chatId';
  static Object heroName(String chatId) => 'name-$chatId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final me = ref.watch(currentUidProvider);
    final repo = ref.read(chatRepositoryProvider);
    final peerUid = chat.isGroup || chat.isSaved ? null : chat.peerUid;
    final online =
        peerUid != null && peerUid != me && (ref.watch(peerPresenceProvider(peerUid)).value?.online ?? false);
    final typing = peerUid != null && peerUid != me && (ref.watch(peerTypingProvider(chat.id, peerUid)).value ?? false);
    final title = chat.title('…');
    final last = chat.last;
    final mine = last != null && last.senderId == me;

    final receipt = !mine
        ? null
        : (chat.peerReadUpTo != null && !last.at.isAfter(chat.peerReadUpTo!))
        ? Receipt.read
        : (chat.peerDeliveredUpTo != null && !last.at.isAfter(chat.peerDeliveredUpTo!))
        ? Receipt.delivered
        : Receipt.sent;

    final subtitle = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: typing
          ? Text(
              'typing…',
              key: const ValueKey('typing'),
              style: context.text.bodyMedium?.copyWith(color: p.primary),
            )
          : Row(
              key: const ValueKey('preview'),
              children: [
                if (chat.draft != null) ...[
                  Text('Draft ', style: context.text.bodyMedium?.copyWith(color: p.danger)),
                ] else if (receipt != null) ...[
                  ReceiptTicks(receipt: receipt, size: 15),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    chat.draft ??
                        (chat.isGroup && last?.senderName != null && last!.kind != MessageKind.system
                            ? '${mine ? 'You' : last.senderName!.split(' ').first}: ${last.preview}'
                            : last?.preview ?? ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(color: p.textMuted),
                  ),
                ),
              ],
            ),
    );

    return SwipeActions(
      leading: [
        SwipeAction(
          icon: chat.pinned ? AppIcons.pinFill : AppIcons.pin,
          label: chat.pinned ? 'Unpin' : 'Pin',
          color: p.primary,
          onTap: () => repo.setPinned(chat.id, !chat.pinned),
        ),
      ],
      trailing: [
        SwipeAction(
          icon: AppIcons.mute,
          label: chat.muted ? 'Unmute' : 'Mute',
          color: const Color(0xFF7A8699),
          onTap: () => repo.setMuted(chat.id, chat.muted ? null : const Duration(days: 3650)),
        ),
        SwipeAction(
          icon: AppIcons.archive,
          label: chat.archived ? 'Unarchive' : 'Archive',
          color: const Color(0xFFF0A63A),
          onTap: () {
            repo.setArchived(chat.id, !chat.archived);
            showToast(context, chat.archived ? 'Unarchived' : 'Archived', icon: AppIcons.archive);
          },
        ),
        SwipeAction(icon: AppIcons.trash, label: 'Delete', color: p.danger, onTap: () => repo.clearForMe(chat.id)),
      ],
      child: ColoredBox(
        color: p.bg,
        child: Pressable(
          scale: 0.975,
          onTap: () => context.push(
            '/chat/${chat.id}',
            extra: ChatRouteArgs(peer: chat.peer, heroTag: heroAvatar(chat.id)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.x4, vertical: 10),
            child: Row(
              children: [
                ChatAvatar(chat: chat, peer: chat.peer, size: 54, online: online, heroTag: heroAvatar(chat.id)),
                const SizedBox(width: Gaps.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Hero(
                              tag: heroName(chat.id),
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleSmall,
                                ),
                              ),
                            ),
                          ),
                          if (chat.muted)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(AppIcons.mute, size: 14, color: p.textFaint),
                            ),
                          if (last != null)
                            Text(
                              TimeFormat.chatList(last.at),
                              style: context.text.labelMedium?.copyWith(
                                color: chat.unread > 0 ? p.primary : p.textFaint,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(child: subtitle),
                          if (chat.pinned && chat.unread == 0) Icon(AppIcons.pinFill, size: 14, color: p.textFaint),
                          CountBadge(count: chat.unread, muted: chat.muted),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
