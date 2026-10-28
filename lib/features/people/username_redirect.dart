import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/icons.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/shimmer.dart';
import '../../data/providers.dart';

/// Resolves `arnavchat://app/u/{username}` to the profile screen.
class UsernameRedirect extends ConsumerStatefulWidget {
  const UsernameRedirect({super.key, required this.username});

  final String username;

  @override
  ConsumerState<UsernameRedirect> createState() => _UsernameRedirectState();
}

class _UsernameRedirectState extends ConsumerState<UsernameRedirect> {
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    ref.read(userRepositoryProvider).byUsername(widget.username).then((u) {
      if (!mounted) return;
      if (u == null) return setState(() => _missing = true);
      context.pushReplacement('/user/${u.uid}');
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const GlassAppBar(),
    body: _missing
        ? const EmptyState(icon: AppIcons.user, label: 'Not found')
        : const Padding(padding: EdgeInsets.only(top: 120), child: ChatListSkeleton(count: 1)),
  );
}
