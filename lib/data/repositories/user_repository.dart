import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../models/app_user.dart';
import '../remote/firestore_refs.dart';

final usernamePattern = RegExp(r'^[a-z0-9_]{3,20}$');

String normalizeUsername(String raw) => raw.trim().toLowerCase().replaceAll('@', '');

class UserRepository {
  UserRepository(this._refs, this._db, this._uid);

  final FirestoreRefs _refs;
  final AppDatabase _db;
  final String _uid;

  static const _profileTtl = Duration(hours: 12);

  // ---------- me ----------

  Future<bool> isUsernameAvailable(String handle) async {
    if (!usernamePattern.hasMatch(handle)) return false;
    final snap = await _refs.username(handle).get(const GetOptions(source: Source.server));
    return !snap.exists || snap.data()?['uid'] == _uid;
  }

  /// Atomically claims the username and creates the profile. Rules reject the
  /// batch if the username document already exists.
  Future<void> createProfile({required String username, required String displayName, String? bio, String? photoUrl}) async {
    final handle = normalizeUsername(username);
    final user = AppUser(uid: _uid, username: handle, displayName: displayName.trim(), bio: bio?.trim(), photoUrl: photoUrl);
    final batch = _refs.fs.batch()
      ..set(_refs.username(handle), {'uid': _uid, 'createdAt': FieldValue.serverTimestamp()})
      ..set(_refs.user(_uid), {...user.toMap(), 'createdAt': FieldValue.serverTimestamp()});
    await batch.commit();
    await cache(user);
  }

  Future<void> updateProfile({String? displayName, String? bio, String? photoUrl}) async {
    await _refs.user(_uid).update({
      'displayName': ?displayName?.trim(),
      'bio': ?bio?.trim(),
      'photoUrl': ?photoUrl,
    });
  }

  Future<void> updatePrivacy(PrivacySettings privacy) => _refs.user(_uid).update({'privacy': privacy.toMap()});

  /// My profile. A cache miss while offline is skipped (not reported as
  /// "no profile"), so a cold offline start never routes to onboarding.
  Stream<AppUser?> watchMe() => _refs
      .user(_uid)
      .snapshots(includeMetadataChanges: true)
      .where((s) => s.exists || !s.metadata.isFromCache)
      .map((s) {
        final d = s.data();
        if (d == null) return null;
        final u = AppUser.fromMap(d);
        cache(u);
        return u;
      })
      .distinct((a, b) => a?.toMap().toString() == b?.toMap().toString());

  Future<AppUser?> cachedMe() async {
    final row = await (_db.select(_db.users)..where((t) => t.uid.equals(_uid))).getSingleOrNull();
    return row == null ? null : fromRow(row);
  }

  Future<void> addFcmToken(String token) => _refs.userPrivate(_uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  Future<void> removeFcmToken(String token) => _refs.userPrivate(_uid).set({
        'fcmTokens': FieldValue.arrayRemove([token]),
      }, SetOptions(merge: true));

  // ---------- others ----------

  Future<void> cache(AppUser u) => _db.into(_db.users).insertOnConflictUpdate(UsersCompanion.insert(
        uid: u.uid,
        username: u.username,
        displayName: u.displayName,
        photoUrl: Value(u.photoUrl),
        bio: Value(u.bio),
        privacyJson: Value(jsonEncode(u.privacy.toMap())),
        fetchedAt: DateTime.now().millisecondsSinceEpoch,
      ));

  static AppUser fromRow(UserRow r) => AppUser(
        uid: r.uid,
        username: r.username,
        displayName: r.displayName,
        photoUrl: r.photoUrl,
        bio: r.bio,
        privacy: PrivacySettings.fromMap(jsonDecode(r.privacyJson) as Map<String, dynamic>),
      );

  /// Cached profile, refreshed from Firestore when older than the TTL.
  Future<AppUser?> get(String uid, {bool refresh = false}) async {
    final row = await (_db.select(_db.users)..where((t) => t.uid.equals(uid))).getSingleOrNull();
    final fresh = row != null &&
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(row.fetchedAt)) < _profileTtl;
    if (row != null && fresh && !refresh) return fromRow(row);
    try {
      final snap = await _refs.user(uid).get();
      final d = snap.data();
      if (d == null) return row == null ? null : fromRow(row);
      final u = AppUser.fromMap(d);
      await cache(u);
      return u;
    } catch (_) {
      return row == null ? null : fromRow(row);
    }
  }

  Stream<AppUser?> watchCached(String uid) => (_db.select(_db.users)..where((t) => t.uid.equals(uid)))
      .watchSingleOrNull()
      .map((r) => r == null ? null : fromRow(r));

  Future<AppUser?> byUsername(String handle) async {
    final snap = await _refs.username(normalizeUsername(handle)).get();
    final uid = snap.data()?['uid'] as String?;
    return uid == null ? null : get(uid, refresh: true);
  }

  /// Prefix search on @username (max 15 results, one query).
  Future<List<AppUser>> search(String query) async {
    final q = normalizeUsername(query);
    if (q.length < 2) return const [];
    final snap = await _refs.users
        .where('usernameLower', isGreaterThanOrEqualTo: q)
        .where('usernameLower', isLessThan: '$q')
        .limit(15)
        .get();
    final users = snap.docs.map((d) => AppUser.fromMap(d.data())).where((u) => u.uid != _uid).toList();
    for (final u in users) {
      await cache(u);
    }
    return users;
  }

  // ---------- contacts ----------

  Future<void> addContact(String uid) async {
    await _db.into(_db.contacts).insertOnConflictUpdate(
          ContactsCompanion.insert(uid: uid, addedAt: DateTime.now().millisecondsSinceEpoch),
        );
    await _refs.contacts(_uid).doc(uid).set({'addedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeContact(String uid) async {
    await (_db.delete(_db.contacts)..where((t) => t.uid.equals(uid))).go();
    await _refs.contacts(_uid).doc(uid).delete();
  }

  Stream<List<AppUser>> watchContacts() {
    final q = _db.select(_db.contacts).join([innerJoin(_db.users, _db.users.uid.equalsExp(_db.contacts.uid))])
      ..orderBy([OrderingTerm.asc(_db.users.displayName)]);
    return q.watch().map((rows) => rows.map((r) => fromRow(r.readTable(_db.users))).toList());
  }

  Stream<bool> watchIsContact(String uid) =>
      (_db.select(_db.contacts)..where((t) => t.uid.equals(uid))).watchSingleOrNull().map((r) => r != null);

  /// One-time pull of the contact list on a fresh install.
  Future<void> syncContactsOnce() async {
    if (await _db.getMeta('contactsSynced') == '1') return;
    final snap = await _refs.contacts(_uid).get();
    for (final d in snap.docs) {
      await _db.into(_db.contacts).insertOnConflictUpdate(ContactsCompanion.insert(
            uid: d.id,
            addedAt: (d.data()['addedAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0,
          ));
      await get(d.id);
    }
    await _db.setMeta('contactsSynced', '1');
  }
}
