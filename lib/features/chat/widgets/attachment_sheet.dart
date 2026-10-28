import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/design/icons.dart';
import '../../../core/design/palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../../core/widgets/pressable.dart';

enum AttachKind { photo, camera, video, file }

/// Glass sheet whose tiles unfold with a staggered spring.
Future<AttachKind?> showAttachmentSheet(BuildContext context) =>
    showGlassSheet<AttachKind>(context, builder: (ctx) => const _AttachmentGrid());

class _AttachmentGrid extends StatelessWidget {
  const _AttachmentGrid();

  static const _items = [
    (AttachKind.photo, AppIcons.image, 'Photos', [Color(0xFF2F5BEA), Color(0xFF27B4D9)]),
    (AttachKind.camera, AppIcons.camera, 'Camera', [Color(0xFFE0525F), Color(0xFFF59E6C)]),
    (AttachKind.video, AppIcons.video, 'Video', [Color(0xFF15946A), Color(0xFF7BCB5A)]),
    (AttachKind.file, AppIcons.file, 'File', [Color(0xFFD9861C), Color(0xFFF2C14E)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.x4, Gaps.x5, Gaps.x4, Gaps.x5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final (i, (kind, icon, label, colors)) in _items.indexed)
            Pressable(
                  haptic: true,
                  semanticLabel: label,
                  onTap: () => Navigator.of(context).pop(kind),
                  child: Column(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: ShapeDecoration(
                          shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.md)),
                          gradient: LinearGradient(
                            colors: colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(label, style: context.text.labelMedium),
                    ],
                  ),
                )
                .animate()
                .scale(begin: const Offset(0.3, 0.3), delay: (45 * i).ms, duration: 460.ms, curve: Curves.elasticOut)
                .fadeIn(delay: (45 * i).ms, duration: 140.ms)
                .moveY(begin: 24, end: 0, delay: (45 * i).ms, duration: 380.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}
