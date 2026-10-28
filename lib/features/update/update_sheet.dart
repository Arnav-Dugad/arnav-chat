import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass_sheet.dart';
import '../../core/widgets/logo.dart';
import '../../core/widgets/progress_ring.dart';
import 'update_controller.dart';

Future<void> showUpdateSheet(BuildContext context, {required bool force}) =>
    showGlassSheet<void>(context, dismissible: !force, builder: (_) => const UpdateSheet());

class UpdateSheet extends ConsumerWidget {
  const UpdateSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateControllerProvider);
    final ctl = ref.read(updateControllerProvider.notifier);
    final p = context.palette;

    final info = switch (state) {
      UpdateAvailable(:final info) ||
      UpdateDownloading(:final info) ||
      UpdateReady(:final info) ||
      UpdateFailed(:final info) => info,
      UpdateIdle() => null,
    };
    if (info == null) return const SizedBox(height: 120);

    final Widget hero = switch (state) {
      UpdateDownloading(:final progress) => ProgressRing(progress: progress, size: 96),
      UpdateReady() => const ProgressRing(progress: 1, size: 96, done: true),
      _ => const LogoMark(size: 72),
    };

    final List<Widget> actions = switch (state) {
      UpdateDownloading() => [
        if (!info.force) PillButton(label: 'Cancel', style: PillStyle.ghost, onPressed: ctl.later),
      ],
      UpdateReady(needsPermission: true) => [
        PillButton(label: 'Allow installs', icon: AppIcons.shield, onPressed: ctl.openPermissionSettings),
      ],
      UpdateReady() => [PillButton(label: 'Install', icon: AppIcons.download, onPressed: ctl.install)],
      UpdateFailed() => [PillButton(label: 'Retry', onPressed: ctl.download)],
      _ => [PillButton(label: 'Update', icon: AppIcons.download, onPressed: ctl.download)],
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.x6, Gaps.x5, Gaps.x6, Gaps.x5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (c, a) => ScaleTransition(
              scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
              child: c,
            ),
            child: KeyedSubtree(key: ValueKey(state.runtimeType), child: hero),
          ),
          const SizedBox(height: Gaps.x4),
          Text('Arnav Chat ${info.version}', style: context.text.titleLarge),
          if (state is UpdateFailed) ...[
            const SizedBox(height: Gaps.x2),
            Text(state.reason, style: context.text.bodyMedium?.copyWith(color: p.danger)),
          ],
          if (info.notes.isNotEmpty && state is UpdateAvailable) ...[
            const SizedBox(height: Gaps.x4),
            for (final (i, n) in info.notes.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(color: p.primary, shape: BoxShape.circle),
                      ),
                    ),
                    const SizedBox(width: Gaps.x3),
                    Expanded(
                      child: Text(n, style: context.text.bodyMedium?.copyWith(color: p.textMuted)),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (60 * i).ms).moveX(begin: 8, end: 0),
          ],
          const SizedBox(height: Gaps.x6),
          ...actions,
          if (!info.force && state is UpdateAvailable) ...[
            const SizedBox(height: Gaps.x2),
            PillButton(
              label: 'Later',
              style: PillStyle.ghost,
              onPressed: () {
                ctl.later();
                Navigator.of(context).maybePop();
              },
            ),
          ],
        ],
      ),
    );
  }
}
