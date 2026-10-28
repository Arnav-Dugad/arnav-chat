import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/icons.dart';
import '../../../core/design/palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/platform/local_image.dart';
import '../../../core/utils/media_url.dart';
import '../../../core/utils/time_format.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/models/message.dart';
import '../../../data/models/message_payload.dart';
import '../../../data/providers.dart';
import '../../media/media_viewer.dart';
import '../../../core/widgets/progress_ring.dart';

const kBubbleMaxMediaWidth = 264.0;

/// Upload progress ring for media still in the outbox.
class _UploadOverlay extends ConsumerWidget {
  const _UploadOverlay({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (message.state == SendState.sent) return const SizedBox.shrink();
    final progress = ref.watch(outboxProvider).progressOf(message.id);
    return Center(
      child: Glass(
        pill: true,
        tint: Colors.black.withValues(alpha: 0.35),
        border: false,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: progress == null
              ? const SizedBox.square(dimension: 44, child: Icon(AppIcons.clock, color: Colors.white, size: 20))
              : ValueListenableBuilder<double>(
                  valueListenable: progress,
                  builder: (_, v, _) => ProgressRing(progress: v, size: 44),
                ),
        ),
      ),
    );
  }
}

class ImageContent extends StatelessWidget {
  const ImageContent({super.key, required this.message, required this.radius});

  final Message message;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final media = message.payload.media!;
    final ratio = (media.aspectRatio ?? 1).clamp(0.62, 1.8);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final px = (kBubbleMaxMediaWidth * dpr).round();
    final hero = 'media-${message.id}';
    final local = media.url.isEmpty && message.localPath != null;

    Widget image;
    if (local) {
      image = Image(image: localImage(message.localPath!), fit: BoxFit.cover, gaplessPlayback: true);
    } else {
      image = Stack(
        fit: StackFit.expand,
        children: [
          if (media.blurhash != null)
            BlurHash(hash: media.blurhash!, imageFit: BoxFit.cover, decodingWidth: 24, decodingHeight: 24),
          CachedNetworkImage(
            imageUrl: MediaUrl.fit(media.url, px),
            memCacheWidth: px,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 320),
            placeholder: (_, _) =>
                media.blurhash == null ? ColoredBox(color: context.palette.surfaceRaised) : const SizedBox.shrink(),
          ),
        ],
      );
    }

    return Pressable(
      scale: 0.98,
      onTap: local ? null : () => openMediaViewer(context, url: media.url, heroTag: hero, blurhash: media.blurhash),
      child: SizedBox(
        width: kBubbleMaxMediaWidth,
        child: AspectRatio(
          aspectRatio: ratio,
          child: ClipRSuperellipse(
            borderRadius: radius,
            child: Hero(
              tag: hero,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  image,
                  _UploadOverlay(message: message),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoContent extends StatelessWidget {
  const VideoContent({super.key, required this.message, required this.radius});

  final Message message;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final media = message.payload.media!;
    final ratio = (media.aspectRatio ?? 16 / 9).clamp(0.62, 1.8);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final ready = media.url.isNotEmpty;
    final p = context.palette;
    return Pressable(
      scale: 0.98,
      onTap: ready ? () => openMediaViewer(context, url: media.url, heroTag: 'media-${message.id}', video: true) : null,
      child: SizedBox(
        width: kBubbleMaxMediaWidth,
        child: AspectRatio(
          aspectRatio: ratio,
          child: ClipRSuperellipse(
            borderRadius: radius,
            child: Hero(
              tag: 'media-${message.id}',
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (ready)
                    CachedNetworkImage(
                      imageUrl: MediaUrl.videoPoster(media.url, (kBubbleMaxMediaWidth * dpr).round()),
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 300),
                      placeholder: (_, _) => ColoredBox(color: p.surfaceRaised),
                      errorWidget: (_, _, _) => ColoredBox(color: p.surfaceRaised),
                    )
                  else
                    DecoratedBox(decoration: BoxDecoration(gradient: p.accentGradient)),
                  if (ready)
                    Center(
                      child: Glass(
                        pill: true,
                        tint: Colors.black.withValues(alpha: 0.3),
                        border: false,
                        child: const SizedBox.square(
                          dimension: 52,
                          child: Icon(AppIcons.play, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  if (media.durationMs != null)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Glass(
                        pill: true,
                        tint: Colors.black.withValues(alpha: 0.35),
                        border: false,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        child: Text(
                          TimeFormat.duration(Duration(milliseconds: media.durationMs!)),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  _UploadOverlay(message: message),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Voice note: play/pause, waveform that fills as it plays, remaining time.
class VoiceContent extends ConsumerStatefulWidget {
  const VoiceContent({super.key, required this.message, required this.mine});

  final Message message;
  final bool mine;

  @override
  ConsumerState<VoiceContent> createState() => _VoiceContentState();
}

class _VoiceContentState extends ConsumerState<VoiceContent> {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _stateSub;
  bool _playing = false;

  MediaRef get _media => widget.message.payload.media!;

  Future<void> _toggle() async {
    if (_media.url.isEmpty) return;
    if (_player == null) {
      _player = AudioPlayer();
      await _player!.setUrl(_media.url);
      _stateSub = _player!.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.completed) {
          _player!.pause();
          _player!.seek(Duration.zero);
        }
        if (mounted) setState(() => _playing = s.playing && s.processingState != ProcessingState.completed);
      });
    }
    _playing ? await _player!.pause() : await _player!.play();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = widget.mine ? Colors.white : p.text;
    final dim = widget.mine ? Colors.white.withValues(alpha: 0.45) : p.textFaint;
    final total = Duration(milliseconds: _media.durationMs ?? 0);
    final wave = _media.waveform ?? List.filled(40, 0.2);

    return SizedBox(
      width: 230,
      child: Row(
        children: [
          Pressable(
            onTap: _toggle,
            haptic: true,
            semanticLabel: _playing ? 'Pause' : 'Play',
            scale: 0.88,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.mine ? Colors.white.withValues(alpha: 0.22) : p.primary,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: Icon(
                  _playing ? AppIcons.pause : AppIcons.play,
                  key: ValueKey(_playing),
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: _player?.positionStream,
              builder: (context, snap) {
                final pos = snap.data ?? Duration.zero;
                final frac = total.inMilliseconds == 0
                    ? 0.0
                    : (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 28,
                      child: CustomPaint(
                        painter: WaveformPainter(wave, frac, fg, dim),
                        size: const Size(double.infinity, 28),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      TimeFormat.duration(_playing || pos > Duration.zero ? total - pos : total),
                      style: TextStyle(
                        color: dim,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  WaveformPainter(this.levels, this.progress, this.active, this.idle);

  final List<double> levels;
  final double progress;
  final Color active;
  final Color idle;

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;
    final n = levels.length;
    final gap = 2.0;
    final w = ((size.width - gap * (n - 1)) / n).clamp(1.5, 4.0);
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < n; i++) {
      final h = (levels[i].clamp(0.08, 1.0)) * size.height;
      final x = i * (w + gap) + w / 2;
      paint
        ..color = (i / n) <= progress ? active : idle
        ..strokeWidth = w;
      canvas.drawLine(Offset(x, (size.height - h) / 2), Offset(x, (size.height + h) / 2), paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter old) => old.progress != progress || old.levels != levels || old.active != active;
}

class FileContent extends StatelessWidget {
  const FileContent({super.key, required this.message, required this.mine});

  final Message message;
  final bool mine;

  static String _size(int? b) {
    if (b == null) return '';
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final media = message.payload.media!;
    final fg = mine ? Colors.white : p.text;
    final sub = mine ? Colors.white70 : p.textMuted;
    return Pressable(
      onTap: media.url.isEmpty ? null : () => launchUrl(Uri.parse(media.url), mode: LaunchMode.externalApplication),
      child: SizedBox(
        width: 230,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: ShapeDecoration(
                color: mine ? Colors.white.withValues(alpha: 0.2) : p.primary.withValues(alpha: 0.12),
                shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.sm)),
              ),
              child: Icon(media.url.isEmpty ? AppIcons.clock : AppIcons.file, color: mine ? Colors.white : p.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.name ?? 'File',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(color: fg),
                  ),
                  Text(_size(media.bytes), style: context.text.labelMedium?.copyWith(color: sub)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LinkCard extends StatelessWidget {
  const LinkCard({super.key, required this.link, required this.mine});

  final LinkPreview link;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = mine ? Colors.white : p.text;
    final sub = mine ? Colors.white70 : p.textMuted;
    return Pressable(
      scale: 0.98,
      onTap: () => launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication),
      child: Container(
        width: 248,
        margin: const EdgeInsets.only(bottom: 6),
        decoration: ShapeDecoration(
          color: mine ? Colors.white.withValues(alpha: 0.14) : p.surfaceRaised,
          shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.sm)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (link.imageUrl != null)
              AspectRatio(
                aspectRatio: 1.91,
                child: CachedNetworkImage(
                  imageUrl: link.imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (link.siteName != null) Text(link.siteName!, style: context.text.labelSmall?.copyWith(color: sub)),
                  if (link.title != null)
                    Text(
                      link.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(color: fg),
                    ),
                  if (link.description != null)
                    Text(
                      link.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(color: sub),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text with tappable URLs. Owns its gesture recognizers.
class LinkifiedText extends StatefulWidget {
  const LinkifiedText(this.text, {super.key, required this.style, required this.linkColor});

  final String text;
  final TextStyle style;
  final Color linkColor;

  @override
  State<LinkifiedText> createState() => _LinkifiedTextState();
}

class _LinkifiedTextState extends State<LinkifiedText> {
  static final _re = RegExp(r'https?://[^\s<>"]+|@[a-z0-9_]{3,20}', caseSensitive: false);
  final _recognizers = <TapGestureRecognizer>[];

  void _clear() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _clear();
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _re.allMatches(widget.text)) {
      if (m.start > last) spans.add(TextSpan(text: widget.text.substring(last, m.start)));
      final url = m.group(0)!;
      if (url.startsWith('@')) {
        spans.add(TextSpan(text: url, style: TextStyle(color: widget.linkColor, fontWeight: FontWeight.w600)));
        last = m.end;
        continue;
      }
      final r = TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      _recognizers.add(r);
      spans.add(
        TextSpan(
          text: url,
          recognizer: r,
          style: TextStyle(
            color: widget.linkColor,
            decoration: TextDecoration.underline,
            decorationColor: widget.linkColor,
          ),
        ),
      );
      last = m.end;
    }
    if (last < widget.text.length) spans.add(TextSpan(text: widget.text.substring(last)));
    return Text.rich(TextSpan(style: widget.style, children: spans));
  }
}
