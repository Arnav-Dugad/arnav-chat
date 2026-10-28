import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/env.dart';
import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/fields.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_sheet.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/settings_group.dart';
import '../../core/widgets/toast.dart';
import '../../data/models/app_user.dart';
import '../../data/models/chat.dart';
import '../../data/providers.dart';
import '../../data/repositories/group_repository.dart';
import '../chat/chat_screen_providers.dart';
import '../chats/chat_avatar.dart';
import '../people/people_providers.dart';
import '../settings/avatar_picker.dart';

class ChatInfoScreen extends ConsumerWidget {
  const ChatInfoScreen({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chat = ref.watch(chatSummaryProvider(chatId)).value;
    final me = ref.watch(currentUidProvider)!;
    if (chat == null) return const Scaffold(appBar: GlassAppBar());
    final p = context.palette;
    final isGroup = chat.isGroup;
    final admin = chat.isAdmin(me);
    final members = isGroup ? (ref.watch(chatMembersProvider(chatId)).value ?? const <String, AppUser>{}) : const <String, AppUser>{};
    final peer = chat.peer;
    final groups = ref.read(groupRepositoryProvider);
    final chats = ref.read(chatRepositoryProvider);

    final subtitle = isGroup
        ? '${chat.members.length} members'
        : peer?.handle ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        actions: [
          if (isGroup && admin)
            GlassIconButton(icon: AppIcons.edit, label: 'Edit', onPressed: () => _editGroup(context, ref, chat)),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 64, bottom: Gaps.x10),
        children: [
          Center(
            child: isGroup && admin
                ? AvatarPicker(
                    url: chat.photoUrl,
                    name: chat.title('?'),
                    size: 108,
                    onUploaded: (url) => groups.setPhoto(chatId, url),
                  )
                : ChatAvatar(chat: chat, peer: peer, size: 108),
          ),
          const SizedBox(height: Gaps.x3),
          Text(chat.title(peer?.displayName ?? ''), textAlign: TextAlign.center, style: context.text.headlineSmall),
          Text(subtitle, textAlign: TextAlign.center, style: context.text.bodyMedium?.copyWith(color: p.textMuted)),
          if ((isGroup ? chat.description : peer?.bio)?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.x6, Gaps.x3, Gaps.x6, 0),
              child: Text((isGroup ? chat.description : peer?.bio)!, textAlign: TextAlign.center, style: context.text.bodyLarge),
            ),
          const SizedBox(height: Gaps.x5),
          // Quick actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.x4),
            child: Row(
              children: [
                _Action(
                  icon: chat.muted ? AppIcons.mute : AppIcons.mute,
                  label: chat.muted ? 'Unmute' : 'Mute',
                  active: chat.muted,
                  onTap: () => chats.setMuted(chatId, chat.muted ? null : const Duration(days: 3650)),
                ),
                _Action(icon: AppIcons.search, label: 'Search', onTap: () => context.push('/search?chat=$chatId')),
                _Action(icon: AppIcons.images, label: 'Media', onTap: () => context.push('/chat/$chatId/media')),
                _Action(icon: AppIcons.paint, label: 'Theme', onTap: () => context.push('/chat/$chatId/appearance')),
              ],
            ),
          ).animate().fadeIn(duration: 220.ms).moveY(begin: 8, end: 0),
          const SizedBox(height: Gaps.x3),
          if (isGroup) ...[
            _InviteSection(chat: chat, admin: admin),
            SettingsGroup(
              children: [
                if (admin)
                  SettingsRow(
                    icon: AppIcons.userPlus,
                    label: 'Add members',
                    onTap: () => _addMembers(context, ref, chat),
                  ),
                for (final uid in chat.members)
                  _MemberRow(
                    user: members[uid],
                    uid: uid,
                    isAdmin: chat.isAdmin(uid),
                    isMe: uid == me,
                    onTap: uid == me ? null : () => _memberActions(context, ref, chat, uid, members[uid], admin),
                  ),
              ],
            ),
          ] else if (peer != null)
            SettingsGroup(
              children: [
                SettingsRow(icon: AppIcons.user, label: 'Profile', onTap: () => context.push('/user/${peer.uid}')),
              ],
            ),
          SettingsGroup(
            children: [
              SettingsRow(
                icon: AppIcons.archive,
                label: chat.archived ? 'Unarchive' : 'Archive',
                color: const Color(0xFFF0A63A),
                onTap: () => chats.setArchived(chatId, !chat.archived),
              ),
              SettingsRow(
                icon: AppIcons.trash,
                label: 'Clear history',
                destructive: true,
                onTap: () async {
                  if (await _confirm(context, 'Clear history')) {
                    await chats.clearForMe(chatId);
                    if (context.mounted) showToast(context, 'Cleared');
                  }
                },
              ),
              if (isGroup && chat.members.contains(me))
                SettingsRow(
                  icon: AppIcons.signOut,
                  label: 'Leave group',
                  destructive: true,
                  onTap: () async {
                    if (chat.members.length == 1) return showToast(context, 'You are the last member');
                    if (!await _confirm(context, 'Leave group')) return;
                    await groups.leave(chatId, members: chat.members, admins: chat.admins);
                    if (context.mounted) context.go('/chats');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<bool> _confirm(BuildContext context, String label) async =>
      await showGlassSheet<bool>(
        context,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(Gaps.x4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PillButton(label: label, style: PillStyle.danger, onPressed: () => Navigator.pop(ctx, true)),
              PillButton(label: 'Cancel', style: PillStyle.ghost, onPressed: () => Navigator.pop(ctx, false)),
            ],
          ),
        ),
      ) ==
      true;

  Future<void> _editGroup(BuildContext context, WidgetRef ref, ChatSummary chat) async {
    final name = TextEditingController(text: chat.groupName);
    final desc = TextEditingController(text: chat.description);
    final ok = await showGlassSheet<bool>(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(Gaps.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PillField(controller: name, hint: 'Group name', maxLength: 64, autofocus: true),
            const SizedBox(height: Gaps.x3),
            PillField(controller: desc, hint: 'Description', maxLength: 280, multiline: true),
            const SizedBox(height: Gaps.x4),
            PillButton(label: 'Save', onPressed: () => Navigator.pop(ctx, true)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final groups = ref.read(groupRepositoryProvider);
    try {
      if (name.text.trim().isNotEmpty && name.text.trim() != chat.groupName) await groups.rename(chatId, name.text);
      if (desc.text.trim() != (chat.description ?? '')) await groups.setDescription(chatId, desc.text);
    } catch (_) {
      if (context.mounted) showToast(context, 'Not saved', error: true);
    }
  }

  Future<void> _addMembers(BuildContext context, WidgetRef ref, ChatSummary chat) async {
    final contacts = (ref.read(contactsProvider).value ?? const <AppUser>[])
        .where((u) => !chat.members.contains(u.uid))
        .toList();
    if (contacts.isEmpty) {
      showToast(context, 'No contacts to add');
      return;
    }
    final picked = await showGlassSheet<Map<String, String>>(
      context,
      builder: (_) => _PickContacts(contacts: contacts),
    );
    if (picked == null || picked.isEmpty) return;
    try {
      await ref.read(groupRepositoryProvider).addMembers(chatId, picked);
      Haptics.success();
    } catch (_) {
      if (context.mounted) showToast(context, 'Not added', error: true);
    }
  }

  Future<void> _memberActions(
    BuildContext context,
    WidgetRef ref,
    ChatSummary chat,
    String uid,
    AppUser? user,
    bool iAmAdmin,
  ) async {
    final name = user?.displayName ?? 'member';
    final action = await showGlassSheet<String>(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(Gaps.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: ctx.text.titleMedium),
            const SizedBox(height: Gaps.x3),
            PillButton(label: 'Message', icon: AppIcons.chats, onPressed: () => Navigator.pop(ctx, 'message')),
            if (iAmAdmin) ...[
              const SizedBox(height: Gaps.x2),
              PillButton(
                label: chat.isAdmin(uid) ? 'Remove admin' : 'Make admin',
                icon: AppIcons.crown,
                style: PillStyle.secondary,
                onPressed: () => Navigator.pop(ctx, 'admin'),
              ),
              PillButton(label: 'Remove from group', style: PillStyle.danger, onPressed: () => Navigator.pop(ctx, 'remove')),
            ],
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    final groups = ref.read(groupRepositoryProvider);
    try {
      switch (action) {
        case 'message':
          if (user != null) await openChatWith(context, ref, user);
        case 'admin':
          await groups.setAdmin(chatId, uid, !chat.isAdmin(uid));
        case 'remove':
          await groups.removeMember(chatId, uid, name);
      }
    } catch (_) {
      if (context.mounted) showToast(context, 'Not allowed', error: true);
    }
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap, this.active = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Pressable(
        onTap: onTap,
        haptic: true,
        semanticLabel: label,
        child: Container(
          height: 68,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: ShapeDecoration(
            color: active ? p.primary.withValues(alpha: 0.16) : p.surface,
            shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.md)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: p.primary, size: 22),
              const SizedBox(height: 4),
              Text(label, style: context.text.labelMedium?.copyWith(color: p.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.user, required this.uid, required this.isAdmin, required this.isMe, this.onTap});

  final AppUser? user;
  final String uid;
  final bool isAdmin;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final name = isMe ? 'You' : (user?.displayName ?? '…');
    return Pressable(
      scale: 0.985,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gaps.x4, vertical: 8),
        child: Row(
          children: [
            Avatar(name: user?.displayName ?? '?', url: user?.photoUrl, size: 38),
            const SizedBox(width: Gaps.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: context.text.titleSmall),
                  if (user != null) Text(user!.handle, style: context.text.bodySmall),
                ],
              ),
            ),
            if (isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: ShapeDecoration(shape: const StadiumBorder(), color: p.primary.withValues(alpha: 0.14)),
                child: Text('admin', style: context.text.labelSmall?.copyWith(color: p.primary)),
              ),
          ],
        ),
      ),
    );
  }
}

class _InviteSection extends ConsumerStatefulWidget {
  const _InviteSection({required this.chat, required this.admin});

  final ChatSummary chat;
  final bool admin;

  @override
  ConsumerState<_InviteSection> createState() => _InviteSectionState();
}

class _InviteSectionState extends ConsumerState<_InviteSection> {
  bool _busy = false;

  Future<void> _reset() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(groupRepositoryProvider)
          .resetInvite(
            widget.chat.id,
            name: widget.chat.title('Group'),
            photoUrl: widget.chat.photoUrl,
            memberCount: widget.chat.members.length,
            oldCode: widget.chat.inviteCode,
          );
      Haptics.success();
    } catch (_) {
      if (mounted) showToast(context, 'Not allowed', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.chat.inviteCode;
    final url = code == null ? null : GroupRepository.inviteUrl(Env.workerUrl, code);
    if (url == null && !widget.admin) return const SizedBox.shrink();
    return SettingsGroup(
      children: [
        if (url == null)
          SettingsRow(icon: AppIcons.link, label: _busy ? 'Creating…' : 'Create invite link', onTap: _busy ? null : _reset)
        else ...[
          SettingsRow(
            icon: AppIcons.link,
            label: url.replaceFirst('https://', ''),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) showToast(context, 'Link copied', icon: AppIcons.copy);
            },
            trailing: Icon(AppIcons.copy, size: 18, color: context.palette.textMuted),
          ),
          SettingsRow(
            icon: AppIcons.share,
            label: 'Share link',
            onTap: () => SharePlus.instance.share(ShareParams(text: 'Join "${widget.chat.title('Group')}" on Arnav Chat: $url')),
          ),
          if (widget.admin) ...[
            SettingsRow(icon: AppIcons.sparkle, label: 'Reset link', onTap: _busy ? null : _reset),
            SettingsRow(
              icon: AppIcons.close,
              label: 'Revoke link',
              destructive: true,
              onTap: () => ref.read(groupRepositoryProvider).revokeInvite(widget.chat.id, code!),
            ),
          ],
        ],
      ],
    );
  }
}

class _PickContacts extends StatefulWidget {
  const _PickContacts({required this.contacts});

  final List<AppUser> contacts;

  @override
  State<_PickContacts> createState() => _PickContactsState();
}

class _PickContactsState extends State<_PickContacts> {
  final _picked = <String, String>{};

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.55),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: Gaps.x3),
            children: [
              for (final u in widget.contacts)
                Pressable(
                  onTap: () => setState(() => _picked.containsKey(u.uid) ? _picked.remove(u.uid) : _picked[u.uid] = u.displayName),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Gaps.x5, vertical: 8),
                    child: Row(
                      children: [
                        Avatar(name: u.displayName, url: u.photoUrl, size: 40),
                        const SizedBox(width: Gaps.x3),
                        Expanded(child: Text(u.displayName, style: context.text.titleSmall)),
                        Icon(
                          _picked.containsKey(u.uid) ? AppIcons.check : AppIcons.plus,
                          color: _picked.containsKey(u.uid) ? p.primary : p.textFaint,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.x4, 0, Gaps.x4, Gaps.x4),
          child: PillButton(
            label: _picked.isEmpty ? 'Add' : 'Add ${_picked.length}',
            onPressed: _picked.isEmpty ? null : () => Navigator.pop(context, _picked),
          ),
        ),
      ],
    );
  }
}
