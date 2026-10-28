import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass_sheet.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/settings_group.dart';
import '../../core/widgets/toast.dart';
import '../../data/providers.dart';
import '../chats/large_title_header.dart';
import '../home/home_shell.dart';
import '../update/update_controller.dart';

final _versionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final p = context.palette;
    final version = ref.watch(_versionProvider).value ?? '';
    final bottom = MediaQuery.paddingOf(context).bottom + HomeShell.tabBarHeight + 24;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          const LargeTitleHeader(title: 'Settings'),
          SliverToBoxAdapter(
            child: Pressable(
              scale: 0.98,
              onTap: () => context.push('/settings/profile'),
              child: Container(
                margin: const EdgeInsets.fromLTRB(Gaps.x4, Gaps.x2, Gaps.x4, Gaps.x2),
                padding: const EdgeInsets.all(Gaps.x4),
                decoration: ShapeDecoration(
                  color: p.surface,
                  shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.lg)),
                ),
                child: Row(
                  children: [
                    Avatar(name: me.displayName, url: me.photoUrl, size: 62, heroTag: 'me-avatar'),
                    const SizedBox(width: Gaps.x4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(me.displayName, style: context.text.titleMedium),
                          Text(me.handle, style: context.text.bodyMedium?.copyWith(color: p.textMuted)),
                        ],
                      ),
                    ),
                    Icon(AppIcons.chevron, size: 16, color: p.textFaint),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsGroup(
              children: [
                SettingsRow(
                  icon: AppIcons.palette,
                  label: 'Appearance',
                  color: const Color(0xFF8A63D2),
                  onTap: () => context.push('/settings/appearance'),
                ),
                SettingsRow(
                  icon: AppIcons.eye,
                  label: 'Privacy',
                  color: const Color(0xFF15946A),
                  onTap: () => context.push('/settings/privacy'),
                ),
                SettingsRow(
                  icon: AppIcons.bookmarkFill,
                  label: 'Saved Messages',
                  color: const Color(0xFF2F8FEA),
                  onTap: () async {
                    final id = await ref.read(chatRepositoryProvider).ensureDirect(me.uid);
                    if (context.mounted) context.push('/chat/$id');
                  },
                ),
                SettingsRow(
                  icon: AppIcons.folder,
                  label: 'Chat folders',
                  color: const Color(0xFF0E9AA7),
                  onTap: () => context.push('/settings/folders'),
                ),
                SettingsRow(
                  icon: AppIcons.starFill,
                  label: 'Starred',
                  color: const Color(0xFFF0A63A),
                  onTap: () => context.push('/settings/starred'),
                ),
                SettingsRow(
                  icon: AppIcons.qr,
                  label: 'My code',
                  color: const Color(0xFF2F5BEA),
                  onTap: () => context.push('/qr'),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsGroup(
              children: [
                SettingsRow(
                  icon: AppIcons.download,
                  label: 'Updates',
                  color: const Color(0xFF27B4D9),
                  value: version,
                  onTap: () async {
                    final info = await ref.read(updateControllerProvider.notifier).check(onLaunch: true);
                    if (info == null && context.mounted) showToast(context, 'Up to date');
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsGroup(
              children: [
                SettingsRow(
                  icon: AppIcons.signOut,
                  label: 'Sign out',
                  destructive: true,
                  onTap: () => _confirmSignOut(context, ref),
                ),
              ],
            ),
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final ok = await showGlassSheet<bool>(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(Gaps.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PillButton(label: 'Sign out', style: PillStyle.danger, onPressed: () => Navigator.pop(ctx, true)),
            PillButton(label: 'Cancel', style: PillStyle.ghost, onPressed: () => Navigator.pop(ctx, false)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await ref.read(presenceProvider).goOffline(share: true).catchError((_) {});
    await ref.read(authRepositoryProvider).signOut();
  }
}
