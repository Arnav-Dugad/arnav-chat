import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../repositories/chat_repository.dart';

/// Group push delivery: one FCM topic per group (the Worker sends ONE request
/// per message instead of one per member).
class FcmTopics implements TopicSubscriber {
  const FcmTopics();

  @override
  Future<void> subscribe(String topic) async {
    // Retry once: the very first call can race FCM registration.
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        return;
      } catch (e) {
        debugPrint('topic subscribe failed: $e');
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
  }

  @override
  Future<void> unsubscribe(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    } catch (_) {}
  }
}
