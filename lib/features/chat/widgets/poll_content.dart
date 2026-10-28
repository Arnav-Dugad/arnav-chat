import 'package:flutter/material.dart';

import '../../../core/design/haptics.dart';
import '../../../core/design/icons.dart';
import '../../../core/design/palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/models/message.dart';

/// Poll bubble body. Results (animated bars) appear once I voted, and always
/// for the poll's author.
class PollContent extends StatelessWidget {
  const PollContent({super.key, required this.message, required this.mine, required this.myUid, required this.onVote});

  final Message message;
  final bool mine;
  final String myUid;
  final void Function(String optionId) onVote;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final poll = message.payload.poll!;
    final fg = mine ? Colors.white : p.text;
    final sub = mine ? Colors.white.withValues(alpha: 0.72) : p.textMuted;
    final myPicks = message.votes[myUid] ?? const <String>[];
    final counts = message.voteCounts;
    final voters = message.voterCount;
    final showResults = myPicks.isNotEmpty || mine;
    final total = counts.values.fold<int>(0, (a, b) => a + b);

    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(poll.question, style: context.text.titleSmall?.copyWith(color: fg)),
          const SizedBox(height: 2),
          Text(poll.multi ? 'Multiple choice' : 'Poll', style: context.text.labelSmall?.copyWith(color: sub)),
          const SizedBox(height: Gaps.x2),
          for (final o in poll.options)
            _OptionRow(
              text: o.text,
              picked: myPicks.contains(o.id),
              fraction: total == 0 ? 0 : (counts[o.id] ?? 0) / total,
              count: counts[o.id] ?? 0,
              showResults: showResults,
              mine: mine,
              multi: poll.multi,
              onTap: () {
                Haptics.select();
                onVote(o.id);
              },
            ),
          const SizedBox(height: 4),
          Text(
            voters == 1 ? '1 vote' : '$voters votes',
            style: context.text.labelSmall?.copyWith(color: sub),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.text,
    required this.picked,
    required this.fraction,
    required this.count,
    required this.showResults,
    required this.mine,
    required this.multi,
    required this.onTap,
  });

  final String text;
  final bool picked;
  final double fraction;
  final int count;
  final bool showResults;
  final bool mine;
  final bool multi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = mine ? Colors.white : p.text;
    final track = mine ? Colors.white.withValues(alpha: 0.16) : p.surfaceRaised;
    final fill = mine ? Colors.white.withValues(alpha: 0.30) : p.primary.withValues(alpha: 0.22);
    return Pressable(
      scale: 0.98,
      onTap: onTap,
      semanticLabel: '$text, $count votes${picked ? ', selected' : ''}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: ClipRSuperellipse(
          borderRadius: BorderRadius.circular(Radii.sm),
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: track)),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: showResults ? fraction : 0),
                    duration: const Duration(milliseconds: 520),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => FractionallySizedBox(widthFactor: v, heightFactor: 1, child: ColoredBox(color: fill)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                      child: Icon(
                        picked ? AppIcons.check : (multi ? AppIcons.plus : AppIcons.chevron),
                        key: ValueKey(picked),
                        size: 15,
                        color: picked ? fg : fg.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(text, style: context.text.bodyMedium?.copyWith(color: fg))),
                    if (showResults)
                      Text(
                        '${(fraction * 100).round()}%',
                        style: context.text.labelMedium?.copyWith(color: fg, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
