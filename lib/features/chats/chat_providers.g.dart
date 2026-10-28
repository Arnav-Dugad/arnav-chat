// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatList)
final chatListProvider = ChatListProvider._();

final class ChatListProvider
    extends $FunctionalProvider<AsyncValue<List<ChatSummary>>, List<ChatSummary>, Stream<List<ChatSummary>>>
    with $FutureModifier<List<ChatSummary>>, $StreamProvider<List<ChatSummary>> {
  ChatListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatListHash();

  @$internal
  @override
  $StreamProviderElement<List<ChatSummary>> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<List<ChatSummary>> create(Ref ref) {
    return chatList(ref);
  }
}

String _$chatListHash() => r'44b7aa5cfd78d48e268d6952b8a3e83af009bcd0';

/// RTDB presence for a peer (one multiplexed socket; no Firestore reads).

@ProviderFor(peerPresence)
final peerPresenceProvider = PeerPresenceFamily._();

/// RTDB presence for a peer (one multiplexed socket; no Firestore reads).

final class PeerPresenceProvider extends $FunctionalProvider<AsyncValue<Presence>, Presence, Stream<Presence>>
    with $FutureModifier<Presence>, $StreamProvider<Presence> {
  /// RTDB presence for a peer (one multiplexed socket; no Firestore reads).
  PeerPresenceProvider._({required PeerPresenceFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'peerPresenceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$peerPresenceHash();

  @override
  String toString() {
    return r'peerPresenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Presence> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<Presence> create(Ref ref) {
    final argument = this.argument as String;
    return peerPresence(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PeerPresenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$peerPresenceHash() => r'371a7fb2bdf63c6549e69061c19779793233dde7';

/// RTDB presence for a peer (one multiplexed socket; no Firestore reads).

final class PeerPresenceFamily extends $Family with $FunctionalFamilyOverride<Stream<Presence>, String> {
  PeerPresenceFamily._()
    : super(
        retry: null,
        name: r'peerPresenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// RTDB presence for a peer (one multiplexed socket; no Firestore reads).

  PeerPresenceProvider call(String uid) => PeerPresenceProvider._(argument: uid, from: this);

  @override
  String toString() => r'peerPresenceProvider';
}

@ProviderFor(peerTyping)
final peerTypingProvider = PeerTypingFamily._();

final class PeerTypingProvider extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  PeerTypingProvider._({required PeerTypingFamily super.from, required (String, String) super.argument})
    : super(
        retry: null,
        name: r'peerTypingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$peerTypingHash();

  @override
  String toString() {
    return r'peerTypingProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as (String, String);
    return peerTyping(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PeerTypingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$peerTypingHash() => r'0dd065264428913fa044d6aa93c0bdb985eddcb5';

final class PeerTypingFamily extends $Family with $FunctionalFamilyOverride<Stream<bool>, (String, String)> {
  PeerTypingFamily._()
    : super(
        retry: null,
        name: r'peerTypingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PeerTypingProvider call(String chatId, String uid) => PeerTypingProvider._(argument: (chatId, uid), from: this);

  @override
  String toString() => r'peerTypingProvider';
}
