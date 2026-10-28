import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/design/palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/models/app_user.dart';

/// The "@que" being typed at the caret, or null.
String? mentionQuery(TextEditingValue v) {
  final caret = v.selection.baseOffset;
  if (caret < 0 || caret > v.text.length) return null;
  final before = v.text.substring(0, caret);
  final m = RegExp(r'(?:^|\s)@([a-z0-9_]{0,20})$', caseSensitive: false).firstMatch(before);
  return m?.group(1)?.toLowerCase();
}

/// Replaces the "@que" at the caret with "@username ".
TextEditingValue insertMention(TextEditingValue v, String username) {
  final caret = v.selection.baseOffset;
  final before = v.text.substring(0, caret);
  final start = before.lastIndexOf('@');
  final text = '${v.text.substring(0, start)}@$username ${v.text.substring(caret)}';
  final offset = start + username.length + 2;
  return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: offset));
}

/// uids whose @username appears in [text].
List<String> mentionedUids(String text, Iterable<AppUser> members) {
  final lower = text.toLowerCase();
  return [
    for (final u in members)
      if (RegExp('(^|\\W)@${RegExp.escape(u.username)}(\\W|\$)').hasMatch(lower)) u.uid,
  ];
}

class MentionSuggestions extends StatelessWidget {
  const MentionSuggestions({super.key, required this.users, required this.onPick});

  final List<AppUser> users;
  final ValueChanged<AppUser> onPick;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gaps.x2),
      child: Glass(
        radius: Radii.md,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              for (final (i, u) in users.indexed)
                Pressable(
                  scale: 0.98,
                  onTap: () => onPick(u),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Gaps.x3, vertical: 7),
                    child: Row(
                      children: [
                        Avatar(name: u.displayName, url: u.photoUrl, size: 32),
                        const SizedBox(width: Gaps.x3),
                        Expanded(child: Text(u.displayName, style: context.text.titleSmall, maxLines: 1)),
                        Text(u.handle, style: context.text.labelMedium?.copyWith(color: context.palette.textMuted)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (i * 20).ms, duration: 140.ms),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 140.ms).moveY(begin: 10, end: 0, curve: Curves.easeOutCubic);
  }
}
