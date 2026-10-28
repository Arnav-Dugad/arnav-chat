import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/repositories/user_repository.dart';
import 'push_handlers.dart';

/// Registers this device for FCM and routes notification taps.
class PushService {
  PushService(this._users, {required this.onOpenChat});

  final UserRepository _users;
  final void Function(String chatId) onOpenChat;
  final _subs = <StreamSubscription<Object?>>[];
  String? _token;

  Future<void> start() async {
    if (kIsWeb) return;
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    await initLocalNotifications(onResponse: _onResponse);

    // Registration tokens are the documented FCM HTTP v1 target the Worker uses;
    // the newer FID registration API is not needed yet.
    // ignore: deprecated_member_use
    _token = await messaging.getToken();
    if (_token != null) await _users.addFcmToken(_token!);
    // ignore: deprecated_member_use
    _subs.add(messaging.onTokenRefresh.listen((t) {
      _token = t;
      _users.addFcmToken(t);
    }));

    _subs.add(FirebaseMessaging.onMessage.listen((m) {
      if (m.data['type'] == 'message') showMessageNotification(m.data);
    }));

    final launch = await notificationsPlugin.getNotificationAppLaunchDetails();
    final r = launch?.notificationResponse;
    if ((launch?.didNotificationLaunchApp ?? false) && r != null) _onResponse(r);
  }

  void _onResponse(NotificationResponse r) {
    if (r.actionId == actionReply || r.actionId == actionRead) {
      handleNotificationAction(r);
      return;
    }
    final payload = r.payload == null ? null : jsonDecode(r.payload!) as Map<String, dynamic>;
    final chatId = payload?['chatId'] as String?;
    if (chatId != null) onOpenChat(chatId);
  }

  /// Called on sign-out so this device stops receiving the old account's pushes.
  Future<void> unregister() async {
    if (_token != null) {
      try {
        await _users.removeFcmToken(_token!);
      } catch (_) {}
    }
    // ignore: deprecated_member_use
    await FirebaseMessaging.instance.deleteToken();
  }

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
  }
}
