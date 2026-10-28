import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/fields.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/pressable.dart';
import '../../data/models/chat.dart';
import '../../data/models/message.dart';
import '../../data/providers.dart';
import '../chats/chat_avatar.dart';
import '../chats/chat_providers.dart';
import '../chats/chat_tile.dart';

/// Searches chat names and cached message text (local Drift: zero reads).
/// With [chatId] the search is scoped to one conversation.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.chatId});

  final String? chatId;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _q = TextEditingController();
  Timer? _debounce;
  List<Message> _messages = const [];
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () async {
      final found = await ref.read(messageRepositoryProvider).search(v);
      if (!mounted) return;
      setState(() {
        _query = v.trim().toLowerCase();
        _messages = widget.chatId == null ? found : found.where((m) => m.chatId == widget.chatId).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final chats = ref.watch(chatListProvider).value ?? const <ChatSummary>[];
    final byId = {for (final c in chats) c.id: c};
    final matchingChats = widget.chatId != null || _query.length < 2
        ? const <ChatSummary>[]
        : chats.where((c) => c.title('').toLowerCase().contains(_query)).toList();
    final top = MediaQuery.paddingOf(context).top + 56;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(title: widget.chatId == null ? 'Search' : 'Search in chat'),
      body: Column(
        children: [
          SizedBox(height: top + Gaps.x2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.x4),
            child: PillField(controller: _q, hint: 'Messages, people', icon: AppIcons.search, autofocus: true, onChanged: _onChanged),
          ),
          Expanded(
            child: _query.length < 2
                ? const EmptyState(icon: AppIcons.search, label: 'Search chats')
                : matchingChats.isEmpty && _messages.isEmpty
                ? const EmptyState(icon: AppIcons.search, label: 'No results')
                : ListView(
                    padding: const EdgeInsets.only(top: Gaps.x2, bottom: Gaps.x8),
                    children: [
                      if (matchingChats.isNotEmpty) ...[
                        const _Header('Chats'),
                        for (final c in matchingChats) ChatTile(key: ValueKey('c${c.id}'), chat: c),
                      ],
                      if (_messages.isNotEmpty) ...[
                        const _Header('Messages'),
                        for (final (i, m) in _messages.indexed)
                          _MessageHit(message: m, chat: byId[m.chatId], query: _query)
                              .animate()
                              .fadeIn(delay: (i.clamp(0, 12) * 20).ms, duration: 160.ms),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      backgroundColor: p.bg,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Gaps.x5, Gaps.x3, Gaps.x5, Gaps.x1),
    child: Text(label.toUpperCase(), style: context.text.labelSmall),
  );
}

class _MessageHit extends StatelessWidget {
  const _MessageHit({required this.message, required this.chat, required this.query});

  final Message message;
  final ChatSummary? chat;
  final String query;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = message.payload.preview;
    final i = text.toLowerCase().indexOf(query);
    final spans = i < 0
        ? [TextSpan(text: text)]
        : [
            TextSpan(text: i > 30 ? '…${text.substring(i - 24, i)}' : text.substring(0, i)),
            TextSpan(
              text: text.substring(i, i + query.length),
              style: TextStyle(color: p.primary, fontWeight: FontWeight.w600),
            ),
            TextSpan(text: text.substring(i + query.length)),
          ];
    return Pressable(
      scale: 0.98,
      onTap: () => context.push('/chat/${message.chatId}?m=${message.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gaps.x4, vertical: 9),
        child: Row(
          children: [
            ChatAvatar(chat: chat, peer: chat?.peer, size: 44, heroTag: null),
            const SizedBox(width: Gaps.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(chat?.title('Chat') ?? 'Chat', maxLines: 1, style: context.text.titleSmall),
                      ),
                      Text(TimeFormat.chatList(message.createdAt), style: context.text.labelMedium),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(style: context.text.bodyMedium?.copyWith(color: p.textMuted), children: spans),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
