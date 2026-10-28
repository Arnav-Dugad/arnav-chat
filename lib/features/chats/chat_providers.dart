import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/chat.dart';
import '../../data/remote/presence_service.dart';
import '../../data/providers.dart';

part 'chat_providers.g.dart';

@riverpod
Stream<List<ChatSummary>> chatList(Ref ref) => ref.watch(chatRepositoryProvider).watchChats();

/// RTDB presence for a peer (one multiplexed socket; no Firestore reads).
@riverpod
Stream<Presence> peerPresence(Ref ref, String uid) => ref.watch(presenceProvider).watch(uid);

@riverpod
Stream<bool> peerTyping(Ref ref, String chatId, String uid) => ref.watch(presenceProvider).watchTyping(chatId, uid);
