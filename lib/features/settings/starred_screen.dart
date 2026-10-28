import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/pressable.dart';
import '../../data/models/message.dart';
import '../../data/providers.dart';

final _starredProvider = StreamProvider.autoDispose<List<Message>>(
  (ref) => ref.watch(messageRepositoryProvider).watchStarred(),
);

class StarredScreen extends ConsumerWidget {
  const StarredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_starredProvider).value ?? const [];
    final p = context.palette;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Starred'),
      body: items.isEmpty
          ? const EmptyState(icon: AppIcons.star, label: 'Nothing starred')
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(Gaps.x4, MediaQuery.paddingOf(context).top + 68, Gaps.x4, Gaps.x8),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: Gaps.x2),
              itemBuilder: (context, i) {
                final m = items[i];
                return Pressable(
                  scale: 0.98,
                  onTap: () => context.push('/chat/${m.chatId}'),
                  child: Container(
                    padding: const EdgeInsets.all(Gaps.x4),
                    decoration: ShapeDecoration(
                      color: p.surface,
                      shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.md)),
                    ),
                    child: Row(
                      children: [
                        Icon(AppIcons.starFill, size: 18, color: p.warning),
                        const SizedBox(width: Gaps.x3),
                        Expanded(
                          child: Text(
                            m.payload.preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyLarge,
                          ),
                        ),
                        const SizedBox(width: Gaps.x2),
                        Text(TimeFormat.chatList(m.createdAt), style: context.text.labelMedium),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
