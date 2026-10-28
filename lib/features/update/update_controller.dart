import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers.dart';
import 'update_service.dart';

part 'update_controller.g.dart';

sealed class UpdateState {
  const UpdateState();
}

class UpdateIdle extends UpdateState {
  const UpdateIdle();
}

class UpdateAvailable extends UpdateState {
  const UpdateAvailable(this.info);
  final UpdateInfo info;
}

class UpdateDownloading extends UpdateState {
  const UpdateDownloading(this.info, this.progress);
  final UpdateInfo info;
  final double progress;
}

class UpdateReady extends UpdateState {
  const UpdateReady(this.info, this.path, {this.needsPermission = false});
  final UpdateInfo info;
  final String path;
  final bool needsPermission;
}

class UpdateFailed extends UpdateState {
  const UpdateFailed(this.info, this.reason);
  final UpdateInfo info;
  final String reason;
}

@Riverpod(keepAlive: true)
UpdateService updateService(Ref ref) => UpdateService();

@Riverpod(keepAlive: true)
class UpdateController extends _$UpdateController {
  static const _lastCheckKey = 'update.lastCheck';
  CancelToken? _cancel;

  @override
  UpdateState build() => const UpdateIdle();

  /// [onLaunch] checks regardless of the daily throttle.
  Future<UpdateInfo?> check({bool onLaunch = false}) async {
    final prefs = ref.read(sharedPrefsProvider);
    final last = prefs.getInt(_lastCheckKey) ?? 0;
    final due = DateTime.now().millisecondsSinceEpoch - last > const Duration(hours: 24).inMilliseconds;
    if (!onLaunch && !due) return null;
    if (state is UpdateDownloading) return null;
    try {
      final info = await ref.read(updateServiceProvider).check();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
      if (info != null) state = UpdateAvailable(info);
      return info;
    } catch (_) {
      return null;
    }
  }

  Future<void> download() async {
    final info = switch (state) {
      UpdateAvailable(:final info) || UpdateFailed(:final info) => info,
      _ => null,
    };
    if (info == null) return;
    final svc = ref.read(updateServiceProvider);
    _cancel = CancelToken();
    state = UpdateDownloading(info, 0);
    try {
      final path = await svc.download(
        info,
        cancel: _cancel,
        onProgress: (p) {
          if (state is UpdateDownloading) state = UpdateDownloading(info, p);
        },
      );
      await install(UpdateReady(info, path));
    } on ChecksumMismatch {
      state = UpdateFailed(info, 'Verification failed');
    } on DioException catch (e) {
      state = e.type == DioExceptionType.cancel ? UpdateAvailable(info) : UpdateFailed(info, 'Download failed');
    } catch (_) {
      state = UpdateFailed(info, 'Download failed');
    }
  }

  /// Launches the system installer, or asks for "install unknown apps" first.
  Future<void> install([UpdateReady? ready]) async {
    final r = ready ?? (state is UpdateReady ? state as UpdateReady : null);
    if (r == null) return;
    final installer = ref.read(updateServiceProvider).installer;
    if (!await installer.canInstall()) {
      state = UpdateReady(r.info, r.path, needsPermission: true);
      return;
    }
    state = UpdateReady(r.info, r.path);
    await installer.install(r.path);
  }

  Future<void> openPermissionSettings() => ref.read(updateServiceProvider).installer.openInstallSettings();

  /// "Later": keep the result but stop prompting until the next check.
  void later() {
    _cancel?.cancel();
    state = const UpdateIdle();
  }
}
