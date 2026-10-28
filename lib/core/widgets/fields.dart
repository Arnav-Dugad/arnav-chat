import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/palette.dart';
import '../design/tokens.dart';

/// Pill-shaped text input with a leading icon and optional trailing widget.
class PillField extends StatelessWidget {
  const PillField({
    super.key,
    this.controller,
    this.hint,
    this.icon,
    this.trailing,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.inputFormatters,
    this.maxLength,
    this.autofillHints,
    this.multiline = false,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final Widget? trailing;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final bool multiline;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      decoration: ShapeDecoration(
        color: p.surfaceRaised,
        shape: multiline
            ? RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.md))
            : const StadiumBorder(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Gaps.x5),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 20, color: p.textMuted), const SizedBox(width: Gaps.x3)],
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscure,
              autofocus: autofocus,
              keyboardType: multiline ? TextInputType.multiline : keyboardType,
              textInputAction: textInputAction,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              autofillHints: autofillHints,
              minLines: 1,
              maxLines: multiline ? 4 : 1,
              style: context.text.bodyLarge,
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: hint,
                hintStyle: context.text.bodyLarge?.copyWith(color: p.textFaint),
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
