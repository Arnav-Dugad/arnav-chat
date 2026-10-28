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
    this.senderName,
  });

  final String id;
  final String senderId;
  final MessageKind kind;
  final String preview;
  final DateTime at;

  /// Set in groups so the list can show "Alice: hi".
  final String? senderName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'kind': kind.name,
    'preview': preview,
    'at': at.millisecondsSinceEpoch,
    'senderName': ?senderName,
  };

  factory LastMessage.fromJson(Map<String, dynamic> m) => LastMessage(
    id: m['id'] as String? ?? '',
    senderId: m['senderId'] as String? ?? '',
    kind: MessageKind.values.firstWhere((k) => k.name == m['kind'], orElse: () => MessageKind.text),
    preview: m['preview'] as String? ?? '',
    at: DateTime.fromMillisecondsSinceEpoch((m['at'] as num?)?.toInt() ?? 0),
    senderName: m['senderName'] as String?,
  );
}

class PinnedMessage {
  const PinnedMessage({required this.id, required this.senderId, required this.preview});

  final String id;
  final String senderId;
  final String preview;

  Map<String, dynamic> toJson() => {'id': id, 'senderId': senderId, 'preview': preview};

  factory PinnedMessage.fromJson(Map<String, dynamic> m) => PinnedMessage(
    id: m['id'] as String? ?? '',
    senderId: m['senderId'] as String? ?? '',
    preview: m['preview'] as String? ?? '',
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
    this.groupName,
    this.photoUrl,
    this.description,
    this.admins = const [],
    this.pinnedMessages = const [],
    this.wallpaper,
    this.accent,
    this.inviteCode,
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

  // Groups
  final String? groupName;
  final String? photoUrl;
  final String? description;
  final List<String> admins;
  final String? inviteCode;

  final List<PinnedMessage> pinnedMessages;

  // Per-chat appearance (local preference, synced via chatState).
  final String? wallpaper;
  final String? accent;

  bool get muted => mutedUntil != null && mutedUntil!.isAfter(DateTime.now());
  bool get isGroup => type == ChatType.group;
  bool get isSaved => type == ChatType.self;

  bool isAdmin(String uid) => admins.contains(uid);

  String title(String fallback) => switch (type) {
    ChatType.self => 'Saved Messages',
    ChatType.group => groupName ?? fallback,
    ChatType.direct => peer?.displayName ?? fallback,
  };

  String? get avatarUrl => isGroup ? photoUrl : peer?.photoUrl;

  DateTime get sortTime => last?.at ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Deterministic id for a 1:1 chat.
  static String directId(String a, String b) => a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';
}

/// Telegram-style folder: a named filter over the chat list.
class ChatFolder {
  const ChatFolder({
    required this.id,
    required this.name,
    this.includeDirect = false,
    this.includeGroups = false,
    this.unreadOnly = false,
    this.excludeMuted = false,
    this.chatIds = const [],
    this.order = 0,
  });

  final String id;
  final String name;
  final bool includeDirect;
  final bool includeGroups;
  final bool unreadOnly;
  final bool excludeMuted;
  final List<String> chatIds;
  final int order;

  bool matches(ChatSummary c) {
    final included =
        chatIds.contains(c.id) ||
        (includeDirect && c.type != ChatType.group) ||
        (includeGroups && c.type == ChatType.group);
    if (!included) return false;
    if (unreadOnly && c.unread == 0) return false;
    if (excludeMuted && c.muted) return false;
    return true;
  }

  int get flags =>
      (includeDirect ? 1 : 0) | (includeGroups ? 2 : 0) | (unreadOnly ? 4 : 0) | (excludeMuted ? 8 : 0);

  static ChatFolder fromFlags({
    required String id,
    required String name,
    required int flags,
    required List<String> chatIds,
    int order = 0,
  }) => ChatFolder(
    id: id,
    name: name,
    includeDirect: flags & 1 != 0,
    includeGroups: flags & 2 != 0,
    unreadOnly: flags & 4 != 0,
    excludeMuted: flags & 8 != 0,
    chatIds: chatIds,
    order: order,
  );

  Map<String, dynamic> toMap() => {'name': name, 'flags': flags, 'chatIds': chatIds, 'order': order};

  ChatFolder copyWith({
    String? name,
    bool? includeDirect,
    bool? includeGroups,
    bool? unreadOnly,
    bool? excludeMuted,
    List<String>? chatIds,
  }) => ChatFolder(
    id: id,
    name: name ?? this.name,
    includeDirect: includeDirect ?? this.includeDirect,
    includeGroups: includeGroups ?? this.includeGroups,
    unreadOnly: unreadOnly ?? this.unreadOnly,
    excludeMuted: excludeMuted ?? this.excludeMuted,
    chatIds: chatIds ?? this.chatIds,
    order: order,
  );
}
