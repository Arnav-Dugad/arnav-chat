import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/utils/media_url.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/pressable.dart';
import '../../data/models/message.dart';
import '../../data/models/message_payload.dart';
import '../../data/providers.dart';
import '../media/media_viewer.dart';

enum _Tab {
  media('Media', ['image', 'video']),
  links('Links', ['link']),
  files('Files', ['file']),
  voice('Voice', ['audio']);

  const _Tab(this.label, this.kinds);
  final String label;
  final List<String> kinds;
}

final _galleryProvider = StreamProvider.autoDispose.family<List<Message>, (String, _Tab)>(
  (ref, k) => ref.watch(messageRepositoryProvider).watchGallery(k.$1, k.$2.kinds),
);

/// Per-chat media, links, files and voice notes (from the local cache).
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  _Tab _tab = _Tab.media;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = ref.watch(_galleryProvider((widget.chatId, _tab))).value;
    final top = MediaQuery.paddingOf(context).top + 56;

    final Widget body;
    if (items == null) {
      body = const SizedBox.shrink();
    } else if (items.isEmpty) {
      body = EmptyState(icon: _tab == _Tab.media ? AppIcons.images : AppIcons.file, label: 'Nothing here');
    } else if (_tab == _Tab.media) {
      final px = (MediaQuery.sizeOf(context).width / 3 * MediaQuery.devicePixelRatioOf(context)).round();
      body = GridView.builder(
        padding: const EdgeInsets.fromLTRB(2, Gaps.x2, 2, Gaps.x8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final m = items[i];
          final media = m.payload.media;
          if (media == null || media.url.isEmpty) return ColoredBox(color: p.surfaceRaised);
          final video = m.payload.kind == MessageKind.video;
          return Pressable(
            scale: 0.95,
            onTap: () => openMediaViewer(context, url: media.url, heroTag: 'g-${m.id}', blurhash: media.blurhash, video: video),
            onLongPress: () => context.push('/chat/${widget.chatId}?m=${m.id}'),
            child: Hero(
              tag: 'g-${m.id}',
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video ? MediaUrl.videoPoster(media.url, px) : MediaUrl.thumb(media.url, px),
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 200),
                    placeholder: (_, _) => ColoredBox(color: p.surfaceRaised),
                    errorWidget: (_, _, _) => ColoredBox(color: p.surfaceRaised),
                  ),
                  if (video) const Center(child: Icon(AppIcons.play, color: Colors.white, size: 26)),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (i.clamp(0, 18) * 15).ms, duration: 180.ms);
        },
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(Gaps.x4, Gaps.x2, Gaps.x4, Gaps.x8),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: Gaps.x2),
        itemBuilder: (context, i) => _Row(message: items[i], onOpen: () => context.push('/chat/${widget.chatId}?m=${items[i].id}')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Shared'),
      body: Column(
        children: [
          SizedBox(height: top + Gaps.x2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.x4),
            child: Glass(
              pill: true,
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  for (final t in _Tab.values)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Haptics.select();
                          setState(() => _tab = t);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          height: 36,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            shape: const StadiumBorder(),
                            gradient: t == _tab ? p.accentGradient : null,
                          ),
                          child: Text(
                            t.label,
                            style: context.text.labelLarge?.copyWith(color: t == _tab ? Colors.white : p.text),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: KeyedSubtree(key: ValueKey(_tab), child: body))),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.message, required this.onOpen});

  final Message message;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final payload = message.payload;
    final link = payload.link?.url ?? RegExp(r'https?://\S+').firstMatch(payload.text ?? '')?.group(0);
    final (IconData icon, String title, String? sub) = switch (payload.kind) {
      MessageKind.file => (AppIcons.file, payload.media?.name ?? 'File', null),
      MessageKind.audio => (
        AppIcons.mic,
        'Voice message',
        payload.media?.durationMs == null ? null : TimeFormat.duration(Duration(milliseconds: payload.media!.durationMs!)),
      ),
      _ => (AppIcons.link, payload.link?.title ?? link ?? '', payload.link?.siteName ?? link),
    };
    return Pressable(
      scale: 0.98,
      onTap: () {
        final url = payload.kind == MessageKind.file ? payload.media?.url : (payload.kind == MessageKind.audio ? null : link);
        if (url != null && url.isNotEmpty) {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          onOpen();
        }
      },
      onLongPress: onOpen,
      child: Container(
        padding: const EdgeInsets.all(Gaps.x3),
        decoration: ShapeDecoration(
          color: p.surface,
          shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.md)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: ShapeDecoration(
                color: p.primary.withValues(alpha: 0.12),
                shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.sm)),
              ),
              child: Icon(icon, color: p.primary),
            ),
            const SizedBox(width: Gaps.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                  if (sub != null) Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
                ],
              ),
            ),
            Text(TimeFormat.chatList(message.createdAt), style: context.text.labelMedium),
          ],
        ),
      ),
    );
  }
}
