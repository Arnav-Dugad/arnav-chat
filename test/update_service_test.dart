import 'package:arnav_chat/features/update/update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('versions', () {
    test('parses tags and build suffixes', () {
      expect(parseVersion('v1.2.3'), [1, 2, 3]);
      expect(parseVersion('1.0.0+7'), [1, 0, 0]);
      expect(parseVersion('2.1'), [2, 1, 0]);
    });

    test('compares semver numerically', () {
      expect(compareVersions('v1.0.1', '1.0.0'), greaterThan(0));
      expect(compareVersions('1.10.0', '1.9.9'), greaterThan(0));
      expect(compareVersions('1.0.0', 'v1.0.0'), 0);
      expect(compareVersions('0.9.0', '1.0.0'), lessThan(0));
    });
  });

  group('pickApk', () {
    final assets = [
      {'name': 'arnav-chat-arm64-v8a.apk', 'browser_download_url': 'u/arm64', 'size': 10},
      {'name': 'arnav-chat-armeabi-v7a.apk', 'browser_download_url': 'u/v7a', 'size': 9},
      {'name': 'arnav-chat-universal.apk', 'browser_download_url': 'u/universal', 'size': 30},
      {'name': 'checksums.txt', 'browser_download_url': 'u/sums', 'size': 1},
    ];

    test('prefers the device primary ABI', () {
      expect(pickApk(assets, ['arm64-v8a', 'armeabi-v7a'])!.url, 'u/arm64');
    });

    test('falls back to universal for unknown ABIs', () {
      expect(pickApk(assets, ['riscv64'])!.name, 'arnav-chat-universal.apk');
    });

    test('returns null without APKs', () {
      expect(pickApk([assets.last], ['arm64-v8a']), isNull);
    });
  });

  test('checksumFor reads sha256sum output', () {
    const sums = 'abc123  arnav-chat-universal.apk\nDEF456 *arnav-chat-arm64-v8a.apk\n';
    expect(checksumFor(sums, 'arnav-chat-arm64-v8a.apk'), 'def456');
    expect(checksumFor(sums, 'arnav-chat-universal.apk'), 'abc123');
    expect(checksumFor(sums, 'missing.apk'), isNull);
  });

  test('condenseNotes keeps a few clean bullet lines', () {
    const body = "## What's Changed\n* Faster chat list by @arnav in https://github.com/x/y/pull/1\n* **Voice** notes\n\n"
        '**Full Changelog**: https://github.com/x/y/compare/v1...v2';
    expect(condenseNotes(body), ['Faster chat list', 'Voice notes']);
  });
}
