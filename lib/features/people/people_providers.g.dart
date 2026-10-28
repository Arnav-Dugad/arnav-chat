// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contacts)
final contactsProvider = ContactsProvider._();

final class ContactsProvider
    extends $FunctionalProvider<AsyncValue<List<AppUser>>, List<AppUser>, Stream<List<AppUser>>>
    with $FutureModifier<List<AppUser>>, $StreamProvider<List<AppUser>> {
  ContactsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppUser>> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppUser>> create(Ref ref) {
    return contacts(ref);
  }
}

String _$contactsHash() => r'0a94cb395f546b6cdfcde2190107ad1eb643d76e';

@ProviderFor(isContact)
final isContactProvider = IsContactFamily._();

final class IsContactProvider extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  IsContactProvider._({required IsContactFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'isContactProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isContactHash();

  @override
  String toString() {
    return r'isContactProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isContact(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsContactProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isContactHash() => r'21b15e69cde38a074b697072d69225f3d97def81';

final class IsContactFamily extends $Family with $FunctionalFamilyOverride<Stream<bool>, String> {
  IsContactFamily._()
    : super(
        retry: null,
        name: r'isContactProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsContactProvider call(String uid) => IsContactProvider._(argument: uid, from: this);

  @override
  String toString() => r'isContactProvider';
}

@ProviderFor(profile)
final profileProvider = ProfileFamily._();

final class ProfileProvider extends $FunctionalProvider<AsyncValue<AppUser?>, AppUser?, FutureOr<AppUser?>>
    with $FutureModifier<AppUser?>, $FutureProvider<AppUser?> {
  ProfileProvider._({required ProfileFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'profileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileHash();

  @override
  String toString() {
    return r'profileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AppUser?> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<AppUser?> create(Ref ref) {
    final argument = this.argument as String;
    return profile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileHash() => r'281810b5befb44f41ad0fcd6993d5a6409dda09c';

final class ProfileFamily extends $Family with $FunctionalFamilyOverride<FutureOr<AppUser?>, String> {
  ProfileFamily._()
    : super(
        retry: null,
        name: r'profileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileProvider call(String uid) => ProfileProvider._(argument: uid, from: this);

  @override
  String toString() => r'profileProvider';
}
