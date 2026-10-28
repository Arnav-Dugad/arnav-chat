import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/router.dart';
import '../../data/models/app_user.dart';
import '../../data/providers.dart';

part 'people_providers.g.dart';

@riverpod
Stream<List<AppUser>> contacts(Ref ref) => ref.watch(userRepositoryProvider).watchContacts();

@riverpod
Stream<bool> isContact(Ref ref, String uid) => ref.watch(userRepositoryProvider).watchIsContact(uid);

@riverpod
Future<AppUser?> profile(Ref ref, String uid) => ref.watch(userRepositoryProvider).get(uid, refresh: true);

/// Opens (creating locally if needed) the 1:1 chat with [user].
Future<void> openChatWith(BuildContext context, WidgetRef ref, AppUser user) async {
  final id = await ref.read(chatRepositoryProvider).ensureDirect(user.uid);
  if (context.mounted) context.push('/chat/$id', extra: ChatRouteArgs(peer: user));
}

/// QR payload format for adding a contact.
String qrPayloadFor(String username) => 'arnavchat://app/u/$username';

String? usernameFromQr(String raw) {
  // Accepts the v1.0 format (arnavchat://u/x) and the deep-link one (arnavchat://app/u/x).
  final m = RegExp(r'^arnavchat://(?:app/)?u/([a-z0-9_]{3,20})$').firstMatch(raw.trim());
  return m?.group(1);
}
