/// The message body. Everything that would be encrypted end-to-end lives here,
/// so an E2EE [PayloadCodec] can later replace [PlainPayloadCodec] without
/// touching the rest of the message document.
enum MessageKind { text, image, video, audio, file, deleted }

class MediaRef {
  const MediaRef({
    required this.url,
    this.publicId,
    this.mime,
    this.name,
    this.bytes,
    this.width,
    this.height,
    this.durationMs,
    this.blurhash,
    this.waveform,
  });

  final String url;
  final String? publicId;
  final String? mime;
  final String? name;
  final int? bytes;
  final int? width;
  final int? height;
  final int? durationMs;
  final String? blurhash;

  /// Normalised 0..1 amplitudes for voice notes.
  final List<double>? waveform;

  double? get aspectRatio => (width != null && height != null && height! > 0) ? width! / height! : null;

  Map<String, dynamic> toMap() => {
    'url': url,
    'publicId': ?publicId,
    'mime': ?mime,
    'name': ?name,
    'bytes': ?bytes,
    'w': ?width,
    'h': ?height,
    'dur': ?durationMs,
    'bh': ?blurhash,
    if (waveform != null) 'wave': waveform!.map((v) => (v * 100).round()).toList(),
  };

  factory MediaRef.fromMap(Map<String, dynamic> m) => MediaRef(
    url: m['url'] as String? ?? '',
    publicId: m['publicId'] as String?,
    mime: m['mime'] as String?,
    name: m['name'] as String?,
    bytes: (m['bytes'] as num?)?.toInt(),
    width: (m['w'] as num?)?.toInt(),
    height: (m['h'] as num?)?.toInt(),
    durationMs: (m['dur'] as num?)?.toInt(),
    blurhash: m['bh'] as String?,
    waveform: (m['wave'] as List?)?.map((v) => (v as num).toDouble() / 100).toList(),
  );

  MediaRef copyWith({String? url, String? publicId}) => MediaRef(
    url: url ?? this.url,
    publicId: publicId ?? this.publicId,
    mime: mime,
    name: name,
    bytes: bytes,
    width: width,
    height: height,
    durationMs: durationMs,
    blurhash: blurhash,
    waveform: waveform,
  );
}

class LinkPreview {
  const LinkPreview({required this.url, this.title, this.description, this.imageUrl, this.siteName});

  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? siteName;

  Map<String, dynamic> toMap() => {
    'url': url,
    'title': ?title,
    'desc': ?description,
    'img': ?imageUrl,
    'site': ?siteName,
  };

  factory LinkPreview.fromMap(Map<String, dynamic> m) => LinkPreview(
    url: m['url'] as String? ?? '',
    title: m['title'] as String?,
    description: m['desc'] as String?,
    imageUrl: m['img'] as String?,
    siteName: m['site'] as String?,
  );
}

class MessagePayload {
  const MessagePayload({required this.kind, this.text, this.media, this.link});

  const MessagePayload.text(String this.text, {this.link}) : kind = MessageKind.text, media = null;

  static const deleted = MessagePayload(kind: MessageKind.deleted);

  final MessageKind kind;
  final String? text;
  final MediaRef? media;
  final LinkPreview? link;

  bool get hasMedia => media != null;

  /// Short plain-text preview for chat list rows and notifications.
  String get preview => switch (kind) {
    MessageKind.text => (text ?? '').replaceAll('\n', ' '),
    MessageKind.image => (text?.isNotEmpty ?? false) ? 'Photo · $text' : 'Photo',
    MessageKind.video => (text?.isNotEmpty ?? false) ? 'Video · $text' : 'Video',
    MessageKind.audio => 'Voice message',
    MessageKind.file => media?.name ?? 'File',
    MessageKind.deleted => 'Message deleted',
  };

  MessagePayload copyWith({String? text, MediaRef? media, LinkPreview? link}) =>
      MessagePayload(kind: kind, text: text ?? this.text, media: media ?? this.media, link: link ?? this.link);
}

/// Encodes a [MessagePayload] into the Firestore `payload` field and back.
abstract interface class PayloadCodec {
  Map<String, dynamic> encode(MessagePayload payload);
  MessagePayload decode(Map<String, dynamic> map);
}

/// Version 1, unencrypted. `enc` tells future clients how to decode.
class PlainPayloadCodec implements PayloadCodec {
  const PlainPayloadCodec();

  static const version = 1;

  @override
  Map<String, dynamic> encode(MessagePayload p) => {
    'v': version,
    'enc': 'none',
    'kind': p.kind.name,
    if (p.text != null && p.text!.isNotEmpty) 'text': p.text,
    if (p.media != null) 'media': p.media!.toMap(),
    if (p.link != null) 'link': p.link!.toMap(),
  };

  @override
  MessagePayload decode(Map<String, dynamic> m) {
    if (m['enc'] != null && m['enc'] != 'none') {
      // Unknown encryption scheme (newer client) — show a safe placeholder.
      return const MessagePayload(kind: MessageKind.text, text: 'Update the app to view this message');
    }
    final kind = MessageKind.values.firstWhere((k) => k.name == m['kind'], orElse: () => MessageKind.text);
    return MessagePayload(
      kind: kind,
      text: m['text'] as String?,
      media: m['media'] is Map ? MediaRef.fromMap(Map<String, dynamic>.from(m['media'] as Map)) : null,
      link: m['link'] is Map ? LinkPreview.fromMap(Map<String, dynamic>.from(m['link'] as Map)) : null,
    );
  }
}
