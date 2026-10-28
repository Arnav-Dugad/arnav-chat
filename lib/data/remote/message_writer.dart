import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message.dart';
import '../models/message_payload.dart';
import 'firestore_refs.dart';

/// Pure Firestore write path for messages. Shared by the outbox (main isolate)
/// and notification inline-reply (background isolate).
///
/// Each send is ONE batched write: the message + the denormalised chat summary
/// (lastMessage, unread counter, updatedAt). That is 2 document writes.
class MessageWriter {
  MessageWriter(this._refs, {this.codec = const PlainPayloadCodec()});

  final FirestoreRefs _refs;
  final PayloadCodec codec;

  String newId(String chatId) => _refs.messages(chatId).doc().id;

  Future<void> send({
    required String chatId,
    required String messageId,
    required String senderId,
    required List<String> members,
    required MessagePayload payload,
    required int clientTs,
    ReplyRef? reply,
    bool forwarded = false,
    bool group = false,
    String? senderName,
  }) {
    final now = FieldValue.serverTimestamp();
    final others = members.where((m) => m != senderId).toList();
    final lastMessage = {
      'id': messageId,
      'senderId': senderId,
      'kind': payload.kind.name,
      'preview': _clip(payload.preview),
      'at': now,
      if (group && senderName != null) 'senderName': senderName,
    };
    final batch = _refs.fs.batch()
      ..set(_refs.messages(chatId).doc(messageId), {
        'senderId': senderId,
        'createdAt': now,
        'updatedAt': now,
        'clientTs': clientTs,
        'payload': codec.encode(payload),
        if (reply != null) 'reply': reply.toMap(),
        if (forwarded) 'forwarded': true,
      });
    if (group) {
      // Groups: one counter bump instead of a per-member unread field.
      // My own readSeq moves with it, so my message never counts as unread.
      batch.update(_refs.chat(chatId), {
        'updatedAt': now,
        'lastMessage': lastMessage,
        'seq': FieldValue.increment(1),
        'readSeq.$senderId': FieldValue.increment(1),
      });
    } else {
      batch.set(_refs.chat(chatId), {
        'type': members.length == 1 ? 'self' : 'direct',
        'members': members,
        'updatedAt': now,
        'lastMessage': lastMessage,
        'unread': {for (final o in others) o: FieldValue.increment(1)},
      }, SetOptions(merge: true));
    }
    return batch.commit();
  }

  Future<void> vote(String chatId, String messageId, String uid, List<String> optionIds) =>
      _refs.messages(chatId).doc(messageId).update({
        'votes.$uid': optionIds.isEmpty ? FieldValue.delete() : optionIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> setPins(String chatId, List<Map<String, dynamic>> pins) =>
      _refs.chat(chatId).update({'pinned': pins, 'updatedAt': FieldValue.serverTimestamp()});

  Future<bool> existsOnServer(String chatId, String messageId) async {
    final s = await _refs.messages(chatId).doc(messageId).get(const GetOptions(source: Source.server));
    return s.exists;
  }

  Future<void> edit(String chatId, String messageId, MessagePayload payload) =>
      _refs.messages(chatId).doc(messageId).update({
        'payload': codec.encode(payload),
        'editedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteForEveryone(String chatId, String messageId, {required bool wasLast, required String senderId}) {
    final batch = _refs.fs.batch()
      ..update(_refs.messages(chatId).doc(messageId), {
        'payload': codec.encode(MessagePayload.deleted),
        'deleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    if (wasLast) {
      batch.update(_refs.chat(chatId), {
        'lastMessage.kind': MessageKind.deleted.name,
        'lastMessage.preview': MessagePayload.deleted.preview,
        'lastMessage.senderId': senderId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return batch.commit();
  }

  Future<void> react(String chatId, String messageId, String uid, String? emoji) => _refs
      .messages(chatId)
      .doc(messageId)
      .update({'reactions.$uid': emoji ?? FieldValue.delete(), 'updatedAt': FieldValue.serverTimestamp()});

  static String _clip(String s) => s.length > 120 ? '${s.substring(0, 119)}…' : s;
}
