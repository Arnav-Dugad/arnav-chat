import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/palette.dart';
import '../design/tokens.dart';
import 'pressable.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(left: 58),
            child: Divider(height: 0.5, thickness: 0.5, color: p.separator),
          ),
        );
      }
      rows.add(children[i]);
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Gaps.x4, vertical: Gaps.x2),
      decoration: ShapeDecoration(
        color: p.surface,
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.value,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pressable(
      scale: 0.985,
      onTap: onTap,
      semanticLabel: label,
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.x4),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: ShapeDecoration(
                  color: destructive ? p.danger : (color ?? p.primary),
                  shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(9)),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: Gaps.x3),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyLarge?.copyWith(color: destructive ? p.danger : p.text),
                ),
              ),
              if (value != null) Text(value!, style: context.text.bodyMedium?.copyWith(color: p.textMuted)),
              if (trailing != null)
                trailing!
              else if (onTap != null && !destructive) ...[
                const SizedBox(width: 6),
                Icon(AppIcons.chevron, size: 16, color: p.textFaint),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
