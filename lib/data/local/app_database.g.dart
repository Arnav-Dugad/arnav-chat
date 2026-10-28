// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _privacyJsonMeta = const VerificationMeta('privacyJson');
  @override
  late final GeneratedColumn<String> privacyJson = GeneratedColumn<String>(
    'privacy_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [uid, username, displayName, photoUrl, bio, privacyJson, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(_uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta, username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(_displayNameMeta, displayName.isAcceptableOrUnknown(data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta, photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('bio')) {
      context.handle(_bioMeta, bio.isAcceptableOrUnknown(data['bio']!, _bioMeta));
    }
    if (data.containsKey('privacy_json')) {
      context.handle(_privacyJsonMeta, privacyJson.isAcceptableOrUnknown(data['privacy_json']!, _privacyJsonMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta, fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      uid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      username: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      displayName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      photoUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      bio: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}bio']),
      privacyJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}privacy_json'])!,
      fetchedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String uid;
  final String username;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final String privacyJson;
  final int fetchedAt;
  const UserRow({
    required this.uid,
    required this.username,
    required this.displayName,
    this.photoUrl,
    this.bio,
    required this.privacyJson,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['username'] = Variable<String>(username);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    map['privacy_json'] = Variable<String>(privacyJson);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      uid: Value(uid),
      username: Value(username),
      displayName: Value(displayName),
      photoUrl: photoUrl == null && nullToAbsent ? const Value.absent() : Value(photoUrl),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      privacyJson: Value(privacyJson),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory UserRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      uid: serializer.fromJson<String>(json['uid']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String>(json['displayName']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      bio: serializer.fromJson<String?>(json['bio']),
      privacyJson: serializer.fromJson<String>(json['privacyJson']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String>(displayName),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'bio': serializer.toJson<String?>(bio),
      'privacyJson': serializer.toJson<String>(privacyJson),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  UserRow copyWith({
    String? uid,
    String? username,
    String? displayName,
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> bio = const Value.absent(),
    String? privacyJson,
    int? fetchedAt,
  }) => UserRow(
    uid: uid ?? this.uid,
    username: username ?? this.username,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    bio: bio.present ? bio.value : this.bio,
    privacyJson: privacyJson ?? this.privacyJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      uid: data.uid.present ? data.uid.value : this.uid,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present ? data.displayName.value : this.displayName,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      bio: data.bio.present ? data.bio.value : this.bio,
      privacyJson: data.privacyJson.present ? data.privacyJson.value : this.privacyJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('uid: $uid, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('bio: $bio, ')
          ..write('privacyJson: $privacyJson, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, username, displayName, photoUrl, bio, privacyJson, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.uid == this.uid &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.photoUrl == this.photoUrl &&
          other.bio == this.bio &&
          other.privacyJson == this.privacyJson &&
          other.fetchedAt == this.fetchedAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> uid;
  final Value<String> username;
  final Value<String> displayName;
  final Value<String?> photoUrl;
  final Value<String?> bio;
  final Value<String> privacyJson;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.uid = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.bio = const Value.absent(),
    this.privacyJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String uid,
    required String username,
    required String displayName,
    this.photoUrl = const Value.absent(),
    this.bio = const Value.absent(),
    this.privacyJson = const Value.absent(),
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : uid = Value(uid),
       username = Value(username),
       displayName = Value(displayName),
       fetchedAt = Value(fetchedAt);
  static Insertable<UserRow> custom({
    Expression<String>? uid,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? photoUrl,
    Expression<String>? bio,
    Expression<String>? privacyJson,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (bio != null) 'bio': bio,
      if (privacyJson != null) 'privacy_json': privacyJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? uid,
    Value<String>? username,
    Value<String>? displayName,
    Value<String?>? photoUrl,
    Value<String?>? bio,
    Value<String>? privacyJson,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      privacyJson: privacyJson ?? this.privacyJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (privacyJson.present) {
      map['privacy_json'] = Variable<String>(privacyJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('uid: $uid, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('bio: $bio, ')
          ..write('privacyJson: $privacyJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatsTable extends Chats with TableInfo<$ChatsTable, ChatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _membersJsonMeta = const VerificationMeta('membersJson');
  @override
  late final GeneratedColumn<String> membersJson = GeneratedColumn<String>(
    'members_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peerUidMeta = const VerificationMeta('peerUid');
  @override
  late final GeneratedColumn<String> peerUid = GeneratedColumn<String>(
    'peer_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageJsonMeta = const VerificationMeta('lastMessageJson');
  @override
  late final GeneratedColumn<String> lastMessageJson = GeneratedColumn<String>(
    'last_message_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAtMeta = const VerificationMeta('lastAt');
  @override
  late final GeneratedColumn<int> lastAt = GeneratedColumn<int>(
    'last_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unreadMeta = const VerificationMeta('unread');
  @override
  late final GeneratedColumn<int> unread = GeneratedColumn<int>(
    'unread',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _peerReadUpToMeta = const VerificationMeta('peerReadUpTo');
  @override
  late final GeneratedColumn<int> peerReadUpTo = GeneratedColumn<int>(
    'peer_read_up_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peerDeliveredUpToMeta = const VerificationMeta('peerDeliveredUpTo');
  @override
  late final GeneratedColumn<int> peerDeliveredUpTo = GeneratedColumn<int>(
    'peer_delivered_up_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _myDeliveredUpToMeta = const VerificationMeta('myDeliveredUpTo');
  @override
  late final GeneratedColumn<int> myDeliveredUpTo = GeneratedColumn<int>(
    'my_delivered_up_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("pinned" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mutedUntilMeta = const VerificationMeta('mutedUntil');
  @override
  late final GeneratedColumn<int> mutedUntil = GeneratedColumn<int>(
    'muted_until',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _draftMeta = const VerificationMeta('draft');
  @override
  late final GeneratedColumn<String> draft = GeneratedColumn<String>(
    'draft',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _msgCursorMeta = const VerificationMeta('msgCursor');
  @override
  late final GeneratedColumn<int> msgCursor = GeneratedColumn<int>(
    'msg_cursor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasMoreOlderMeta = const VerificationMeta('hasMoreOlder');
  @override
  late final GeneratedColumn<bool> hasMoreOlder = GeneratedColumn<bool>(
    'has_more_older',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("has_more_older" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _clearedAtMeta = const VerificationMeta('clearedAt');
  @override
  late final GeneratedColumn<int> clearedAt = GeneratedColumn<int>(
    'cleared_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    membersJson,
    peerUid,
    lastMessageJson,
    lastAt,
    unread,
    peerReadUpTo,
    peerDeliveredUpTo,
    myDeliveredUpTo,
    pinned,
    archived,
    mutedUntil,
    draft,
    msgCursor,
    hasMoreOlder,
    clearedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(Insertable<ChatRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('members_json')) {
      context.handle(_membersJsonMeta, membersJson.isAcceptableOrUnknown(data['members_json']!, _membersJsonMeta));
    } else if (isInserting) {
      context.missing(_membersJsonMeta);
    }
    if (data.containsKey('peer_uid')) {
      context.handle(_peerUidMeta, peerUid.isAcceptableOrUnknown(data['peer_uid']!, _peerUidMeta));
    }
    if (data.containsKey('last_message_json')) {
      context.handle(
        _lastMessageJsonMeta,
        lastMessageJson.isAcceptableOrUnknown(data['last_message_json']!, _lastMessageJsonMeta),
      );
    }
    if (data.containsKey('last_at')) {
      context.handle(_lastAtMeta, lastAt.isAcceptableOrUnknown(data['last_at']!, _lastAtMeta));
    }
    if (data.containsKey('unread')) {
      context.handle(_unreadMeta, unread.isAcceptableOrUnknown(data['unread']!, _unreadMeta));
    }
    if (data.containsKey('peer_read_up_to')) {
      context.handle(
        _peerReadUpToMeta,
        peerReadUpTo.isAcceptableOrUnknown(data['peer_read_up_to']!, _peerReadUpToMeta),
      );
    }
    if (data.containsKey('peer_delivered_up_to')) {
      context.handle(
        _peerDeliveredUpToMeta,
        peerDeliveredUpTo.isAcceptableOrUnknown(data['peer_delivered_up_to']!, _peerDeliveredUpToMeta),
      );
    }
    if (data.containsKey('my_delivered_up_to')) {
      context.handle(
        _myDeliveredUpToMeta,
        myDeliveredUpTo.isAcceptableOrUnknown(data['my_delivered_up_to']!, _myDeliveredUpToMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(_pinnedMeta, pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    if (data.containsKey('muted_until')) {
      context.handle(_mutedUntilMeta, mutedUntil.isAcceptableOrUnknown(data['muted_until']!, _mutedUntilMeta));
    }
    if (data.containsKey('draft')) {
      context.handle(_draftMeta, draft.isAcceptableOrUnknown(data['draft']!, _draftMeta));
    }
    if (data.containsKey('msg_cursor')) {
      context.handle(_msgCursorMeta, msgCursor.isAcceptableOrUnknown(data['msg_cursor']!, _msgCursorMeta));
    }
    if (data.containsKey('has_more_older')) {
      context.handle(_hasMoreOlderMeta, hasMoreOlder.isAcceptableOrUnknown(data['has_more_older']!, _hasMoreOlderMeta));
    }
    if (data.containsKey('cleared_at')) {
      context.handle(_clearedAtMeta, clearedAt.isAcceptableOrUnknown(data['cleared_at']!, _clearedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      membersJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}members_json'])!,
      peerUid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}peer_uid']),
      lastMessageJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_json'],
      ),
      lastAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}last_at'])!,
      unread: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}unread'])!,
      peerReadUpTo: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}peer_read_up_to']),
      peerDeliveredUpTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peer_delivered_up_to'],
      ),
      myDeliveredUpTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}my_delivered_up_to'],
      ),
      pinned: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}pinned'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      mutedUntil: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}muted_until']),
      draft: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}draft']),
      msgCursor: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}msg_cursor']),
      hasMoreOlder: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}has_more_older'])!,
      clearedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cleared_at']),
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class ChatRow extends DataClass implements Insertable<ChatRow> {
  final String id;
  final String type;
  final String membersJson;
  final String? peerUid;
  final String? lastMessageJson;
  final int lastAt;
  final int unread;
  final int? peerReadUpTo;
  final int? peerDeliveredUpTo;
  final int? myDeliveredUpTo;
  final bool pinned;
  final bool archived;
  final int? mutedUntil;
  final String? draft;

  /// Highest message `updatedAt` (ms) already synced — listeners resume here.
  final int? msgCursor;
  final bool hasMoreOlder;

  /// Messages before this time (ms) are hidden ("delete chat" for me).
  final int? clearedAt;
  const ChatRow({
    required this.id,
    required this.type,
    required this.membersJson,
    this.peerUid,
    this.lastMessageJson,
    required this.lastAt,
    required this.unread,
    this.peerReadUpTo,
    this.peerDeliveredUpTo,
    this.myDeliveredUpTo,
    required this.pinned,
    required this.archived,
    this.mutedUntil,
    this.draft,
    this.msgCursor,
    required this.hasMoreOlder,
    this.clearedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['members_json'] = Variable<String>(membersJson);
    if (!nullToAbsent || peerUid != null) {
      map['peer_uid'] = Variable<String>(peerUid);
    }
    if (!nullToAbsent || lastMessageJson != null) {
      map['last_message_json'] = Variable<String>(lastMessageJson);
    }
    map['last_at'] = Variable<int>(lastAt);
    map['unread'] = Variable<int>(unread);
    if (!nullToAbsent || peerReadUpTo != null) {
      map['peer_read_up_to'] = Variable<int>(peerReadUpTo);
    }
    if (!nullToAbsent || peerDeliveredUpTo != null) {
      map['peer_delivered_up_to'] = Variable<int>(peerDeliveredUpTo);
    }
    if (!nullToAbsent || myDeliveredUpTo != null) {
      map['my_delivered_up_to'] = Variable<int>(myDeliveredUpTo);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || mutedUntil != null) {
      map['muted_until'] = Variable<int>(mutedUntil);
    }
    if (!nullToAbsent || draft != null) {
      map['draft'] = Variable<String>(draft);
    }
    if (!nullToAbsent || msgCursor != null) {
      map['msg_cursor'] = Variable<int>(msgCursor);
    }
    map['has_more_older'] = Variable<bool>(hasMoreOlder);
    if (!nullToAbsent || clearedAt != null) {
      map['cleared_at'] = Variable<int>(clearedAt);
    }
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      id: Value(id),
      type: Value(type),
      membersJson: Value(membersJson),
      peerUid: peerUid == null && nullToAbsent ? const Value.absent() : Value(peerUid),
      lastMessageJson: lastMessageJson == null && nullToAbsent ? const Value.absent() : Value(lastMessageJson),
      lastAt: Value(lastAt),
      unread: Value(unread),
      peerReadUpTo: peerReadUpTo == null && nullToAbsent ? const Value.absent() : Value(peerReadUpTo),
      peerDeliveredUpTo: peerDeliveredUpTo == null && nullToAbsent ? const Value.absent() : Value(peerDeliveredUpTo),
      myDeliveredUpTo: myDeliveredUpTo == null && nullToAbsent ? const Value.absent() : Value(myDeliveredUpTo),
      pinned: Value(pinned),
      archived: Value(archived),
      mutedUntil: mutedUntil == null && nullToAbsent ? const Value.absent() : Value(mutedUntil),
      draft: draft == null && nullToAbsent ? const Value.absent() : Value(draft),
      msgCursor: msgCursor == null && nullToAbsent ? const Value.absent() : Value(msgCursor),
      hasMoreOlder: Value(hasMoreOlder),
      clearedAt: clearedAt == null && nullToAbsent ? const Value.absent() : Value(clearedAt),
    );
  }

  factory ChatRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      membersJson: serializer.fromJson<String>(json['membersJson']),
      peerUid: serializer.fromJson<String?>(json['peerUid']),
      lastMessageJson: serializer.fromJson<String?>(json['lastMessageJson']),
      lastAt: serializer.fromJson<int>(json['lastAt']),
      unread: serializer.fromJson<int>(json['unread']),
      peerReadUpTo: serializer.fromJson<int?>(json['peerReadUpTo']),
      peerDeliveredUpTo: serializer.fromJson<int?>(json['peerDeliveredUpTo']),
      myDeliveredUpTo: serializer.fromJson<int?>(json['myDeliveredUpTo']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      archived: serializer.fromJson<bool>(json['archived']),
      mutedUntil: serializer.fromJson<int?>(json['mutedUntil']),
      draft: serializer.fromJson<String?>(json['draft']),
      msgCursor: serializer.fromJson<int?>(json['msgCursor']),
      hasMoreOlder: serializer.fromJson<bool>(json['hasMoreOlder']),
      clearedAt: serializer.fromJson<int?>(json['clearedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'membersJson': serializer.toJson<String>(membersJson),
      'peerUid': serializer.toJson<String?>(peerUid),
      'lastMessageJson': serializer.toJson<String?>(lastMessageJson),
      'lastAt': serializer.toJson<int>(lastAt),
      'unread': serializer.toJson<int>(unread),
      'peerReadUpTo': serializer.toJson<int?>(peerReadUpTo),
      'peerDeliveredUpTo': serializer.toJson<int?>(peerDeliveredUpTo),
      'myDeliveredUpTo': serializer.toJson<int?>(myDeliveredUpTo),
      'pinned': serializer.toJson<bool>(pinned),
      'archived': serializer.toJson<bool>(archived),
      'mutedUntil': serializer.toJson<int?>(mutedUntil),
      'draft': serializer.toJson<String?>(draft),
      'msgCursor': serializer.toJson<int?>(msgCursor),
      'hasMoreOlder': serializer.toJson<bool>(hasMoreOlder),
      'clearedAt': serializer.toJson<int?>(clearedAt),
    };
  }

  ChatRow copyWith({
    String? id,
    String? type,
    String? membersJson,
    Value<String?> peerUid = const Value.absent(),
    Value<String?> lastMessageJson = const Value.absent(),
    int? lastAt,
    int? unread,
    Value<int?> peerReadUpTo = const Value.absent(),
    Value<int?> peerDeliveredUpTo = const Value.absent(),
    Value<int?> myDeliveredUpTo = const Value.absent(),
    bool? pinned,
    bool? archived,
    Value<int?> mutedUntil = const Value.absent(),
    Value<String?> draft = const Value.absent(),
    Value<int?> msgCursor = const Value.absent(),
    bool? hasMoreOlder,
    Value<int?> clearedAt = const Value.absent(),
  }) => ChatRow(
    id: id ?? this.id,
    type: type ?? this.type,
    membersJson: membersJson ?? this.membersJson,
    peerUid: peerUid.present ? peerUid.value : this.peerUid,
    lastMessageJson: lastMessageJson.present ? lastMessageJson.value : this.lastMessageJson,
    lastAt: lastAt ?? this.lastAt,
    unread: unread ?? this.unread,
    peerReadUpTo: peerReadUpTo.present ? peerReadUpTo.value : this.peerReadUpTo,
    peerDeliveredUpTo: peerDeliveredUpTo.present ? peerDeliveredUpTo.value : this.peerDeliveredUpTo,
    myDeliveredUpTo: myDeliveredUpTo.present ? myDeliveredUpTo.value : this.myDeliveredUpTo,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    mutedUntil: mutedUntil.present ? mutedUntil.value : this.mutedUntil,
    draft: draft.present ? draft.value : this.draft,
    msgCursor: msgCursor.present ? msgCursor.value : this.msgCursor,
    hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
    clearedAt: clearedAt.present ? clearedAt.value : this.clearedAt,
  );
  ChatRow copyWithCompanion(ChatsCompanion data) {
    return ChatRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      membersJson: data.membersJson.present ? data.membersJson.value : this.membersJson,
      peerUid: data.peerUid.present ? data.peerUid.value : this.peerUid,
      lastMessageJson: data.lastMessageJson.present ? data.lastMessageJson.value : this.lastMessageJson,
      lastAt: data.lastAt.present ? data.lastAt.value : this.lastAt,
      unread: data.unread.present ? data.unread.value : this.unread,
      peerReadUpTo: data.peerReadUpTo.present ? data.peerReadUpTo.value : this.peerReadUpTo,
      peerDeliveredUpTo: data.peerDeliveredUpTo.present ? data.peerDeliveredUpTo.value : this.peerDeliveredUpTo,
      myDeliveredUpTo: data.myDeliveredUpTo.present ? data.myDeliveredUpTo.value : this.myDeliveredUpTo,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      archived: data.archived.present ? data.archived.value : this.archived,
      mutedUntil: data.mutedUntil.present ? data.mutedUntil.value : this.mutedUntil,
      draft: data.draft.present ? data.draft.value : this.draft,
      msgCursor: data.msgCursor.present ? data.msgCursor.value : this.msgCursor,
      hasMoreOlder: data.hasMoreOlder.present ? data.hasMoreOlder.value : this.hasMoreOlder,
      clearedAt: data.clearedAt.present ? data.clearedAt.value : this.clearedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('membersJson: $membersJson, ')
          ..write('peerUid: $peerUid, ')
          ..write('lastMessageJson: $lastMessageJson, ')
          ..write('lastAt: $lastAt, ')
          ..write('unread: $unread, ')
          ..write('peerReadUpTo: $peerReadUpTo, ')
          ..write('peerDeliveredUpTo: $peerDeliveredUpTo, ')
          ..write('myDeliveredUpTo: $myDeliveredUpTo, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('mutedUntil: $mutedUntil, ')
          ..write('draft: $draft, ')
          ..write('msgCursor: $msgCursor, ')
          ..write('hasMoreOlder: $hasMoreOlder, ')
          ..write('clearedAt: $clearedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    membersJson,
    peerUid,
    lastMessageJson,
    lastAt,
    unread,
    peerReadUpTo,
    peerDeliveredUpTo,
    myDeliveredUpTo,
    pinned,
    archived,
    mutedUntil,
    draft,
    msgCursor,
    hasMoreOlder,
    clearedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.membersJson == this.membersJson &&
          other.peerUid == this.peerUid &&
          other.lastMessageJson == this.lastMessageJson &&
          other.lastAt == this.lastAt &&
          other.unread == this.unread &&
          other.peerReadUpTo == this.peerReadUpTo &&
          other.peerDeliveredUpTo == this.peerDeliveredUpTo &&
          other.myDeliveredUpTo == this.myDeliveredUpTo &&
          other.pinned == this.pinned &&
          other.archived == this.archived &&
          other.mutedUntil == this.mutedUntil &&
          other.draft == this.draft &&
          other.msgCursor == this.msgCursor &&
          other.hasMoreOlder == this.hasMoreOlder &&
          other.clearedAt == this.clearedAt);
}

class ChatsCompanion extends UpdateCompanion<ChatRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> membersJson;
  final Value<String?> peerUid;
  final Value<String?> lastMessageJson;
  final Value<int> lastAt;
  final Value<int> unread;
  final Value<int?> peerReadUpTo;
  final Value<int?> peerDeliveredUpTo;
  final Value<int?> myDeliveredUpTo;
  final Value<bool> pinned;
  final Value<bool> archived;
  final Value<int?> mutedUntil;
  final Value<String?> draft;
  final Value<int?> msgCursor;
  final Value<bool> hasMoreOlder;
  final Value<int?> clearedAt;
  final Value<int> rowid;
  const ChatsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.membersJson = const Value.absent(),
    this.peerUid = const Value.absent(),
    this.lastMessageJson = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.unread = const Value.absent(),
    this.peerReadUpTo = const Value.absent(),
    this.peerDeliveredUpTo = const Value.absent(),
    this.myDeliveredUpTo = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.mutedUntil = const Value.absent(),
    this.draft = const Value.absent(),
    this.msgCursor = const Value.absent(),
    this.hasMoreOlder = const Value.absent(),
    this.clearedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatsCompanion.insert({
    required String id,
    required String type,
    required String membersJson,
    this.peerUid = const Value.absent(),
    this.lastMessageJson = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.unread = const Value.absent(),
    this.peerReadUpTo = const Value.absent(),
    this.peerDeliveredUpTo = const Value.absent(),
    this.myDeliveredUpTo = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.mutedUntil = const Value.absent(),
    this.draft = const Value.absent(),
    this.msgCursor = const Value.absent(),
    this.hasMoreOlder = const Value.absent(),
    this.clearedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       membersJson = Value(membersJson);
  static Insertable<ChatRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? membersJson,
    Expression<String>? peerUid,
    Expression<String>? lastMessageJson,
    Expression<int>? lastAt,
    Expression<int>? unread,
    Expression<int>? peerReadUpTo,
    Expression<int>? peerDeliveredUpTo,
    Expression<int>? myDeliveredUpTo,
    Expression<bool>? pinned,
    Expression<bool>? archived,
    Expression<int>? mutedUntil,
    Expression<String>? draft,
    Expression<int>? msgCursor,
    Expression<bool>? hasMoreOlder,
    Expression<int>? clearedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (membersJson != null) 'members_json': membersJson,
      if (peerUid != null) 'peer_uid': peerUid,
      if (lastMessageJson != null) 'last_message_json': lastMessageJson,
      if (lastAt != null) 'last_at': lastAt,
      if (unread != null) 'unread': unread,
      if (peerReadUpTo != null) 'peer_read_up_to': peerReadUpTo,
      if (peerDeliveredUpTo != null) 'peer_delivered_up_to': peerDeliveredUpTo,
      if (myDeliveredUpTo != null) 'my_delivered_up_to': myDeliveredUpTo,
      if (pinned != null) 'pinned': pinned,
      if (archived != null) 'archived': archived,
      if (mutedUntil != null) 'muted_until': mutedUntil,
      if (draft != null) 'draft': draft,
      if (msgCursor != null) 'msg_cursor': msgCursor,
      if (hasMoreOlder != null) 'has_more_older': hasMoreOlder,
      if (clearedAt != null) 'cleared_at': clearedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? membersJson,
    Value<String?>? peerUid,
    Value<String?>? lastMessageJson,
    Value<int>? lastAt,
    Value<int>? unread,
    Value<int?>? peerReadUpTo,
    Value<int?>? peerDeliveredUpTo,
    Value<int?>? myDeliveredUpTo,
    Value<bool>? pinned,
    Value<bool>? archived,
    Value<int?>? mutedUntil,
    Value<String?>? draft,
    Value<int?>? msgCursor,
    Value<bool>? hasMoreOlder,
    Value<int?>? clearedAt,
    Value<int>? rowid,
  }) {
    return ChatsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      membersJson: membersJson ?? this.membersJson,
      peerUid: peerUid ?? this.peerUid,
      lastMessageJson: lastMessageJson ?? this.lastMessageJson,
      lastAt: lastAt ?? this.lastAt,
      unread: unread ?? this.unread,
      peerReadUpTo: peerReadUpTo ?? this.peerReadUpTo,
      peerDeliveredUpTo: peerDeliveredUpTo ?? this.peerDeliveredUpTo,
      myDeliveredUpTo: myDeliveredUpTo ?? this.myDeliveredUpTo,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      mutedUntil: mutedUntil ?? this.mutedUntil,
      draft: draft ?? this.draft,
      msgCursor: msgCursor ?? this.msgCursor,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      clearedAt: clearedAt ?? this.clearedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (membersJson.present) {
      map['members_json'] = Variable<String>(membersJson.value);
    }
    if (peerUid.present) {
      map['peer_uid'] = Variable<String>(peerUid.value);
    }
    if (lastMessageJson.present) {
      map['last_message_json'] = Variable<String>(lastMessageJson.value);
    }
    if (lastAt.present) {
      map['last_at'] = Variable<int>(lastAt.value);
    }
    if (unread.present) {
      map['unread'] = Variable<int>(unread.value);
    }
    if (peerReadUpTo.present) {
      map['peer_read_up_to'] = Variable<int>(peerReadUpTo.value);
    }
    if (peerDeliveredUpTo.present) {
      map['peer_delivered_up_to'] = Variable<int>(peerDeliveredUpTo.value);
    }
    if (myDeliveredUpTo.present) {
      map['my_delivered_up_to'] = Variable<int>(myDeliveredUpTo.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (mutedUntil.present) {
      map['muted_until'] = Variable<int>(mutedUntil.value);
    }
    if (draft.present) {
      map['draft'] = Variable<String>(draft.value);
    }
    if (msgCursor.present) {
      map['msg_cursor'] = Variable<int>(msgCursor.value);
    }
    if (hasMoreOlder.present) {
      map['has_more_older'] = Variable<bool>(hasMoreOlder.value);
    }
    if (clearedAt.present) {
      map['cleared_at'] = Variable<int>(clearedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('membersJson: $membersJson, ')
          ..write('peerUid: $peerUid, ')
          ..write('lastMessageJson: $lastMessageJson, ')
          ..write('lastAt: $lastAt, ')
          ..write('unread: $unread, ')
          ..write('peerReadUpTo: $peerReadUpTo, ')
          ..write('peerDeliveredUpTo: $peerDeliveredUpTo, ')
          ..write('myDeliveredUpTo: $myDeliveredUpTo, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('mutedUntil: $mutedUntil, ')
          ..write('draft: $draft, ')
          ..write('msgCursor: $msgCursor, ')
          ..write('hasMoreOlder: $hasMoreOlder, ')
          ..write('clearedAt: $clearedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverConfirmedMeta = const VerificationMeta('serverConfirmed');
  @override
  late final GeneratedColumn<bool> serverConfirmed = GeneratedColumn<bool>(
    'server_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("server_confirmed" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _replyJsonMeta = const VerificationMeta('replyJson');
  @override
  late final GeneratedColumn<String> replyJson = GeneratedColumn<String>(
    'reply_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _forwardedMeta = const VerificationMeta('forwarded');
  @override
  late final GeneratedColumn<bool> forwarded = GeneratedColumn<bool>(
    'forwarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("forwarded" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta('editedAt');
  @override
  late final GeneratedColumn<int> editedAt = GeneratedColumn<int>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedForEveryoneMeta = const VerificationMeta('deletedForEveryone');
  @override
  late final GeneratedColumn<bool> deletedForEveryone = GeneratedColumn<bool>(
    'deleted_for_everyone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("deleted_for_everyone" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reactionsJsonMeta = const VerificationMeta('reactionsJson');
  @override
  late final GeneratedColumn<String> reactionsJson = GeneratedColumn<String>(
    'reactions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _sendStateMeta = const VerificationMeta('sendState');
  @override
  late final GeneratedColumn<int> sendState = GeneratedColumn<int>(
    'send_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _starredMeta = const VerificationMeta('starred');
  @override
  late final GeneratedColumn<bool> starred = GeneratedColumn<bool>(
    'starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("starred" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("hidden" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    senderId,
    createdAt,
    serverConfirmed,
    updatedAt,
    payloadJson,
    replyJson,
    forwarded,
    editedAt,
    deletedForEveryone,
    reactionsJson,
    sendState,
    attempts,
    starred,
    hidden,
    localPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<MessageRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(_chatIdMeta, chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta));
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta, senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('server_confirmed')) {
      context.handle(
        _serverConfirmedMeta,
        serverConfirmed.isAcceptableOrUnknown(data['server_confirmed']!, _serverConfirmedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(_payloadJsonMeta, payloadJson.isAcceptableOrUnknown(data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('reply_json')) {
      context.handle(_replyJsonMeta, replyJson.isAcceptableOrUnknown(data['reply_json']!, _replyJsonMeta));
    }
    if (data.containsKey('forwarded')) {
      context.handle(_forwardedMeta, forwarded.isAcceptableOrUnknown(data['forwarded']!, _forwardedMeta));
    }
    if (data.containsKey('edited_at')) {
      context.handle(_editedAtMeta, editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta));
    }
    if (data.containsKey('deleted_for_everyone')) {
      context.handle(
        _deletedForEveryoneMeta,
        deletedForEveryone.isAcceptableOrUnknown(data['deleted_for_everyone']!, _deletedForEveryoneMeta),
      );
    }
    if (data.containsKey('reactions_json')) {
      context.handle(
        _reactionsJsonMeta,
        reactionsJson.isAcceptableOrUnknown(data['reactions_json']!, _reactionsJsonMeta),
      );
    }
    if (data.containsKey('send_state')) {
      context.handle(_sendStateMeta, sendState.isAcceptableOrUnknown(data['send_state']!, _sendStateMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta, attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('starred')) {
      context.handle(_starredMeta, starred.isAcceptableOrUnknown(data['starred']!, _starredMeta));
    }
    if (data.containsKey('hidden')) {
      context.handle(_hiddenMeta, hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta, localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chatId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}chat_id'])!,
      senderId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      serverConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}server_confirmed'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}updated_at']),
      payloadJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      replyJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}reply_json']),
      forwarded: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}forwarded'])!,
      editedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}edited_at']),
      deletedForEveryone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_for_everyone'],
      )!,
      reactionsJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}reactions_json'])!,
      sendState: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}send_state'])!,
      attempts: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      starred: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}starred'])!,
      hidden: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}hidden'])!,
      localPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}local_path']),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  final String id;
  final String chatId;
  final String senderId;
  final int createdAt;
  final bool serverConfirmed;
  final int? updatedAt;
  final String payloadJson;
  final String? replyJson;
  final bool forwarded;
  final int? editedAt;
  final bool deletedForEveryone;
  final String reactionsJson;

  /// 0 = sent, 1 = pending, 2 = failed (see SendState).
  final int sendState;
  final int attempts;
  final bool starred;
  final bool hidden;
  final String? localPath;
  const MessageRow({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.createdAt,
    required this.serverConfirmed,
    this.updatedAt,
    required this.payloadJson,
    this.replyJson,
    required this.forwarded,
    this.editedAt,
    required this.deletedForEveryone,
    required this.reactionsJson,
    required this.sendState,
    required this.attempts,
    required this.starred,
    required this.hidden,
    this.localPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['sender_id'] = Variable<String>(senderId);
    map['created_at'] = Variable<int>(createdAt);
    map['server_confirmed'] = Variable<bool>(serverConfirmed);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || replyJson != null) {
      map['reply_json'] = Variable<String>(replyJson);
    }
    map['forwarded'] = Variable<bool>(forwarded);
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<int>(editedAt);
    }
    map['deleted_for_everyone'] = Variable<bool>(deletedForEveryone);
    map['reactions_json'] = Variable<String>(reactionsJson);
    map['send_state'] = Variable<int>(sendState);
    map['attempts'] = Variable<int>(attempts);
    map['starred'] = Variable<bool>(starred);
    map['hidden'] = Variable<bool>(hidden);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      senderId: Value(senderId),
      createdAt: Value(createdAt),
      serverConfirmed: Value(serverConfirmed),
      updatedAt: updatedAt == null && nullToAbsent ? const Value.absent() : Value(updatedAt),
      payloadJson: Value(payloadJson),
      replyJson: replyJson == null && nullToAbsent ? const Value.absent() : Value(replyJson),
      forwarded: Value(forwarded),
      editedAt: editedAt == null && nullToAbsent ? const Value.absent() : Value(editedAt),
      deletedForEveryone: Value(deletedForEveryone),
      reactionsJson: Value(reactionsJson),
      sendState: Value(sendState),
      attempts: Value(attempts),
      starred: Value(starred),
      hidden: Value(hidden),
      localPath: localPath == null && nullToAbsent ? const Value.absent() : Value(localPath),
    );
  }

  factory MessageRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      id: serializer.fromJson<String>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      serverConfirmed: serializer.fromJson<bool>(json['serverConfirmed']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      replyJson: serializer.fromJson<String?>(json['replyJson']),
      forwarded: serializer.fromJson<bool>(json['forwarded']),
      editedAt: serializer.fromJson<int?>(json['editedAt']),
      deletedForEveryone: serializer.fromJson<bool>(json['deletedForEveryone']),
      reactionsJson: serializer.fromJson<String>(json['reactionsJson']),
      sendState: serializer.fromJson<int>(json['sendState']),
      attempts: serializer.fromJson<int>(json['attempts']),
      starred: serializer.fromJson<bool>(json['starred']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      localPath: serializer.fromJson<String?>(json['localPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatId': serializer.toJson<String>(chatId),
      'senderId': serializer.toJson<String>(senderId),
      'createdAt': serializer.toJson<int>(createdAt),
      'serverConfirmed': serializer.toJson<bool>(serverConfirmed),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'replyJson': serializer.toJson<String?>(replyJson),
      'forwarded': serializer.toJson<bool>(forwarded),
      'editedAt': serializer.toJson<int?>(editedAt),
      'deletedForEveryone': serializer.toJson<bool>(deletedForEveryone),
      'reactionsJson': serializer.toJson<String>(reactionsJson),
      'sendState': serializer.toJson<int>(sendState),
      'attempts': serializer.toJson<int>(attempts),
      'starred': serializer.toJson<bool>(starred),
      'hidden': serializer.toJson<bool>(hidden),
      'localPath': serializer.toJson<String?>(localPath),
    };
  }

  MessageRow copyWith({
    String? id,
    String? chatId,
    String? senderId,
    int? createdAt,
    bool? serverConfirmed,
    Value<int?> updatedAt = const Value.absent(),
    String? payloadJson,
    Value<String?> replyJson = const Value.absent(),
    bool? forwarded,
    Value<int?> editedAt = const Value.absent(),
    bool? deletedForEveryone,
    String? reactionsJson,
    int? sendState,
    int? attempts,
    bool? starred,
    bool? hidden,
    Value<String?> localPath = const Value.absent(),
  }) => MessageRow(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    senderId: senderId ?? this.senderId,
    createdAt: createdAt ?? this.createdAt,
    serverConfirmed: serverConfirmed ?? this.serverConfirmed,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    payloadJson: payloadJson ?? this.payloadJson,
    replyJson: replyJson.present ? replyJson.value : this.replyJson,
    forwarded: forwarded ?? this.forwarded,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
    deletedForEveryone: deletedForEveryone ?? this.deletedForEveryone,
    reactionsJson: reactionsJson ?? this.reactionsJson,
    sendState: sendState ?? this.sendState,
    attempts: attempts ?? this.attempts,
    starred: starred ?? this.starred,
    hidden: hidden ?? this.hidden,
    localPath: localPath.present ? localPath.value : this.localPath,
  );
  MessageRow copyWithCompanion(MessagesCompanion data) {
    return MessageRow(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverConfirmed: data.serverConfirmed.present ? data.serverConfirmed.value : this.serverConfirmed,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      payloadJson: data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      replyJson: data.replyJson.present ? data.replyJson.value : this.replyJson,
      forwarded: data.forwarded.present ? data.forwarded.value : this.forwarded,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      deletedForEveryone: data.deletedForEveryone.present ? data.deletedForEveryone.value : this.deletedForEveryone,
      reactionsJson: data.reactionsJson.present ? data.reactionsJson.value : this.reactionsJson,
      sendState: data.sendState.present ? data.sendState.value : this.sendState,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      starred: data.starred.present ? data.starred.value : this.starred,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverConfirmed: $serverConfirmed, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('replyJson: $replyJson, ')
          ..write('forwarded: $forwarded, ')
          ..write('editedAt: $editedAt, ')
          ..write('deletedForEveryone: $deletedForEveryone, ')
          ..write('reactionsJson: $reactionsJson, ')
          ..write('sendState: $sendState, ')
          ..write('attempts: $attempts, ')
          ..write('starred: $starred, ')
          ..write('hidden: $hidden, ')
          ..write('localPath: $localPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    senderId,
    createdAt,
    serverConfirmed,
    updatedAt,
    payloadJson,
    replyJson,
    forwarded,
    editedAt,
    deletedForEveryone,
    reactionsJson,
    sendState,
    attempts,
    starred,
    hidden,
    localPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.senderId == this.senderId &&
          other.createdAt == this.createdAt &&
          other.serverConfirmed == this.serverConfirmed &&
          other.updatedAt == this.updatedAt &&
          other.payloadJson == this.payloadJson &&
          other.replyJson == this.replyJson &&
          other.forwarded == this.forwarded &&
          other.editedAt == this.editedAt &&
          other.deletedForEveryone == this.deletedForEveryone &&
          other.reactionsJson == this.reactionsJson &&
          other.sendState == this.sendState &&
          other.attempts == this.attempts &&
          other.starred == this.starred &&
          other.hidden == this.hidden &&
          other.localPath == this.localPath);
}

class MessagesCompanion extends UpdateCompanion<MessageRow> {
  final Value<String> id;
  final Value<String> chatId;
  final Value<String> senderId;
  final Value<int> createdAt;
  final Value<bool> serverConfirmed;
  final Value<int?> updatedAt;
  final Value<String> payloadJson;
  final Value<String?> replyJson;
  final Value<bool> forwarded;
  final Value<int?> editedAt;
  final Value<bool> deletedForEveryone;
  final Value<String> reactionsJson;
  final Value<int> sendState;
  final Value<int> attempts;
  final Value<bool> starred;
  final Value<bool> hidden;
  final Value<String?> localPath;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverConfirmed = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.replyJson = const Value.absent(),
    this.forwarded = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.deletedForEveryone = const Value.absent(),
    this.reactionsJson = const Value.absent(),
    this.sendState = const Value.absent(),
    this.attempts = const Value.absent(),
    this.starred = const Value.absent(),
    this.hidden = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String chatId,
    required String senderId,
    required int createdAt,
    this.serverConfirmed = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String payloadJson,
    this.replyJson = const Value.absent(),
    this.forwarded = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.deletedForEveryone = const Value.absent(),
    this.reactionsJson = const Value.absent(),
    this.sendState = const Value.absent(),
    this.attempts = const Value.absent(),
    this.starred = const Value.absent(),
    this.hidden = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatId = Value(chatId),
       senderId = Value(senderId),
       createdAt = Value(createdAt),
       payloadJson = Value(payloadJson);
  static Insertable<MessageRow> custom({
    Expression<String>? id,
    Expression<String>? chatId,
    Expression<String>? senderId,
    Expression<int>? createdAt,
    Expression<bool>? serverConfirmed,
    Expression<int>? updatedAt,
    Expression<String>? payloadJson,
    Expression<String>? replyJson,
    Expression<bool>? forwarded,
    Expression<int>? editedAt,
    Expression<bool>? deletedForEveryone,
    Expression<String>? reactionsJson,
    Expression<int>? sendState,
    Expression<int>? attempts,
    Expression<bool>? starred,
    Expression<bool>? hidden,
    Expression<String>? localPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (senderId != null) 'sender_id': senderId,
      if (createdAt != null) 'created_at': createdAt,
      if (serverConfirmed != null) 'server_confirmed': serverConfirmed,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (replyJson != null) 'reply_json': replyJson,
      if (forwarded != null) 'forwarded': forwarded,
      if (editedAt != null) 'edited_at': editedAt,
      if (deletedForEveryone != null) 'deleted_for_everyone': deletedForEveryone,
      if (reactionsJson != null) 'reactions_json': reactionsJson,
      if (sendState != null) 'send_state': sendState,
      if (attempts != null) 'attempts': attempts,
      if (starred != null) 'starred': starred,
      if (hidden != null) 'hidden': hidden,
      if (localPath != null) 'local_path': localPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? chatId,
    Value<String>? senderId,
    Value<int>? createdAt,
    Value<bool>? serverConfirmed,
    Value<int?>? updatedAt,
    Value<String>? payloadJson,
    Value<String?>? replyJson,
    Value<bool>? forwarded,
    Value<int?>? editedAt,
    Value<bool>? deletedForEveryone,
    Value<String>? reactionsJson,
    Value<int>? sendState,
    Value<int>? attempts,
    Value<bool>? starred,
    Value<bool>? hidden,
    Value<String?>? localPath,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      serverConfirmed: serverConfirmed ?? this.serverConfirmed,
      updatedAt: updatedAt ?? this.updatedAt,
      payloadJson: payloadJson ?? this.payloadJson,
      replyJson: replyJson ?? this.replyJson,
      forwarded: forwarded ?? this.forwarded,
      editedAt: editedAt ?? this.editedAt,
      deletedForEveryone: deletedForEveryone ?? this.deletedForEveryone,
      reactionsJson: reactionsJson ?? this.reactionsJson,
      sendState: sendState ?? this.sendState,
      attempts: attempts ?? this.attempts,
      starred: starred ?? this.starred,
      hidden: hidden ?? this.hidden,
      localPath: localPath ?? this.localPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverConfirmed.present) {
      map['server_confirmed'] = Variable<bool>(serverConfirmed.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (replyJson.present) {
      map['reply_json'] = Variable<String>(replyJson.value);
    }
    if (forwarded.present) {
      map['forwarded'] = Variable<bool>(forwarded.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<int>(editedAt.value);
    }
    if (deletedForEveryone.present) {
      map['deleted_for_everyone'] = Variable<bool>(deletedForEveryone.value);
    }
    if (reactionsJson.present) {
      map['reactions_json'] = Variable<String>(reactionsJson.value);
    }
    if (sendState.present) {
      map['send_state'] = Variable<int>(sendState.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (starred.present) {
      map['starred'] = Variable<bool>(starred.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverConfirmed: $serverConfirmed, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('replyJson: $replyJson, ')
          ..write('forwarded: $forwarded, ')
          ..write('editedAt: $editedAt, ')
          ..write('deletedForEveryone: $deletedForEveryone, ')
          ..write('reactionsJson: $reactionsJson, ')
          ..write('sendState: $sendState, ')
          ..write('attempts: $attempts, ')
          ..write('starred: $starred, ')
          ..write('hidden: $hidden, ')
          ..write('localPath: $localPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, ContactRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [uid, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<ContactRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(_uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta, addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  ContactRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactRow(
      uid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      addedAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class ContactRow extends DataClass implements Insertable<ContactRow> {
  final String uid;
  final int addedAt;
  const ContactRow({required this.uid, required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['added_at'] = Variable<int>(addedAt);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(uid: Value(uid), addedAt: Value(addedAt));
  }

  factory ContactRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactRow(
      uid: serializer.fromJson<String>(json['uid']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'uid': serializer.toJson<String>(uid), 'addedAt': serializer.toJson<int>(addedAt)};
  }

  ContactRow copyWith({String? uid, int? addedAt}) =>
      ContactRow(uid: uid ?? this.uid, addedAt: addedAt ?? this.addedAt);
  ContactRow copyWithCompanion(ContactsCompanion data) {
    return ContactRow(
      uid: data.uid.present ? data.uid.value : this.uid,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactRow(')
          ..write('uid: $uid, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ContactRow && other.uid == this.uid && other.addedAt == this.addedAt);
}

class ContactsCompanion extends UpdateCompanion<ContactRow> {
  final Value<String> uid;
  final Value<int> addedAt;
  final Value<int> rowid;
  const ContactsCompanion({
    this.uid = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({required String uid, required int addedAt, this.rowid = const Value.absent()})
    : uid = Value(uid),
      addedAt = Value(addedAt);
  static Insertable<ContactRow> custom({Expression<String>? uid, Expression<int>? addedAt, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith({Value<String>? uid, Value<int>? addedAt, Value<int>? rowid}) {
    return ContactsCompanion(uid: uid ?? this.uid, addedAt: addedAt ?? this.addedAt, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('uid: $uid, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaTable extends Meta with TableInfo<$MetaTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(Insertable<MetaRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String key;
  final String value;
  const MetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(key: Value(key), value: Value(value));
  }

  factory MetaRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  MetaRow copyWith({String? key, String? value}) => MetaRow(key: key ?? this.key, value: value ?? this.value);
  MetaRow copyWithCompanion(MetaCompanion data) {
    return MetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MetaRow && other.key == this.key && other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<MetaRow> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return MetaCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $MetaTable meta = $MetaTable(this);
  late final Index messagesChatCreated = Index(
    'messages_chat_created',
    'CREATE INDEX messages_chat_created ON messages (chat_id, created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [users, chats, messages, contacts, meta, messagesChatCreated];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String uid,
  required String username,
  required String displayName,
  Value<String?> photoUrl,
  Value<String?> bio,
  Value<String> privacyJson,
  required int fetchedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> uid,
  Value<String> username,
  Value<String> displayName,
  Value<String?> photoUrl,
  Value<String?> bio,
  Value<String> privacyJson,
  Value<int> fetchedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bio => $composableBuilder(column: $table.bio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get privacyJson =>
      $composableBuilder(column: $table.privacyJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get privacyJson =>
      $composableBuilder(column: $table.privacyJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid => $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get username => $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get photoUrl => $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get bio => $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get privacyJson =>
      $composableBuilder(column: $table.privacyJson, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt => $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uid = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String> privacyJson = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                uid: uid,
                username: username,
                displayName: displayName,
                photoUrl: photoUrl,
                bio: bio,
                privacyJson: privacyJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uid,
                required String username,
                required String displayName,
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String> privacyJson = const Value.absent(),
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                uid: uid,
                username: username,
                displayName: displayName,
                photoUrl: photoUrl,
                bio: bio,
                privacyJson: privacyJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  BaseReferences<_$AppDatabase, $UsersTable, UserRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$ChatsTableCreateCompanionBuilder = ChatsCompanion Function({
  required String id,
  required String type,
  required String membersJson,
  Value<String?> peerUid,
  Value<String?> lastMessageJson,
  Value<int> lastAt,
  Value<int> unread,
  Value<int?> peerReadUpTo,
  Value<int?> peerDeliveredUpTo,
  Value<int?> myDeliveredUpTo,
  Value<bool> pinned,
  Value<bool> archived,
  Value<int?> mutedUntil,
  Value<String?> draft,
  Value<int?> msgCursor,
  Value<bool> hasMoreOlder,
  Value<int?> clearedAt,
  Value<int> rowid,
});
typedef $$ChatsTableUpdateCompanionBuilder = ChatsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> membersJson,
  Value<String?> peerUid,
  Value<String?> lastMessageJson,
  Value<int> lastAt,
  Value<int> unread,
  Value<int?> peerReadUpTo,
  Value<int?> peerDeliveredUpTo,
  Value<int?> myDeliveredUpTo,
  Value<bool> pinned,
  Value<bool> archived,
  Value<int?> mutedUntil,
  Value<String?> draft,
  Value<int?> msgCursor,
  Value<bool> hasMoreOlder,
  Value<int?> clearedAt,
  Value<int> rowid,
});

class $$ChatsTableFilterComposer extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get membersJson =>
      $composableBuilder(column: $table.membersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get peerUid =>
      $composableBuilder(column: $table.peerUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMessageJson =>
      $composableBuilder(column: $table.lastMessageJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastAt =>
      $composableBuilder(column: $table.lastAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unread =>
      $composableBuilder(column: $table.unread, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get peerReadUpTo =>
      $composableBuilder(column: $table.peerReadUpTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get peerDeliveredUpTo =>
      $composableBuilder(column: $table.peerDeliveredUpTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get myDeliveredUpTo =>
      $composableBuilder(column: $table.myDeliveredUpTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mutedUntil =>
      $composableBuilder(column: $table.mutedUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get draft =>
      $composableBuilder(column: $table.draft, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get msgCursor =>
      $composableBuilder(column: $table.msgCursor, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasMoreOlder =>
      $composableBuilder(column: $table.hasMoreOlder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clearedAt =>
      $composableBuilder(column: $table.clearedAt, builder: (column) => ColumnFilters(column));
}

class $$ChatsTableOrderingComposer extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get membersJson =>
      $composableBuilder(column: $table.membersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get peerUid =>
      $composableBuilder(column: $table.peerUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMessageJson =>
      $composableBuilder(column: $table.lastMessageJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastAt =>
      $composableBuilder(column: $table.lastAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unread =>
      $composableBuilder(column: $table.unread, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get peerReadUpTo =>
      $composableBuilder(column: $table.peerReadUpTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get peerDeliveredUpTo =>
      $composableBuilder(column: $table.peerDeliveredUpTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get myDeliveredUpTo =>
      $composableBuilder(column: $table.myDeliveredUpTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mutedUntil =>
      $composableBuilder(column: $table.mutedUntil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get draft =>
      $composableBuilder(column: $table.draft, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get msgCursor =>
      $composableBuilder(column: $table.msgCursor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasMoreOlder =>
      $composableBuilder(column: $table.hasMoreOlder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clearedAt =>
      $composableBuilder(column: $table.clearedAt, builder: (column) => ColumnOrderings(column));
}

class $$ChatsTableAnnotationComposer extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get membersJson =>
      $composableBuilder(column: $table.membersJson, builder: (column) => column);

  GeneratedColumn<String> get peerUid => $composableBuilder(column: $table.peerUid, builder: (column) => column);

  GeneratedColumn<String> get lastMessageJson =>
      $composableBuilder(column: $table.lastMessageJson, builder: (column) => column);

  GeneratedColumn<int> get lastAt => $composableBuilder(column: $table.lastAt, builder: (column) => column);

  GeneratedColumn<int> get unread => $composableBuilder(column: $table.unread, builder: (column) => column);

  GeneratedColumn<int> get peerReadUpTo => $composableBuilder(column: $table.peerReadUpTo, builder: (column) => column);

  GeneratedColumn<int> get peerDeliveredUpTo =>
      $composableBuilder(column: $table.peerDeliveredUpTo, builder: (column) => column);

  GeneratedColumn<int> get myDeliveredUpTo =>
      $composableBuilder(column: $table.myDeliveredUpTo, builder: (column) => column);

  GeneratedColumn<bool> get pinned => $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get mutedUntil => $composableBuilder(column: $table.mutedUntil, builder: (column) => column);

  GeneratedColumn<String> get draft => $composableBuilder(column: $table.draft, builder: (column) => column);

  GeneratedColumn<int> get msgCursor => $composableBuilder(column: $table.msgCursor, builder: (column) => column);

  GeneratedColumn<bool> get hasMoreOlder =>
      $composableBuilder(column: $table.hasMoreOlder, builder: (column) => column);

  GeneratedColumn<int> get clearedAt => $composableBuilder(column: $table.clearedAt, builder: (column) => column);
}

class $$ChatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatsTable,
          ChatRow,
          $$ChatsTableFilterComposer,
          $$ChatsTableOrderingComposer,
          $$ChatsTableAnnotationComposer,
          $$ChatsTableCreateCompanionBuilder,
          $$ChatsTableUpdateCompanionBuilder,
          (ChatRow, BaseReferences<_$AppDatabase, $ChatsTable, ChatRow>),
          ChatRow,
          PrefetchHooks Function()
        > {
  $$ChatsTableTableManager(_$AppDatabase db, $ChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> membersJson = const Value.absent(),
                Value<String?> peerUid = const Value.absent(),
                Value<String?> lastMessageJson = const Value.absent(),
                Value<int> lastAt = const Value.absent(),
                Value<int> unread = const Value.absent(),
                Value<int?> peerReadUpTo = const Value.absent(),
                Value<int?> peerDeliveredUpTo = const Value.absent(),
                Value<int?> myDeliveredUpTo = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int?> mutedUntil = const Value.absent(),
                Value<String?> draft = const Value.absent(),
                Value<int?> msgCursor = const Value.absent(),
                Value<bool> hasMoreOlder = const Value.absent(),
                Value<int?> clearedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion(
                id: id,
                type: type,
                membersJson: membersJson,
                peerUid: peerUid,
                lastMessageJson: lastMessageJson,
                lastAt: lastAt,
                unread: unread,
                peerReadUpTo: peerReadUpTo,
                peerDeliveredUpTo: peerDeliveredUpTo,
                myDeliveredUpTo: myDeliveredUpTo,
                pinned: pinned,
                archived: archived,
                mutedUntil: mutedUntil,
                draft: draft,
                msgCursor: msgCursor,
                hasMoreOlder: hasMoreOlder,
                clearedAt: clearedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String membersJson,
                Value<String?> peerUid = const Value.absent(),
                Value<String?> lastMessageJson = const Value.absent(),
                Value<int> lastAt = const Value.absent(),
                Value<int> unread = const Value.absent(),
                Value<int?> peerReadUpTo = const Value.absent(),
                Value<int?> peerDeliveredUpTo = const Value.absent(),
                Value<int?> myDeliveredUpTo = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int?> mutedUntil = const Value.absent(),
                Value<String?> draft = const Value.absent(),
                Value<int?> msgCursor = const Value.absent(),
                Value<bool> hasMoreOlder = const Value.absent(),
                Value<int?> clearedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion.insert(
                id: id,
                type: type,
                membersJson: membersJson,
                peerUid: peerUid,
                lastMessageJson: lastMessageJson,
                lastAt: lastAt,
                unread: unread,
                peerReadUpTo: peerReadUpTo,
                peerDeliveredUpTo: peerDeliveredUpTo,
                myDeliveredUpTo: myDeliveredUpTo,
                pinned: pinned,
                archived: archived,
                mutedUntil: mutedUntil,
                draft: draft,
                msgCursor: msgCursor,
                hasMoreOlder: hasMoreOlder,
                clearedAt: clearedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChatsTable, ChatRow>(table),
                  BaseReferences<_$AppDatabase, $ChatsTable, ChatRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatsTable,
      ChatRow,
      $$ChatsTableFilterComposer,
      $$ChatsTableOrderingComposer,
      $$ChatsTableAnnotationComposer,
      $$ChatsTableCreateCompanionBuilder,
      $$ChatsTableUpdateCompanionBuilder,
      (ChatRow, BaseReferences<_$AppDatabase, $ChatsTable, ChatRow>),
      ChatRow,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String chatId,
  required String senderId,
  required int createdAt,
  Value<bool> serverConfirmed,
  Value<int?> updatedAt,
  required String payloadJson,
  Value<String?> replyJson,
  Value<bool> forwarded,
  Value<int?> editedAt,
  Value<bool> deletedForEveryone,
  Value<String> reactionsJson,
  Value<int> sendState,
  Value<int> attempts,
  Value<bool> starred,
  Value<bool> hidden,
  Value<String?> localPath,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> chatId,
  Value<String> senderId,
  Value<int> createdAt,
  Value<bool> serverConfirmed,
  Value<int?> updatedAt,
  Value<String> payloadJson,
  Value<String?> replyJson,
  Value<bool> forwarded,
  Value<int?> editedAt,
  Value<bool> deletedForEveryone,
  Value<String> reactionsJson,
  Value<int> sendState,
  Value<int> attempts,
  Value<bool> starred,
  Value<bool> hidden,
  Value<String?> localPath,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get serverConfirmed =>
      $composableBuilder(column: $table.serverConfirmed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyJson =>
      $composableBuilder(column: $table.replyJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get forwarded =>
      $composableBuilder(column: $table.forwarded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedForEveryone =>
      $composableBuilder(column: $table.deletedForEveryone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reactionsJson =>
      $composableBuilder(column: $table.reactionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sendState =>
      $composableBuilder(column: $table.sendState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get serverConfirmed =>
      $composableBuilder(column: $table.serverConfirmed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyJson =>
      $composableBuilder(column: $table.replyJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get forwarded =>
      $composableBuilder(column: $table.forwarded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedForEveryone =>
      $composableBuilder(column: $table.deletedForEveryone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reactionsJson =>
      $composableBuilder(column: $table.reactionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sendState =>
      $composableBuilder(column: $table.sendState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chatId => $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get senderId => $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get serverConfirmed =>
      $composableBuilder(column: $table.serverConfirmed, builder: (column) => column);

  GeneratedColumn<int> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get replyJson => $composableBuilder(column: $table.replyJson, builder: (column) => column);

  GeneratedColumn<bool> get forwarded => $composableBuilder(column: $table.forwarded, builder: (column) => column);

  GeneratedColumn<int> get editedAt => $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<bool> get deletedForEveryone =>
      $composableBuilder(column: $table.deletedForEveryone, builder: (column) => column);

  GeneratedColumn<String> get reactionsJson =>
      $composableBuilder(column: $table.reactionsJson, builder: (column) => column);

  GeneratedColumn<int> get sendState => $composableBuilder(column: $table.sendState, builder: (column) => column);

  GeneratedColumn<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<bool> get starred => $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<bool> get hidden => $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<String> get localPath => $composableBuilder(column: $table.localPath, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          MessageRow,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (MessageRow, BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>),
          MessageRow,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> serverConfirmed = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> replyJson = const Value.absent(),
                Value<bool> forwarded = const Value.absent(),
                Value<int?> editedAt = const Value.absent(),
                Value<bool> deletedForEveryone = const Value.absent(),
                Value<String> reactionsJson = const Value.absent(),
                Value<int> sendState = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                chatId: chatId,
                senderId: senderId,
                createdAt: createdAt,
                serverConfirmed: serverConfirmed,
                updatedAt: updatedAt,
                payloadJson: payloadJson,
                replyJson: replyJson,
                forwarded: forwarded,
                editedAt: editedAt,
                deletedForEveryone: deletedForEveryone,
                reactionsJson: reactionsJson,
                sendState: sendState,
                attempts: attempts,
                starred: starred,
                hidden: hidden,
                localPath: localPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chatId,
                required String senderId,
                required int createdAt,
                Value<bool> serverConfirmed = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                required String payloadJson,
                Value<String?> replyJson = const Value.absent(),
                Value<bool> forwarded = const Value.absent(),
                Value<int?> editedAt = const Value.absent(),
                Value<bool> deletedForEveryone = const Value.absent(),
                Value<String> reactionsJson = const Value.absent(),
                Value<int> sendState = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                chatId: chatId,
                senderId: senderId,
                createdAt: createdAt,
                serverConfirmed: serverConfirmed,
                updatedAt: updatedAt,
                payloadJson: payloadJson,
                replyJson: replyJson,
                forwarded: forwarded,
                editedAt: editedAt,
                deletedForEveryone: deletedForEveryone,
                reactionsJson: reactionsJson,
                sendState: sendState,
                attempts: attempts,
                starred: starred,
                hidden: hidden,
                localPath: localPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessagesTable, MessageRow>(table),
                  BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      MessageRow,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessageRow, BaseReferences<_$AppDatabase, $MessagesTable, MessageRow>),
      MessageRow,
      PrefetchHooks Function()
    >;
typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  required String uid,
  required int addedAt,
  Value<int> rowid,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<String> uid,
  Value<int> addedAt,
  Value<int> rowid,
});

class $$ContactsTableFilterComposer extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => ColumnFilters(column));
}

class $$ContactsTableOrderingComposer extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => ColumnOrderings(column));
}

class $$ContactsTableAnnotationComposer extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid => $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<int> get addedAt => $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          ContactRow,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (ContactRow, BaseReferences<_$AppDatabase, $ContactsTable, ContactRow>),
          ContactRow,
          PrefetchHooks Function()
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uid = const Value.absent(),
            Value<int> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ContactsCompanion(uid: uid, addedAt: addedAt, rowid: rowid),
          createCompanionCallback: ({
            required String uid,
            required int addedAt,
            Value<int> rowid = const Value.absent(),
          }) => ContactsCompanion.insert(uid: uid, addedAt: addedAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContactsTable, ContactRow>(table),
                  BaseReferences<_$AppDatabase, $ContactsTable, ContactRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      ContactRow,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (ContactRow, BaseReferences<_$AppDatabase, $ContactsTable, ContactRow>),
      ContactRow,
      PrefetchHooks Function()
    >;
typedef $$MetaTableCreateCompanionBuilder = MetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$MetaTableUpdateCompanionBuilder = MetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$MetaTableFilterComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$MetaTableOrderingComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$MetaTableAnnotationComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetaTable,
          MetaRow,
          $$MetaTableFilterComposer,
          $$MetaTableOrderingComposer,
          $$MetaTableAnnotationComposer,
          $$MetaTableCreateCompanionBuilder,
          $$MetaTableUpdateCompanionBuilder,
          (MetaRow, BaseReferences<_$AppDatabase, $MetaTable, MetaRow>),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$AppDatabase db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaTable, MetaRow>(table),
                  BaseReferences<_$AppDatabase, $MetaTable, MetaRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetaTable,
      MetaRow,
      $$MetaTableFilterComposer,
      $$MetaTableOrderingComposer,
      $$MetaTableAnnotationComposer,
      $$MetaTableCreateCompanionBuilder,
      $$MetaTableUpdateCompanionBuilder,
      (MetaRow, BaseReferences<_$AppDatabase, $MetaTable, MetaRow>),
      MetaRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users => $$UsersTableTableManager(_db, _db.users);
  $$ChatsTableTableManager get chats => $$ChatsTableTableManager(_db, _db.chats);
  $$MessagesTableTableManager get messages => $$MessagesTableTableManager(_db, _db.messages);
  $$ContactsTableTableManager get contacts => $$ContactsTableTableManager(_db, _db.contacts);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
}
