import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/aurora.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/dots_loader.dart';
import '../../core/widgets/fields.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/toast.dart';
import '../../data/providers.dart';
import '../../data/repositories/user_repository.dart';
import '../settings/avatar_picker.dart';

enum _Availability { idle, checking, free, taken, invalid }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();
  Timer? _debounce;
  var _availability = _Availability.idle;
  String? _photoUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).value;
    _name.text = user?.displayName ?? '';
    _photoUrl = user?.photoURL;
    final seed = (user?.displayName ?? user?.email?.split('@').first ?? '').toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_]'),
      '',
    );
    if (seed.length >= 3) {
      _username.text = seed.length > 20 ? seed.substring(0, 20) : seed;
      _check(_username.text);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _check(String raw) {
    _debounce?.cancel();
    final handle = normalizeUsername(raw);
    if (handle.isEmpty) return setState(() => _availability = _Availability.idle);
    if (!usernamePattern.hasMatch(handle)) return setState(() => _availability = _Availability.invalid);
    setState(() => _availability = _Availability.checking);
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final free = await ref.read(userRepositoryProvider).isUsernameAvailable(handle);
        if (!mounted || normalizeUsername(_username.text) != handle) return;
        setState(() => _availability = free ? _Availability.free : _Availability.taken);
        if (free) Haptics.tick();
      } catch (_) {
        if (mounted) setState(() => _availability = _Availability.idle);
      }
    });
  }

  bool get _valid => _name.text.trim().isNotEmpty && _availability == _Availability.free;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(userRepositoryProvider)
          .createProfile(
            username: _username.text,
            displayName: _name.text,
            bio: _bio.text.isEmpty ? null : _bio.text,
            photoUrl: _photoUrl,
          );
      Haptics.success();
    } catch (e) {
      if (mounted) {
        showToast(context, 'Username taken', error: true);
        setState(() => _availability = _Availability.taken);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Widget status = switch (_availability) {
      _Availability.checking => DotsLoader(color: p.textMuted, size: 5, gap: 3, amplitude: 2),
      _Availability.free => Icon(AppIcons.check, color: p.success, size: 20),
      _Availability.taken || _Availability.invalid => Icon(AppIcons.close, color: p.danger, size: 20),
      _Availability.idle => const SizedBox.shrink(),
    };

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: Aurora()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Gaps.x6, vertical: Gaps.x6),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      AvatarPicker(
                        url: _photoUrl,
                        name: _name.text.isEmpty ? '?' : _name.text,
                        size: 112,
                        onUploaded: (url) => setState(() => _photoUrl = url),
                      ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack, duration: 500.ms),
                      const SizedBox(height: Gaps.x8),
                      Glass(
                        radius: Radii.xl,
                        padding: const EdgeInsets.all(Gaps.x4),
                        child: Column(
                          children: [
                            PillField(
                              controller: _name,
                              hint: 'Name',
                              icon: AppIcons.user,
                              textInputAction: TextInputAction.next,
                              maxLength: 40,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: Gaps.x3),
                            PillField(
                              controller: _username,
                              hint: 'username',
                              icon: AppIcons.at,
                              maxLength: 20,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                                TextInputFormatter.withFunction((o, n) => n.copyWith(text: n.text.toLowerCase())),
                              ],
                              onChanged: _check,
                              trailing: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                                child: KeyedSubtree(key: ValueKey(_availability), child: status),
                              ),
                            ),
                            const SizedBox(height: Gaps.x3),
                            PillField(
                              controller: _bio,
                              hint: 'Bio',
                              icon: AppIcons.sparkle,
                              maxLength: 140,
                              multiline: true,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 120.ms).moveY(begin: 20, end: 0, curve: Curves.easeOutCubic),
                      const SizedBox(height: Gaps.x6),
                      PillButton(
                        label: 'Done',
                        busy: _saving,
                        onPressed: _valid ? _save : null,
                      ).animate().fadeIn(delay: 220.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
