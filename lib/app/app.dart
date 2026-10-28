import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/theme.dart';
import '../data/providers.dart';
import '../features/home/session_services.dart';
import '../features/launch/launch_overlay.dart';
import '../features/settings/appearance_controller.dart';
import 'router.dart';

class ArnavChatApp extends ConsumerWidget {
  const ArnavChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceControllerProvider);
    final router = ref.watch(routerProvider);
    final ready = ref.watch(sessionProvider.select((s) => s.hasValue && s.value is! SessionLoading));

    return MaterialApp.router(
      title: 'Arnav Chat',
      debugShowCheckedModeBanner: false,
      themeMode: appearance.mode,
      theme: AppTheme.build(Brightness.light, appearance.accent),
      darkTheme: AppTheme.build(Brightness.dark, appearance.accent),
      routerConfig: router,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.overlayStyle(brightness),
          child: _SplashHandoff(
            child: LaunchOverlay(
              ready: ready,
              child: SessionServices(child: child ?? const SizedBox.shrink()),
            ),
          ),
        );
      },
    );
  }
}

/// Removes the native splash on the first Flutter frame; the launch overlay
/// draws the identical logo so the hand-off is invisible.
class _SplashHandoff extends StatefulWidget {
  const _SplashHandoff({required this.child});
  final Widget child;

  @override
  State<_SplashHandoff> createState() => _SplashHandoffState();
}

class _SplashHandoffState extends State<_SplashHandoff> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => FlutterNativeSplash.remove());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
