import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide Query;
import 'package:shared_preferences/shared_preferences.dart';

import '../local/app_database.dart';
import '../models/app_user.dart';
import '../models/chat.dart';
import '../models/message_payload.dart';
import '../remote/firestore_refs.dart';
import 'user_repository.dart';

/// Push topic subscription (implemented with FCM in the notifications layer).
abstract interface class TopicSubscriber {
  Future<void> subscribe(String topic);
  Future<void> unsubscribe(String topic);
}

/// Key in SharedPreferences listing muted chat ids (read by the background
/// notification isolate, which has no access to Drift).
const mutedChatsPrefKey = 'mutedChats';

String groupTopic(String chatId, String secret) => 'g_${chatId}_$secret';

/// Keeps the local chat list in sync with Firestore.
///
/// Quota strategy: one listener for the whole list, filtered by
/// `updatedAt > cursor`, so a reconnect only re-reads chats that actually
/// changed since the last sync — never the full list.
class ChatRepository {
  ChatRepository(this._refs, this._db, this._users, this._uid, this._prefs, {this.topics});

  final FirestoreRefs _refs;
  final AppDatabase _db;
  final UserRepository _users;
  final String _uid;
  final SharedPreferences _prefs;
  final TopicSubscriber? topics;

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
    _sub = q.snapshots().listen(
      _onSnapshot,
      onError: (Object _) {
        _sub = null;
        Future.delayed(const Duration(seconds: 5), startSync);
      },
    );
    unawaited(_pullStateOnce());
    unawaited(_resubscribeTopics());
  }

  /// FCM topic subscriptions are idempotent; renewing them on every start
  /// covers reinstalls, token rotation and any earlier failed attempt.
  Future<void> _resubscribeTopics() async {
    final t = topics;
    if (t == null) return;
    final groups =
        await (_db.select(_db.chats)
              ..where((c) => c.type.equals('group') & c.left.equals(false) & c.topicSecret.isNotNull()))
            .get();
    for (final g in groups) {
      await t.subscribe(groupTopic(g.id, g.topicSecret!));
    }
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
      final doc = change.doc;
      if (change.type == DocumentChangeType.removed) {
        // Falls out of `members array-contains me`: I left or was removed.
        // (Also fires for docs scrolling out of the cursor window, so check.)
        final data = doc.data();
        final members = List<String>.from(data?['members'] as List? ?? const []);
        if (data != null && !members.contains(_uid)) await _markLeft(doc.id);
        continue;
      }
      // Local pending writes have null server timestamps; the optimistic row
      // already reflects them, so wait for the server-confirmed snapshot.
      if (doc.metadata.hasPendingWrites) continue;
      final data = doc.data();
      if (data == null) continue;
      await _upsert(doc.id, data);
      final u = millisOf(data['updatedAt']) ?? 0;
      if (u > maxCursor) maxCursor = u;
    }
    if (maxCursor > 0) await _db.setMeta(_cursorKey, '$maxCursor');
  }

  Future<void> _markLeft(String id) async {
    final row = await chatRow(id);
    if (row == null) return;
    if (row.topicSecret != null) unawaited(topics?.unsubscribe(groupTopic(id, row.topicSecret!)));
    await _write(id, const ChatsCompanion(left: Value(true), unread: Value(0)));
  }

  Future<void> _upsert(String id, Map<String, dynamic> d) async {
    final type = d['type'] as String? ?? 'direct';
    final isGroup = type == 'group';
    final members = List<String>.from(d['members'] as List? ?? const []);
    final peer = isGroup ? null : members.firstWhere((m) => m != _uid, orElse: () => _uid);
    final lm = d['lastMessage'] as Map<String, dynamic>?;
    final last = lm == null
        ? null
        : LastMessage(
            id: lm['id'] as String? ?? '',
            senderId: lm['senderId'] as String? ?? '',
            kind: MessageKind.values.firstWhere((k) => k.name == lm['kind'], orElse: () => MessageKind.text),
            preview: lm['preview'] as String? ?? '',
            at: DateTime.fromMillisecondsSinceEpoch(millisOf(lm['at']) ?? 0),
            senderName: lm['senderName'] as String?,
          );
    Map<String, dynamic> m(String k) => (d[k] as Map?)?.cast<String, dynamic>() ?? const {};
    final myDelivered = millisOf(m('deliveredUpTo')[_uid]);

    // Receipts: in a group a message is "read" once every other member read it.
    int? minOthers(String key) {
      final others = members.where((x) => x != _uid).toList();
      if (others.isEmpty) return null;
      int? low;
      for (final o in others) {
        final v = millisOf(m(key)[o]);
        if (v == null) return null;
        if (low == null || v < low) low = v;
      }
      return low;
    }

    final seq = (d['seq'] as num?)?.toInt() ?? 0;
    final readSeq = (m('readSeq')[_uid] as num?)?.toInt() ?? 0;
    final unread = isGroup ? (seq - readSeq).clamp(0, 9999) : (m('unread')[_uid] as num?)?.toInt() ?? 0;
    final previous = await chatRow(id);
    final secret = d['topicSecret'] as String?;

    final remote = ChatsCompanion(
      id: Value(id),
      type: Value(type),
      membersJson: Value(jsonEncode(members)),
      peerUid: Value(peer),
      lastMessageJson: Value(last == null ? null : jsonEncode(last.toJson())),
      lastAt: Value(last?.at.millisecondsSinceEpoch ?? 0),
      unread: Value(unread),
      peerReadUpTo: Value(isGroup ? minOthers('readUpTo') : millisOf(m('readUpTo')[peer])),
      peerDeliveredUpTo: Value(isGroup ? minOthers('deliveredUpTo') : millisOf(m('deliveredUpTo')[peer])),
      myDeliveredUpTo: Value(myDelivered),
      title: Value(d['name'] as String?),
      photoUrl: Value(d['photoUrl'] as String?),
      description: Value(d['description'] as String?),
      adminsJson: Value(jsonEncode(List<String>.from(d['admins'] as List? ?? const []))),
      pinnedJson: Value(jsonEncode(d['pinned'] as List? ?? const [])),
      inviteCode: Value(d['inviteCode'] as String?),
      topicSecret: Value(secret),
      seq: Value(seq),
      readSeq: Value(readSeq),
      left: const Value(false),
    );
    await _db.into(_db.chats).insert(remote, onConflict: DoUpdate((_) => remote));

    if (peer != null && peer != _uid) unawaited(_users.get(peer));

    // Group pushes arrive on a topic whose name embeds a members-only secret;
    // re-subscribe whenever an admin rotates it.
    if (isGroup && secret != null && previous?.topicSecret != secret) {
      if (previous?.topicSecret != null) unawaited(topics?.unsubscribe(groupTopic(id, previous!.topicSecret!)));
      unawaited(topics?.subscribe(groupTopic(id, secret)));
    }

    // Delivered receipt: the latest message has reached this device.
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
    if (row == null || row.lastAt == 0 || row.left) return;
    final last = row.lastMessageJson == null
        ? null
        : LastMessage.fromJson(jsonDecode(row.lastMessageJson!) as Map<String, dynamic>);
    if (row.unread == 0 && (last == null || last.senderId == _uid)) return;
    await _write(chatId, ChatsCompanion(unread: const Value(0), readSeq: Value(row.seq)));
    if (row.unread == 0 && !shareReadReceipts) return;
    final group = row.type == 'group';
    try {
      await _refs.chat(chatId).update({
        if (group) 'readSeq.$_uid': row.seq else 'unread.$_uid': 0,
        if (shareReadReceipts) 'readUpTo.$_uid': FieldValue.serverTimestamp(),
        'deliveredUpTo.$_uid': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ---------- local reads ----------

  Future<ChatRow?> chatRow(String id) => (_db.select(_db.chats)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<ChatRow?> watchChatRow(String id) =>
      (_db.select(_db.chats)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Stream<List<ChatSummary>> watchChats({bool archived = false}) {
    final q = _db.select(_db.chats).join([leftOuterJoin(_db.users, _db.users.uid.equalsExp(_db.chats.peerUid))])
      ..where(_db.chats.archived.equals(archived) & _db.chats.lastAt.isBiggerThanValue(0))
      ..orderBy([OrderingTerm.desc(_db.chats.pinned), OrderingTerm.desc(_db.chats.lastAt)]);
    return q.watch().map(
      (rows) => rows.map((r) {
        final c = r.readTable(_db.chats);
        final u = r.readTableOrNull(_db.users);
        return toSummary(c, u == null ? null : UserRepository.fromRow(u));
      }).toList(),
    );
  }

  Stream<int> watchArchivedCount() {
    final count = _db.chats.id.count();
    final q = _db.selectOnly(_db.chats)
      ..addColumns([count])
      ..where(_db.chats.archived.equals(true) & _db.chats.lastAt.isBiggerThanValue(0));
    return q.watchSingle().map((r) => r.read(count) ?? 0);
  }

  Stream<ChatSummary?> watchSummary(String id) {
    final q = _db.select(_db.chats).join([leftOuterJoin(_db.users, _db.users.uid.equalsExp(_db.chats.peerUid))])
      ..where(_db.chats.id.equals(id));
    return q.watchSingleOrNull().map((r) {
      if (r == null) return null;
      final u = r.readTableOrNull(_db.users);
      return toSummary(r.readTable(_db.chats), u == null ? null : UserRepository.fromRow(u));
    });
  }

  static List<String> _strings(String json) => List<String>.from(jsonDecode(json) as List);

  static ChatSummary toSummary(ChatRow c, AppUser? peer) => ChatSummary(
    id: c.id,
    type: ChatType.values.firstWhere((t) => t.name == c.type, orElse: () => ChatType.direct),
    members: _strings(c.membersJson),
    peerUid: c.peerUid,
    peer: peer,
    last: c.lastMessageJson == null
        ? null
        : LastMessage.fromJson(jsonDecode(c.lastMessageJson!) as Map<String, dynamic>),
    unread: c.unread,
    peerReadUpTo: c.peerReadUpTo == null ? null : DateTime.fromMillisecondsSinceEpoch(c.peerReadUpTo!),
    peerDeliveredUpTo: c.peerDeliveredUpTo == null ? null : DateTime.fromMillisecondsSinceEpoch(c.peerDeliveredUpTo!),
    pinned: c.pinned,
    archived: c.archived,
    mutedUntil: c.mutedUntil == null ? null : DateTime.fromMillisecondsSinceEpoch(c.mutedUntil!),
    draft: c.draft,
    groupName: c.title,
    photoUrl: c.photoUrl,
    description: c.description,
    admins: _strings(c.adminsJson),
    pinnedMessages: [
      for (final p in jsonDecode(c.pinnedJson) as List) PinnedMessage.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
    wallpaper: c.wallpaper,
    accent: c.accent,
    inviteCode: c.inviteCode,
  );

  Stream<int> watchTotalUnread() {
    final sum = _db.chats.unread.sum();
    final q = _db.selectOnly(_db.chats)
      ..addColumns([sum])
      ..where(_db.chats.archived.equals(false) & (_db.chats.mutedUntil.isNull() | _db.chats.mutedUntil.isSmallerThanValue(DateTime.now().millisecondsSinceEpoch)));
    return q.watchSingle().map((r) => r.read(sum) ?? 0);
  }

  // ---------- local-first chat creation ----------

  /// Ensures a local row exists for a direct chat with [peerUid] (the remote
  /// document is created by the first message's batch). [peerUid] == me
  /// opens Saved Messages.
  Future<String> ensureDirect(String peerUid) async {
    final id = peerUid == _uid ? _uid : ChatSummary.directId(_uid, peerUid);
    final members = peerUid == _uid ? [_uid] : ([_uid, peerUid]..sort());
    await _db
        .into(_db.chats)
        .insert(
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

  /// Fetches one chat document immediately (after creating/joining a group),
  /// instead of waiting for the list listener.
  Future<void> fetchOne(String chatId) async {
    final snap = await _refs.chat(chatId).get();
    final d = snap.data();
    if (d != null) await _upsert(chatId, d);
  }

  /// Optimistic chat-list update when I send a message.
  Future<void> setLocalLast(String chatId, LastMessage last) =>
      (_db.update(_db.chats)..where((t) => t.id.equals(chatId))).write(
        ChatsCompanion(
          lastMessageJson: Value(jsonEncode(last.toJson())),
          lastAt: Value(last.at.millisecondsSinceEpoch),
        ),
      );

  // ---------- per-user chat state (local first, synced to users/{me}/chatState) ----------

  Future<void> _write(String id, ChatsCompanion c) => (_db.update(_db.chats)..where((t) => t.id.equals(id))).write(c);

  Future<void> _syncState(String chatId, Map<String, Object?> fields) async {
    try {
      await _refs
          .user(_uid)
          .collection('chatState')
          .doc(chatId)
          .set({...fields, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> setPinned(String id, bool v) async {
    await _write(id, ChatsCompanion(pinned: Value(v)));
    unawaited(_syncState(id, {'pinned': v}));
  }

  Future<void> setArchived(String id, bool v) async {
    await _write(id, ChatsCompanion(archived: Value(v)));
    unawaited(_syncState(id, {'archived': v}));
  }

  Future<void> setMuted(String id, Duration? d) async {
    final until = d == null ? null : DateTime.now().add(d).millisecondsSinceEpoch;
    await _write(id, ChatsCompanion(mutedUntil: Value(until)));
    await _publishMuted();
    unawaited(_syncState(id, {'mutedUntil': until}));
  }

  Future<void> setAppearance(String id, {String? wallpaper, String? accent}) async {
    await _write(id, ChatsCompanion(wallpaper: Value(wallpaper), accent: Value(accent)));
    unawaited(_syncState(id, {'wallpaper': wallpaper, 'accent': accent}));
  }

  Future<void> setDraft(String id, String? draft) =>
      _write(id, ChatsCompanion(draft: Value(draft?.isEmpty ?? true ? null : draft)));

  /// Mirrors muted chat ids into SharedPreferences for the background
  /// notification handler.
  Future<void> _publishMuted() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = await (_db.select(_db.chats)..where((t) => t.mutedUntil.isBiggerThanValue(now))).get();
    await _prefs.setStringList(mutedChatsPrefKey, rows.map((r) => r.id).toList());
  }

  /// Fresh install: restore pins/archives/mutes/wallpapers and folders once.
  Future<void> _pullStateOnce() async {
    if (await _db.getMeta('stateSynced') == '1') return;
    try {
      final states = await _refs.user(_uid).collection('chatState').get();
      for (final s in states.docs) {
        final d = s.data();
        await _db
            .into(_db.chats)
            .insert(
              ChatsCompanion.insert(id: s.id, type: s.id == _uid ? 'self' : 'direct', membersJson: '[]'),
              mode: InsertMode.insertOrIgnore,
            );
        await _write(
          s.id,
          ChatsCompanion(
            pinned: Value(d['pinned'] == true),
            archived: Value(d['archived'] == true),
            mutedUntil: Value((d['mutedUntil'] as num?)?.toInt()),
            wallpaper: Value(d['wallpaper'] as String?),
            accent: Value(d['accent'] as String?),
          ),
        );
      }
      final folders = await _refs.user(_uid).collection('folders').get();
      for (final f in folders.docs) {
        final d = f.data();
        await _db
            .into(_db.folders)
            .insertOnConflictUpdate(
              FoldersCompanion.insert(
                id: f.id,
                name: d['name'] as String? ?? 'Folder',
                flags: Value((d['flags'] as num?)?.toInt() ?? 0),
                chatIdsJson: Value(jsonEncode(d['chatIds'] as List? ?? const [])),
                sortOrder: Value((d['order'] as num?)?.toInt() ?? 0),
              ),
            );
      }
      await _publishMuted();
      await _db.setMeta('stateSynced', '1');
    } catch (_) {}
  }

  /// "Delete chat" for me: hides history locally; new messages reappear.
  Future<void> clearForMe(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((t) => t.chatId.equals(id))).write(const MessagesCompanion(hidden: Value(true)));
      await _write(id, ChatsCompanion(clearedAt: Value(now), lastAt: const Value(0), unread: const Value(0)));
    });
  }

  // ---------- folders ----------

  Stream<List<ChatFolder>> watchFolders() =>
      (_db.select(_db.folders)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch().map(
        (rows) => [
          for (final r in rows)
            ChatFolder.fromFlags(
              id: r.id,
              name: r.name,
              flags: r.flags,
              chatIds: _strings(r.chatIdsJson),
              order: r.sortOrder,
            ),
        ],
      );

  Future<void> saveFolder(ChatFolder f) async {
    await _db
        .into(_db.folders)
        .insertOnConflictUpdate(
          FoldersCompanion.insert(
            id: f.id,
            name: f.name,
            flags: Value(f.flags),
            chatIdsJson: Value(jsonEncode(f.chatIds)),
            sortOrder: Value(f.order),
          ),
        );
    unawaited(_refs.user(_uid).collection('folders').doc(f.id).set(f.toMap()).catchError((_) {}));
  }

  Future<void> deleteFolder(String id) async {
    await (_db.delete(_db.folders)..where((t) => t.id.equals(id))).go();
    unawaited(_refs.user(_uid).collection('folders').doc(id).delete().catchError((_) {}));
  }

  String newFolderId() => _refs.user(_uid).collection('folders').doc().id;
}
