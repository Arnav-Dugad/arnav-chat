import 'package:flutter/material.dart';

import '../design/haptics.dart';
import '../design/icons.dart';

/// Short floating pill message. One or two words, never a paragraph.
void showToast(BuildContext context, String message, {bool error = false, IconData? icon}) {
  if (error) Haptics.heavy();
  final m = ScaffoldMessenger.maybeOf(context);
  if (m == null) return;
  m
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2200),
        margin: const EdgeInsets.fromLTRB(48, 0, 48, 24),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? (error ? AppIcons.warning : AppIcons.check), color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Flexible(child: Text(message, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
}
