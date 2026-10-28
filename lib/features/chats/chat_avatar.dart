import 'package:flutter/material.dart';

import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/widgets/avatar.dart';
import '../../data/models/app_user.dart';
import '../../data/models/chat.dart';

/// Avatar for any chat: peer photo, group photo, or the Saved Messages badge.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({super.key, required this.chat, this.peer, this.size = 54, this.online = false, this.heroTag});

  final ChatSummary? chat;
  final AppUser? peer;
  final double size;
  final bool online;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final c = chat;
    if (c != null && c.isSaved) {
      Widget badge = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: context.palette.accentGradient),
        child: Icon(AppIcons.bookmarkFill, color: Colors.white, size: size * 0.46),
      );
      if (heroTag != null) badge = Hero(tag: heroTag!, child: badge);
      return Semantics(label: 'Saved Messages', image: true, child: badge);
    }
    final name = c?.title(peer?.displayName ?? '?') ?? peer?.displayName ?? '?';
    return Avatar(
      name: name.isEmpty ? '?' : name,
      url: c?.isGroup ?? false ? c!.photoUrl : (peer?.photoUrl ?? c?.peer?.photoUrl),
      size: size,
      online: online,
      heroTag: heroTag,
    );
  }
}
