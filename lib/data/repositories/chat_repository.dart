import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide Query;

import '../local/app_database.dart';
import '../models/app_user.dart';
import '../models/chat.dart';
import '../models/message_payload.dart';
import '../remote/firestore_refs.dart';
import 'user_repository.dart';

/// Keeps the local chat list in sync with Firestore.
///
/// Quota strategy: one listener for the whole list, filtered by
/// `updatedAt > cursor`, so a reconnect only re-reads chats that actually
/// changed since the last sync — never the full list.
class ChatRepository {
  ChatRepository(this._refs, this._db, this._users, this._uid);

  final FirestoreRefs _refs;
  final AppDatabase _db;
  final UserRepository _users;
  final String _uid;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  final _pendingDelivered = <String>{};
  Timer? _deliveredTimer;
  bool shareReadReceipts = true;

  static const _cursorKey = 'chatCursor';

  Future<void> startSync() async {
    if (_sub != null) return;
    final cursor = int.tryParse(await _db.getMeta(_cursorKey) ?? '');
    Query<Map<String, dynamic>> q = _refs.chats.where('members', arrayContains: _uid);
    q = cursor == null
        ? q.orderBy('updatedAt', descending: true).limit(200)
        : q.where('updatedAt', isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(cursor)).orderBy('updatedAt');
    _sub = q.snapshots().listen(_onSnapshot, onError: (Object _) {
      _sub = null;
      Future.delayed(const Duration(seconds: 5), startSync);
    });
  }

  Future<void> stopSync() async {
    await _sub?.cancel();
    _sub = null;
  }

  /// Pull-to-refresh: re-attach the listener (picks up anything missed).
  Future<void> refresh() async {
    await stopSync();
    await startSync();
  }

  Future<void> _onSnapshot(QuerySnapshot<Map<String, dynamic>> snap) async {
    var maxCursor = int.tryParse(await _db.getMeta(_cursorKey) ?? '') ?? 0;
    for (final change in snap.docChanges) {
      if (change.type == DocumentChangeType.removed) continue;
      final doc = change.doc;
      // Local pending writes have null server timestamps; the optimistic row
      // already reflects them, so wait for the server-confirmed snapshot.
      if (doc.metadata.hasPendingWrites) continue;
      final data = doc.data();
      if (data == null) continue;
      await _upsert(doc.id, data);
      final u = data['updatedAt'].asMillis ?? 0;
      if (u > maxCursor) maxCursor = u;
    }
    if (maxCursor > 0) await _db.setMeta(_cursorKey, '$maxCursor');
  }

  Future<void> _upsert(String id, Map<String, dynamic> d) async {
    final members = List<String>.from(d['members'] as List? ?? const []);
    final peer = members.firstWhere((m) => m != _uid, orElse: () => _uid);
    final lm = d['lastMessage'] as Map<String, dynamic>?;
    final last = lm == null
        ? null
        : LastMessage(
            id: lm['id'] as String? ?? '',
            senderId: lm['senderId'] as String? ?? '',
            kind: MessageKind.values.firstWhere((k) => k.name == lm['kind'], orElse: () => MessageKind.text),
            preview: lm['preview'] as String? ?? '',
            at: DateTime.fromMillisecondsSinceEpoch(lm['at'].asMillis ?? 0),
          );
    Map<String, dynamic> m(String k) => (d[k] as Map?)?.cast<String, dynamic>() ?? const {};
    final unread = (m('unread')[_uid] as num?)?.toInt() ?? 0;
    final myDelivered = m('deliveredUpTo')[_uid].asMillis;

    final remote = ChatsCompanion(
      id: Value(id),
      type: Value(d['type'] as String? ?? 'direct'),
      membersJson: Value(jsonEncode(members)),
      peerUid: Value(peer),
      lastMessageJson: Value(last == null ? null : jsonEncode(last.toJson())),
      lastAt: Value(last?.at.millisecondsSinceEpoch ?? 0),
      unread: Value(unread),
      peerReadUpTo: Value(m('readUpTo')[peer].asMillis),
      peerDeliveredUpTo: Value(m('deliveredUpTo')[peer].asMillis),
      myDeliveredUpTo: Value(myDelivered),
    );
    await _db.into(_db.chats).insert(remote, onConflict: DoUpdate((_) => remote));

    if (peer != _uid) unawaited(_users.get(peer));

    // Delivered receipt: the peer's latest message has reached this device.
    if (last != null && last.senderId != _uid && (myDelivered ?? 0) < last.at.millisecondsSinceEpoch) {
      _queueDelivered(id);
    }
  }

  void _queueDelivered(String chatId) {
    _pendingDelivered.add(chatId);
    _deliveredTimer ??= Timer(const Duration(milliseconds: 1500), _flushDelivered);
  }

  Future<void> _flushDelivered() async {
    _deliveredTimer = null;
    if (_pendingDelivered.isEmpty) return;
    final batch = _refs.fs.batch();
    for (final id in _pendingDelivered) {
      batch.update(_refs.chat(id), {
        'deliveredUpTo.$_uid': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    _pendingDelivered.clear();
    try {
      await batch.commit();
    } catch (_) {}
  }

  /// Clears my unread counter and (if allowed) advances my read receipt.
  Future<void> markRead(String chatId) async {
    final row = await chatRow(chatId);
    if (row == null || row.lastAt == 0) return;
    final last = row.lastMessageJson == null ? null : LastMessage.fromJson(jsonDecode(row.lastMessageJson!) as Map<String, dynamic>);
    if (row.unread == 0 && (last == null || last.senderId == _uid)) return;
    await (_db.update(_db.chats)..where((t) => t.id.equals(chatId))).write(const ChatsCompanion(unread: Value(0)));
    if (row.unread == 0 && !shareReadReceipts) return;
    try {
      await _refs.chat(chatId).update({
        'unread.$_uid': 0,
        if (shareReadReceipts) 'readUpTo.$_uid': FieldValue.serverTimestamp(),
        'deliveredUpTo.$_uid': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ---------- local reads ----------

  Future<ChatRow?> chatRow(String id) => (_db.select(_db.chats)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<ChatRow?> watchChatRow(String id) => (_db.select(_db.chats)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Stream<List<ChatSummary>> watchChats({bool archived = false}) {
    final q = _db.select(_db.chats).join([leftOuterJoin(_db.users, _db.users.uid.equalsExp(_db.chats.peerUid))])
      ..where(_db.chats.archived.equals(archived) & _db.chats.lastAt.isBiggerThanValue(0))
      ..orderBy([OrderingTerm.desc(_db.chats.pinned), OrderingTerm.desc(_db.chats.lastAt)]);
    return q.watch().map((rows) => rows.map((r) {
          final c = r.readTable(_db.chats);
          final u = r.readTableOrNull(_db.users);
          return toSummary(c, u == null ? null : UserRepository.fromRow(u));
        }).toList());
  }

  static ChatSummary toSummary(ChatRow c, AppUser? peer) => ChatSummary(
        id: c.id,
        type: ChatType.values.firstWhere((t) => t.name == c.type, orElse: () => ChatType.direct),
        members: List<String>.from(jsonDecode(c.membersJson) as List),
        peerUid: c.peerUid,
        peer: peer,
        last: c.lastMessageJson == null ? null : LastMessage.fromJson(jsonDecode(c.lastMessageJson!) as Map<String, dynamic>),
        unread: c.unread,
        peerReadUpTo: c.peerReadUpTo == null ? null : DateTime.fromMillisecondsSinceEpoch(c.peerReadUpTo!),
        peerDeliveredUpTo: c.peerDeliveredUpTo == null ? null : DateTime.fromMillisecondsSinceEpoch(c.peerDeliveredUpTo!),
        pinned: c.pinned,
        archived: c.archived,
        mutedUntil: c.mutedUntil == null ? null : DateTime.fromMillisecondsSinceEpoch(c.mutedUntil!),
        draft: c.draft,
      );

  Stream<int> watchTotalUnread() {
    final sum = _db.chats.unread.sum();
    final q = _db.selectOnly(_db.chats)
      ..addColumns([sum])
      ..where(_db.chats.archived.equals(false));
    return q.watchSingle().map((r) => r.read(sum) ?? 0);
  }

  // ---------- local-first chat creation ----------

  /// Ensures a local row exists for a direct chat with [peerUid] (the remote
  /// document is created by the first message's batch).
  Future<String> ensureDirect(String peerUid) async {
    final id = peerUid == _uid ? _uid : ChatSummary.directId(_uid, peerUid);
    final members = peerUid == _uid ? [_uid] : ([_uid, peerUid]..sort());
    await _db.into(_db.chats).insert(
          ChatsCompanion.insert(
            id: id,
            type: peerUid == _uid ? 'self' : 'direct',
            membersJson: jsonEncode(members),
            peerUid: Value(peerUid),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return id;
  }

  /// Optimistic chat-list update when I send a message.
  Future<void> setLocalLast(String chatId, LastMessage last) =>
      (_db.update(_db.chats)..where((t) => t.id.equals(chatId))).write(ChatsCompanion(
        lastMessageJson: Value(jsonEncode(last.toJson())),
        lastAt: Value(last.at.millisecondsSinceEpoch),
      ));

  // ---------- per-user chat state (local) ----------

  Future<void> _write(String id, ChatsCompanion c) => (_db.update(_db.chats)..where((t) => t.id.equals(id))).write(c);

  Future<void> setPinned(String id, bool v) => _write(id, ChatsCompanion(pinned: Value(v)));
  Future<void> setArchived(String id, bool v) => _write(id, ChatsCompanion(archived: Value(v)));
  Future<void> setMuted(String id, Duration? d) =>
      _write(id, ChatsCompanion(mutedUntil: Value(d == null ? null : DateTime.now().add(d).millisecondsSinceEpoch)));
  Future<void> setDraft(String id, String? draft) =>
      _write(id, ChatsCompanion(draft: Value(draft?.isEmpty ?? true ? null : draft)));

  /// "Delete chat" for me: hides history locally; new messages reappear.
  Future<void> clearForMe(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await (_db.update(_db.messages)..where((t) => t.chatId.equals(id))).write(const MessagesCompanion(hidden: Value(true)));
      await _write(id, ChatsCompanion(clearedAt: Value(now), lastAt: const Value(0), unread: const Value(0)));
    });
  }
}
