import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/env.dart';
import '../../data/models/message_payload.dart';
import '../../data/repositories/chat_repository.dart' show mutedChatsPrefKey;
import '../../data/remote/firestore_refs.dart';
import '../../data/remote/message_writer.dart';
import '../../firebase_options.dart';

// Everything in this file must work in a background isolate (no Riverpod,
// no widgets): FCM data messages and notification actions arrive here while
// the app is killed.

const _channelId = 'messages';
const _groupKey = 'com.arnav.chat.MESSAGES';
const _summaryId = 0;
const actionReply = 'reply';
const actionRead = 'read';

final _plugin = FlutterLocalNotificationsPlugin();
bool _initialised = false;

/// Chat currently on screen — its messages are not shown as notifications.
String? activeChatId;

int notificationIdFor(String chatId) => chatId.hashCode & 0x7fffffff | 1;

Future<void> initLocalNotifications({DidReceiveNotificationResponseCallback? onResponse}) async {
  if (kIsWeb) return;
  if (_initialised && onResponse == null) return;
  await _plugin.initialize(
    settings: const InitializationSettings(android: AndroidInitializationSettings('ic_notification')),
    onDidReceiveNotificationResponse: onResponse,
    onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
  );
  await _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(_channelId, 'Messages', importance: Importance.high),
      );
  _initialised = true;
}

FlutterLocalNotificationsPlugin get notificationsPlugin => _plugin;

/// Shows (or appends to) a conversation-style notification for one chat, and
/// keeps a group summary so several chats collapse together.
/// SharedPreferences key holding my uid, so the background isolate can drop
/// the echo of my own group messages without waiting for auth.
const myUidPrefKey = 'myUid';

Future<void> showMessageNotification(Map<String, dynamic> data) async {
  final chatId = data['chatId'] as String?;
  if (chatId == null || chatId == activeChatId) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload(); // written by the main isolate
  final me = prefs.getString(myUidPrefKey);
  if (me != null && data['senderId'] == me) return;
  final mentioned = me != null && (data['mentions'] as String? ?? '').split(',').contains(me);
  final muted = prefs.getStringList(mutedChatsPrefKey)?.contains(chatId) ?? false;
  if (muted && !mentioned) return;
  await initLocalNotifications();
  final isGroup = data['chatType'] == 'group';
  final chatName = data['chatName'] as String?;
  final sender = (data['senderName'] as String?)?.trim().isNotEmpty == true
      ? data['senderName'] as String
      : 'New message';
  final text = data['preview'] as String? ?? '';
  final id = notificationIdFor(chatId);
  final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  final person = Person(name: sender, key: data['senderId'] as String?);
  final existing = await android?.getActiveNotificationMessagingStyle(id: id);
  final messages = <Message>[...?existing?.messages, Message(text, DateTime.now(), person)];
  final style = MessagingStyleInformation(
    const Person(name: 'You', key: 'me'),
    conversationTitle: isGroup ? chatName : null,
    groupConversation: isGroup,
    messages: messages.length > 8 ? messages.sublist(messages.length - 8) : messages,
  );

  await _plugin.show(
    id: id,
    title: isGroup ? (chatName ?? sender) : sender,
    body: text,
    payload: jsonEncode({'chatId': chatId}),
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Messages',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.message,
        styleInformation: style,
        groupKey: _groupKey,
        color: const Color(0xFF2350E6),
        icon: 'ic_notification',
        actions: const [
          AndroidNotificationAction(actionReply, 'Reply', inputs: [AndroidNotificationActionInput(label: 'Message')]),
          AndroidNotificationAction(actionRead, 'Mark read', cancelNotification: true),
        ],
      ),
    ),
  );

  await _plugin.show(
    id: _summaryId,
    title: 'Arnav Chat',
    body: 'New messages',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Messages',
        groupKey: _groupKey,
        setAsGroupSummary: true,
        icon: 'ic_notification',
        color: Color(0xFF2350E6),
        styleInformation: InboxStyleInformation([], summaryText: 'New messages'),
      ),
    ),
  );
}

Future<void> cancelChatNotification(String chatId) async {
  if (kIsWeb) return;
  await _plugin.cancel(id: notificationIdFor(chatId));
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (message.data['type'] == 'message') await showMessageNotification(message.data);
}

/// Handles "Reply" / "Mark read" from the notification shade, even when the
/// app process was killed.
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(NotificationResponse response) async {
  try {
    await handleNotificationAction(response);
  } catch (e, s) {
    debugPrint('notification action failed: $e\n$s');
  }
}

Future<bool> handleNotificationAction(NotificationResponse response) async {
  final payload = response.payload == null ? null : jsonDecode(response.payload!) as Map<String, dynamic>;
  final chatId = payload?['chatId'] as String?;
  if (chatId == null) return false;
  if (response.actionId != actionReply && response.actionId != actionRead) return false;

  if (Firebase.apps.isEmpty) await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // In a fresh background isolate the persisted session is restored
  // asynchronously, so currentUser is briefly null.
  final user =
      FirebaseAuth.instance.currentUser ??
      await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((u) => u != null)
          .timeout(const Duration(seconds: 10), onTimeout: () => null);
  final uid = user?.uid;
  if (uid == null) {
    debugPrint('notification action: no signed-in user');
    return true;
  }
  final refs = FirestoreRefs(FirebaseFirestore.instance);

  if (response.actionId == actionRead) {
    final d = (await refs.chat(chatId).get()).data();
    await refs.chat(chatId).update({
      if (d?['type'] == 'group') 'readSeq.$uid': (d?['seq'] as num?)?.toInt() ?? 0 else 'unread.$uid': 0,
      'readUpTo.$uid': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await cancelChatNotification(chatId);
    return true;
  }

  final text = response.input?.trim() ?? '';
  if (text.isEmpty) return true;
  final writer = MessageWriter(refs);
  final chat = await refs.chat(chatId).get();
  final members = List<String>.from(chat.data()?['members'] as List? ?? [uid]);
  final group = chat.data()?['type'] == 'group';
  final myName = ((await refs.user(uid).get()).data()?['displayName'] as String?) ?? 'Someone';
  final id = writer.newId(chatId);
  final payloadText = MessagePayload.text(text);
  await writer.send(
    chatId: chatId,
    messageId: id,
    senderId: uid,
    members: members,
    payload: payloadText,
    clientTs: DateTime.now().millisecondsSinceEpoch,
    group: group,
    senderName: myName,
  );
  if (!group) await refs.chat(chatId).update({'unread.$uid': 0, 'updatedAt': FieldValue.serverTimestamp()});
  await cancelChatNotification(chatId);
  if (Env.hasWorker) {
    try {
      final token = await FirebaseAuth.instance.currentUser!.getIdToken();
      await Dio(BaseOptions(baseUrl: Env.workerUrl)).post<void>(
        '/v1/notify',
        data: {'chatId': chatId, 'messageId': id, 'preview': payloadText.preview, 'kind': 'text'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {}
  }
  return true;
}
