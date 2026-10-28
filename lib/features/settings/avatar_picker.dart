import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/toast.dart';
import '../../data/models/message_payload.dart';
import '../../data/providers.dart';
import '../../core/widgets/progress_ring.dart';

/// Tappable avatar that picks a photo and uploads it (signed) to Cloudinary.
class AvatarPicker extends ConsumerStatefulWidget {
  const AvatarPicker({super.key, required this.url, required this.name, required this.onUploaded, this.size = 96});

  final String? url;
  final String name;
  final double size;
  final ValueChanged<String> onUploaded;

  @override
  ConsumerState<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<AvatarPicker> {
  double? _progress;

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 88,
    );
    if (file == null) return;
    setState(() => _progress = 0);
    try {
      final media = await ref
          .read(mediaUploaderProvider)
          .upload(
            path: file.path,
            kind: 'avatar',
            draft: MediaRef(url: '', name: file.name, mime: file.mimeType ?? 'image/jpeg'),
            onProgress: (p) => mounted ? setState(() => _progress = p) : null,
          );
      widget.onUploaded(media.url);
    } catch (_) {
      if (mounted) showToast(context, 'Upload failed', error: true);
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      onTap: _progress == null ? _pick : null,
      haptic: true,
      semanticLabel: 'Change photo',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Avatar(name: widget.name, url: widget.url, size: widget.size),
          if (_progress != null) ProgressRing(progress: _progress!, size: widget.size + 12),
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: widget.size * 0.3,
              height: widget.size * 0.3,
              decoration: BoxDecoration(
                gradient: p.accentGradient,
                shape: BoxShape.circle,
                border: Border.all(color: p.bg, width: 3),
              ),
              child: Icon(AppIcons.camera, color: Colors.white, size: widget.size * 0.14),
            ),
          ),
        ],
      ),
    );
  }
}
