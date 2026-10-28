import 'package:flutter/material.dart';

import '../design/palette.dart';
import '../design/tokens.dart';
import 'glass.dart';

/// Shows a frosted bottom sheet with large continuous corners.
Future<T?> showGlassSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
  bool scrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollControlled,
    isDismissible: dismissible,
    enableDrag: dismissible,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    elevation: 0,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: Gaps.x2,
        right: Gaps.x2,
        bottom: MediaQuery.viewInsetsOf(ctx).bottom + MediaQuery.paddingOf(ctx).bottom + Gaps.x2,
      ),
      child: Glass(
        radius: Radii.xl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: ctx.palette.textFaint.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Flexible(child: builder(ctx)),
          ],
        ),
      ),
    ),
  );
}
