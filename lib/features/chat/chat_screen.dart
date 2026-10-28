import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/router.dart';
import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/glass_sheet.dart';
import '../../core/widgets/measure_size.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/toast.dart';
import '../../data/media/media_prep.dart';
import '../../data/models/app_user.dart';
import '../../data/models/message.dart';
import '../../data/models/message_payload.dart';
import '../../data/providers.dart';
import '../../data/remote/link_preview_service.dart';
import '../chats/chat_providers.dart';
import '../chats/chat_tile.dart';
import '../notifications/push_handlers.dart';
import 'chat_header.dart';
import 'chat_screen_providers.dart';
import 'widgets/attachment_sheet.dart';
import 'widgets/bubble_body.dart';
import 'widgets/day_separator.dart';
import 'widgets/forward_sheet.dart';
import 'widgets/input_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_menu.dart';
import 'widgets/typing_bubble.dart';
import 'widgets/voice_recorder.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId, this.args});

  final String chatId;
  final ChatRouteArgs? args;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WidgetsBindingObserver {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  final _openedAt = DateTime.now();

  int _limit = 40;
  List<Message> _messages = const [];
  final _seen = <String>{};
  final _dissolving = <String, VoidCallback>{};
  bool _loadingMore = false;
  bool _showJump = false;
  double _inputHeight = 72;

  Message? _reply;
  Message? _editing;
  LinkPreview? _link;
  String? _linkUrl;
  final _dismissedLinks = <String>{};
  Timer? _linkTimer;

  StreamSubscription<void>? _live;
  bool _attaching = false;
  Timer? _typingOff;
  DateTime _typingSentAt = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _readTimer;
  late final String _me = ref.read(currentUidProvider)!;

  String get _chatId => widget.chatId;

  String? get _peerUid {
    if (_chatId == _me) return _me;
    final parts = _chatId.split('_');
    return parts.length == 2 ? (parts.first == _me ? parts.last : parts.first) : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    activeChatId = _chatId;
    cancelChatNotification(_chatId);
    _scroll.addListener(_onScroll);
    _boot();
  }

  Future<void> _boot() async {
    final chats = ref.read(chatRepositoryProvider);
    if (await chats.chatRow(_chatId) == null && _peerUid != null) await chats.ensureDirect(_peerUid!);
    final row = await chats.chatRow(_chatId);
    if (row?.draft != null && _text.text.isEmpty) _text.text = row!.draft!;
    await _attach();
    _scheduleRead();
  }

  Future<void> _attach() async {
    if (_live != null || _attaching) return;
    _attaching = true;
    try {
      _live = await ref.read(messageRepositoryProvider).attach(_chatId);
    } catch (_) {}
    _attaching = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      activeChatId = _chatId;
      _scheduleRead();
    } else if (state == AppLifecycleState.paused) {
      activeChatId = null;
    }
  }

  void _scheduleRead() {
    _readTimer?.cancel();
    _readTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) ref.read(chatRepositoryProvider).markRead(_chatId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (activeChatId == _chatId) activeChatId = null;
    _live?.cancel();
    _readTimer?.cancel();
    _linkTimer?.cancel();
    _typingOff?.cancel();
    final draft = _editing == null ? _text.text.trim() : '';
    final chats = ref.read(chatRepositoryProvider);
    final presence = ref.read(presenceProvider);
    chats.setDraft(_chatId, draft);
    presence.setTyping(_chatId, false).catchError((_) {});
    _text.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---------- paging ----------

  void _onScroll() {
    final pos = _scroll.position;
    final jump = pos.pixels > 500;
    if (jump != _showJump) setState(() => _showJump = jump);
    if (pos.pixels > pos.maxScrollExtent - 700) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    final row = ref.read(chatRowProvider(_chatId)).value;
    final localExhausted = _messages.length < _limit;
    if (localExhausted && !(row?.hasMoreOlder ?? false)) return;
    _loadingMore = true;
    if (localExhausted) await ref.read(messageRepositoryProvider).loadOlder(_chatId);
    if (mounted) setState(() => _limit += 30);
    _loadingMore = false;
  }

  // ---------- composing ----------

  void _onChanged(String text) {
    final now = DateTime.now();
    final presence = ref.read(presenceProvider);
    if (text.isNotEmpty && now.difference(_typingSentAt) > const Duration(seconds: 3)) {
      _typingSentAt = now;
      presence.setTyping(_chatId, true).catchError((_) {});
    }
    _typingOff?.cancel();
    _typingOff = Timer(const Duration(seconds: 4), () {
      _typingSentAt = DateTime.fromMillisecondsSinceEpoch(0);
      presence.setTyping(_chatId, false).catchError((_) {});
    });

    final url = firstUrl(text);
    if (url != _linkUrl) {
      _linkUrl = url;
      _linkTimer?.cancel();
      if (url == null || _dismissedLinks.contains(url)) {
        if (_link != null) setState(() => _link = null);
      } else {
        _linkTimer = Timer(const Duration(milliseconds: 600), () async {
          final preview = await ref.read(linkPreviewsProvider).fetch(url);
          if (mounted && _linkUrl == url) setState(() => _link = preview);
        });
      }
    }
  }

  ReplyRef? get _replyRef => _reply == null
      ? null
      : ReplyRef(
          id: _reply!.id,
          senderId: _reply!.senderId,
          preview: _reply!.payload.preview,
          kind: _reply!.payload.kind,
        );

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    if (_editing != null) {
      await ref.read(messageRepositoryProvider).edit(_chatId, _editing!.id, text);
      setState(() => _editing = null);
      _text.clear();
      return;
    }
    final link = (_link != null && text.contains(_link!.url)) ? _link : null;
    final reply = _replyRef;
    _text.clear();
    setState(() {
      _reply = null;
      _link = null;
      _linkUrl = null;
    });
    _typingOff?.cancel();
    _typingSentAt = DateTime.fromMillisecondsSinceEpoch(0);
    ref.read(presenceProvider).setTyping(_chatId, false).catchError((_) {});
    await ref
        .read(outboxProvider)
        .send(
          chatId: _chatId,
          payload: MessagePayload.text(text, link: link),
          reply: reply,
        );
    _toBottom();
  }

  void _toBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(0, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
  }

  Future<void> _sendVoice(VoiceClip clip) async {
    await ref
        .read(outboxProvider)
        .send(
          chatId: _chatId,
          reply: _replyRef,
          localPath: clip.path,
          payload: MessagePayload(
            kind: MessageKind.audio,
            media: MediaRef(
              url: '',
              mime: 'audio/mp4',
              name: 'voice.m4a',
              durationMs: clip.duration.inMilliseconds,
              waveform: clip.waveform,
            ),
          ),
        );
    setState(() => _reply = null);
    _toBottom();
  }

  Future<void> _attachMedia() async {
    final kind = await showAttachmentSheet(context);
    if (kind == null || !mounted) return;
    final outbox = ref.read(outboxProvider);
    final picker = ImagePicker();
    switch (kind) {
      case AttachKind.photo:
      case AttachKind.camera:
        final files = kind == AttachKind.photo
            ? await picker.pickMultiImage(maxWidth: 2048, maxHeight: 2048, imageQuality: 85, limit: 10)
            : [?await picker.pickImage(source: ImageSource.camera, maxWidth: 2048, maxHeight: 2048, imageQuality: 85)];
        for (final f in files) {
          final bytes = await f.readAsBytes();
          final meta = await analyzeImage(bytes);
          await outbox.send(
            chatId: _chatId,
            localPath: f.path,
            payload: MessagePayload(
              kind: MessageKind.image,
              media: MediaRef(
                url: '',
                name: f.name,
                mime: f.mimeType ?? 'image/jpeg',
                bytes: bytes.length,
                width: meta?.width,
                height: meta?.height,
                blurhash: meta?.blurhash,
              ),
            ),
          );
        }
      case AttachKind.video:
        final f = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 3));
        if (f == null) return;
        await outbox.send(
          chatId: _chatId,
          localPath: f.path,
          payload: MessagePayload(
            kind: MessageKind.video,
            media: MediaRef(url: '', name: f.name, mime: f.mimeType ?? 'video/mp4'),
          ),
        );
      case AttachKind.file:
        final res = await FilePicker.pickFiles();
        if (res.isEmpty || res.first.path == null) return;
        final f = res.first;
        await outbox.send(
          chatId: _chatId,
          localPath: f.path,
          payload: MessagePayload(
            kind: MessageKind.file,
            media: MediaRef(url: '', name: f.name, bytes: await f.length()),
          ),
        );
    }
    _toBottom();
  }

  // ---------- message actions ----------

  Future<void> _openMenu(Message m, GlobalKey key, Receipt receipt, bool first, bool last) async {
    FocusScope.of(context).unfocus();
    final mine = m.senderId == _me;
    final isText = m.payload.kind == MessageKind.text;
    final actions = <MenuAction>[
      if (!m.deletedForEveryone) const MenuAction('reply', 'Reply', AppIcons.reply),
      if (isText && !m.deletedForEveryone) const MenuAction('copy', 'Copy', AppIcons.copy),
      if (mine && isText && !m.deletedForEveryone && m.state == SendState.sent)
        const MenuAction('edit', 'Edit', AppIcons.edit),
      if (!m.deletedForEveryone) const MenuAction('forward', 'Forward', AppIcons.forward),
      if (!m.deletedForEveryone)
        MenuAction('star', m.starred ? 'Unstar' : 'Star', m.starred ? AppIcons.starFill : AppIcons.star),
      const MenuAction('delete', 'Delete', AppIcons.trash, destructive: true),
    ];
    final result = await showMessageMenu(
      context,
      bubbleKey: key,
      mine: mine,
      myReaction: m.reactions[_me],
      actions: actions,
      bubble: BubbleBody(
        message: m,
        mine: mine,
        receipt: receipt,
        first: first,
        last: last,
        replyAuthor: _authorName(m.reply?.senderId),
      ),
    );
    if (!mounted || result == null) return;
    final repo = ref.read(messageRepositoryProvider);
    switch (result) {
      case ReactResult(:final emoji):
        await repo.react(_chatId, m.id, m.reactions[_me] == emoji ? null : emoji);
      case ActionResult(id: 'reply'):
        setState(() => _reply = m);
        _focus.requestFocus();
      case ActionResult(id: 'copy'):
        await Clipboard.setData(ClipboardData(text: m.payload.text ?? ''));
        if (mounted) showToast(context, 'Copied', icon: AppIcons.copy);
      case ActionResult(id: 'edit'):
        setState(() {
          _editing = m;
          _reply = null;
        });
        _text.text = m.payload.text ?? '';
        _focus.requestFocus();
      case ActionResult(id: 'forward'):
        final target = await showForwardSheet(context);
        if (target != null) {
          await ref.read(outboxProvider).send(chatId: target, payload: m.payload, forwarded: true);
          if (mounted) showToast(context, 'Forwarded', icon: AppIcons.forward);
        }
      case ActionResult(id: 'star'):
        await repo.setStarred(m.id, !m.starred);
      case ActionResult(id: 'delete'):
        await _confirmDelete(m);
      case ActionResult():
        break;
    }
  }

  Future<void> _confirmDelete(Message m) async {
    final mine = m.senderId == _me;
    final everyone = mine && !m.deletedForEveryone && DateTime.now().difference(m.createdAt) < const Duration(days: 2);
    final choice = await showGlassSheet<String>(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (everyone)
              PillButton(
                label: 'Delete for everyone',
                style: PillStyle.danger,
                onPressed: () => Navigator.pop(ctx, 'all'),
              ),
            PillButton(label: 'Delete for me', style: PillStyle.danger, onPressed: () => Navigator.pop(ctx, 'me')),
            PillButton(label: 'Cancel', style: PillStyle.ghost, onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    Haptics.heavy();
    final repo = ref.read(messageRepositoryProvider);
    final wasLast = _messages.isNotEmpty && _messages.first.id == m.id;
    setState(() {
      _dissolving[m.id] = () {
        if (choice == 'all') {
          repo.deleteForEveryone(_chatId, m.id, wasLast: wasLast);
        } else {
          repo.deleteForMe(m.id);
        }
      };
    });
  }

  String? _authorName(String? uid) {
    if (uid == null) return null;
    if (uid == _me) return 'You';
    return _peer?.displayName;
  }

  AppUser? get _peer {
    final uid = _peerUid;
    return widget.args?.peer ?? (uid == null ? null : ref.read(cachedUserProvider(uid)).value);
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final peerUid = _peerUid;
    final peer = peerUid == null ? null : (ref.watch(cachedUserProvider(peerUid)).value ?? widget.args?.peer);
    final row = ref.watch(chatRowProvider(_chatId)).value;
    final typing =
        peerUid != null && peerUid != _me && (ref.watch(peerTypingProvider(_chatId, peerUid)).value ?? false);
    _messages = ref.watch(chatMessagesProvider(_chatId, _limit)).value ?? _messages;

    ref.listen(chatRowProvider(_chatId), (prev, next) {
      final r = next.value;
      if (r == null) return;
      if (r.lastAt > 0 && _live == null) _attach();
      if (r.unread > 0) _scheduleRead();
    });

    final deliveredUpTo = row?.peerDeliveredUpTo == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row!.peerDeliveredUpTo!);
    final readUpTo = row?.peerReadUpTo == null ? null : DateTime.fromMillisecondsSinceEpoch(row!.peerReadUpTo!);
    final top = MediaQuery.paddingOf(context).top + 60;
    final firstBuild = _seen.isEmpty;

    final list = ListView.builder(
      controller: _scroll,
      reverse: true,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(top: top + 8, bottom: _inputHeight + 6),
      itemCount: _messages.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return TypingBubble(visible: typing);
        final idx = i - 1;
        final m = _messages[idx];
        final older = idx + 1 < _messages.length ? _messages[idx + 1] : null;
        final newer = idx > 0 ? _messages[idx - 1] : null;
        bool grouped(Message? a, Message b) =>
            a != null &&
            a.senderId == b.senderId &&
            b.createdAt.difference(a.createdAt).abs() < const Duration(minutes: 3) &&
            TimeFormat.sameDay(a.createdAt, b.createdAt);
        final first = !grouped(older, m);
        final last = newer == null || !grouped(m, newer);
        final mine = m.senderId == _me;
        final receipt = m.receipt(deliveredUpTo: deliveredUpTo, readUpTo: readUpTo);
        final isNew =
            !firstBuild && !_seen.contains(m.id) && m.createdAt.isAfter(_openedAt.subtract(const Duration(seconds: 2)));
        _seen.add(m.id);

        final bubble = MessageBubble(
          key: ValueKey(m.id),
          message: m,
          mine: mine,
          receipt: receipt,
          myUid: _me,
          first: first,
          last: last,
          animateIn: isNew,
          replyAuthor: _authorName(m.reply?.senderId),
          dissolving: _dissolving.containsKey(m.id),
          onDissolved: () {
            final act = _dissolving.remove(m.id);
            act?.call();
            if (mounted) setState(() {});
          },
          onReply: () {
            setState(() => _reply = m);
            _focus.requestFocus();
          },
          onLongPress: (key) => _openMenu(m, key, receipt, first, last),
          onDoubleTap: () {
            if (m.reactions[_me] != '❤️') ref.read(messageRepositoryProvider).react(_chatId, m.id, '❤️');
          },
          onReact: (e) => ref.read(messageRepositoryProvider).react(_chatId, m.id, m.reactions[_me] == e ? null : e),
          onRetry: () => ref.read(outboxProvider).retry(m.id),
        );
        final showDay = older == null || !TimeFormat.sameDay(older.createdAt, m.createdAt);
        return showDay
            ? Column(
                children: [
                  DaySeparator(date: m.createdAt),
                  bubble,
                ],
              )
            : bubble;
      },
    );
    if (firstBuild) {
      for (final m in _messages) {
        _seen.add(m.id);
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.9, -1.1),
                  radius: 1.4,
                  colors: [
                    p.primary.withValues(alpha: p.isDark ? 0.10 : 0.07),
                    p.bg,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(child: list),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ChatHeader(
              chatId: _chatId,
              peerUid: peerUid,
              peer: peer,
              typing: typing,
              heroTag: widget.args?.heroTag ?? ChatTile.heroAvatar(_chatId),
              nameTag: ChatTile.heroName(_chatId),
            ),
          ),
          Positioned(
            right: 12,
            bottom: _inputHeight + 12,
            child: IgnorePointer(
              ignoring: !_showJump,
              child: AnimatedScale(
                scale: _showJump ? 1 : 0,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutBack,
                child: _JumpButton(onTap: _toBottom),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MeasureSize(
              onChange: (s) {
                if (mounted && (s.height - _inputHeight).abs() > 0.5) setState(() => _inputHeight = s.height);
              },
              child: InputBar(
                controller: _text,
                focusNode: _focus,
                onSend: _send,
                onAttach: _attachMedia,
                onVoice: _sendVoice,
                onChanged: _onChanged,
                reply: _reply,
                replyAuthor: _authorName(_reply?.senderId),
                editing: _editing,
                link: _link,
                onCancelReply: () => setState(() => _reply = null),
                onCancelEdit: () {
                  setState(() => _editing = null);
                  _text.clear();
                },
                onDismissLink: () => setState(() {
                  if (_linkUrl != null) _dismissedLinks.add(_linkUrl!);
                  _link = null;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JumpButton extends StatelessWidget {
  const _JumpButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Glass(
    pill: true,
    child: RotatedBox(
      quarterTurns: 2,
      child: GlassIconButton(icon: AppIcons.up, label: 'Latest', onPressed: onTap, size: 44),
    ),
  );
}
