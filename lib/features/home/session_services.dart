import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../data/models/app_user.dart';
import '../../data/providers.dart';
import '../notifications/push_handlers.dart' show myUidPrefKey;
import '../notifications/push_service.dart';
import '../update/update_controller.dart';
import '../update/update_sheet.dart';
import 'offline_banner.dart';

/// Starts and stops everything that lives for a signed-in session: chat-list
/// sync, the outbox, presence, push registration and update checks.
class SessionServices extends ConsumerStatefulWidget {
  const SessionServices({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionServices> createState() => _SessionServicesState();
}

class _SessionServicesState extends ConsumerState<SessionServices> {
  String? _startedFor;
  PushService? _push;
  AppLifecycleListener? _life;
  Timer? _daily;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _life = AppLifecycleListener(
      onResume: () {
        _setPresence(true);
        ref.read(updateControllerProvider.notifier).check();
        final s = ref.read(updateControllerProvider);
        if (s is UpdateReady && s.needsPermission) ref.read(updateControllerProvider.notifier).install();
        if (_startedFor != null) ref.read(outboxProvider).kick();
      },
      onPause: () => _setPresence(false),
      onDetach: () => _setPresence(false),
    );
    ref.listenManual(sessionProvider, (_, next) {
      final s = next.value;
      if (s is SessionReady) {
        _start(s.me);
      } else if (s is SessionSignedOut) {
        _stop();
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _life?.dispose();
    _daily?.cancel();
    _push?.dispose();
    super.dispose();
  }

  void _setPresence(bool online) {
    if (_startedFor == null) return;
    final me = _meOrNull();
    if (me == null) return;
    final share = me.privacy.lastSeen == Audience.everyone;
    final presence = ref.read(presenceProvider);
    (online ? presence.goOnline(share: share) : presence.goOffline(share: share)).catchError((_) {});
  }

  AppUser? _meOrNull() {
    final s = ref.read(sessionProvider).value;
    return s is SessionReady ? s.me : null;
  }

  Future<void> _start(AppUser me) async {
    if (_startedFor == me.uid) {
      ref.read(chatRepositoryProvider).shareReadReceipts = me.privacy.readReceipts;
      _setPresence(true);
      return;
    }
    _startedFor = me.uid;
    unawaited(ref.read(sharedPrefsProvider).setString(myUidPrefKey, me.uid));
    final chats = ref.read(chatRepositoryProvider)..shareReadReceipts = me.privacy.readReceipts;
    unawaited(chats.startSync());
    unawaited(ref.read(outboxProvider).kick());
    unawaited(ref.read(userRepositoryProvider).syncContactsOnce().catchError((_) {}));
    _setPresence(true);

    _push = PushService(
      ref.read(userRepositoryProvider),
      onOpenChat: (id) => ref.read(routerProvider).push('/chat/$id'),
    );
    unawaited(_push!.start().catchError((_) {}));

    unawaited(ref.read(updateControllerProvider.notifier).check(onLaunch: true));
    _daily?.cancel();
    _daily = Timer.periodic(const Duration(hours: 24), (_) => ref.read(updateControllerProvider.notifier).check());
  }

  void _stop() {
    _startedFor = null;
    _push?.dispose();
    _push = null;
    _daily?.cancel();
  }

  void _maybeShowUpdate(UpdateState next) {
    if (next is! UpdateAvailable || _sheetOpen) return;
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    _sheetOpen = true;
    showUpdateSheet(ctx, force: next.info.force).whenComplete(() {
      _sheetOpen = false;
      final s = ref.read(updateControllerProvider);
      if (s is UpdateAvailable && !s.info.force) ref.read(updateControllerProvider.notifier).later();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(onlineProvider, (_, next) {
      if (next.value == true && _startedFor != null) ref.read(outboxProvider).kick();
    });
    ref.listen(updateControllerProvider, (_, next) => _maybeShowUpdate(next));

    return Stack(children: [widget.child, const OfflineBanner()]);
  }
}
