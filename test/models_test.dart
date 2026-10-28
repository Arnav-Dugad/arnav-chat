import 'package:arnav_chat/data/media/media_prep.dart';
import 'package:arnav_chat/data/models/chat.dart';
import 'package:arnav_chat/data/models/message.dart';
import 'package:arnav_chat/data/models/message_payload.dart';
import 'package:arnav_chat/data/remote/link_preview_service.dart';
import 'package:arnav_chat/data/repositories/user_repository.dart';
import 'package:arnav_chat/features/people/people_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlainPayloadCodec', () {
    const codec = PlainPayloadCodec();

    test('round-trips media payloads', () {
      const p = MessagePayload(
        kind: MessageKind.audio,
        media: MediaRef(url: 'https://res.cloudinary.com/x.m4a', durationMs: 3200, waveform: [0.1, 0.5, 1.0]),
      );
      final back = codec.decode(codec.encode(p));
      expect(back.kind, MessageKind.audio);
      expect(back.media!.durationMs, 3200);
      expect(back.media!.waveform, [0.1, 0.5, 1.0]);
    });

    test('marks the envelope version and encryption scheme', () {
      final m = codec.encode(const MessagePayload.text('hi'));
      expect(m['v'], 1);
      expect(m['enc'], 'none');
    });

    test('unknown encryption degrades to a placeholder, never crashes', () {
      final p = codec.decode({'v': 2, 'enc': 'e2ee-v1', 'kind': 'text', 'ct': 'xx'});
      expect(p.kind, MessageKind.text);
      expect(p.text, contains('Update'));
    });
  });

  test('preview text per kind', () {
    expect(const MessagePayload.text('a\nb').preview, 'a b');
    expect(const MessagePayload(kind: MessageKind.image).preview, 'Photo');
    expect(MessagePayload.deleted.preview, 'Message deleted');
  });

  test('direct chat id is order-independent', () {
    expect(ChatSummary.directId('b', 'a'), 'a_b');
    expect(ChatSummary.directId('a', 'b'), 'a_b');
  });

  group('receipts', () {
    final t = DateTime(2026, 1, 1, 12);
    Message msg(SendState s) =>
        Message(id: '1', chatId: 'c', senderId: 'me', createdAt: t, payload: const MessagePayload.text('x'), state: s);

    test('pending and failed come from local state', () {
      expect(msg(SendState.pending).receipt(), Receipt.pending);
      expect(msg(SendState.failed).receipt(), Receipt.failed);
    });

    test('delivered/read derive from peer watermarks', () {
      final m = msg(SendState.sent);
      expect(m.receipt(), Receipt.sent);
      expect(m.receipt(deliveredUpTo: t), Receipt.delivered);
      expect(m.receipt(deliveredUpTo: t, readUpTo: t.add(const Duration(seconds: 1))), Receipt.read);
      expect(m.receipt(readUpTo: t.subtract(const Duration(seconds: 1))), Receipt.sent);
    });

    test('reaction counts are sorted by popularity', () {
      final m = Message(
        id: '1',
        chatId: 'c',
        senderId: 'a',
        createdAt: t,
        payload: const MessagePayload.text('x'),
        reactions: const {'a': '👍', 'b': '❤️', 'c': '❤️'},
      );
      expect(m.reactionCounts.first.key, '❤️');
      expect(m.reactionCounts.first.value, 2);
    });
  });

  group('usernames', () {
    test('normalise and validate', () {
      expect(normalizeUsername('  @Arnav_01 '), 'arnav_01');
      expect(usernamePattern.hasMatch('ab'), isFalse);
      expect(usernamePattern.hasMatch('arnav.chat'), isFalse);
      expect(usernamePattern.hasMatch('arnav_chat'), isTrue);
    });

    test('QR payload round-trips', () {
      expect(usernameFromQr(qrPayloadFor('arnav')), 'arnav');
      expect(usernameFromQr('https://evil.example/u/arnav'), isNull);
    });
  });

  group('link previews', () {
    test('finds the first URL', () {
      expect(firstUrl('see https://flutter.dev/docs now'), 'https://flutter.dev/docs');
      expect(firstUrl('no links here'), isNull);
    });

    test('parses OpenGraph tags in either attribute order', () {
      const html = '<meta property="og:title" content="Flutter &amp; Dart">'
          '<meta content="Build apps" name="description">'
          '<meta property="og:image" content="/img.png">';
      final p = parseOpenGraph('https://flutter.dev/x', html)!;
      expect(p.title, 'Flutter & Dart');
      expect(p.description, 'Build apps');
      expect(p.imageUrl, 'https://flutter.dev/img.png');
      expect(p.siteName, 'flutter.dev');
    });
  });

  test('waveform is normalised to the requested bar count', () {
    final w = normalizeWaveform(List.generate(200, (i) => -50.0 + (i % 50)), bars: 32);
    expect(w, hasLength(32));
    expect(w.every((v) => v >= 0.05 && v <= 1), isTrue);
    expect(normalizeWaveform(const []), hasLength(48));
  });
}
