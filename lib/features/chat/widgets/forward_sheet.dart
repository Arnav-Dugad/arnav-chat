import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/pressable.dart';
import '../../chats/chat_providers.dart';

/// Pick a chat to forward to. Returns the chat id.
Future<String?> showForwardSheet(BuildContext context) => showModalBottomSheet<String>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => const _ForwardSheet(),
);

class _ForwardSheet extends ConsumerWidget {
  const _ForwardSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatListProvider).value ?? const [];
    final p = context.palette;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, scroll) => Container(
        margin: const EdgeInsets.symmetric(horizontal: Gaps.x2),
        decoration: ShapeDecoration(
          color: p.surface,
          shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl))),
        ),
        child: ListView.builder(
          controller: scroll,
          padding: const EdgeInsets.symmetric(vertical: Gaps.x4),
          itemCount: chats.length,
          itemBuilder: (context, i) {
            final c = chats[i];
            return Pressable(
              onTap: () => Navigator.of(context).pop(c.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gaps.x5, vertical: 8),
                child: Row(
                  children: [
                    Avatar(name: c.title('…'), url: c.peer?.photoUrl, size: 44),
                    const SizedBox(width: Gaps.x3),
                    Expanded(child: Text(c.title('…'), style: context.text.titleSmall)),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (i * 25).ms).moveX(begin: 12, end: 0);
          },
        ),
      ),
    );
  }
}
