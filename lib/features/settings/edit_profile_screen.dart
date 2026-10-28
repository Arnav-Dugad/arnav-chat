import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/fields.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/toast.dart';
import '../../data/providers.dart';
import 'avatar_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final _me = ref.read(meProvider);
  late final _name = TextEditingController(text: _me.displayName);
  late final _bio = TextEditingController(text: _me.bio ?? '');
  late String? _photo = _me.photoUrl;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(userRepositoryProvider).updateProfile(displayName: _name.text, bio: _bio.text, photoUrl: _photo);
      Haptics.success();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) showToast(context, 'Not saved', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Profile'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(Gaps.x6, MediaQuery.paddingOf(context).top + 80, Gaps.x6, Gaps.x8),
        children: [
          Center(child: AvatarPicker(url: _photo, name: _name.text, size: 112, onUploaded: (u) => setState(() => _photo = u))),
          const SizedBox(height: Gaps.x3),
          Text(_me.handle, textAlign: TextAlign.center, style: context.text.bodyMedium?.copyWith(color: context.palette.textMuted)),
          const SizedBox(height: Gaps.x6),
          PillField(controller: _name, hint: 'Name', icon: AppIcons.user, maxLength: 40),
          const SizedBox(height: Gaps.x3),
          PillField(controller: _bio, hint: 'Bio', icon: AppIcons.sparkle, maxLength: 140, multiline: true),
          const SizedBox(height: Gaps.x6),
          PillButton(label: 'Save', busy: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
