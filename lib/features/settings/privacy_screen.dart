import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/settings_group.dart';
import '../../data/models/app_user.dart';
import '../../data/providers.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final repo = ref.read(userRepositoryProvider);
    final privacy = me.privacy;

    Future<void> update(PrivacySettings next) async {
      Haptics.select();
      await repo.updatePrivacy(next);
      ref.read(chatRepositoryProvider).shareReadReceipts = next.readReceipts;
      final presence = ref.read(presenceProvider);
      await presence.goOnline(share: next.lastSeen == Audience.everyone).catchError((_) {});
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Privacy'),
      body: ListView(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 64, bottom: Gaps.x8),
        children: [
          SettingsGroup(children: [
            SettingsRow(
              icon: AppIcons.clock,
              label: 'Last seen & online',
              color: const Color(0xFF15946A),
              trailing: Switch.adaptive(
                value: privacy.lastSeen == Audience.everyone,
                onChanged: (v) => update(privacy.copyWith(lastSeen: v ? Audience.everyone : Audience.nobody)),
              ),
            ),
            SettingsRow(
              icon: AppIcons.checks,
              label: 'Read receipts',
              color: const Color(0xFF2F5BEA),
              trailing: Switch.adaptive(
                value: privacy.readReceipts,
                onChanged: (v) => update(privacy.copyWith(readReceipts: v)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
