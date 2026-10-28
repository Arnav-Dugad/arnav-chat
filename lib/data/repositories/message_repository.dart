import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide Query;

import '../local/app_database.dart';
import '../models/message.dart';
import '../models/message_payload.dart';
import '../remote/firestore_refs.dart';
import '../remote/message_writer.dart';

/// Messages: Drift is the source of truth for the UI; Firestore is synced
/// into it.
///
/// Quota strategy:
///  * history is fetched in pages of [pageSize] and only once (cached forever);
///  * the open chat has exactly one listener, `updatedAt > cursor`, so it only
///    ever reads new or modified messages;
///  * no listeners for chats that are not on screen.
class MessageRepository {
  MessageRepository(this._refs, this._db, this._writer, this._uid);

  final FirestoreRefs _refs;
  final AppDatabase _db;
  final MessageWriter _writer;
  final String _uid;

  static const pageSize = 30;
  PayloadCodec get codec => _writer.codec;

  // ---------- reading ----------

  Stream<List<Message>> watch(String chatId, {required int limit}) {
    final q = _db.select(_db.messages)
      ..where((t) => t.chatId.equals(chatId) & t.hidden.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    return q.watch().map((rows) => rows.map(fromRow).toList());
  }

  Future<int> localCount(String chatId) async {
    final c = _db.messages.id.count();
    final q = _db.selectOnly(_db.messages)
      ..addColumns([c])
      ..where(_db.messages.chatId.equals(chatId) & _db.messages.hidden.equals(false));
    return (await q.getSingle()).read(c) ?? 0;
  }

  Message fromRow(MessageRow r) => Message(
    id: r.id,
    chatId: r.chatId,
    senderId: r.senderId,
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
    serverConfirmed: r.serverConfirmed,
    payload: codec.decode(jsonDecode(r.payloadJson) as Map<String, dynamic>),
    reply: r.replyJson == null ? null : ReplyRef.fromMap(jsonDecode(r.replyJson!) as Map<String, dynamic>),
    forwarded: r.forwarded,
    editedAt: r.editedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(r.editedAt!),
    deletedForEveryone: r.deletedForEveryone,
    reactions: Map<String, String>.from(jsonDecode(r.reactionsJson) as Map),
    votes: (jsonDecode(r.votesJson) as Map).map((k, v) => MapEntry(k as String, List<String>.from(v as List))),
    state: SendState.values[r.sendState],
    starred: r.starred,
    localPath: r.localPath,
  );

  /// Attaches the single live listener for the visible chat. Returns a handle
  /// to cancel when the chat leaves the screen.
  Future<StreamSubscription<void>?> attach(String chatId) async {
    final chat = await (_db.select(_db.chats)..where((t) => t.id.equals(chatId))).getSingleOrNull();
    if (chat == null || chat.lastAt == 0 && chat.msgCursor == null) {
      // No remote chat yet (it is created by the first message).
      bool exists;
      try {
        exists = (await _refs.chat(chatId).get()).exists;
      } catch (_) {
        exists = false;
      }
      if (!exists) return null;
    }
    var cursor = chat?.msgCursor;
    cursor ??= await _fetchLatestPage(chatId);
    final q = _refs
        .messages(chatId)
        .where('updatedAt', isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(cursor ?? 0))
        .orderBy('updatedAt');
    return q.snapshots().listen((snap) async {
      var max = cursor ?? 0;
      for (final ch in snap.docChanges) {
        if (ch.type == DocumentChangeType.removed) continue;
        final u = await _upsertDoc(chatId, ch.doc);
        if (u != null && !ch.doc.metadata.hasPendingWrites && u > max) max = u;
      }
      if (max > (cursor ?? 0)) {
        cursor = max;
        await _setCursor(chatId, max);
      }
    }, onError: (Object _) {});
  }

  Future<int?> _fetchLatestPage(String chatId) async {
    final snap = await _refs.messages(chatId).orderBy('createdAt', descending: true).limit(pageSize).get();
    var max = 0;
    await _db.transaction(() async {
      for (final d in snap.docs) {
        final u = await _upsertDoc(chatId, d) ?? 0;
        if (u > max) max = u;
      }
    });
    await (_db.update(_db.chats)..where((t) => t.id.equals(chatId))).write(
      ChatsCompanion(hasMoreOlder: Value(snap.size == pageSize), msgCursor: Value(max == 0 ? null : max)),
    );
    return max == 0 ? null : max;
  }

  Future<void> _setCursor(String chatId, int cursor) =>
      (_db.update(_db.chats)..where((t) => t.id.equals(chatId))).write(ChatsCompanion(msgCursor: Value(cursor)));

  /// Loads the next older page from Firestore (only when the local cache has
  /// run out). Returns false when there is no more history.
  Future<bool> loadOlder(String chatId) async {
    final chat = await (_db.select(_db.chats)..where((t) => t.id.equals(chatId))).getSingleOrNull();
    if (chat == null || !chat.hasMoreOlder) return false;
    final oldest =
        await (_db.select(_db.messages)
              ..where((t) => t.chatId.equals(chatId) & t.serverConfirmed.equals(true))
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    Query<Map<String, dynamic>> q = _refs.messages(chatId).orderBy('createdAt', descending: true).limit(pageSize);
    if (oldest != null) q = q.startAfter([Timestamp.fromMillisecondsSinceEpoch(oldest.createdAt)]);
    final snap = await q.get();
    await _db.transaction(() async {
      for (final d in snap.docs) {
        await _upsertDoc(chatId, d);
      }
    });
    final more = snap.size == pageSize;
    await (_db.update(_db.chats)..where((t) => t.id.equals(chatId))).write(ChatsCompanion(hasMoreOlder: Value(more)));
    return more;
  }

  /// Writes a Firestore message into Drift without clobbering local-only
  /// fields (starred, hidden, localPath). Returns the doc's updatedAt (ms).
  Future<int?> _upsertDoc(String chatId, DocumentSnapshot<Map<String, dynamic>> doc) async {
    if (doc.metadata.hasPendingWrites) return null; // optimistic row already exists
    final d = doc.data();
    if (d == null) return null;
    final created =
        millisOf(d['createdAt']) ?? (d['clientTs'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;
    final updated = millisOf(d['updatedAt']);
    final reactions = (d['reactions'] as Map?)?.map((k, v) => MapEntry(k as String, v as String)) ?? const {};
    final votes = (d['votes'] as Map?)?.map((k, v) => MapEntry(k as String, List<String>.from(v as List))) ?? const {};
    final index = indexFor(codec.decode(Map<String, dynamic>.from(d['payload'] as Map? ?? const {})));
    final chat = await (_db.select(_db.chats)..where((t) => t.id.equals(chatId))).getSingleOrNull();
    final hidden = chat?.clearedAt != null && created <= chat!.clearedAt!;
    final remote = MessagesCompanion(
      id: Value(doc.id),
      chatId: Value(chatId),
      senderId: Value(d['senderId'] as String? ?? ''),
      createdAt: Value(created),
      serverConfirmed: Value(!doc.metadata.hasPendingWrites),
      updatedAt: Value(updated),
      payloadJson: Value(jsonEncode(d['payload'] ?? const {})),
      replyJson: Value(d['reply'] == null ? null : jsonEncode(d['reply'])),
      forwarded: Value(d['forwarded'] == true),
      editedAt: Value(millisOf(d['editedAt'])),
      deletedForEveryone: Value(d['deleted'] == true),
      reactionsJson: Value(jsonEncode(reactions)),
      votesJson: Value(jsonEncode(votes)),
      kind: Value(index.kind),
      searchText: Value(index.text),
      sendState: const Value(0),
    );
    await _db.into(_db.messages).insert(remote.copyWith(hidden: Value(hidden)), onConflict: DoUpdate((_) => remote));
    return updated;
  }

  // ---------- local mutations (optimistic) ----------

  Future<void> insertPending({
    required String id,
    required String chatId,
    required MessagePayload payload,
    required int createdAt,
    ReplyRef? reply,
    bool forwarded = false,
    String? localPath,
  }) => _db
      .into(_db.messages)
      .insert(
        MessagesCompanion.insert(
          id: id,
          chatId: chatId,
          senderId: _uid,
          createdAt: createdAt,
          kind: Value(indexFor(payload).kind),
          searchText: Value(indexFor(payload).text),
          payloadJson: jsonEncode(codec.encode(payload)),
          replyJson: Value(reply == null ? null : jsonEncode(reply.toMap())),
          forwarded: Value(forwarded),
          sendState: const Value(1),
          localPath: Value(localPath),
        ),
      );

  Future<List<MessageRow>> pendingOutbox() =>
      (_db.select(_db.messages)
            ..where((t) => t.sendState.isIn(const [1, 2]) & t.senderId.equals(_uid))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<void> setSendState(String id, SendState s, {bool bumpAttempts = false}) async {
    final row = await (_db.select(_db.messages)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (_db.update(_db.messages)..where((t) => t.id.equals(id))).write(
      MessagesCompanion(sendState: Value(s.index), attempts: Value(bumpAttempts ? row.attempts + 1 : row.attempts)),
    );
  }

  Future<void> setPayload(String id, MessagePayload p) => (_db.update(_db.messages)..where((t) => t.id.equals(id))).write(
    MessagesCompanion(payloadJson: Value(jsonEncode(codec.encode(p))), searchText: Value(indexFor(p).text)),
  );

  Future<void> edit(String chatId, String id, String text) async {
    final p = MessagePayload.text(text);
    await (_db.update(_db.messages)..where((t) => t.id.equals(id))).write(
      MessagesCompanion(
        payloadJson: Value(jsonEncode(codec.encode(p))),
        searchText: Value(indexFor(p).text),
        editedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    unawaited(_writer.edit(chatId, id, p).catchError((_) {}));
  }

  Future<void> deleteForEveryone(String chatId, String id, {required bool wasLast}) async {
    await (_db.update(_db.messages)..where((t) => t.id.equals(id))).write(
      MessagesCompanion(
        payloadJson: Value(jsonEncode(codec.encode(MessagePayload.deleted))),
        deletedForEveryone: const Value(true),
      ),
    );
    unawaited(_writer.deleteForEveryone(chatId, id, wasLast: wasLast, senderId: _uid).catchError((_) {}));
  }

  Future<void> deleteForMe(String id) =>
      (_db.update(_db.messages)..where((t) => t.id.equals(id))).write(const MessagesCompanion(hidden: Value(true)));

  Future<void> react(String chatId, String id, String? emoji) async {
    final row = await (_db.select(_db.messages)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    final r = Map<String, String>.from(jsonDecode(row.reactionsJson) as Map);
    emoji == null ? r.remove(_uid) : r[_uid] = emoji;
    await (_db.update(
      _db.messages,
    )..where((t) => t.id.equals(id))).write(MessagesCompanion(reactionsJson: Value(jsonEncode(r))));
    unawaited(_writer.react(chatId, id, _uid, emoji).catchError((_) {}));
  }

  Future<void> setStarred(String id, bool v) =>
      (_db.update(_db.messages)..where((t) => t.id.equals(id))).write(MessagesCompanion(starred: Value(v)));

  Stream<List<Message>> watchStarred() =>
      (_db.select(_db.messages)
            ..where((t) => t.starred.equals(true) & t.hidden.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch()
          .map((rows) => rows.map(fromRow).toList());

  /// Toggle (single choice) or add/remove (multi) my vote, optimistically.
  Future<void> vote(Message m, String optionId) async {
    final poll = m.payload.poll;
    if (poll == null) return;
    final mine = List<String>.from(m.votes[_uid] ?? const []);
    if (mine.contains(optionId)) {
      mine.remove(optionId);
    } else if (poll.multi) {
      mine.add(optionId);
    } else {
      mine
        ..clear()
        ..add(optionId);
    }
    final votes = Map<String, List<String>>.from(m.votes);
    mine.isEmpty ? votes.remove(_uid) : votes[_uid] = mine;
    await (_db.update(_db.messages)..where((t) => t.id.equals(m.id))).write(
      MessagesCompanion(votesJson: Value(jsonEncode(votes))),
    );
    unawaited(_writer.vote(m.chatId, m.id, _uid, mine).catchError((_) {}));
  }

  // ---------- search & gallery (local cache, zero Firestore reads) ----------

  Future<List<Message>> search(String query, {int limit = 60}) async {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return const [];
    final rows =
        await (_db.select(_db.messages)
              ..where((t) => t.hidden.equals(false) & t.deletedForEveryone.equals(false) & t.searchText.like('%$q%'))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(limit))
            .get();
    return rows.map(fromRow).toList();
  }

  /// [kinds]: e.g. ['image', 'video'] for media, ['link'] for links.
  Stream<List<Message>> watchGallery(String chatId, List<String> kinds) =>
      (_db.select(_db.messages)
            ..where(
              (t) =>
                  t.chatId.equals(chatId) & t.hidden.equals(false) & t.deletedForEveryone.equals(false) & t.kind.isIn(kinds),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch()
          .map((rows) => rows.map(fromRow).toList());

  /// Index of the newest-first message list for [messageId], or -1.
  Future<int> positionOf(String chatId, String messageId) async {
    final target = await (_db.select(_db.messages)..where((t) => t.id.equals(messageId))).getSingleOrNull();
    if (target == null) return -1;
    final c = _db.messages.id.count();
    final q = _db.selectOnly(_db.messages)
      ..addColumns([c])
      ..where(
        _db.messages.chatId.equals(chatId) &
            _db.messages.hidden.equals(false) &
            _db.messages.createdAt.isBiggerThanValue(target.createdAt),
      );
    return (await q.getSingle()).read(c) ?? -1;
  }

  Future<Message?> byId(String id) async {
    final r = await (_db.select(_db.messages)..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : fromRow(r);
  }
}

/// Searchable text + gallery kind for a payload.
({String kind, String text}) indexFor(MessagePayload p) {
  final hasLink = p.link != null || RegExp(r'https?://', caseSensitive: false).hasMatch(p.text ?? '');
  final kind = switch (p.kind) {
    MessageKind.text when hasLink => 'link',
    final k => k.name,
  };
  final parts = [
    p.text ?? '',
    p.media?.name ?? '',
    p.link?.title ?? '',
    for (final o in p.poll?.options ?? const <PollOption>[]) o.text,
  ];
  return (kind: kind, text: parts.where((e) => e.isNotEmpty).join(' ').toLowerCase());
}
