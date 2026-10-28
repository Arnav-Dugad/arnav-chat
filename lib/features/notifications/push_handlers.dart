import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/config/env.dart';
import '../../data/models/message_payload.dart';
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
      ?.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        'Messages',
        importance: Importance.high,
      ));
  _initialised = true;
}

FlutterLocalNotificationsPlugin get notificationsPlugin => _plugin;

/// Shows (or appends to) a conversation-style notification for one chat, and
/// keeps a group summary so several chats collapse together.
Future<void> showMessageNotification(Map<String, dynamic> data) async {
  final chatId = data['chatId'] as String?;
  if (chatId == null || chatId == activeChatId) return;
  await initLocalNotifications();
  final sender = (data['senderName'] as String?)?.trim().isNotEmpty == true ? data['senderName'] as String : 'New message';
  final text = data['preview'] as String? ?? '';
  final id = notificationIdFor(chatId);
  final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  final person = Person(name: sender, key: data['senderId'] as String?);
  final existing = await android?.getActiveNotificationMessagingStyle(id: id);
  final messages = <Message>[...?existing?.messages, Message(text, DateTime.now(), person)];
  final style = MessagingStyleInformation(
    const Person(name: 'You', key: 'me'),
    messages: messages.length > 8 ? messages.sublist(messages.length - 8) : messages,
  );

  await _plugin.show(
    id: id,
    title: sender,
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
          AndroidNotificationAction(
            actionReply,
            'Reply',
            inputs: [AndroidNotificationActionInput(label: 'Message')],
          ),
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
  await handleNotificationAction(response);
}

Future<bool> handleNotificationAction(NotificationResponse response) async {
  final payload = response.payload == null ? null : jsonDecode(response.payload!) as Map<String, dynamic>;
  final chatId = payload?['chatId'] as String?;
  if (chatId == null) return false;
  if (response.actionId != actionReply && response.actionId != actionRead) return false;

  if (Firebase.apps.isEmpty) await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return true;
  final refs = FirestoreRefs(FirebaseFirestore.instance);

  if (response.actionId == actionRead) {
    await refs.chat(chatId).update({
      'unread.$uid': 0,
      'readUpTo.$uid': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  final text = response.input?.trim() ?? '';
  if (text.isEmpty) return true;
  final writer = MessageWriter(refs);
  final chat = await refs.chat(chatId).get();
  final members = List<String>.from(chat.data()?['members'] as List? ?? [uid]);
  final id = writer.newId(chatId);
  final payloadText = MessagePayload.text(text);
  await writer.send(
    chatId: chatId,
    messageId: id,
    senderId: uid,
    members: members,
    payload: payloadText,
    clientTs: DateTime.now().millisecondsSinceEpoch,
  );
  await refs.chat(chatId).update({'unread.$uid': 0, 'updatedAt': FieldValue.serverTimestamp()});
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
