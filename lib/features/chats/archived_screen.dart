import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/icons.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_app_bar.dart';
import 'chat_providers.dart';
import 'chat_tile.dart';

class ArchivedScreen extends ConsumerWidget {
  const ArchivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(archivedChatsProvider).value ?? const [];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Archived'),
      body: chats.isEmpty
          ? const EmptyState(icon: AppIcons.archive, label: 'Nothing archived')
          : ListView.builder(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 60, bottom: 24),
              itemCount: chats.length,
              itemBuilder: (_, i) => ChatTile(key: ValueKey(chats[i].id), chat: chats[i]),
            ),
    );
  }
}
