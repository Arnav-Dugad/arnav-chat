import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_payload.dart';
import '../remote/firestore_refs.dart';
import '../remote/message_writer.dart';

class InvitePreview {
  const InvitePreview({required this.code, required this.chatId, required this.name, this.photoUrl, this.memberCount});

  final String code;
  final String chatId;
  final String name;
  final String? photoUrl;
  final int? memberCount;
}

String randomToken(int length) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
  final r = Random.secure();
  return List.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
}

/// Group lifecycle. Every admin action is ONE update of the chat document that
/// also carries a system message ("Alice added Bob"), mirroring the rules in
/// firebase/firestore.rules (seq advances by exactly one per message).
class GroupRepository {
  GroupRepository(this._refs, this._writer, this._uid, this._myName);

  final FirestoreRefs _refs;
  final MessageWriter _writer;
  final String _uid;
  final String Function() _myName;

  static const maxMembers = 256;

  /// Fields that post a system message as part of an update.
  Map<String, Object> _system(String messageId, String text) => {
    'lastMessage': {
      'id': messageId,
      'senderId': _uid,
      'kind': MessageKind.system.name,
      'preview': text,
      'at': FieldValue.serverTimestamp(),
    },
    'seq': FieldValue.increment(1),
    'readSeq.$_uid': FieldValue.increment(1),
  };

  void _addSystemMessage(WriteBatch b, String chatId, String messageId, String text) {
    b.set(_refs.messages(chatId).doc(messageId), {
      'senderId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'clientTs': DateTime.now().millisecondsSinceEpoch,
      'payload': _writer.codec.encode(MessagePayload.system(text)),
    });
  }

  Future<String> create({required String name, required List<String> memberUids, String? photoUrl, String? description}) async {
    final ref = _refs.chats.doc();
    final members = {_uid, ...memberUids}.toList();
    final msgId = _writer.newId(ref.id);
    final text = '${_myName()} created the group';
    final b = _refs.fs.batch()
      ..set(ref, {
        'type': 'group',
        'members': members,
        'admins': [_uid],
        'name': name.trim(),
        'photoUrl': photoUrl,
        'description': description?.trim(),
        'createdBy': _uid,
        'inviteCode': null,
        'topicSecret': randomToken(24),
        'seq': 1,
        'readSeq': {_uid: 1},
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': {
          'id': msgId,
          'senderId': _uid,
          'kind': MessageKind.system.name,
          'preview': text,
          'at': FieldValue.serverTimestamp(),
        },
      });
    _addSystemMessage(b, ref.id, msgId, text);
    await b.commit();
    return ref.id;
  }

  Future<void> _adminUpdate(String chatId, Map<String, Object?> fields, String systemText) async {
    final msgId = _writer.newId(chatId);
    final b = _refs.fs.batch()
      ..update(_refs.chat(chatId), {...fields, ..._system(msgId, systemText), 'updatedAt': FieldValue.serverTimestamp()});
    _addSystemMessage(b, chatId, msgId, systemText);
    await b.commit();
  }

  Future<void> rename(String chatId, String name) =>
      _adminUpdate(chatId, {'name': name.trim()}, '${_myName()} renamed the group to "${name.trim()}"');

  Future<void> setPhoto(String chatId, String url) =>
      _adminUpdate(chatId, {'photoUrl': url}, '${_myName()} changed the group photo');

  Future<void> setDescription(String chatId, String text) =>
      _refs.chat(chatId).update({'description': text.trim(), 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> addMembers(String chatId, Map<String, String> uidToName) => _adminUpdate(chatId, {
    'members': FieldValue.arrayUnion(uidToName.keys.toList()),
  }, '${_myName()} added ${uidToName.values.join(', ')}');

  /// Removing someone also rotates the push topic so they stop receiving it.
  Future<void> removeMember(String chatId, String uid, String name) => _adminUpdate(chatId, {
    'members': FieldValue.arrayRemove([uid]),
    'admins': FieldValue.arrayRemove([uid]),
    'topicSecret': randomToken(24),
  }, '${_myName()} removed $name');

  Future<void> setAdmin(String chatId, String uid, bool admin) => _refs.chat(chatId).update({
    'admins': admin ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid]),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  /// Leave the group. If I am the last admin, the role passes to the longest
  /// standing other member in the same single write.
  Future<void> leave(String chatId, {required List<String> members, required List<String> admins}) async {
    final msgId = _writer.newId(chatId);
    final text = '${_myName()} left';
    final fields = <String, Object>{
      'members': FieldValue.arrayRemove([_uid]),
      ..._system(msgId, text),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (admins.contains(_uid)) {
      final remaining = admins.where((a) => a != _uid).toList();
      final others = members.where((m) => m != _uid).toList();
      if (remaining.isEmpty && others.isNotEmpty) remaining.add(others.first);
      fields['admins'] = remaining;
      fields['topicSecret'] = randomToken(24);
    }
    final b = _refs.fs.batch()..update(_refs.chat(chatId), fields);
    _addSystemMessage(b, chatId, msgId, text);
    await b.commit();
  }

  // ---------- invite links ----------

  /// Creates (or rotates) the invite code and its public preview card.
  Future<String> resetInvite(String chatId, {required String name, String? photoUrl, required int memberCount, String? oldCode}) async {
    final code = randomToken(16);
    final b = _refs.fs.batch()
      ..update(_refs.chat(chatId), {'inviteCode': code, 'updatedAt': FieldValue.serverTimestamp()})
      ..set(_refs.fs.collection('invites').doc(code), {
        'chatId': chatId,
        'name': name,
        'photoUrl': photoUrl,
        'memberCount': memberCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    if (oldCode != null) b.delete(_refs.fs.collection('invites').doc(oldCode));
    await b.commit();
    return code;
  }

  Future<void> revokeInvite(String chatId, String code) async {
    final b = _refs.fs.batch()
      ..update(_refs.chat(chatId), {'inviteCode': null, 'updatedAt': FieldValue.serverTimestamp()})
      ..delete(_refs.fs.collection('invites').doc(code));
    await b.commit();
  }

  Future<InvitePreview?> preview(String code) async {
    final d = (await _refs.fs.collection('invites').doc(code).get()).data();
    if (d == null) return null;
    return InvitePreview(
      code: code,
      chatId: d['chatId'] as String,
      name: d['name'] as String? ?? 'Group',
      photoUrl: d['photoUrl'] as String?,
      memberCount: (d['memberCount'] as num?)?.toInt(),
    );
  }

  Future<String> join(InvitePreview invite) async {
    final msgId = _writer.newId(invite.chatId);
    final text = '${_myName()} joined via link';
    final b = _refs.fs.batch()
      ..update(_refs.chat(invite.chatId), {
        'members': FieldValue.arrayUnion([_uid]),
        'lastJoinCode': invite.code,
        ..._system(msgId, text),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    _addSystemMessage(b, invite.chatId, msgId, text);
    await b.commit();
    // Start caught up rather than with the whole history unread.
    final seq = ((await _refs.chat(invite.chatId).get()).data()?['seq'] as num?)?.toInt();
    if (seq != null) {
      await _refs.chat(invite.chatId).update({'readSeq.$_uid': seq, 'updatedAt': FieldValue.serverTimestamp()});
    }
    return invite.chatId;
  }

  static String inviteUrl(String workerUrl, String code) => '$workerUrl/j/$code';
}
