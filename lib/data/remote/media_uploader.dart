import 'package:dio/dio.dart';

import '../../core/platform/files.dart';
import '../models/message_payload.dart';
import 'worker_api.dart';

/// Signed direct-to-Cloudinary uploads. The signature comes from the Worker;
/// the API secret never reaches the device.
class MediaUploader {
  MediaUploader(this._worker, {Dio? dio}) : _dio = dio ?? Dio();

  final WorkerApi _worker;
  final Dio _dio;

  Future<MediaRef> upload({
    required String path,
    required String kind,
    required MediaRef draft,
    void Function(double progress)? onProgress,
    CancelToken? cancel,
  }) async {
    final sig = await _worker.signUpload(kind);
    final resource = switch (kind) {
      'file' => 'raw',
      'audio' || 'video' => 'video',
      _ => 'image',
    };
    final form = FormData.fromMap({
      'file': await multipartFromPath(path, draft.name ?? 'upload'),
      'api_key': sig.apiKey,
      'timestamp': sig.timestamp,
      'signature': sig.signature,
      'folder': sig.folder,
    });
    final res = await _dio.post<Map<String, dynamic>>(
      'https://api.cloudinary.com/v1_1/${sig.cloudName}/$resource/upload',
      data: form,
      cancelToken: cancel,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    final j = res.data!;
    return MediaRef(
      url: j['secure_url'] as String,
      publicId: j['public_id'] as String?,
      mime: draft.mime,
      name: draft.name,
      bytes: (j['bytes'] as num?)?.toInt() ?? draft.bytes,
      width: (j['width'] as num?)?.toInt() ?? draft.width,
      height: (j['height'] as num?)?.toInt() ?? draft.height,
      durationMs: j['duration'] is num ? ((j['duration'] as num) * 1000).round() : draft.durationMs,
      blurhash: draft.blurhash,
      waveform: draft.waveform,
    );
  }
}
