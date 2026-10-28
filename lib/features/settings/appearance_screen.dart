import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/pressable.dart';
import 'appearance_controller.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(appearanceControllerProvider);
    final ctl = ref.read(appearanceControllerProvider.notifier);
    final p = context.palette;

    Widget mode(ThemeMode m, IconData icon, String label) {
      final selected = a.mode == m;
      return Expanded(
        child: Pressable(
          onTap: () {
            Haptics.select();
            ctl.setMode(m);
          },
          semanticLabel: label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            height: 86,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: ShapeDecoration(
              color: selected ? p.primary.withValues(alpha: 0.14) : p.surface,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(Radii.md),
                side: BorderSide(color: selected ? p.primary : Colors.transparent, width: 1.5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? p.primary : p.textMuted),
                const SizedBox(height: 6),
                Text(label, style: context.text.labelMedium?.copyWith(color: selected ? p.primary : p.textMuted)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Appearance'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(Gaps.x4, MediaQuery.paddingOf(context).top + 72, Gaps.x4, Gaps.x8),
        children: [
          Row(
            children: [
              mode(ThemeMode.system, AppIcons.sparkle, 'Auto'),
              mode(ThemeMode.light, AppIcons.sun, 'Light'),
              mode(ThemeMode.dark, AppIcons.moon, 'Dark'),
            ],
          ),
          const SizedBox(height: Gaps.x8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Gaps.x4,
            runSpacing: Gaps.x4,
            children: [
              for (final accent in AccentColor.values)
                Pressable(
                  scale: 0.88,
                  semanticLabel: accent.name,
                  onTap: () {
                    Haptics.select();
                    ctl.setAccent(accent);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: a.accent == accent ? accent.base : Colors.transparent, width: 2.5),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: accent.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: AnimatedScale(
                        scale: a.accent == accent ? 1 : 0,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutBack,
                        child: const Icon(AppIcons.check, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
