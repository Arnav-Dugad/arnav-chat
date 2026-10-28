/// Build-time configuration, injected with `--dart-define-from-file=env/app.json`.
/// Nothing in here is a secret: secrets live only in the Cloudflare Worker.
abstract final class Env {
  static const workerUrl = String.fromEnvironment('WORKER_URL');

  /// OAuth "web" client id (client_type 3 in google-services.json).
  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const rtdbUrl = String.fromEnvironment(
    'RTDB_URL',
    defaultValue: 'https://arnavchat-a16-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const githubRepo = String.fromEnvironment('GITHUB_REPO', defaultValue: 'Arnav-Dugad/arnav-chat');

  static bool get hasWorker => workerUrl.isNotEmpty;
}
