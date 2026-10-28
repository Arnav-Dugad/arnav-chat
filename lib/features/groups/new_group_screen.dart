import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/fields.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/toast.dart';
import '../../data/models/app_user.dart';
import '../../data/providers.dart';
import '../people/people_providers.dart';
import '../settings/avatar_picker.dart';

class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({super.key});

  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  final _name = TextEditingController();
  final _query = TextEditingController();
  final _selected = <String, AppUser>{};
  List<AppUser>? _results;
  String? _photo;
  Timer? _debounce;
  bool _creating = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    _query.dispose();
    super.dispose();
  }

  void _search(String q) {
    _debounce?.cancel();
    if (q.trim().replaceAll('@', '').length < 2) return setState(() => _results = null);
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final r = await ref.read(userRepositoryProvider).search(q);
      if (mounted) setState(() => _results = r);
    });
  }

  void _toggle(AppUser u) {
    Haptics.select();
    setState(() => _selected.containsKey(u.uid) ? _selected.remove(u.uid) : _selected[u.uid] = u);
  }

  Future<void> _create() async {
    setState(() => _creating = true);
    try {
      final id = await ref
          .read(groupRepositoryProvider)
          .create(name: _name.text, memberUids: _selected.keys.toList(), photoUrl: _photo);
      await ref.read(chatRepositoryProvider).fetchOne(id);
      Haptics.success();
      if (mounted) context.pushReplacement('/chat/$id');
    } catch (_) {
      if (mounted) showToast(context, 'Not created', error: true);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final contacts = ref.watch(contactsProvider).value ?? const <AppUser>[];
    final list = _results ?? contacts;
    final top = MediaQuery.paddingOf(context).top + 64;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'New group'),
      body: Column(
        children: [
          SizedBox(height: top),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.x4),
            child: Row(
              children: [
                AvatarPicker(
                  url: _photo,
                  name: _name.text.isEmpty ? '?' : _name.text,
                  size: 64,
                  onUploaded: (u) => setState(() => _photo = u),
                ),
                const SizedBox(width: Gaps.x3),
                Expanded(
                  child: PillField(
                    controller: _name,
                    hint: 'Group name',
                    maxLength: 64,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gaps.x3),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: _selected.isEmpty
                ? const SizedBox(width: double.infinity)
                : SizedBox(
                    height: 84,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: Gaps.x3),
                      children: [
                        for (final u in _selected.values)
                          Pressable(
                            key: ValueKey(u.uid),
                            onTap: () => _toggle(u),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Avatar(name: u.displayName, url: u.photoUrl, size: 52),
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(color: p.textMuted, shape: BoxShape.circle),
                                          child: const Icon(AppIcons.close, size: 12, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      u.displayName.split(' ').first,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack, duration: 300.ms),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.x4),
            child: PillField(controller: _query, hint: 'Add people', icon: AppIcons.search, onChanged: _search),
          ),
          const SizedBox(height: Gaps.x2),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final u = list[i];
                final on = _selected.containsKey(u.uid);
                return Pressable(
                  scale: 0.98,
                  onTap: () => _toggle(u),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Gaps.x4, vertical: 8),
                    child: Row(
                      children: [
                        Avatar(name: u.displayName, url: u.photoUrl, size: 44),
                        const SizedBox(width: Gaps.x3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.displayName, style: context.text.titleSmall),
                              Text(u.handle, style: context.text.bodySmall),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: on ? p.accentGradient : null,
                            border: on ? null : Border.all(color: p.textFaint, width: 1.5),
                          ),
                          child: on ? const Icon(AppIcons.check, size: 14, color: Colors.white) : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gaps.x4),
        child: PillButton(
          label: _selected.isEmpty ? 'Create' : 'Create · ${_selected.length + 1}',
          icon: AppIcons.group,
          busy: _creating,
          onPressed: _name.text.trim().isNotEmpty ? _create : null,
        ),
      ),
    );
  }
}
