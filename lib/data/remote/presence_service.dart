import 'package:firebase_database/firebase_database.dart';

class Presence {
  const Presence({required this.online, this.lastSeen});

  static const unknown = Presence(online: false);

  final bool online;
  final DateTime? lastSeen;
}

/// Online status + typing on Realtime Database (cheap, ephemeral writes,
/// cleaned up server-side with onDisconnect).
class PresenceService {
  PresenceService(this._db, this._uid);

  final FirebaseDatabase _db;
  final String _uid;

  DatabaseReference get _me => _db.ref('status/$_uid');

  Map<String, Object?> _offline(bool share) => {'online': false, 'lastSeen': share ? ServerValue.timestamp : null};

  /// [share] false = "last seen: nobody" — we publish nothing about ourselves.
  Future<void> goOnline({required bool share}) async {
    if (!share) {
      await _me.onDisconnect().cancel();
      await _me.remove();
      return;
    }
    await _me.onDisconnect().set(_offline(true));
    await _me.set({'online': true, 'lastSeen': ServerValue.timestamp});
  }

  Future<void> goOffline({required bool share}) async {
    if (!share) return _me.remove();
    await _me.set(_offline(true));
  }

  Stream<Presence> watch(String uid) => _db.ref('status/$uid').onValue.map((e) {
    final v = e.snapshot.value;
    if (v is! Map) return Presence.unknown;
    final ts = v['lastSeen'];
    return Presence(online: v['online'] == true, lastSeen: ts is int ? DateTime.fromMillisecondsSinceEpoch(ts) : null);
  });

  DatabaseReference _typing(String chatId, String uid) => _db.ref('typing/$chatId/$uid');

  Future<void> setTyping(String chatId, bool typing) async {
    final ref = _typing(chatId, _uid);
    if (typing) {
      await ref.onDisconnect().remove();
      await ref.set(ServerValue.timestamp);
    } else {
      await ref.remove();
    }
  }

  Stream<bool> watchTyping(String chatId, String peerUid) =>
      _typing(chatId, peerUid).onValue.map((e) => e.snapshot.value != null);

  /// Everyone typing in [chatId] except me (groups).
  Stream<List<String>> watchTypingAny(String chatId) => _db.ref('typing/$chatId').onValue.map((e) {
    final v = e.snapshot.value;
    if (v is! Map) return const <String>[];
    return v.keys.map((k) => '$k').where((k) => k != _uid).toList();
  });

  /// Groups: RTDB cannot see Firestore membership, so members self-register
  /// to unlock the group's typing path (see firebase/database.rules.json).
  Future<void> registerGroupMember(String chatId) => _db.ref('groupMembers/$chatId/$_uid').set(true);
}
