import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/glass_sheet.dart';
import '../../core/widgets/pressable.dart';
import '../../data/models/chat.dart';

class SearchPill extends StatelessWidget {
  const SearchPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.x4, Gaps.x1, Gaps.x4, Gaps.x2),
      child: Pressable(
        scale: 0.98,
        onTap: onTap,
        semanticLabel: 'Search',
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: Gaps.x4),
          decoration: ShapeDecoration(shape: const StadiumBorder(), color: p.surfaceRaised),
          child: Row(
            children: [
              Icon(AppIcons.search, size: 18, color: p.textMuted),
              const SizedBox(width: Gaps.x2),
              Text('Search', style: context.text.bodyLarge?.copyWith(color: p.textFaint)),
            ],
          ),
        ),
      ),
    );
  }
}

/// "All" + user folders; the selection pill glides between tabs.
class FolderTabs extends StatelessWidget {
  const FolderTabs({super.key, required this.folders, required this.selected, required this.onSelect});

  final List<ChatFolder> folders;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tabs = <(String?, String)>[(null, 'All'), for (final f in folders) (f.id, f.name)];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Gaps.x3),
        children: [
          for (final (id, name) in tabs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
              child: Pressable(
                scale: 0.94,
                onTap: () => onSelect(id),
                semanticLabel: name,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    color: id == selected ? null : p.surfaceRaised,
                    gradient: id == selected ? p.accentGradient : null,
                  ),
                  child: Text(
                    name,
                    style: context.text.labelLarge?.copyWith(color: id == selected ? Colors.white : p.text),
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class ArchivedRow extends StatelessWidget {
  const ArchivedRow({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      scale: 0.98,
      onTap: onTap,
      semanticLabel: 'Archived chats',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gaps.x4, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 38,
              alignment: Alignment.center,
              child: Icon(AppIcons.archive, color: p.textMuted, size: 24),
            ),
            const SizedBox(width: Gaps.x3),
            Expanded(child: Text('Archived', style: context.text.titleSmall)),
            Text('$count', style: context.text.labelMedium),
            const SizedBox(width: 6),
            Icon(AppIcons.chevron, size: 14, color: p.textFaint),
          ],
        ),
      ),
    );
  }
}

/// New chat / New group / Saved Messages.
Future<String?> showComposeSheet(BuildContext context) => showGlassSheet<String>(
  context,
  builder: (ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(Gaps.x3, Gaps.x3, Gaps.x3, Gaps.x3),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, (id, icon, label)) in const [
          ('chat', AppIcons.user, 'New chat'),
          ('group', AppIcons.group, 'New group'),
          ('saved', AppIcons.bookmark, 'Saved Messages'),
        ].indexed)
          Pressable(
            scale: 0.98,
            onTap: () => Navigator.of(ctx).pop(id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gaps.x3, vertical: Gaps.x3),
              child: Row(
                children: [
                  Glass(
                    pill: true,
                    tint: ctx.palette.primary.withValues(alpha: 0.14),
                    border: false,
                    child: SizedBox.square(dimension: 42, child: Icon(icon, color: ctx.palette.primary, size: 22)),
                  ),
                  const SizedBox(width: Gaps.x4),
                  Text(label, style: ctx.text.titleSmall),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (40 * i).ms).moveX(begin: 14, end: 0, curve: Curves.easeOutCubic),
      ],
    ),
  ),
);
