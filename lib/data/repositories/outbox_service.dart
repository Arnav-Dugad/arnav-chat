import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/message_payload.dart';
import '../remote/media_uploader.dart';
import '../remote/message_writer.dart';
import '../remote/worker_api.dart';
import 'chat_repository.dart';
import 'message_repository.dart';

/// Optimistic sending with a durable retry queue.
///
/// A message is written to Drift first (shows instantly with a clock icon),
/// then media is uploaded and the Firestore batch is committed. Anything that
/// fails for network reasons stays queued and is retried when connectivity
/// returns or the app restarts.
class OutboxService {
  OutboxService(this._messages, this._chats, this._writer, this._uploader, this._worker, this._uid, this._myName);

  final MessageRepository _messages;
  final ChatRepository _chats;
  final MessageWriter _writer;
  final MediaUploader _uploader;
  final WorkerApi _worker;
  final String _uid;
  final String Function() _myName;

  final _progress = <String, ValueNotifier<double>>{};
  bool _running = false;
  bool _rerun = false;
  Timer? _retry;
  int _backoff = 0;

  ValueListenable<double>? progressOf(String messageId) => _progress[messageId];

  Future<String> send({
    required String chatId,
    required MessagePayload payload,
    ReplyRef? reply,
    bool forwarded = false,
    String? localPath,
  }) async {
    final id = _writer.newId(chatId);
    final now = DateTime.now().millisecondsSinceEpoch;
    await _messages.insertPending(
      id: id,
      chatId: chatId,
      payload: payload,
      createdAt: now,
      reply: reply,
      forwarded: forwarded,
      localPath: localPath,
    );
    await _chats.setLocalLast(
      chatId,
      LastMessage(
        id: id,
        senderId: _uid,
        kind: payload.kind,
        preview: payload.preview,
        at: DateTime.fromMillisecondsSinceEpoch(now),
      ),
    );
    unawaited(kick());
    return id;
  }

  /// Process the queue now (called on send, on reconnect and on app start).
  Future<void> kick() async {
    if (_running) {
      _rerun = true;
      return;
    }
    _running = true;
    try {
      do {
        _rerun = false;
        final pending = await _messages.pendingOutbox();
        for (final row in pending) {
          final ok = await _deliver(row);
          if (!ok) {
            _scheduleRetry();
            break; // keep order: don't send later messages before earlier ones
          }
        }
      } while (_rerun);
    } finally {
      _running = false;
    }
  }

  void _scheduleRetry() {
    _retry?.cancel();
    final secs = [3, 8, 20, 45, 90][_backoff.clamp(0, 4)];
    _backoff++;
    _retry = Timer(Duration(seconds: secs), kick);
  }

  Future<bool> _deliver(MessageRow row) async {
    final chat = await _chats.chatRow(row.chatId);
    if (chat == null) return true;
    final members = List<String>.from(jsonDecode(chat.membersJson) as List);
    var payload = _messages.codec.decode(jsonDecode(row.payloadJson) as Map<String, dynamic>);

    try {
      // A previous attempt may have reached the server while we were offline.
      if (row.attempts > 0 && await _writer.existsOnServer(row.chatId, row.id)) {
        await _messages.setSendState(row.id, SendState.sent);
        return true;
      }

      if (payload.media != null && payload.media!.url.isEmpty && row.localPath != null) {
        final notifier = _progress.putIfAbsent(row.id, () => ValueNotifier(0));
        final kind = payload.kind == MessageKind.file ? 'file' : payload.kind.name;
        final media = await _uploader.upload(
          path: row.localPath!,
          kind: kind,
          draft: payload.media!,
          onProgress: (p) => notifier.value = p,
        );
        payload = payload.copyWith(media: media);
        await _messages.setPayload(row.id, payload);
      }

      await _messages.setSendState(row.id, SendState.pending, bumpAttempts: true);
      final reply = row.replyJson == null ? null : ReplyRef.fromMap(jsonDecode(row.replyJson!) as Map<String, dynamic>);
      final commit = _writer.send(
        chatId: row.chatId,
        messageId: row.id,
        senderId: _uid,
        members: members,
        payload: payload,
        clientTs: row.createdAt,
        reply: reply,
        forwarded: row.forwarded,
        group: chat.type == 'group',
        senderName: _myName(),
      );
      try {
        await commit.timeout(const Duration(seconds: 12));
      } on TimeoutException {
        // Offline: Firestore keeps the write queued; finish when it lands.
        unawaited(commit.then((_) => _onSent(row.id, row.chatId, payload)).catchError((_) {}));
        return false;
      }
      await _onSent(row.id, row.chatId, payload);
      _backoff = 0;
      return true;
    } on WorkerUnavailable {
      await _messages.setSendState(row.id, SendState.failed);
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || e.code == 'invalid-argument') {
        await _messages.setSendState(row.id, SendState.failed);
        return true;
      }
      return false;
    } on DioException {
      return false;
    } catch (e) {
      // Not a network problem (e.g. a malformed write). Retry a few times,
      // then fail the message so it cannot block everything queued after it.
      debugPrint('outbox: $e');
      if (row.attempts >= 3) {
        await _messages.setSendState(row.id, SendState.failed);
        return true;
      }
      return false;
    }
  }

  Future<void> _onSent(String id, String chatId, MessagePayload payload) async {
    await _messages.setSendState(id, SendState.sent);
    _progress.remove(id)?.dispose();
    // Push notification via the Worker. Best effort; never blocks sending.
    unawaited(
      _worker
          .notify(chatId: chatId, messageId: id, preview: payload.preview, kind: payload.kind.name, mentions: payload.mentions)
          .catchError((_) {}),
    );
  }

  /// Retry a message the user tapped (failed state).
  Future<void> retry(String id) async {
    await _messages.setSendState(id, SendState.pending);
    _backoff = 0;
    await kick();
  }

  void dispose() {
    _retry?.cancel();
    for (final n in _progress.values) {
      n.dispose();
    }
  }
}
