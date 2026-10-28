import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/toast.dart';
import '../../data/providers.dart';
import 'people_providers.dart';

/// "My code" and "Scan" in one screen, switched by a glass segmented pill.
class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> {
  bool _scan = false;
  bool _handled = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    final handle = raw == null ? null : usernameFromQr(raw);
    if (handle == null) return;
    _handled = true;
    Haptics.success();
    final user = await ref.read(userRepositoryProvider).byUsername(handle);
    if (!mounted) return;
    if (user == null) {
      showToast(context, 'Not found', error: true);
      _handled = false;
      return;
    }
    context.pushReplacement('/user/${user.uid}');
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider);
    final p = context.palette;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: _scan
                  ? MobileScanner(key: const ValueKey('scan'), onDetect: _onDetect)
                  : Center(
                      key: const ValueKey('code'),
                      child: Padding(
                        padding: const EdgeInsets.all(Gaps.x6),
                        child:
                            Glass(
                                  radius: Radii.xl,
                                  padding: const EdgeInsets.all(Gaps.x6),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Avatar(name: me.displayName, url: me.photoUrl, size: 64),
                                      const SizedBox(height: Gaps.x3),
                                      Text(me.handle, style: context.text.titleMedium),
                                      const SizedBox(height: Gaps.x5),
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: ShapeDecoration(
                                          color: Colors.white,
                                          shape: RoundedSuperellipseBorder(
                                            borderRadius: BorderRadius.circular(Radii.lg),
                                          ),
                                        ),
                                        child: QrImageView(
                                          data: qrPayloadFor(me.username),
                                          size: 220,
                                          eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.circle, color: p.accent.base),
                                          dataModuleStyle: const QrDataModuleStyle(
                                            dataModuleShape: QrDataModuleShape.circle,
                                            color: Color(0xFF0E1116),
                                          ),
                                          embeddedImage: const AssetImage('assets/brand/logo_48.png'),
                                          embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
                                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                                        ),
                                      ),
                                      const SizedBox(height: Gaps.x5),
                                      PillButton(
                                        label: 'Share',
                                        icon: AppIcons.share,
                                        style: PillStyle.secondary,
                                        expand: false,
                                        onPressed: () =>
                                            SharePlus.instance.share(ShareParams(text: '${me.handle} on Arnav Chat')),
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOutBack, duration: 420.ms)
                                .fadeIn(),
                      ),
                    ),
            ),
          ),
          if (_scan)
            Center(
              child: IgnorePointer(
                child:
                    Container(
                          width: 250,
                          height: 250,
                          decoration: ShapeDecoration(
                            shape: RoundedSuperellipseBorder(
                              borderRadius: BorderRadius.circular(Radii.xl),
                              side: const BorderSide(color: Colors.white, width: 3),
                            ),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 1, end: 1.04, duration: 900.ms, curve: Curves.easeInOut),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + Gaps.x6,
            child: Center(
              child: _Segmented(
                scan: _scan,
                onChanged: (v) {
                  Haptics.select();
                  setState(() {
                    _scan = v;
                    _handled = false;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.scan, required this.onChanged});

  final bool scan;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget seg(String label, IconData icon, bool value) => GestureDetector(
      onTap: () => onChanged(value),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 112,
        height: 44,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: scan == value ? Colors.white : p.text),
            const SizedBox(width: 6),
            Text(label, style: context.text.labelLarge?.copyWith(color: scan == value ? Colors.white : p.text)),
          ],
        ),
      ),
    );
    return Glass(
      pill: true,
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: scan ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            child: Container(
              width: 112,
              height: 44,
              decoration: ShapeDecoration(shape: const StadiumBorder(), gradient: p.accentGradient),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [seg('My code', AppIcons.qr, false), seg('Scan', AppIcons.scan, true)],
          ),
        ],
      ),
    );
  }
}
