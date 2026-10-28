import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/app_database.dart';
import '../../data/models/app_user.dart';
import '../../data/models/chat.dart';
import '../../data/models/message.dart';
import '../../data/providers.dart';

part 'chat_screen_providers.g.dart';

@riverpod
Stream<List<Message>> chatMessages(Ref ref, String chatId, int limit) =>
    ref.watch(messageRepositoryProvider).watch(chatId, limit: limit);

// Hand-written: riverpod_generator cannot see Drift-generated row types.
final chatRowProvider = StreamProvider.autoDispose.family<ChatRow?, String>(
  (ref, chatId) => ref.watch(chatRepositoryProvider).watchChatRow(chatId),
);

@riverpod
Stream<ChatSummary?> chatSummary(Ref ref, String chatId) => ref.watch(chatRepositoryProvider).watchSummary(chatId);

@riverpod
Stream<AppUser?> cachedUser(Ref ref, String uid) => ref.watch(userRepositoryProvider).watchCached(uid);

/// Profiles of a chat's members (cached in Drift; fetched once when missing).
@riverpod
Future<Map<String, AppUser>> chatMembers(Ref ref, String chatId) async {
  final members = ref.watch(chatSummaryProvider(chatId).select((s) => s.value?.members ?? const <String>[]));
  final users = ref.read(userRepositoryProvider);
  final out = <String, AppUser>{};
  await Future.wait([
    for (final uid in members)
      users.get(uid).then((u) {
        if (u != null) out[uid] = u;
      }),
  ]);
  return out;
}

/// uids currently typing in a group (excluding me).
@riverpod
Stream<List<String>> groupTyping(Ref ref, String chatId) => ref.watch(presenceProvider).watchTypingAny(chatId);
