import 'package:dio/dio.dart';

// Web: media is picked as bytes; path-based helpers are unsupported.

Future<MultipartFile> multipartFromPath(String path, String filename) async =>
    throw UnsupportedError('Path uploads are not supported on this platform');

Future<String> tempFilePath(String extension) async => 'ac_${DateTime.now().microsecondsSinceEpoch}.$extension';

Future<int> fileSize(String path) async => 0;

Future<bool> fileExists(String path) async => false;

Future<void> deleteFile(String path) async {}

Future<String> updatesDir() async => throw UnsupportedError('Updates are Android-only');

Future<String> sha256OfFile(String path) async => throw UnsupportedError('Updates are Android-only');
