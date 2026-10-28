// File-system helpers behind a conditional import so UI/web code never
// touches dart:io directly.
export 'files_stub.dart' if (dart.library.io) 'files_io.dart';
