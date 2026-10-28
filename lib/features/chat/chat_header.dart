import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/pressable.dart';
import '../../data/models/app_user.dart';
import '../../data/providers.dart';
import '../chats/chat_providers.dart';

class ChatHeader extends ConsumerWidget {
  const ChatHeader({
    super.key,
    required this.chatId,
    required this.peerUid,
    required this.peer,
    required this.typing,
    required this.heroTag,
    required this.nameTag,
  });

  final String chatId;
  final String? peerUid;
  final AppUser? peer;
  final bool typing;
  final Object heroTag;
  final Object nameTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final me = ref.watch(currentUidProvider);
    final self = peerUid == me;
    final presence = (peerUid == null || self) ? null : ref.watch(peerPresenceProvider(peerUid!)).value;
    final name = self ? 'Saved' : (peer?.displayName ?? '');

    final String status;
    if (typing) {
      status = 'typing…';
    } else if (presence?.online ?? false) {
      status = 'online';
    } else if (presence?.lastSeen != null) {
      status = TimeFormat.lastSeen(presence!.lastSeen!);
    } else {
      status = peer == null || self ? '' : peer!.handle;
    }

    return GlassBar(
      top: true,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              GlassIconButton(icon: AppIcons.back, label: 'Back', onPressed: () => Navigator.of(context).maybePop()),
              Expanded(
                child: Pressable(
                  scale: 0.98,
                  onTap: peerUid == null || self ? null : () => context.push('/user/$peerUid'),
                  child: Row(
                    children: [
                      Avatar(name: name.isEmpty ? '?' : name, url: peer?.photoUrl, size: 38, heroTag: heroTag),
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
                                child: SlideTransition(position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(a), child: c),
                              ),
                              child: status.isEmpty
                                  ? const SizedBox.shrink()
                                  : Text(
                                      status,
                                      key: ValueKey(status),
                                      style: context.text.labelMedium?.copyWith(
                                        color: typing || status == 'online' ? p.primary : p.textMuted,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
