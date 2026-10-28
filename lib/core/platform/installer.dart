import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android package installer bridge (see MainActivity.kt).
abstract interface class PackageInstaller {
  bool get supported;
  Future<bool> canInstall();
  Future<void> openInstallSettings();
  Future<void> install(String apkPath);
  Future<List<String>> supportedAbis();

  factory PackageInstaller() => (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
      ? _AndroidInstaller()
      : const _UnsupportedInstaller();
}

class _AndroidInstaller implements PackageInstaller {
  static const _ch = MethodChannel('com.arnav.chat/installer');

  @override
  bool get supported => true;

  @override
  Future<bool> canInstall() async => await _ch.invokeMethod<bool>('canInstall') ?? false;

  @override
  Future<void> openInstallSettings() => _ch.invokeMethod('openInstallSettings');

  @override
  Future<void> install(String apkPath) => _ch.invokeMethod('install', {'path': apkPath});

  @override
  Future<List<String>> supportedAbis() async => (await DeviceInfoPlugin().androidInfo).supportedAbis;
}

class _UnsupportedInstaller implements PackageInstaller {
  const _UnsupportedInstaller();

  @override
  bool get supported => false;

  @override
  Future<bool> canInstall() async => false;

  @override
  Future<void> openInstallSettings() async {}

  @override
  Future<void> install(String apkPath) async {}

  @override
  Future<List<String>> supportedAbis() async => const [];
}
