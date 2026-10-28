import 'package:arnav_chat/core/design/motion.dart';
import 'package:arnav_chat/core/utils/media_url.dart';
import 'package:arnav_chat/core/utils/time_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeFormat', () {
    final now = DateTime(2026, 10, 28, 15, 0);

    test('chat list timestamps', () {
      expect(TimeFormat.chatList(DateTime(2026, 10, 28, 9, 5), now: now), '09:05');
      expect(TimeFormat.chatList(DateTime(2026, 10, 27, 23, 0), now: now), 'Yesterday');
      expect(TimeFormat.chatList(DateTime(2026, 1, 3), now: now), '03/01/26');
    });

    test('last seen', () {
      expect(TimeFormat.lastSeen(now.subtract(const Duration(seconds: 20)), now: now), 'last seen just now');
      expect(TimeFormat.lastSeen(now.subtract(const Duration(minutes: 5)), now: now), 'last seen 5m ago');
    });

    test('durations', () {
      expect(TimeFormat.duration(const Duration(seconds: 65)), '1:05');
      expect(TimeFormat.duration(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
    });
  });

  group('MediaUrl', () {
    const url = 'https://res.cloudinary.com/demo/image/upload/v1/arnav-chat/u/image/a.jpg';

    test('injects CDN transformations', () {
      expect(
        MediaUrl.fit(url, 600),
        'https://res.cloudinary.com/demo/image/upload/c_limit,w_600,f_auto,q_auto/v1/arnav-chat/u/image/a.jpg',
      );
    });

    test('leaves foreign URLs alone', () {
      expect(MediaUrl.thumb('https://example.com/a.jpg', 96), 'https://example.com/a.jpg');
    });
  });

  test('rubber band resists and never exceeds its limit', () {
    expect(rubberBand(0, 100), 0);
    expect(rubberBand(50, 100), lessThan(50));
    expect(rubberBand(10000, 100), lessThan(100));
    expect(rubberBand(-50, 100), lessThan(0));
  });

  test('spring curve settles at 1 and overshoots for bouncy springs', () {
    final c = SpringCurve(Springs.bouncy, settle: 0.75);
    expect(c.transform(0), 0);
    expect(c.transform(1), 1);
    final peak = List.generate(100, (i) => c.transform(i / 100)).reduce((a, b) => a > b ? a : b);
    expect(peak, greaterThan(1));
  });
}
