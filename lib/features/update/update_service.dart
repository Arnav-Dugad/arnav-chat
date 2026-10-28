import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/config/env.dart';
import '../../core/platform/files.dart';
import '../../core/platform/installer.dart';

class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.notes,
    required this.apkUrl,
    required this.apkName,
    required this.force,
    this.checksumsUrl,
    this.sizeBytes,
  });

  final String version;
  final List<String> notes;
  final String apkUrl;
  final String apkName;
  final String? checksumsUrl;
  final int? sizeBytes;
  final bool force;
}

class ChecksumMismatch implements Exception {
  const ChecksumMismatch();
}

/// Parses "v1.2.3" / "1.2.3+4" into comparable [major, minor, patch].
List<int> parseVersion(String v) {
  final core = v.trim().replaceFirst(RegExp('^v'), '').split('+').first.split('-').first;
  final parts = core.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  while (parts.length < 3) {
    parts.add(0);
  }
  return parts.take(3).toList();
}

int compareVersions(String a, String b) {
  final x = parseVersion(a), y = parseVersion(b);
  for (var i = 0; i < 3; i++) {
    if (x[i] != y[i]) return x[i].compareTo(y[i]);
  }
  return 0;
}

/// Picks the APK for this device's ABI; falls back to the universal build.
/// All APKs share one versionCode, so any of them upgrades any other.
({String name, String url, int? size})? pickApk(List<Map<String, dynamic>> assets, List<String> abis) {
  final apks = assets.where((a) => (a['name'] as String).endsWith('.apk')).toList();
  for (final abi in abis) {
    final match = apks.where((a) => (a['name'] as String).contains(abi));
    if (match.isNotEmpty) {
      final a = match.first;
      return (name: a['name'] as String, url: a['browser_download_url'] as String, size: (a['size'] as num?)?.toInt());
    }
  }
  final universal = apks.where((a) => (a['name'] as String).contains('universal'));
  if (universal.isEmpty) return null;
  final a = universal.first;
  return (name: a['name'] as String, url: a['browser_download_url'] as String, size: (a['size'] as num?)?.toInt());
}

/// Release notes → a few short lines (GitHub's generated notes are verbose).
List<String> condenseNotes(String body) => body
    .split('\n')
    .map((l) => l.trim())
    .where((l) => l.startsWith('* ') || l.startsWith('- '))
    .map((l) => l.substring(2).replaceAll(RegExp(r' by @\S+ in https://\S+'), '').replaceAll(RegExp(r'\*\*|`'), '').trim())
    .where((l) => l.isNotEmpty)
    .take(5)
    .toList();

@visibleForTesting
String? checksumFor(String checksums, String fileName) {
  for (final line in checksums.split('\n')) {
    final parts = line.trim().split(RegExp(r'\s+\*?'));
    if (parts.length >= 2 && parts.last == fileName) return parts.first.toLowerCase();
  }
  return null;
}

class UpdateService {
  UpdateService({Dio? dio, PackageInstaller? installer})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 10))),
        installer = installer ?? PackageInstaller();

  final Dio _dio;
  final PackageInstaller installer;

  bool get supported => installer.supported;

  Future<UpdateInfo?> check() async {
    if (!supported) return null;
    final current = (await PackageInfo.fromPlatform()).version;
    final res = await _dio.get<Map<String, dynamic>>(
      'https://api.github.com/repos/${Env.githubRepo}/releases/latest',
      options: Options(headers: {'Accept': 'application/vnd.github+json'}),
    );
    final rel = res.data!;
    final latest = rel['tag_name'] as String? ?? '';
    if (compareVersions(latest, current) <= 0) return null;

    final assets = List<Map<String, dynamic>>.from(rel['assets'] as List? ?? const []);
    final apk = pickApk(assets, await installer.supportedAbis());
    if (apk == null) return null;
    final checksums = assets.where((a) => a['name'] == 'checksums.txt').map((a) => a['browser_download_url'] as String);

    var force = false;
    try {
      final v = await _dio.get<String>(
        'https://raw.githubusercontent.com/${Env.githubRepo}/main/version.json',
        options: Options(responseType: ResponseType.plain),
      );
      final min = RegExp(r'"min_version"\s*:\s*"([^"]+)"').firstMatch(v.data ?? '')?.group(1);
      if (min != null) force = compareVersions(current, min) < 0;
    } catch (_) {}

    return UpdateInfo(
      version: latest.replaceFirst('v', ''),
      notes: condenseNotes(rel['body'] as String? ?? ''),
      apkUrl: apk.url,
      apkName: apk.name,
      sizeBytes: apk.size,
      checksumsUrl: checksums.isEmpty ? null : checksums.first,
      force: force,
    );
  }

  /// Downloads and verifies the APK. Returns the local path.
  Future<String> download(UpdateInfo info, {required void Function(double) onProgress, CancelToken? cancel}) async {
    final dir = await updatesDir();
    final path = '$dir/${info.apkName}';
    await deleteFile(path);
    await _dio.download(
      info.apkUrl,
      path,
      cancelToken: cancel,
      onReceiveProgress: (r, t) {
        final total = t > 0 ? t : (info.sizeBytes ?? 0);
        if (total > 0) onProgress((r / total).clamp(0, 1));
      },
    );
    if (info.checksumsUrl != null) {
      final sums = await _dio.get<String>(info.checksumsUrl!, options: Options(responseType: ResponseType.plain));
      final expected = checksumFor(sums.data ?? '', info.apkName);
      final actual = await sha256OfFile(path);
      if (expected == null || expected != actual) {
        await deleteFile(path);
        throw const ChecksumMismatch();
      }
    }
    return path;
  }
}
