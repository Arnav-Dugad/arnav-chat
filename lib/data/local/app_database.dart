import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Cached public profiles.
@DataClassName('UserRow')
class Users extends Table {
  TextColumn get uid => text()();
  TextColumn get username => text()();
  TextColumn get displayName => text()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get bio => text().nullable()();
  TextColumn get privacyJson => text().withDefault(const Constant('{}'))();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column> get primaryKey => {uid};
}

@DataClassName('ChatRow')
class Chats extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get membersJson => text()();
  TextColumn get peerUid => text().nullable()();
  TextColumn get lastMessageJson => text().nullable()();
  IntColumn get lastAt => integer().withDefault(const Constant(0))();
  IntColumn get unread => integer().withDefault(const Constant(0))();
  IntColumn get peerReadUpTo => integer().nullable()();
  IntColumn get peerDeliveredUpTo => integer().nullable()();
  IntColumn get myDeliveredUpTo => integer().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get mutedUntil => integer().nullable()();
  TextColumn get draft => text().nullable()();

  /// Highest message `updatedAt` (ms) already synced — listeners resume here.
  IntColumn get msgCursor => integer().nullable()();
  BoolColumn get hasMoreOlder => boolean().withDefault(const Constant(true))();

  /// Messages before this time (ms) are hidden ("delete chat" for me).
  IntColumn get clearedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MessageRow')
@TableIndex(name: 'messages_chat_created', columns: {#chatId, #createdAt})
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  IntColumn get createdAt => integer()();
  BoolColumn get serverConfirmed => boolean().withDefault(const Constant(false))();
  IntColumn get updatedAt => integer().nullable()();
  TextColumn get payloadJson => text()();
  TextColumn get replyJson => text().nullable()();
  BoolColumn get forwarded => boolean().withDefault(const Constant(false))();
  IntColumn get editedAt => integer().nullable()();
  BoolColumn get deletedForEveryone => boolean().withDefault(const Constant(false))();
  TextColumn get reactionsJson => text().withDefault(const Constant('{}'))();

  /// 0 = sent, 1 = pending, 2 = failed (see SendState).
  IntColumn get sendState => integer().withDefault(const Constant(0))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  TextColumn get localPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ContactRow')
class Contacts extends Table {
  TextColumn get uid => text()();
  IntColumn get addedAt => integer()();

  @override
  Set<Column> get primaryKey => {uid};
}

/// Small key/value store for sync cursors.
@DataClassName('MetaRow')
class Meta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Users, Chats, Messages, Contacts, Meta])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String uid) : super(_open(uid));

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open(String uid) => driftDatabase(
        name: 'arnav_chat_$uid',
        native: const DriftNativeOptions(shareAcrossIsolates: true),
        web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js')),
      );

  Future<String?> getMeta(String key) async =>
      (await (select(meta)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setMeta(String key, String value) =>
      into(meta).insertOnConflictUpdate(MetaCompanion.insert(key: key, value: value));
}
