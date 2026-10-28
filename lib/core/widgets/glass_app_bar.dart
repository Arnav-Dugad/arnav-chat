import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/icons.dart';
import '../design/palette.dart';
import 'buttons.dart';
import 'glass.dart';

/// Frosted app bar. Use with `Scaffold(extendBodyBehindAppBar: true)` so the
/// content scrolls underneath the blur.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.leading,
    this.showBack = true,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;
  final Widget? leading;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return GlassBar(
      top: true,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: NavigationToolbar(
            leading:
                leading ??
                (showBack
                    ? GlassIconButton(icon: AppIcons.back, label: 'Back', onPressed: () => popOrHome(context))
                    : null),
            middle: titleWidget ?? (title == null ? null : Text(title!, style: context.text.titleMedium)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: actions),
            middleSpacing: 8,
          ),
        ),
      ),
    );
  }
}

/// Back, or — on a screen opened by a deep link with nothing beneath it —
/// home to the chat list.
void popOrHome(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router != null && !router.canPop()) {
    router.go('/chats');
  } else {
    Navigator.of(context).maybePop();
  }
}
