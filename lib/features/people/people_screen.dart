import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/icons.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/shimmer.dart';
import '../../core/design/palette.dart';
import '../chats/large_title_header.dart';
import '../home/home_shell.dart';
import 'people_providers.dart';
import 'user_row.dart';

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);
    final bottom = MediaQuery.paddingOf(context).bottom + HomeShell.tabBarHeight + 24;
    final p = context.palette;
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          LargeTitleHeader(
            title: 'People',
            actions: [GlassIconButton(icon: AppIcons.qr, label: 'QR code', onPressed: () => context.push('/qr'))],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.x4, Gaps.x2, Gaps.x4, Gaps.x3),
              child: Pressable(
                scale: 0.98,
                onTap: () => context.push('/find'),
                child: Glass(
                  pill: true,
                  tint: p.surfaceRaised,
                  border: false,
                  padding: const EdgeInsets.symmetric(horizontal: Gaps.x5, vertical: 14),
                  child: Row(children: [
                    Icon(AppIcons.search, size: 20, color: p.textMuted),
                    const SizedBox(width: Gaps.x3),
                    Text('Search @username', style: context.text.bodyLarge?.copyWith(color: p.textFaint)),
                  ]),
                ),
              ),
            ),
          ),
          switch (contacts) {
            AsyncData(:final value) when value.isEmpty => SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottom),
                  child: EmptyState(
                    icon: AppIcons.people,
                    label: 'No contacts',
                    action: PillButton(label: 'Scan QR', icon: AppIcons.scan, expand: false, onPressed: () => context.push('/qr')),
                  ),
                ),
              ),
            AsyncData(:final value) => SliverList.builder(
                itemCount: value.length,
                itemBuilder: (context, i) => UserRow(
                  user: value[i],
                  onTap: () => openChatWith(context, ref, value[i]),
                ).animate().fadeIn(delay: (i * 30).ms, duration: 260.ms).moveY(begin: 10, end: 0),
              ),
            _ => const SliverToBoxAdapter(child: ChatListSkeleton(count: 5)),
          },
          SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
        ],
      ),
    );
  }
}
