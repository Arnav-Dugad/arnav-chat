import 'message_payload.dart';

/// Local send state (persisted in Drift). Server-side receipt state is
/// derived from the chat's read/delivered watermarks.
enum SendState { sent, pending, failed }

enum Receipt { pending, failed, sent, delivered, read }

class ReplyRef {
  const ReplyRef({required this.id, required this.senderId, required this.preview, this.kind = MessageKind.text});

  final String id;
  final String senderId;
  final String preview;
  final MessageKind kind;

  Map<String, dynamic> toMap() => {'id': id, 'senderId': senderId, 'preview': preview, 'kind': kind.name};

  factory ReplyRef.fromMap(Map<String, dynamic> m) => ReplyRef(
    id: m['id'] as String? ?? '',
    senderId: m['senderId'] as String? ?? '',
    preview: m['preview'] as String? ?? '',
    kind: MessageKind.values.firstWhere((k) => k.name == m['kind'], orElse: () => MessageKind.text),
  );
}

class Message {
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.createdAt,
    required this.payload,
    this.serverConfirmed = false,
    this.reply,
    this.forwarded = false,
    this.editedAt,
    this.deletedForEveryone = false,
    this.reactions = const {},
    this.votes = const {},
    this.state = SendState.sent,
    this.starred = false,
    this.localPath,
    this.progress,
  });

  final String id;
  final String chatId;
  final String senderId;
  final DateTime createdAt;
  final bool serverConfirmed;
  final MessagePayload payload;
  final ReplyRef? reply;
  final bool forwarded;
  final DateTime? editedAt;
  final bool deletedForEveryone;

  /// uid -> emoji
  final Map<String, String> reactions;

  /// Poll votes: uid -> chosen option ids.
  final Map<String, List<String>> votes;
  final SendState state;
  final bool starred;

  /// Local file for media still uploading (or cached after sending).
  final String? localPath;

  /// Upload progress 0..1 while sending media.
  final double? progress;

  bool isMine(String uid) => senderId == uid;

  Receipt receipt({DateTime? deliveredUpTo, DateTime? readUpTo}) {
    if (state == SendState.pending) return Receipt.pending;
    if (state == SendState.failed) return Receipt.failed;
    if (readUpTo != null && !createdAt.isAfter(readUpTo)) return Receipt.read;
    if (deliveredUpTo != null && !createdAt.isAfter(deliveredUpTo)) return Receipt.delivered;
    return Receipt.sent;
  }

  /// Reaction emoji -> count, most popular first.
  List<MapEntry<String, int>> get reactionCounts {
    final counts = <String, int>{};
    for (final e in reactions.values) {
      counts[e] = (counts[e] ?? 0) + 1;
    }
    return counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  /// Option id -> number of voters.
  Map<String, int> get voteCounts {
    final counts = <String, int>{};
    for (final picks in votes.values) {
      for (final id in picks) {
        counts[id] = (counts[id] ?? 0) + 1;
      }
    }
    return counts;
  }

  int get voterCount => votes.values.where((v) => v.isNotEmpty).length;
}
