import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:video_player/video_player.dart';

import '../../core/design/icons.dart';
import '../../core/utils/media_url.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/dots_loader.dart';

Future<void> openMediaViewer(BuildContext context, {required String url, required String heroTag, String? blurhash, bool video = false}) =>
    Navigator.of(context, rootNavigator: true).push(PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => MediaViewer(url: url, heroTag: heroTag, blurhash: blurhash, video: video),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ));

/// Full-screen viewer: pinch-zoom, drag-to-dismiss with background fade.
class MediaViewer extends StatefulWidget {
  const MediaViewer({super.key, required this.url, required this.heroTag, this.blurhash, this.video = false});

  final String url;
  final String heroTag;
  final String? blurhash;
  final bool video;

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> with SingleTickerProviderStateMixin {
  final _zoom = TransformationController();
  late final AnimationController _back = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  Offset _drag = Offset.zero;
  Animation<Offset>? _backAnim;
  VideoPlayerController? _video;

  @override
  void initState() {
    super.initState();
    _back.addListener(() => setState(() => _drag = _backAnim!.value));
    if (widget.video) {
      _video = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _video!.play();
          }
        });
    }
  }

  @override
  void dispose() {
    _back.dispose();
    _zoom.dispose();
    _video?.dispose();
    super.dispose();
  }

  bool get _zoomed => _zoom.value.getMaxScaleOnAxis() > 1.01;

  void _onDragEnd(DragEndDetails d) {
    if (_drag.dy.abs() > 110 || d.velocity.pixelsPerSecond.dy.abs() > 900) {
      Navigator.of(context).pop();
      return;
    }
    _backAnim = Tween(begin: _drag, end: Offset.zero).animate(CurvedAnimation(parent: _back, curve: Curves.easeOutBack));
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final progress = (_drag.dy.abs() / (size.height * 0.4)).clamp(0.0, 1.0);
    final scale = 1 - progress * 0.25;
    final px = (size.width * MediaQuery.devicePixelRatioOf(context)).round();

    final Widget content = widget.video
        ? (_video?.value.isInitialized ?? false)
            ? AspectRatio(aspectRatio: _video!.value.aspectRatio, child: VideoPlayer(_video!))
            : const Center(child: DotsLoader(color: Colors.white))
        : CachedNetworkImage(
            imageUrl: MediaUrl.fit(widget.url, px),
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 250),
            placeholder: (_, _) => widget.blurhash == null
                ? const Center(child: DotsLoader(color: Colors.white))
                : BlurHash(hash: widget.blurhash!, imageFit: BoxFit.contain),
          );

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 1 - progress),
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragUpdate: _zoomed ? null : (d) => setState(() => _drag += d.delta),
            onVerticalDragEnd: _zoomed ? null : _onDragEnd,
            onTap: widget.video && _video != null
                ? () => setState(() => _video!.value.isPlaying ? _video!.pause() : _video!.play())
                : null,
            child: Center(
              child: Transform.translate(
                offset: _drag,
                child: Transform.scale(
                  scale: scale,
                  child: Hero(
                    tag: widget.heroTag,
                    child: InteractiveViewer(
                      transformationController: _zoom,
                      minScale: 1,
                      maxScale: 5,
                      child: SizedBox(width: size.width, height: size.height, child: Center(child: content)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 6,
            left: 8,
            child: Opacity(
              opacity: 1 - progress,
              child: GlassIconButton(icon: AppIcons.close, label: 'Close', color: Colors.white, onPressed: () => Navigator.of(context).pop()),
            ),
          ),
        ],
      ),
    );
  }
}
