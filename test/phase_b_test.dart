import 'package:arnav_chat/data/models/app_user.dart';
import 'package:arnav_chat/data/models/chat.dart';
import 'package:arnav_chat/data/models/message.dart';
import 'package:arnav_chat/data/models/message_payload.dart';
import 'package:arnav_chat/data/repositories/group_repository.dart';
import 'package:arnav_chat/data/repositories/message_repository.dart';
import 'package:arnav_chat/features/chat/widgets/mention_suggestions.dart';
import 'package:arnav_chat/features/people/people_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = PlainPayloadCodec();

  group('polls', () {
    final poll = const Poll(question: 'Lunch?', multi: true, options: [PollOption('a', 'Pizza'), PollOption('b', 'Sushi')]);

    test('round-trip through the payload codec, question mirrored into text', () {
      final enc = codec.encode(MessagePayload.poll(poll));
      expect(enc['text'], 'Lunch?');
      final back = codec.decode(enc);
      expect(back.kind, MessageKind.poll);
      expect(back.poll!.options.map((o) => o.text), ['Pizza', 'Sushi']);
      expect(back.poll!.multi, isTrue);
    });

    test('vote counting', () {
      final m = Message(
        id: 'p',
        chatId: 'c',
        senderId: 'a',
        createdAt: DateTime(2026),
        payload: MessagePayload.poll(poll),
        votes: const {
          'u1': ['a'],
          'u2': ['a', 'b'],
          'u3': [],
        },
      );
      expect(m.voteCounts, {'a': 2, 'b': 1});
      expect(m.voterCount, 2);
    });
  });

  test('system and mention payloads survive encoding', () {
    final sys = codec.decode(codec.encode(const MessagePayload.system('Alice created the group')));
    expect(sys.kind, MessageKind.system);
    expect(sys.preview, 'Alice created the group');
    final t = codec.decode(codec.encode(const MessagePayload.text('hi @bob', mentions: ['uid-bob'])));
    expect(t.mentions, ['uid-bob']);
  });

  group('folders', () {
    const direct = ChatSummary(id: 'a_b', type: ChatType.direct, members: ['a', 'b'], unread: 0);
    final group = ChatSummary(
      id: 'g1',
      type: ChatType.group,
      members: const ['a', 'b', 'c'],
      unread: 3,
      mutedUntil: DateTime.now().add(const Duration(days: 1)),
    );

    test('type rules and explicit chats', () {
      const people = ChatFolder(id: 'f', name: 'People', includeDirect: true);
      expect(people.matches(direct), isTrue);
      expect(people.matches(group), isFalse);
      const picked = ChatFolder(id: 'f', name: 'Picked', chatIds: ['g1']);
      expect(picked.matches(group), isTrue);
    });

    test('unread-only and hide-muted filters', () {
      const unread = ChatFolder(id: 'f', name: 'U', includeDirect: true, includeGroups: true, unreadOnly: true);
      expect(unread.matches(direct), isFalse);
      expect(unread.matches(group), isTrue);
      const quiet = ChatFolder(id: 'f', name: 'Q', includeGroups: true, excludeMuted: true);
      expect(quiet.matches(group), isFalse);
    });

    test('flags round-trip', () {
      const f = ChatFolder(id: 'f', name: 'X', includeGroups: true, excludeMuted: true);
      final back = ChatFolder.fromFlags(id: 'f', name: 'X', flags: f.flags, chatIds: const []);
      expect(back.includeGroups && back.excludeMuted && !back.includeDirect && !back.unreadOnly, isTrue);
    });
  });

  group('mentions', () {
    const bob = AppUser(uid: 'u-bob', username: 'bob', displayName: 'Bob');
    const bobby = AppUser(uid: 'u-bobby', username: 'bobby', displayName: 'Bobby');

    test('query at caret', () {
      expect(mentionQuery(const TextEditingValue(text: 'hey @bo', selection: TextSelection.collapsed(offset: 7))), 'bo');
      expect(mentionQuery(const TextEditingValue(text: 'mail a@b', selection: TextSelection.collapsed(offset: 8))), isNull);
    });

    test('insert replaces the partial handle', () {
      final v = insertMention(const TextEditingValue(text: 'hey @bo', selection: TextSelection.collapsed(offset: 7)), 'bobby');
      expect(v.text, 'hey @bobby ');
      expect(v.selection.baseOffset, v.text.length);
    });

    test('mentioned uids require an exact handle', () {
      expect(mentionedUids('thanks @bob!', [bob, bobby]), ['u-bob']);
      expect(mentionedUids('cc @bobby', [bob, bobby]), ['u-bobby']);
    });
  });

  test('search index lower-cases text, file names and poll options; links get their own kind', () {
    expect(indexFor(const MessagePayload.text('See https://x.dev NOW')).kind, 'link');
    expect(indexFor(const MessagePayload.text('See https://x.dev NOW')).text, 'see https://x.dev now');
    final p = indexFor(MessagePayload.poll(const Poll(question: 'Q', options: [PollOption('a', 'Mango')])));
    expect(p.kind, 'poll');
    expect(p.text, contains('mango'));
  });

  test('invite tokens are random and url-safe', () {
    final a = randomToken(16), b = randomToken(16);
    expect(a, hasLength(16));
    expect(a, isNot(b));
    expect(RegExp(r'^[A-Za-z0-9]+$').hasMatch(a), isTrue);
  });

  test('QR parser accepts both the v1.0 and deep-link formats', () {
    expect(usernameFromQr('arnavchat://u/arnav'), 'arnav');
    expect(usernameFromQr('arnavchat://app/u/arnav'), 'arnav');
    expect(usernameFromQr(qrPayloadFor('arnav')), 'arnav');
  });
}
