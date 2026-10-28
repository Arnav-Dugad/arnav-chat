import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/motion.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/logo.dart';
import '../../core/widgets/shimmer.dart';
import '../../data/models/chat.dart';
import '../../data/providers.dart';
import '../home/home_shell.dart';
import 'chat_providers.dart';
import 'chat_tile.dart';
import 'large_title_header.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatListProvider);
    final bottom = MediaQuery.paddingOf(context).bottom + HomeShell.tabBarHeight + 24;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          LargeTitleHeader(
            title: 'Chats',
            actions: [
              GlassIconButton(icon: AppIcons.qr, label: 'QR code', onPressed: () => context.push('/qr')),
              GlassIconButton(icon: AppIcons.compose, label: 'New chat', onPressed: () => context.push('/find')),
            ],
          ),
          CupertinoSliverRefreshControl(
            refreshTriggerPullDistance: 90,
            refreshIndicatorExtent: 64,
            onRefresh: () async {
              Haptics.medium();
              await ref.read(chatRepositoryProvider).refresh();
              await Future<void>.delayed(const Duration(milliseconds: 700));
            },
            builder: _logoRefresh,
          ),
          switch (chats) {
            AsyncData(:final value) when value.isEmpty => SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottom),
                child: EmptyState(
                  icon: AppIcons.chats,
                  label: 'No chats yet',
                  action: PillButton(
                    label: 'Find people',
                    icon: AppIcons.search,
                    expand: false,
                    onPressed: () => context.push('/find'),
                  ),
                ),
              ),
            ),
            AsyncData(:final value) => _ChatSliverList(chats: value),
            _ => const SliverToBoxAdapter(child: ChatListSkeleton()),
          },
          SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
        ],
      ),
    );
  }

  static Widget _logoRefresh(
    BuildContext context,
    RefreshIndicatorMode mode,
    double pulledExtent,
    double triggerDistance,
    double indicatorExtent,
  ) {
    final p = context.palette;
    final progress = (pulledExtent / triggerDistance).clamp(0.0, 1.0);
    final refreshing = mode == RefreshIndicatorMode.refresh || mode == RefreshIndicatorMode.armed;
    Widget mark = LogoMark(size: 34, withBackground: false, markColor: p.primary, progress: refreshing ? 1 : progress);
    if (refreshing) {
      mark = mark
          .animate(onPlay: (c) => c.repeat())
          .rotate(duration: 900.ms, curve: Curves.easeInOutCubic)
          .scaleXY(begin: 1, end: 0.86, duration: 450.ms)
          .then()
          .scaleXY(begin: 0.86, end: 1, duration: 450.ms);
    }
    return Center(
      child: Opacity(
        opacity: math.min(1, pulledExtent / 40),
        child: Transform.scale(scale: 0.6 + 0.4 * progress, child: mark),
      ),
    );
  }
}

class _ChatSliverList extends StatefulWidget {
  const _ChatSliverList({required this.chats});

  final List<ChatSummary> chats;

  @override
  State<_ChatSliverList> createState() => _ChatSliverListState();
}

class _ChatSliverListState extends State<_ChatSliverList> {
  /// Only the first render staggers in; later updates must not re-animate.
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () => _entered = true);
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.chats.length,
      itemBuilder: (context, i) {
        final chat = widget.chats[i];
        final tile = ChatTile(key: ValueKey(chat.id), chat: chat);
        if (_entered || i > 12 || Motion.reduced(context)) return tile;
        return tile
            .animate()
            .fadeIn(delay: (260 + i * 38).ms, duration: 320.ms)
            .moveY(begin: 18, end: 0, delay: (260 + i * 38).ms, duration: 420.ms, curve: Curves.easeOutCubic);
      },
    );
  }
}
