// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppearanceController)
final appearanceControllerProvider = AppearanceControllerProvider._();

final class AppearanceControllerProvider
    extends $NotifierProvider<AppearanceController, Appearance> {
  AppearanceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appearanceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appearanceControllerHash();

  @$internal
  @override
  AppearanceController create() => AppearanceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Appearance value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Appearance>(value),
    );
  }
}

String _$appearanceControllerHash() =>
    r'a6a31d55ec3206d6426ab68639a56183a7d45c7d';

abstract class _$AppearanceController extends $Notifier<Appearance> {
  Appearance build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Appearance, Appearance>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Appearance, Appearance>,
              Appearance,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
