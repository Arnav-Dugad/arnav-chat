import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageMeta {
  const ImageMeta({required this.width, required this.height, this.blurhash});

  final int width;
  final int height;
  final String? blurhash;
}

/// Decodes an image off the UI thread to get its size and a blurhash
/// placeholder (rendered by receivers while the real image loads).
Future<ImageMeta?> analyzeImage(Uint8List bytes) => compute(_analyze, bytes);

ImageMeta? _analyze(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final oriented = img.bakeOrientation(decoded);
  final small = img.copyResize(oriented, width: 32);
  String? hash;
  try {
    hash = BlurHash.encode(small, numCompX: 4, numCompY: 3).hash;
  } catch (_) {}
  return ImageMeta(width: oriented.width, height: oriented.height, blurhash: hash);
}

/// Downsamples a recorded amplitude stream (dBFS) to [bars] values in 0..1.
List<double> normalizeWaveform(List<double> dbfs, {int bars = 48}) {
  if (dbfs.isEmpty) return List.filled(bars, 0.08);
  final levels = dbfs.map((d) => ((d + 50) / 50).clamp(0.05, 1.0)).toList();
  final out = <double>[];
  for (var i = 0; i < bars; i++) {
    final start = (i * levels.length / bars).floor();
    final end = (((i + 1) * levels.length / bars).ceil()).clamp(start + 1, levels.length);
    var peak = 0.0;
    for (var j = start; j < end; j++) {
      if (levels[j] > peak) peak = levels[j];
    }
    out.add(double.parse(peak.toStringAsFixed(2)));
  }
  return out;
}
