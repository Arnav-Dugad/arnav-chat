import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<MultipartFile> multipartFromPath(String path, String filename) =>
    MultipartFile.fromFile(path, filename: filename);

Future<String> tempFilePath(String extension) async {
  final dir = await getTemporaryDirectory();
  return p.join(dir.path, 'ac_${DateTime.now().microsecondsSinceEpoch}.$extension');
}

Future<int> fileSize(String path) async => File(path).length();

Future<bool> fileExists(String path) async => File(path).exists();

Future<void> deleteFile(String path) async {
  final f = File(path);
  if (await f.exists()) await f.delete();
}

/// Directory used for downloaded update APKs (exposed via FileProvider).
Future<String> updatesDir() async {
  final dir = Directory(p.join((await getTemporaryDirectory()).path, 'updates'));
  await dir.create(recursive: true);
  return dir.path;
}

/// SHA-256 of a file, streamed in a background isolate.
Future<String> sha256OfFile(String path) => compute(_sha256, path);

Future<String> _sha256(String path) async {
  final digest = await sha256.bind(File(path).openRead()).first;
  return digest.toString();
}
