import 'package:flutter/material.dart';

import '../../../core/design/icons.dart';
import '../../../core/design/palette.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/models/chat.dart';

/// Glass strip under the header. Tapping jumps to the shown pin and advances
/// to the next one (Telegram-style); the left bar shows which pin is active.
class PinnedBanner extends StatefulWidget {
  const PinnedBanner({super.key, required this.pins, required this.onJump, this.onUnpin});

  final List<PinnedMessage> pins;
  final ValueChanged<PinnedMessage> onJump;
  final ValueChanged<PinnedMessage>? onUnpin;

  @override
  State<PinnedBanner> createState() => _PinnedBannerState();
}

class _PinnedBannerState extends State<PinnedBanner> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pins = widget.pins;
    if (pins.isEmpty) return const SizedBox.shrink();
    final i = _index.clamp(0, pins.length - 1);
    final pin = pins[pins.length - 1 - i]; // newest first
    return GlassBar(
      top: true,
      child: Pressable(
        scale: 0.99,
        semanticLabel: 'Pinned message',
        onTap: () {
          widget.onJump(pin);
          setState(() => _index = (i + 1) % pins.length);
        },
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              const SizedBox(width: 14),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var k = 0; k < pins.length; k++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 2.5,
                      height: (30 / pins.length).clamp(4, 30) - 2,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      decoration: BoxDecoration(
                        color: k == i ? p.primary : p.primary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(a),
                      child: c,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(pin.id),
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pins.length > 1 ? 'Pinned ${pins.length - i}/${pins.length}' : 'Pinned',
                        style: context.text.labelSmall?.copyWith(color: p.primary),
                      ),
                      Text(pin.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodySmall?.copyWith(color: p.text)),
                    ],
                  ),
                ),
              ),
              if (widget.onUnpin != null)
                Pressable(
                  onTap: () => widget.onUnpin!(pin),
                  semanticLabel: 'Unpin',
                  child: Padding(padding: const EdgeInsets.all(12), child: Icon(AppIcons.close, size: 18, color: p.textMuted)),
                )
              else
                Padding(padding: const EdgeInsets.all(12), child: Icon(AppIcons.pinFill, size: 16, color: p.textFaint)),
            ],
          ),
        ),
      ),
    );
  }
}
