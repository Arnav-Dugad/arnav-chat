import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/fields.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_sheet.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/settings_group.dart';
import '../../data/models/chat.dart';
import '../../data/providers.dart';
import '../chats/chat_avatar.dart';
import '../chats/chat_providers.dart';

/// Telegram-style chat folders: rules (personal / groups / unread / not muted)
/// plus hand-picked chats.
class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(foldersProvider).value ?? const <ChatFolder>[];
    final repo = ref.read(chatRepositoryProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Folders',
        actions: [
          GlassIconButton(
            icon: AppIcons.plus,
            label: 'New folder',
            onPressed: () => _edit(context, ref, ChatFolder(id: repo.newFolderId(), name: '', order: folders.length)),
          ),
        ],
      ),
      body: folders.isEmpty
          ? EmptyState(
              icon: AppIcons.folder,
              label: 'No folders',
              action: PillButton(
                label: 'Create folder',
                expand: false,
                icon: AppIcons.plus,
                onPressed: () => _edit(context, ref, ChatFolder(id: repo.newFolderId(), name: '', order: 0)),
              ),
            )
          : ListView(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 64),
              children: [
                SettingsGroup(
                  children: [
                    for (final f in folders)
                      SettingsRow(
                        icon: AppIcons.folder,
                        label: f.name,
                        value: _describe(f),
                        onTap: () => _edit(context, ref, f),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  static String _describe(ChatFolder f) {
    final parts = [
      if (f.includeDirect) 'People',
      if (f.includeGroups) 'Groups',
      if (f.chatIds.isNotEmpty) '${f.chatIds.length} chats',
    ];
    return parts.join(' · ');
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, ChatFolder folder) async {
    final result = await showGlassSheet<(ChatFolder, bool)>(context, builder: (_) => _FolderEditor(folder: folder));
    if (result == null) return;
    final (f, delete) = result;
    final repo = ref.read(chatRepositoryProvider);
    delete ? await repo.deleteFolder(f.id) : await repo.saveFolder(f);
    Haptics.success();
  }
}

class _FolderEditor extends ConsumerStatefulWidget {
  const _FolderEditor({required this.folder});

  final ChatFolder folder;

  @override
  ConsumerState<_FolderEditor> createState() => _FolderEditorState();
}

class _FolderEditorState extends ConsumerState<_FolderEditor> {
  late final _name = TextEditingController(text: widget.folder.name);
  late ChatFolder _f = widget.folder;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) => Pressable(
    onTap: () => onChanged(!value),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gaps.x2, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.text.bodyLarge)),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final chats = ref.watch(chatListProvider).value ?? const <ChatSummary>[];
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Gaps.x4),
        children: [
          PillField(controller: _name, hint: 'Folder name', icon: AppIcons.folder, maxLength: 24, onChanged: (_) => setState(() {})),
          const SizedBox(height: Gaps.x3),
          _toggle('All people', _f.includeDirect, (v) => setState(() => _f = _f.copyWith(includeDirect: v))),
          _toggle('All groups', _f.includeGroups, (v) => setState(() => _f = _f.copyWith(includeGroups: v))),
          _toggle('Unread only', _f.unreadOnly, (v) => setState(() => _f = _f.copyWith(unreadOnly: v))),
          _toggle('Hide muted', _f.excludeMuted, (v) => setState(() => _f = _f.copyWith(excludeMuted: v))),
          const SizedBox(height: Gaps.x3),
          Text('CHATS', style: context.text.labelSmall),
          for (final c in chats)
            Pressable(
              scale: 0.98,
              onTap: () {
                final ids = [..._f.chatIds];
                ids.contains(c.id) ? ids.remove(c.id) : ids.add(c.id);
                setState(() => _f = _f.copyWith(chatIds: ids));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: Gaps.x2),
                child: Row(
                  children: [
                    ChatAvatar(chat: c, peer: c.peer, size: 36),
                    const SizedBox(width: Gaps.x3),
                    Expanded(child: Text(c.title('…'), style: context.text.titleSmall, maxLines: 1)),
                    Icon(
                      _f.chatIds.contains(c.id) ? AppIcons.check : AppIcons.plus,
                      color: _f.chatIds.contains(c.id) ? p.primary : p.textFaint,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: Gaps.x4),
          PillButton(
            label: 'Save',
            onPressed: _name.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop((_f.copyWith(name: _name.text.trim()), false)),
          ),
          if (widget.folder.name.isNotEmpty)
            PillButton(label: 'Delete folder', style: PillStyle.danger, onPressed: () => Navigator.of(context).pop((_f, true))),
        ],
      ),
    );
  }
}
