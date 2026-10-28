import 'app_user.dart';
import 'message_payload.dart';

enum ChatType { direct, self, group }

class LastMessage {
  const LastMessage({
    required this.id,
    required this.senderId,
    required this.kind,
    required this.preview,
    required this.at,
  });

  final String id;
  final String senderId;
  final MessageKind kind;
  final String preview;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'kind': kind.name,
    'preview': preview,
    'at': at.millisecondsSinceEpoch,
  };

  factory LastMessage.fromJson(Map<String, dynamic> m) => LastMessage(
    id: m['id'] as String? ?? '',
    senderId: m['senderId'] as String? ?? '',
    kind: MessageKind.values.firstWhere((k) => k.name == m['kind'], orElse: () => MessageKind.text),
    preview: m['preview'] as String? ?? '',
    at: DateTime.fromMillisecondsSinceEpoch((m['at'] as num?)?.toInt() ?? 0),
  );
}

/// A chat row as the UI sees it (Drift row + resolved peer profile).
class ChatSummary {
  const ChatSummary({
    required this.id,
    required this.type,
    required this.members,
    this.peerUid,
    this.peer,
    this.last,
    this.unread = 0,
    this.peerReadUpTo,
    this.peerDeliveredUpTo,
    this.pinned = false,
    this.archived = false,
    this.mutedUntil,
    this.draft,
  });

  final String id;
  final ChatType type;
  final List<String> members;
  final String? peerUid;
  final AppUser? peer;
  final LastMessage? last;
  final int unread;
  final DateTime? peerReadUpTo;
  final DateTime? peerDeliveredUpTo;
  final bool pinned;
  final bool archived;
  final DateTime? mutedUntil;
  final String? draft;

  bool get muted => mutedUntil != null && mutedUntil!.isAfter(DateTime.now());

  String title(String fallback) => type == ChatType.self ? 'Saved' : (peer?.displayName ?? fallback);

  DateTime get sortTime => last?.at ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Deterministic id for a 1:1 chat.
  static String directId(String a, String b) => a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';
}
