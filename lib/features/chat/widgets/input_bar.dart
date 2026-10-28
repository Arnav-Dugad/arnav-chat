import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/design/haptics.dart';
import '../../../core/design/icons.dart';
import '../../../core/design/palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/time_format.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/toast.dart';
import '../../../data/models/message.dart';
import '../../../data/models/message_payload.dart';
import 'voice_recorder.dart';

/// Frosted composer: attach · text · send/mic (morphing). Holding the mic
/// records a voice note; slide left to cancel, slide up to lock hands-free.
class InputBar extends StatefulWidget {
  const InputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onAttach,
    required this.onVoice,
    required this.onChanged,
    this.reply,
    this.replyAuthor,
    this.editing,
    this.link,
    this.onCancelReply,
    this.onCancelEdit,
    this.onDismissLink,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final ValueChanged<VoiceClip> onVoice;
  final ValueChanged<String> onChanged;
  final Message? reply;
  final String? replyAuthor;
  final Message? editing;
  final LinkPreview? link;
  final VoidCallback? onCancelReply;
  final VoidCallback? onCancelEdit;
  final VoidCallback? onDismissLink;

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final _rec = VoiceRecorder();
  bool _hasText = false;
  Offset? _down;

  static const _cancelAt = -110.0;
  static const _lockAt = -90.0;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onText);
    _rec.addListener(() => setState(() {}));
  }

  void _onText() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    _rec.dispose();
    super.dispose();
  }

  // ---------- recording gestures ----------

  Future<void> _pressStart(PointerDownEvent e) async {
    if (_hasText || widget.editing != null) return;
    _down = e.position;
    final ok = await _rec.start();
    if (!ok) {
      if (mounted) showToast(context, 'Microphone blocked', error: true);
      return;
    }
    Haptics.medium();
  }

  void _pressMove(PointerMoveEvent e) {
    if (!_rec.recording || _rec.locked || _down == null) return;
    final d = e.position - _down!;
    _rec.drag(math.min(0, d.dx), math.min(0, d.dy));
    if (d.dy < _lockAt) {
      Haptics.heavy();
      _rec.lock();
    } else if (d.dx < _cancelAt) {
      Haptics.heavy();
      _rec.cancel();
    }
  }

  Future<void> _pressEnd(PointerUpEvent e) async {
    _down = null;
    if (!_rec.recording || _rec.locked) return;
    final clip = await _rec.stop();
    if (clip != null) {
      Haptics.tap();
      widget.onVoice(clip);
    }
  }

  Future<void> _sendLocked() async {
    final clip = await _rec.stop();
    if (clip != null) widget.onVoice(clip);
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final recording = _rec.recording;

    return GlassBar(
      child: Padding(
        padding: EdgeInsets.fromLTRB(Gaps.x2, Gaps.x2, Gaps.x2, Gaps.x2 + (MediaQuery.viewInsetsOf(context).bottom > 0 ? 0 : bottom)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: _banner(context),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: recording
                      ? const SizedBox(width: 4, key: ValueKey('none'))
                      : _RoundButton(
                          key: const ValueKey('attach'),
                          icon: AppIcons.plus,
                          label: 'Attach',
                          onTap: widget.onAttach,
                        ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(a), child: c),
                    ),
                    child: recording ? _recorderStrip(context) : _field(context),
                  ),
                ),
                const SizedBox(width: 6),
                _actionButton(context, p),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(BuildContext context) {
    final p = context.palette;
    return Container(
      key: const ValueKey('field'),
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: p.surfaceRaised.withValues(alpha: 0.9),
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        minLines: 1,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
        style: context.text.bodyLarge,
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: 'Message',
          hintStyle: context.text.bodyLarge?.copyWith(color: p.textFaint),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _recorderStrip(BuildContext context) {
    final p = context.palette;
    final cancelProgress = (_rec.dragX / _cancelAt).clamp(0.0, 1.0);
    return SizedBox(
      key: const ValueKey('rec'),
      height: 44,
      child: Row(
        children: [
          if (_rec.locked)
            _RoundButton(icon: AppIcons.trash, label: 'Discard', color: p.danger, onTap: () => _rec.cancel())
          else
            Container(width: 10, height: 10, decoration: BoxDecoration(color: p.danger, shape: BoxShape.circle))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 1, end: 0.2, duration: 600.ms),
          const SizedBox(width: 10),
          Text(
            TimeFormat.duration(_rec.elapsed),
            style: context.text.titleSmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomPaint(
              painter: _LiveWavePainter(_rec.levels, p.primary),
              size: const Size(double.infinity, 32),
            ),
          ),
          if (!_rec.locked)
            Opacity(
              opacity: 1 - cancelProgress,
              child: Transform.translate(
                offset: Offset(_rec.dragX * 0.5, 0),
                child: Row(children: [
                  Icon(AppIcons.back, size: 16, color: p.textMuted),
                  Text('Cancel', style: context.text.labelMedium),
                ]),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveX(begin: 0, end: -4, duration: 700.ms),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, dynamic p) {
    final palette = context.palette;
    final showSend = _hasText || widget.editing != null || (_rec.recording && _rec.locked);
    final button = AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      transitionBuilder: (c, a) => RotationTransition(
        turns: Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
        child: ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack), child: c),
      ),
      child: showSend
          ? Pressable(
              key: const ValueKey('send'),
              scale: 0.86,
              haptic: true,
              semanticLabel: widget.editing != null ? 'Save' : 'Send',
              onTap: _rec.locked ? _sendLocked : widget.onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: palette.accentGradient),
                child: Icon(widget.editing != null ? AppIcons.check : AppIcons.send, color: Colors.white, size: 20),
              ),
            )
          : AnimatedScale(
              key: const ValueKey('mic'),
              scale: _rec.recording ? 1.45 : 1,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _rec.recording ? palette.accentGradient : null,
                ),
                child: Icon(
                  _rec.recording ? AppIcons.micFill : AppIcons.mic,
                  color: _rec.recording ? Colors.white : palette.text,
                  size: 24,
                  semanticLabel: 'Hold to record',
                ),
              ),
            ),
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        if (_rec.recording && !_rec.locked)
          Positioned(
            bottom: 64 - _rec.dragY * 0.4,
            child: Glass(
              pill: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Column(children: [
                Icon(AppIcons.lock, size: 18, color: palette.textMuted),
                const SizedBox(height: 4),
                Icon(Icons.keyboard_arrow_up_rounded, size: 18, color: palette.textFaint),
              ]),
            ).animate().fadeIn(duration: 160.ms).moveY(begin: 20, end: 0, curve: Curves.easeOutBack),
          ),
        Listener(
          onPointerDown: _pressStart,
          onPointerMove: _pressMove,
          onPointerUp: _pressEnd,
          child: button,
        ),
      ],
    );
  }

  Widget _banner(BuildContext context) {
    final p = context.palette;
    final (IconData icon, String title, String body, VoidCallback? close) = widget.editing != null
        ? (AppIcons.edit, 'Edit', widget.editing!.payload.text ?? '', widget.onCancelEdit)
        : widget.reply != null
            ? (AppIcons.reply, widget.replyAuthor ?? '', widget.reply!.payload.preview, widget.onCancelReply)
            : widget.link != null
                ? (AppIcons.link, widget.link!.title ?? widget.link!.url, widget.link!.siteName ?? '', widget.onDismissLink)
                : (AppIcons.reply, '', '', null);
    if (close == null) return const SizedBox(width: double.infinity);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.x2, Gaps.x1, Gaps.x1, Gaps.x2),
      child: Row(
        children: [
          Icon(icon, size: 20, color: p.primary),
          const SizedBox(width: 10),
          Container(width: 2.5, height: 34, decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelMedium?.copyWith(color: p.primary, fontWeight: FontWeight.w600)),
                Text(body, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
              ],
            ),
          ),
          _RoundButton(icon: AppIcons.close, label: 'Cancel', onTap: close, size: 36),
        ],
      ),
    ).animate().fadeIn(duration: 160.ms).moveY(begin: 10, end: 0, curve: Curves.easeOutCubic);
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({super.key, required this.icon, required this.label, required this.onTap, this.color, this.size = 44});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        haptic: true,
        scale: 0.86,
        semanticLabel: label,
        child: SizedBox.square(dimension: size, child: Icon(icon, size: size * 0.55, color: color ?? context.palette.text)),
      );
}

class _LiveWavePainter extends CustomPainter {
  _LiveWavePainter(this.levels, this.color);

  final List<double> levels;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const bar = 3.0, gap = 2.0;
    final count = (size.width / (bar + gap)).floor();
    final recent = levels.length > count ? levels.sublist(levels.length - count) : levels;
    final paint = Paint()
      ..color = color
      ..strokeWidth = bar
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < recent.length; i++) {
      final v = ((recent[i] + 50) / 50).clamp(0.08, 1.0);
      final h = v * size.height;
      final x = size.width - (recent.length - i) * (bar + gap) + bar / 2;
      canvas.drawLine(Offset(x, (size.height - h) / 2), Offset(x, (size.height + h) / 2), paint);
    }
  }

  @override
  bool shouldRepaint(_LiveWavePainter old) => true;
}
