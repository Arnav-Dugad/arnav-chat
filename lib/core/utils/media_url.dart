/// Cloudinary delivery URL helpers. Transformations are applied on the CDN,
/// so we never download more pixels than we draw.
abstract final class MediaUrl {
  static const _marker = '/upload/';

  static String _transform(String url, String t) {
    if (!url.contains('res.cloudinary.com')) return url;
    final i = url.indexOf(_marker);
    if (i < 0) return url;
    return '${url.substring(0, i + _marker.length)}$t/${url.substring(i + _marker.length)}';
  }

  /// Square-cropped thumbnail (avatars).
  static String thumb(String url, int px) => _transform(url, 'c_fill,g_face,w_$px,h_$px,f_auto,q_auto');

  /// Width-bounded image for bubbles / viewer.
  static String fit(String url, int px) => _transform(url, 'c_limit,w_$px,f_auto,q_auto');

  /// First frame of a video as a still image.
  static String videoPoster(String url, int px) =>
      _transform(url, 'so_0,c_limit,w_$px,f_jpg,q_auto').replaceAll(RegExp(r'\.(mp4|mov|webm|mkv)$'), '.jpg');
}
