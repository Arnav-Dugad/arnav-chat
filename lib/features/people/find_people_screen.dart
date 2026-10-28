import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/icons.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/fields.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/shimmer.dart';
import '../../data/models/app_user.dart';
import '../../data/providers.dart';
import 'user_row.dart';

class FindPeopleScreen extends ConsumerStatefulWidget {
  const FindPeopleScreen({super.key});

  @override
  ConsumerState<FindPeopleScreen> createState() => _FindPeopleScreenState();
}

class _FindPeopleScreenState extends ConsumerState<FindPeopleScreen> {
  final _q = TextEditingController();
  Timer? _debounce;
  List<AppUser>? _results;
  bool _loading = false;
  int _seq = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    super.dispose();
  }

  void _search(String q) {
    _debounce?.cancel();
    if (q.trim().replaceAll('@', '').length < 2) {
      setState(() {
        _results = null;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final seq = ++_seq;
      try {
        final r = await ref.read(userRepositoryProvider).search(q);
        if (mounted && seq == _seq) setState(() => _results = r);
      } finally {
        if (mounted && seq == _seq) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 56;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Find people'),
      body: Column(
        children: [
          SizedBox(height: top + Gaps.x2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.x4),
            child: PillField(controller: _q, hint: '@username', icon: AppIcons.at, autofocus: true, onChanged: _search),
          ),
          const SizedBox(height: Gaps.x2),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _loading && _results == null
                  ? const ChatListSkeleton(count: 4)
                  : _results == null
                  ? const EmptyState(icon: AppIcons.search, label: 'Search people')
                  : _results!.isEmpty
                  ? const EmptyState(icon: AppIcons.user, label: 'No one found')
                  : ListView.builder(
                      itemCount: _results!.length,
                      itemBuilder: (context, i) => UserRow(
                        user: _results![i],
                        onTap: () => context.push('/user/${_results![i].uid}'),
                      ).animate().fadeIn(delay: (i * 25).ms).moveX(begin: 10, end: 0),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
