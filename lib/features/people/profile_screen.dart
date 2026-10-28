import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/shimmer.dart';
import '../../core/widgets/toast.dart';
import '../../data/providers.dart';
import '../chats/chat_providers.dart';
import 'people_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider(uid));
    final isContact = ref.watch(isContactProvider(uid)).value ?? false;
    final presence = ref.watch(peerPresenceProvider(uid)).value;
    final p = context.palette;
    final me = ref.watch(currentUidProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(),
      body: switch (user) {
        AsyncData(value: final u?) => ListView(
          padding: EdgeInsets.fromLTRB(Gaps.x6, MediaQuery.paddingOf(context).top + 72, Gaps.x6, Gaps.x8),
          children: [
            Center(
              child: Avatar(
                name: u.displayName,
                url: u.photoUrl,
                size: 116,
                online: presence?.online ?? false,
                heroTag: 'user-${u.uid}',
              ),
            ),
            const SizedBox(height: Gaps.x4),
            Text(
              u.displayName,
              textAlign: TextAlign.center,
              style: context.text.headlineSmall,
            ).animate().fadeIn(delay: 80.ms).moveY(begin: 8, end: 0),
            const SizedBox(height: 2),
            Text(
              presence?.online ?? false
                  ? 'online'
                  : presence?.lastSeen != null
                  ? TimeFormat.lastSeen(presence!.lastSeen!)
                  : u.handle,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: presence?.online ?? false ? p.primary : p.textMuted),
            ),
            if (u.bio != null && u.bio!.isNotEmpty) ...[
              const SizedBox(height: Gaps.x4),
              Text(u.bio!, textAlign: TextAlign.center, style: context.text.bodyLarge),
            ],
            const SizedBox(height: Gaps.x8),
            if (u.uid != me) ...[
              PillButton(label: 'Message', icon: AppIcons.chats, onPressed: () => openChatWith(context, ref, u)),
              const SizedBox(height: Gaps.x3),
              PillButton(
                label: isContact ? 'Remove contact' : 'Add contact',
                icon: isContact ? AppIcons.close : AppIcons.userPlus,
                style: PillStyle.secondary,
                onPressed: () async {
                  final repo = ref.read(userRepositoryProvider);
                  isContact ? await repo.removeContact(u.uid) : await repo.addContact(u.uid);
                  Haptics.success();
                  if (context.mounted) showToast(context, isContact ? 'Removed' : 'Added');
                },
              ),
            ],
          ].animate(interval: 40.ms).fadeIn(duration: 260.ms),
        ),
        AsyncData() => const EmptyState(icon: AppIcons.user, label: 'Not found'),
        AsyncError() => const EmptyState(icon: AppIcons.offline, label: 'Unavailable'),
        _ => const Padding(padding: EdgeInsets.only(top: 120), child: ChatListSkeleton(count: 2)),
      },
    );
  }
}
