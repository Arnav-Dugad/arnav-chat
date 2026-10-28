// Bumps pubspec.yaml version (semver) and always increments the build number
// (Android versionCode), then prints the tag to push.
//
//   dart run tool/bump_version.dart patch   # 1.0.0+1 -> 1.0.1+2
//   dart run tool/bump_version.dart minor   # 1.0.1+2 -> 1.1.0+3
import 'dart:io';

void main(List<String> args) {
  final part = args.isEmpty ? 'patch' : args.first;
  final file = File('pubspec.yaml');
  final text = file.readAsStringSync();
  final re = RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)', multiLine: true);
  final m = re.firstMatch(text);
  if (m == null) {
    stderr.writeln('version: x.y.z+n not found in pubspec.yaml');
    exit(1);
  }
  var major = int.parse(m[1]!), minor = int.parse(m[2]!), patch = int.parse(m[3]!);
  final code = int.parse(m[4]!) + 1;
  switch (part) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
    case 'minor':
      minor++;
      patch = 0;
    case 'patch':
      patch++;
    default:
      stderr.writeln('usage: bump_version.dart [major|minor|patch]');
      exit(64);
  }
  final next = '$major.$minor.$patch+$code';
  file.writeAsStringSync(text.replaceFirst(re, 'version: $next'));
  stdout.writeln('pubspec → $next');
  stdout.writeln(
    'git commit -am "Release v$major.$minor.$patch" && git tag v$major.$minor.$patch && git push origin main v$major.$minor.$patch',
  );
}
