import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/env.dart';
import 'local/app_database.dart';
import 'models/app_user.dart';
import 'remote/fcm_topics.dart';
import 'remote/firestore_refs.dart';
import 'remote/link_preview_service.dart';
import 'remote/media_uploader.dart';
import 'remote/message_writer.dart';
import 'remote/presence_service.dart';
import 'remote/worker_api.dart';
import 'repositories/auth_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/group_repository.dart';
import 'repositories/message_repository.dart';
import 'repositories/outbox_service.dart';
import 'repositories/user_repository.dart';

part 'providers.g.dart';

// ---------- infrastructure ----------

@Riverpod(keepAlive: true)
SharedPreferences sharedPrefs(Ref ref) => throw UnimplementedError('overridden in bootstrap');

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
FirestoreRefs firestoreRefs(Ref ref) => FirestoreRefs(FirebaseFirestore.instance);

@Riverpod(keepAlive: true)
FirebaseDatabase rtdb(Ref ref) => FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: Env.rtdbUrl);

@Riverpod(keepAlive: true)
Stream<bool> online(Ref ref) async* {
  final c = Connectivity();
  bool has(List<ConnectivityResult> r) => r.any((x) => x != ConnectivityResult.none);
  yield has(await c.checkConnectivity());
  yield* c.onConnectivityChanged.map(has).distinct();
}

// ---------- auth & session ----------

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(ref.watch(firebaseAuthProvider));

@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) => ref.watch(authRepositoryProvider).authState();

@Riverpod(keepAlive: true)
String? currentUid(Ref ref) => ref.watch(authStateProvider).value?.uid;

sealed class Session {
  const Session();
}

class SessionLoading extends Session {
  const SessionLoading();
}

class SessionSignedOut extends Session {
  const SessionSignedOut();
}

class SessionNeedsProfile extends Session {
  const SessionNeedsProfile(this.user);
  final User user;
}

class SessionReady extends Session {
  const SessionReady(this.me);
  final AppUser me;
}

@Riverpod(keepAlive: true)
Stream<Session> session(Ref ref) async* {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) {
    yield const SessionSignedOut();
    return;
  }
  final users = ref.watch(userRepositoryProvider);
  final cached = await users.cachedMe();
  if (cached != null) yield SessionReady(cached);
  yield* users.watchMe().map((me) => me == null ? SessionNeedsProfile(user) : SessionReady(me));
}

/// The signed-in profile. Only read below the "ready" part of the router.
@Riverpod(keepAlive: true)
AppUser me(Ref ref) {
  final s = ref.watch(sessionProvider).value;
  if (s is SessionReady) return s.me;
  throw StateError('No profile yet');
}

/// Display name for system messages / group previews. Safe before onboarding.
String Function() _myName(Ref ref) => () {
  final s = ref.read(sessionProvider).value;
  return s is SessionReady ? s.me.displayName : 'Someone';
};

String _uid(Ref ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) throw StateError('Signed out');
  return uid;
}

// ---------- per-user data layer (rebuilt on account switch) ----------

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase(_uid(ref));
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
WorkerApi workerApi(Ref ref) => WorkerApi(ref.watch(firebaseAuthProvider));

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) =>
    UserRepository(ref.watch(firestoreRefsProvider), ref.watch(appDatabaseProvider), _uid(ref));

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  final repo = ChatRepository(
    ref.watch(firestoreRefsProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(userRepositoryProvider),
    _uid(ref),
    ref.watch(sharedPrefsProvider),
    topics: kIsWeb ? null : const FcmTopics(),
  );
  ref.onDispose(repo.stopSync);
  return repo;
}

@Riverpod(keepAlive: true)
GroupRepository groupRepository(Ref ref) =>
    GroupRepository(ref.watch(firestoreRefsProvider), ref.watch(messageWriterProvider), _uid(ref), _myName(ref));

@Riverpod(keepAlive: true)
MessageWriter messageWriter(Ref ref) => MessageWriter(ref.watch(firestoreRefsProvider));

@Riverpod(keepAlive: true)
MessageRepository messageRepository(Ref ref) => MessageRepository(
  ref.watch(firestoreRefsProvider),
  ref.watch(appDatabaseProvider),
  ref.watch(messageWriterProvider),
  _uid(ref),
);

@Riverpod(keepAlive: true)
MediaUploader mediaUploader(Ref ref) => MediaUploader(ref.watch(workerApiProvider));

@Riverpod(keepAlive: true)
OutboxService outbox(Ref ref) {
  final o = OutboxService(
    ref.watch(messageRepositoryProvider),
    ref.watch(chatRepositoryProvider),
    ref.watch(messageWriterProvider),
    ref.watch(mediaUploaderProvider),
    ref.watch(workerApiProvider),
    _uid(ref),
    _myName(ref),
  );
  ref.onDispose(o.dispose);
  return o;
}

@Riverpod(keepAlive: true)
PresenceService presence(Ref ref) => PresenceService(ref.watch(rtdbProvider), _uid(ref));

@Riverpod(keepAlive: true)
LinkPreviewService linkPreviews(Ref ref) => LinkPreviewService();
