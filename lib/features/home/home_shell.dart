import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/widgets/count_badge.dart';
import '../../core/widgets/glass.dart';
import '../../data/providers.dart';

final _totalUnreadProvider = StreamProvider.autoDispose<int>(
  (ref) => ref.watch(chatRepositoryProvider).watchTotalUnread(),
);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const tabBarHeight = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(_totalUnreadProvider).value ?? 0;
    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: _GlassTabBar(
        index: shell.currentIndex,
        unread: unread,
        onSelect: (i) {
          if (i != shell.currentIndex) Haptics.select();
          shell.goBranch(i, initialLocation: i == shell.currentIndex);
        },
      ),
    );
  }
}

class _Tab {
  const _Tab(this.icon, this.active, this.label);
  final IconData icon;
  final IconData active;
  final String label;
}

class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({required this.index, required this.onSelect, required this.unread});

  final int index;
  final int unread;
  final ValueChanged<int> onSelect;

  static const _tabs = [
    _Tab(AppIcons.chats, AppIcons.chatsFill, 'Chats'),
    _Tab(AppIcons.people, AppIcons.peopleFill, 'People'),
    _Tab(AppIcons.settings, AppIcons.settingsFill, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(40, 0, 40, bottom + 12),
      child: Glass(
        pill: true,
        child: SizedBox(
          height: HomeShell.tabBarHeight,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth / _tabs.length;
              return Stack(
                children: [
                  _StretchIndicator(
                    index: index,
                    slot: w,
                    color: p.primary.withValues(alpha: p.isDark ? 0.22 : 0.13),
                  ),
                  Row(
                    children: [
                      for (final (i, t) in _tabs.indexed)
                        Expanded(
                          child: Semantics(
                            selected: i == index,
                            button: true,
                            label: t.label,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onSelect(i),
                              child: Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      transitionBuilder: (c, a) => ScaleTransition(
                                        scale: Tween(
                                          begin: 0.7,
                                          end: 1.0,
                                        ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
                                        child: FadeTransition(opacity: a, child: c),
                                      ),
                                      child: Icon(
                                        i == index ? t.active : t.icon,
                                        key: ValueKey(i == index),
                                        size: 26,
                                        color: i == index ? p.primary : p.textMuted,
                                      ),
                                    ),
                                    if (i == 0) Positioned(right: -14, top: -8, child: CountBadge(count: unread)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Indicator whose leading edge moves faster than its trailing edge, so it
/// stretches while gliding and settles back to a pill.
class _StretchIndicator extends StatelessWidget {
  const _StretchIndicator({required this.index, required this.slot, required this.color});

  final int index;
  final double slot;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const inset = 8.0;
    final left = index * slot + inset;
    final right = (index + 1) * slot - inset;
    return _Edges(
      left: left,
      right: right,
      builder: (l, r) => Positioned(
        left: l,
        width: (r - l).clamp(0, double.infinity),
        top: 8,
        bottom: 8,
        child: DecoratedBox(
          decoration: ShapeDecoration(shape: const StadiumBorder(), color: color),
        ),
      ),
    );
  }
}

class _Edges extends StatefulWidget {
  const _Edges({required this.left, required this.right, required this.builder});

  final double left;
  final double right;
  final Widget Function(double left, double right) builder;

  @override
  State<_Edges> createState() => _EdgesState();
}

class _EdgesState extends State<_Edges> with TickerProviderStateMixin {
  late final _l = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final _r = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late Tween<double> _lt = Tween(begin: widget.left, end: widget.left);
  late Tween<double> _rt = Tween(begin: widget.right, end: widget.right);

  @override
  void didUpdateWidget(_Edges old) {
    super.didUpdateWidget(old);
    if (old.left == widget.left) return;
    final movingRight = widget.left > old.left;
    _lt = Tween(begin: _lt.transform(_l.value), end: widget.left);
    _rt = Tween(begin: _rt.transform(_r.value), end: widget.right);
    final fast = const Duration(milliseconds: 260), slow = const Duration(milliseconds: 440);
    _l.duration = movingRight ? slow : fast;
    _r.duration = movingRight ? fast : slow;
    _l.forward(from: 0);
    _r.forward(from: 0);
  }

  @override
  void dispose() {
    _l.dispose();
    _r.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_l, _r]),
    builder: (_, _) => widget.builder(
      _lt.transform(Curves.easeOutCubic.transform(_l.value)),
      _rt.transform(Curves.easeOutCubic.transform(_r.value)),
    ),
  );
}
