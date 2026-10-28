import 'package:flutter/material.dart';

import '../../../core/design/icons.dart';
import '../../../core/design/palette.dart';
import '../../../data/models/message.dart';

/// clock → ✓ → ✓✓ → ✓✓ (accent). Each step pops with a small overshoot.
class ReceiptTicks extends StatelessWidget {
  const ReceiptTicks({super.key, required this.receipt, this.size = 16, this.onAccent = false});

  final Receipt receipt;
  final double size;

  /// True inside my (gradient) bubble — use white tones.
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = onAccent ? Colors.white.withValues(alpha: 0.75) : p.textFaint;
    final read = onAccent ? Colors.white : p.primary;
    final (IconData icon, Color color, String label) = switch (receipt) {
      Receipt.pending => (AppIcons.clock, base, 'Sending'),
      Receipt.failed => (AppIcons.warning, p.danger, 'Not sent'),
      Receipt.sent => (AppIcons.check, base, 'Sent'),
      Receipt.delivered => (AppIcons.checks, base, 'Delivered'),
      Receipt.read => (AppIcons.checks, read, 'Read'),
    };
    return Semantics(
      label: label,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutBack,
        transitionBuilder: (child, a) => ScaleTransition(
          scale: a,
          child: FadeTransition(opacity: a, child: child),
        ),
        child: Icon(icon, key: ValueKey(receipt), size: size, color: color),
      ),
    );
  }
}
