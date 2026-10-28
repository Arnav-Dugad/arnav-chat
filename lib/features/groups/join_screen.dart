import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/shimmer.dart';
import '../../core/widgets/toast.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';

final _inviteProvider = FutureProvider.autoDispose.family<InvitePreview?, String>(
  (ref, code) => ref.watch(groupRepositoryProvider).preview(code),
);

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key, required this.code});

  final String code;

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  bool _joining = false;

  Future<void> _join(InvitePreview invite) async {
    setState(() => _joining = true);
    try {
      final existing = await ref.read(chatRepositoryProvider).chatRow(invite.chatId);
      if (existing == null || existing.left) await ref.read(groupRepositoryProvider).join(invite);
      await ref.read(chatRepositoryProvider).fetchOne(invite.chatId);
      Haptics.success();
      if (mounted) context.pushReplacement('/chat/${invite.chatId}');
    } catch (_) {
      if (mounted) showToast(context, 'Link expired', error: true);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invite = ref.watch(_inviteProvider(widget.code));
    final p = context.palette;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(),
      body: switch (invite) {
        AsyncData(value: final i?) => Center(
          child: Padding(
            padding: const EdgeInsets.all(Gaps.x6),
            child: Glass(
              radius: Radii.xl,
              padding: const EdgeInsets.all(Gaps.x6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Avatar(name: i.name, url: i.photoUrl, size: 96),
                  const SizedBox(height: Gaps.x4),
                  Text(i.name, textAlign: TextAlign.center, style: context.text.headlineSmall),
                  if (i.memberCount != null)
                    Text('${i.memberCount} members', style: context.text.bodyMedium?.copyWith(color: p.textMuted)),
                  const SizedBox(height: Gaps.x6),
                  PillButton(label: 'Join group', icon: AppIcons.group, busy: _joining, onPressed: () => _join(i)),
                ],
              ),
            ).animate().scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOutBack, duration: 380.ms).fadeIn(),
          ),
        ),
        AsyncData() || AsyncError() => const EmptyState(icon: AppIcons.link, label: 'Link expired'),
        _ => const Center(child: SkeletonBox(width: 240, height: 240, radius: Radii.xl)),
      },
    );
  }
}
