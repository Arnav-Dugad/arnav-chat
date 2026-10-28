import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/glass_app_bar.dart' show popOrHome;
import '../../core/widgets/pressable.dart';
import '../../data/models/app_user.dart';
import '../../data/models/chat.dart';
import '../../data/providers.dart';
import '../chats/chat_avatar.dart';
import '../chats/chat_providers.dart';

class ChatHeader extends ConsumerWidget {
  const ChatHeader({
    super.key,
    required this.chatId,
    required this.chat,
    required this.peer,
    required this.typingNames,
    required this.heroTag,
    required this.nameTag,
    this.onSearch,
  });

  final String chatId;
  final ChatSummary? chat;
  final AppUser? peer;

  /// Display names of people typing right now.
  final List<String> typingNames;
  final Object heroTag;
  final Object nameTag;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final me = ref.watch(currentUidProvider);
    final isGroup = chat?.isGroup ?? false;
    final self = chat?.isSaved ?? chatId == me;
    final peerUid = chat?.peerUid;
    final presence = (isGroup || self || peerUid == null) ? null : ref.watch(peerPresenceProvider(peerUid)).value;
    final name = self ? 'Saved Messages' : (chat?.title(peer?.displayName ?? '') ?? peer?.displayName ?? '');

    final String status;
    final bool live;
    if (typingNames.isNotEmpty) {
      status = isGroup
          ? (typingNames.length == 1 ? '${typingNames.first} is typing…' : '${typingNames.length} people typing…')
          : 'typing…';
      live = true;
    } else if (isGroup) {
      final n = chat?.members.length ?? 0;
      status = n == 1 ? '1 member' : '$n members';
      live = false;
    } else if (presence?.online ?? false) {
      status = 'online';
      live = true;
    } else if (presence?.lastSeen != null) {
      status = TimeFormat.lastSeen(presence!.lastSeen!);
      live = false;
    } else {
      status = self || peer == null ? '' : peer!.handle;
      live = false;
    }

    return GlassBar(
      top: true,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              GlassIconButton(icon: AppIcons.back, label: 'Back', onPressed: () => popOrHome(context)),
              Expanded(
                child: Pressable(
                  scale: 0.98,
                  onTap: self ? null : () => context.push('/chat/$chatId/info'),
                  child: Row(
                    children: [
                      ChatAvatar(chat: chat, peer: peer, size: 38, heroTag: heroTag),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: nameTag,
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (c, a) => FadeTransition(
                                opacity: a,
                                child: SlideTransition(
                                  position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(a),
                                  child: c,
                                ),
                              ),
                              child: status.isEmpty
                                  ? const SizedBox.shrink()
                                  : Text(
                                      status,
                                      key: ValueKey(status),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.labelMedium?.copyWith(color: live ? p.primary : p.textMuted),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (onSearch != null) GlassIconButton(icon: AppIcons.search, label: 'Search', onPressed: onSearch),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
