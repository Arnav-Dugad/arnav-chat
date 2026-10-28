import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/design/wallpapers.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/pressable.dart';
import '../../data/providers.dart';
import '../chat/chat_screen_providers.dart';

/// Wallpaper + bubble colour for one chat, with a live preview.
class ChatAppearanceScreen extends ConsumerStatefulWidget {
  const ChatAppearanceScreen({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<ChatAppearanceScreen> createState() => _ChatAppearanceScreenState();
}

class _ChatAppearanceScreenState extends ConsumerState<ChatAppearanceScreen> {
  Wallpaper? _wallpaper;
  AccentColor? _accent;
  bool _accentTouched = false;

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatSummaryProvider(widget.chatId)).value;
    final wallpaper = _wallpaper ?? Wallpaper.fromName(chat?.wallpaper);
    final accent = _accentTouched ? _accent : (chat?.accent == null ? null : AccentColor.fromName(chat!.accent));
    final base = context.palette;
    final previewPalette = base.copyWith(accent: accent ?? base.accent);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Chat theme'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(Gaps.x4, MediaQuery.paddingOf(context).top + 68, Gaps.x4, Gaps.x8),
        children: [
          // Live preview.
          Theme(
            data: Theme.of(context).copyWith(extensions: [previewPalette]),
            child: Builder(
              builder: (context) => ClipRSuperellipse(
                borderRadius: BorderRadius.circular(Radii.xl),
                child: SizedBox(
                  height: 220,
                  child: Stack(
                    children: [
                      Positioned.fill(child: ChatWallpaper(wallpaper: wallpaper)),
                      const Positioned(left: 14, top: 40, child: _PreviewBubble(text: 'Looks great', mine: false)),
                      const Positioned(right: 14, top: 100, child: _PreviewBubble(text: 'Love this theme', mine: true)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Gaps.x6),
          Text('WALLPAPER', style: context.text.labelSmall),
          const SizedBox(height: Gaps.x2),
          SizedBox(
            height: 112,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final w in Wallpaper.values)
                  Pressable(
                    scale: 0.94,
                    semanticLabel: w.label,
                    onTap: () {
                      Haptics.select();
                      setState(() => _wallpaper = w);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: Gaps.x3),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 64,
                            height: 84,
                            decoration: ShapeDecoration(
                              shape: RoundedSuperellipseBorder(
                                borderRadius: BorderRadius.circular(Radii.sm),
                                side: BorderSide(color: w == wallpaper ? base.primary : base.separator, width: w == wallpaper ? 2 : 1),
                              ),
                            ),
                            child: ClipRSuperellipse(
                              borderRadius: BorderRadius.circular(Radii.sm),
                              child: ChatWallpaper(wallpaper: w),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(w.label, style: context.text.labelSmall),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gaps.x5),
          Text('COLOUR', style: context.text.labelSmall),
          const SizedBox(height: Gaps.x3),
          Wrap(
            spacing: Gaps.x3,
            runSpacing: Gaps.x3,
            children: [
              _Swatch(
                label: 'App',
                selected: accent == null,
                colors: base.accent.gradient,
                onTap: () => setState(() {
                  _accentTouched = true;
                  _accent = null;
                }),
              ),
              for (final a in AccentColor.values)
                _Swatch(
                  label: a.name,
                  selected: accent == a,
                  colors: a.gradient,
                  onTap: () => setState(() {
                    _accentTouched = true;
                    _accent = a;
                  }),
                ),
            ],
          ),
          const SizedBox(height: Gaps.x8),
          PillButton(
            label: 'Apply',
            icon: AppIcons.check,
            onPressed: () async {
              await ref.read(chatRepositoryProvider).setAppearance(widget.chatId, wallpaper: wallpaper.name, accent: accent?.name);
              Haptics.success();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _PreviewBubble extends StatelessWidget {
  const _PreviewBubble({required this.text, required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.bubble)),
        color: mine ? null : p.bubbleIn,
        gradient: mine ? p.accentGradient : null,
      ),
      child: Text(text, style: context.text.bodyLarge?.copyWith(color: mine ? Colors.white : p.bubbleInText)),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.selected, required this.colors, required this.onTap});

  final String label;
  final bool selected;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    scale: 0.88,
    semanticLabel: label,
    onTap: () {
      Haptics.select();
      onTap();
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? colors.first : Colors.transparent, width: 2.5),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: selected ? const Icon(AppIcons.check, color: Colors.white, size: 20) : null,
      ),
    ),
  );
}
