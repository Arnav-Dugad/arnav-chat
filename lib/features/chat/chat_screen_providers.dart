import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/app_database.dart';
import '../../data/models/app_user.dart';
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
Stream<AppUser?> cachedUser(Ref ref, String uid) => ref.watch(userRepositoryProvider).watchCached(uid);
