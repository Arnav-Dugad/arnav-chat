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
