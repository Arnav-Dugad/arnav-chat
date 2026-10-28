import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/config/env.dart';

class UploadSignature {
  const UploadSignature({
    required this.cloudName,
    required this.apiKey,
    required this.timestamp,
    required this.signature,
    required this.folder,
  });

  final String cloudName;
  final String apiKey;
  final int timestamp;
  final String signature;
  final String folder;

  factory UploadSignature.fromJson(Map<String, dynamic> j) => UploadSignature(
        cloudName: j['cloudName'] as String,
        apiKey: j['apiKey'] as String,
        timestamp: (j['timestamp'] as num).toInt(),
        signature: j['signature'] as String,
        folder: j['folder'] as String,
      );
}

class WorkerUnavailable implements Exception {
  const WorkerUnavailable();
  @override
  String toString() => 'Worker URL not configured';
}

/// Client for the Cloudflare Worker. Every call carries the Firebase ID token;
/// the Worker verifies it and holds all secrets.
class WorkerApi {
  WorkerApi(this._auth, {Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: Env.workerUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              contentType: Headers.jsonContentType,
            ));

  final FirebaseAuth _auth;
  final Dio _dio;

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    if (!Env.hasWorker) throw const WorkerUnavailable();
    final token = await _auth.currentUser?.getIdToken();
    if (token == null) throw StateError('Not signed in');
    final res = await _dio.post<Map<String, dynamic>>(
      path,
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return res.data ?? const {};
  }

  /// [kind]: image | video | audio | file | avatar
  Future<UploadSignature> signUpload(String kind) async =>
      UploadSignature.fromJson(await _post('/v1/upload-signature', {'kind': kind}));

  Future<void> notify({required String chatId, required String messageId, required String preview, required String kind}) =>
      _post('/v1/notify', {'chatId': chatId, 'messageId': messageId, 'preview': preview, 'kind': kind});
}
