import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/message_payload.dart';

final _urlRe = RegExp(r'https?://[^\s<>"]+', caseSensitive: false);

String? firstUrl(String text) => _urlRe.firstMatch(text)?.group(0);

/// Fetches OpenGraph metadata on the sender's device, so recipients get the
/// preview inside the message and never fetch it themselves.
class LinkPreviewService {
  LinkPreviewService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 4),
              receiveTimeout: const Duration(seconds: 5),
              responseType: ResponseType.plain,
              headers: {'User-Agent': 'Mozilla/5.0 (Linux; Android 14) ArnavChat/1.0 LinkPreview'},
              validateStatus: (s) => s != null && s < 400,
            ));

  final Dio _dio;
  final _cache = <String, LinkPreview?>{};

  Future<LinkPreview?> fetch(String url) async {
    if (kIsWeb) return null; // CORS: previews come from native clients only.
    if (_cache.containsKey(url)) return _cache[url];
    try {
      final res = await _dio.get<String>(url);
      final html = res.data ?? '';
      final preview = parseOpenGraph(url, html.length > 200000 ? html.substring(0, 200000) : html);
      _cache[url] = preview;
      return preview;
    } catch (_) {
      _cache[url] = null;
      return null;
    }
  }
}

@visibleForTesting
LinkPreview? parseOpenGraph(String url, String html) {
  String? meta(String key) {
    final patterns = [
      RegExp('<meta[^>]+(?:property|name)=["\']$key["\'][^>]*content=["\']([^"\']*)["\']', caseSensitive: false),
      RegExp('<meta[^>]+content=["\']([^"\']*)["\'][^>]*(?:property|name)=["\']$key["\']', caseSensitive: false),
    ];
    for (final re in patterns) {
      final m = re.firstMatch(html);
      if (m != null && m.group(1)!.trim().isNotEmpty) return _decode(m.group(1)!.trim());
    }
    return null;
  }

  final title = meta('og:title') ?? meta('twitter:title') ?? _title(html);
  if (title == null) return null;
  var image = meta('og:image') ?? meta('twitter:image');
  if (image != null && image.startsWith('/')) image = Uri.parse(url).resolve(image).toString();
  return LinkPreview(
    url: url,
    title: title,
    description: meta('og:description') ?? meta('description'),
    imageUrl: image,
    siteName: meta('og:site_name') ?? Uri.parse(url).host.replaceFirst('www.', ''),
  );
}

String? _title(String html) {
  final m = RegExp(r'<title[^>]*>([^<]*)</title>', caseSensitive: false).firstMatch(html);
  final t = m?.group(1)?.trim();
  return (t == null || t.isEmpty) ? null : _decode(t);
}

String _decode(String s) => s
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&#x27;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>');
