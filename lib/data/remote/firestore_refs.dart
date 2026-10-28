import 'package:cloud_firestore/cloud_firestore.dart';

/// Single place for Firestore paths, mirrored by firebase/firestore.rules.
class FirestoreRefs {
  const FirestoreRefs(this.fs);

  final FirebaseFirestore fs;

  CollectionReference<Map<String, dynamic>> get users => fs.collection('users');
  DocumentReference<Map<String, dynamic>> user(String uid) => users.doc(uid);
  DocumentReference<Map<String, dynamic>> userPrivate(String uid) => user(uid).collection('private').doc('meta');
  CollectionReference<Map<String, dynamic>> contacts(String uid) => user(uid).collection('contacts');
  DocumentReference<Map<String, dynamic>> username(String handle) =>
      fs.collection('usernames').doc(handle.toLowerCase());

  CollectionReference<Map<String, dynamic>> get chats => fs.collection('chats');
  DocumentReference<Map<String, dynamic>> chat(String id) => chats.doc(id);
  CollectionReference<Map<String, dynamic>> messages(String chatId) => chat(chatId).collection('messages');
}

/// Reads a Firestore Timestamp (or millis) as epoch milliseconds.
/// A function, not an extension: map values are dynamic, and extension
/// members are not dispatched on dynamic receivers.
int? millisOf(Object? v) => switch (v) {
  final Timestamp t => t.millisecondsSinceEpoch,
  final int i => i,
  _ => null,
};
