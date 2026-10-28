import 'package:flutter/material.dart';

import '../../../core/design/palette.dart';
import '../../../core/widgets/glass.dart';

/// "Alice added Bob" — centered, quiet, never a bubble.
class SystemMessage extends StatelessWidget {
  const SystemMessage({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 6),
    child: Center(
      child: Glass(
        pill: true,
        blur: 12,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.text.labelMedium?.copyWith(color: context.palette.textMuted),
        ),
      ),
    ),
  );
}
