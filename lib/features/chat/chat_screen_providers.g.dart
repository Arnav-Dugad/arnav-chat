// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_screen_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatMessages)
final chatMessagesProvider = ChatMessagesFamily._();

final class ChatMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Message>>,
          List<Message>,
          Stream<List<Message>>
        >
    with $FutureModifier<List<Message>>, $StreamProvider<List<Message>> {
  ChatMessagesProvider._({
    required ChatMessagesFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'chatMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatMessagesHash();

  @override
  String toString() {
    return r'chatMessagesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Message>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Message>> create(Ref ref) {
    final argument = this.argument as (String, int);
    return chatMessages(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatMessagesHash() => r'095ef4865df3275b6d0e81f2b1c8ec4dd328a8d3';

final class ChatMessagesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Message>>, (String, int)> {
  ChatMessagesFamily._()
    : super(
        retry: null,
        name: r'chatMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatMessagesProvider call(String chatId, int limit) =>
      ChatMessagesProvider._(argument: (chatId, limit), from: this);

  @override
  String toString() => r'chatMessagesProvider';
}

@ProviderFor(chatSummary)
final chatSummaryProvider = ChatSummaryFamily._();

final class ChatSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChatSummary?>,
          ChatSummary?,
          Stream<ChatSummary?>
        >
    with $FutureModifier<ChatSummary?>, $StreamProvider<ChatSummary?> {
  ChatSummaryProvider._({
    required ChatSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatSummaryHash();

  @override
  String toString() {
    return r'chatSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ChatSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChatSummary?> create(Ref ref) {
    final argument = this.argument as String;
    return chatSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatSummaryHash() => r'90ef4498bc4e933e88d40c724c619ec4f92cc2fb';

final class ChatSummaryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ChatSummary?>, String> {
  ChatSummaryFamily._()
    : super(
        retry: null,
        name: r'chatSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatSummaryProvider call(String chatId) =>
      ChatSummaryProvider._(argument: chatId, from: this);

  @override
  String toString() => r'chatSummaryProvider';
}

@ProviderFor(cachedUser)
final cachedUserProvider = CachedUserFamily._();

final class CachedUserProvider
    extends
        $FunctionalProvider<AsyncValue<AppUser?>, AppUser?, Stream<AppUser?>>
    with $FutureModifier<AppUser?>, $StreamProvider<AppUser?> {
  CachedUserProvider._({
    required CachedUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cachedUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cachedUserHash();

  @override
  String toString() {
    return r'cachedUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppUser?> create(Ref ref) {
    final argument = this.argument as String;
    return cachedUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CachedUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cachedUserHash() => r'64a5b9f54b97d664f699b6c019e49f561c4b0708';

final class CachedUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppUser?>, String> {
  CachedUserFamily._()
    : super(
        retry: null,
        name: r'cachedUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CachedUserProvider call(String uid) =>
      CachedUserProvider._(argument: uid, from: this);

  @override
  String toString() => r'cachedUserProvider';
}

/// Profiles of a chat's members (cached in Drift; fetched once when missing).

@ProviderFor(chatMembers)
final chatMembersProvider = ChatMembersFamily._();

/// Profiles of a chat's members (cached in Drift; fetched once when missing).

final class ChatMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, AppUser>>,
          Map<String, AppUser>,
          FutureOr<Map<String, AppUser>>
        >
    with
        $FutureModifier<Map<String, AppUser>>,
        $FutureProvider<Map<String, AppUser>> {
  /// Profiles of a chat's members (cached in Drift; fetched once when missing).
  ChatMembersProvider._({
    required ChatMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatMembersHash();

  @override
  String toString() {
    return r'chatMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, AppUser>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, AppUser>> create(Ref ref) {
    final argument = this.argument as String;
    return chatMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatMembersHash() => r'776bceaddae6487b17215fc779e1842544486435';

/// Profiles of a chat's members (cached in Drift; fetched once when missing).

final class ChatMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, AppUser>>, String> {
  ChatMembersFamily._()
    : super(
        retry: null,
        name: r'chatMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Profiles of a chat's members (cached in Drift; fetched once when missing).

  ChatMembersProvider call(String chatId) =>
      ChatMembersProvider._(argument: chatId, from: this);

  @override
  String toString() => r'chatMembersProvider';
}

/// uids currently typing in a group (excluding me).

@ProviderFor(groupTyping)
final groupTypingProvider = GroupTypingFamily._();

/// uids currently typing in a group (excluding me).

final class GroupTypingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// uids currently typing in a group (excluding me).
  GroupTypingProvider._({
    required GroupTypingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupTypingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupTypingHash();

  @override
  String toString() {
    return r'groupTypingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return groupTyping(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupTypingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupTypingHash() => r'd4427579bbf3bc72acdb9bb2c605bc5c40d3032d';

/// uids currently typing in a group (excluding me).

final class GroupTypingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, String> {
  GroupTypingFamily._()
    : super(
        retry: null,
        name: r'groupTypingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// uids currently typing in a group (excluding me).

  GroupTypingProvider call(String chatId) =>
      GroupTypingProvider._(argument: chatId, from: this);

  @override
  String toString() => r'groupTypingProvider';
}
