// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharedPrefs)
final sharedPrefsProvider = SharedPrefsProvider._();

final class SharedPrefsProvider extends $FunctionalProvider<SharedPreferences, SharedPreferences, SharedPreferences>
    with $Provider<SharedPreferences> {
  SharedPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPrefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPrefsHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPrefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<SharedPreferences>(value));
  }
}

String _$sharedPrefsHash() => r'493b07928351fe69424e2452b19b1c6d17324fca';

@ProviderFor(firebaseAuth)
final firebaseAuthProvider = FirebaseAuthProvider._();

final class FirebaseAuthProvider extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  FirebaseAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAuthHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuth> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  FirebaseAuth create(Ref ref) {
    return firebaseAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuth value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<FirebaseAuth>(value));
  }
}

String _$firebaseAuthHash() => r'8c3e9d11b27110ca96130356b5ef4d5d34a5ffc2';

@ProviderFor(firestoreRefs)
final firestoreRefsProvider = FirestoreRefsProvider._();

final class FirestoreRefsProvider extends $FunctionalProvider<FirestoreRefs, FirestoreRefs, FirestoreRefs>
    with $Provider<FirestoreRefs> {
  FirestoreRefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreRefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreRefsHash();

  @$internal
  @override
  $ProviderElement<FirestoreRefs> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  FirestoreRefs create(Ref ref) {
    return firestoreRefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirestoreRefs value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<FirestoreRefs>(value));
  }
}

String _$firestoreRefsHash() => r'a7e2df94b6ae399738f88135bf96f2313debca44';

@ProviderFor(rtdb)
final rtdbProvider = RtdbProvider._();

final class RtdbProvider extends $FunctionalProvider<FirebaseDatabase, FirebaseDatabase, FirebaseDatabase>
    with $Provider<FirebaseDatabase> {
  RtdbProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rtdbProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rtdbHash();

  @$internal
  @override
  $ProviderElement<FirebaseDatabase> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  FirebaseDatabase create(Ref ref) {
    return rtdb(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseDatabase value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<FirebaseDatabase>(value));
  }
}

String _$rtdbHash() => r'fe5c170ddccabd3d0b142b6c0995b7422254dc8b';

@ProviderFor(online)
final onlineProvider = OnlineProvider._();

final class OnlineProvider extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  OnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return online(ref);
  }
}

String _$onlineHash() => r'dc130d4b884b115c71737eaa8b1983ea0ec5d032';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AuthRepository>(value));
  }
}

String _$authRepositoryHash() => r'c3c4aa2a198f809725f6aa65101c5448ea3a0ea6';

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

final class AuthStateProvider extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'227ae2c3c8c0e9d5be389d264437fe0a7c05a16f';

@ProviderFor(currentUid)
final currentUidProvider = CurrentUidProvider._();

final class CurrentUidProvider extends $FunctionalProvider<String?, String?, String?> with $Provider<String?> {
  CurrentUidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUidProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUidHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentUid(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String?>(value));
  }
}

String _$currentUidHash() => r'273859ab432628b4565d554a7b7a1acc27fa90bf';

@ProviderFor(session)
final sessionProvider = SessionProvider._();

final class SessionProvider extends $FunctionalProvider<AsyncValue<Session>, Session, Stream<Session>>
    with $FutureModifier<Session>, $StreamProvider<Session> {
  SessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  $StreamProviderElement<Session> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<Session> create(Ref ref) {
    return session(ref);
  }
}

String _$sessionHash() => r'56ad3539fa536dbcfa96f0a4ac1b785c2c83ce56';

/// The signed-in profile. Only read below the "ready" part of the router.

@ProviderFor(me)
final meProvider = MeProvider._();

/// The signed-in profile. Only read below the "ready" part of the router.

final class MeProvider extends $FunctionalProvider<AppUser, AppUser, AppUser> with $Provider<AppUser> {
  /// The signed-in profile. Only read below the "ready" part of the router.
  MeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'meProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$meHash();

  @$internal
  @override
  $ProviderElement<AppUser> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  AppUser create(Ref ref) {
    return me(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUser value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AppUser>(value));
  }
}

String _$meHash() => r'2231d15e6f2dd16ccf7a551993dcf442ac26b01b';

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AppDatabase>(value));
  }
}

String _$appDatabaseHash() => r'22e555d52c5864dd04e9487da94c7c5f8a529986';

@ProviderFor(workerApi)
final workerApiProvider = WorkerApiProvider._();

final class WorkerApiProvider extends $FunctionalProvider<WorkerApi, WorkerApi, WorkerApi> with $Provider<WorkerApi> {
  WorkerApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workerApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workerApiHash();

  @$internal
  @override
  $ProviderElement<WorkerApi> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  WorkerApi create(Ref ref) {
    return workerApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkerApi value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<WorkerApi>(value));
  }
}

String _$workerApiHash() => r'ea050a26ffb0aea0a2f97ef5941cace31725caa9';

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

final class UserRepositoryProvider extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<UserRepository>(value));
  }
}

String _$userRepositoryHash() => r'70de9cf7bac33125d212c9cde0ffcc2d3b5a2d75';

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

final class ChatRepositoryProvider extends $FunctionalProvider<ChatRepository, ChatRepository, ChatRepository>
    with $Provider<ChatRepository> {
  ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ChatRepository>(value));
  }
}

String _$chatRepositoryHash() => r'b7c82547983e07fd63761b4737155cb9ac3ca658';

@ProviderFor(messageWriter)
final messageWriterProvider = MessageWriterProvider._();

final class MessageWriterProvider extends $FunctionalProvider<MessageWriter, MessageWriter, MessageWriter>
    with $Provider<MessageWriter> {
  MessageWriterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageWriterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageWriterHash();

  @$internal
  @override
  $ProviderElement<MessageWriter> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  MessageWriter create(Ref ref) {
    return messageWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageWriter value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<MessageWriter>(value));
  }
}

String _$messageWriterHash() => r'8d589bf137b4b0997d348c6695bed9eaf066bd82';

@ProviderFor(messageRepository)
final messageRepositoryProvider = MessageRepositoryProvider._();

final class MessageRepositoryProvider
    extends $FunctionalProvider<MessageRepository, MessageRepository, MessageRepository>
    with $Provider<MessageRepository> {
  MessageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageRepositoryHash();

  @$internal
  @override
  $ProviderElement<MessageRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  MessageRepository create(Ref ref) {
    return messageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<MessageRepository>(value));
  }
}

String _$messageRepositoryHash() => r'5510eff1c281459f1158ce06461119e12629fc67';

@ProviderFor(mediaUploader)
final mediaUploaderProvider = MediaUploaderProvider._();

final class MediaUploaderProvider extends $FunctionalProvider<MediaUploader, MediaUploader, MediaUploader>
    with $Provider<MediaUploader> {
  MediaUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaUploaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaUploaderHash();

  @$internal
  @override
  $ProviderElement<MediaUploader> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  MediaUploader create(Ref ref) {
    return mediaUploader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaUploader value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<MediaUploader>(value));
  }
}

String _$mediaUploaderHash() => r'03a89e1c237dc35ab51701867950cd7d3d083c60';

@ProviderFor(outbox)
final outboxProvider = OutboxProvider._();

final class OutboxProvider extends $FunctionalProvider<OutboxService, OutboxService, OutboxService>
    with $Provider<OutboxService> {
  OutboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxHash();

  @$internal
  @override
  $ProviderElement<OutboxService> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  OutboxService create(Ref ref) {
    return outbox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutboxService value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<OutboxService>(value));
  }
}

String _$outboxHash() => r'cae564d82f63ac64c3b8013a30fe9f8bfafd7912';

@ProviderFor(presence)
final presenceProvider = PresenceProvider._();

final class PresenceProvider extends $FunctionalProvider<PresenceService, PresenceService, PresenceService>
    with $Provider<PresenceService> {
  PresenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presenceHash();

  @$internal
  @override
  $ProviderElement<PresenceService> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  PresenceService create(Ref ref) {
    return presence(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresenceService value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<PresenceService>(value));
  }
}

String _$presenceHash() => r'4ed2b7fa12d0c864f84a61395baf0dfe34c1959d';

@ProviderFor(linkPreviews)
final linkPreviewsProvider = LinkPreviewsProvider._();

final class LinkPreviewsProvider extends $FunctionalProvider<LinkPreviewService, LinkPreviewService, LinkPreviewService>
    with $Provider<LinkPreviewService> {
  LinkPreviewsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkPreviewsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkPreviewsHash();

  @$internal
  @override
  $ProviderElement<LinkPreviewService> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  LinkPreviewService create(Ref ref) {
    return linkPreviews(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkPreviewService value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<LinkPreviewService>(value));
  }
}

String _$linkPreviewsHash() => r'061f445680f5a1a5f8d69d662343e26baaf8c9a1';
