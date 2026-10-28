import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/design/icons.dart';
import '../../../core/design/palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/fields.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/models/message_payload.dart';
import '../../../data/repositories/group_repository.dart' show randomToken;

Future<Poll?> showPollComposer(BuildContext context) =>
    showGlassSheet<Poll>(context, builder: (_) => const _PollComposer());

class _PollComposer extends StatefulWidget {
  const _PollComposer();

  @override
  State<_PollComposer> createState() => _PollComposerState();
}

class _PollComposerState extends State<_PollComposer> {
  final _question = TextEditingController();
  final _options = [TextEditingController(), TextEditingController()];
  bool _multi = false;

  @override
  void dispose() {
    _question.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid => _question.text.trim().isNotEmpty && _options.where((o) => o.text.trim().isNotEmpty).length >= 2;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Gaps.x4, Gaps.x4, Gaps.x4, Gaps.x4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PillField(
            controller: _question,
            hint: 'Question',
            icon: AppIcons.chats,
            maxLength: 200,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Gaps.x3),
          for (final (i, c) in _options.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: Gaps.x2),
              child: PillField(
                controller: c,
                hint: 'Option ${i + 1}',
                icon: AppIcons.check,
                maxLength: 80,
                onChanged: (_) => setState(() {}),
                trailing: _options.length > 2
                    ? GlassIconButton(
                        icon: AppIcons.close,
                        label: 'Remove option',
                        size: 32,
                        onPressed: () => setState(() => _options.removeAt(i).dispose()),
                      )
                    : null,
              ).animate().fadeIn(duration: 180.ms).moveY(begin: -6, end: 0),
            ),
          if (_options.length < 10)
            PillButton(
              label: 'Add option',
              icon: AppIcons.plus,
              style: PillStyle.ghost,
              height: 44,
              onPressed: () => setState(() => _options.add(TextEditingController())),
            ),
          Pressable(
            onTap: () => setState(() => _multi = !_multi),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gaps.x2, vertical: Gaps.x2),
              child: Row(
                children: [
                  Expanded(child: Text('Multiple answers', style: context.text.bodyLarge)),
                  Switch.adaptive(value: _multi, onChanged: (v) => setState(() => _multi = v)),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gaps.x2),
          PillButton(
            label: 'Create poll',
            onPressed: _valid
                ? () => Navigator.of(context).pop(
                    Poll(
                      question: _question.text.trim(),
                      multi: _multi,
                      options: [
                        for (final o in _options)
                          if (o.text.trim().isNotEmpty) PollOption(randomToken(6), o.text.trim()),
                      ],
                    ),
                  )
                : null,
          ),
          SizedBox(height: MediaQuery.viewInsetsOf(context).bottom > 0 ? 0 : Gaps.x2, child: ColoredBox(color: p.bg.withValues(alpha: 0))),
        ],
      ),
    );
  }
}
