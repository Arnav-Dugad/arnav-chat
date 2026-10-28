import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/widgets/glass.dart';
import '../../data/providers.dart';

/// Glass pill that slides down from the status bar while offline.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(onlineProvider).value == false;
    final top = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedSlide(
          offset: offline ? Offset.zero : const Offset(0, -1.6),
          duration: const Duration(milliseconds: 420),
          curve: offline ? Curves.easeOutBack : Curves.easeInCubic,
          child: Padding(
            padding: EdgeInsets.only(top: top + 6),
            child: Center(
              child: Semantics(
                liveRegion: true,
                label: 'Offline',
                child: Glass(
                  pill: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.offline, size: 16, color: context.palette.warning),
                      const SizedBox(width: 8),
                      Text('Offline', style: context.text.labelMedium?.copyWith(color: context.palette.text)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
