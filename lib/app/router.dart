import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/app_user.dart';
import '../data/providers.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/chats/chat_list_screen.dart';
import '../features/home/home_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/people/find_people_screen.dart';
import '../features/people/people_screen.dart';
import '../features/people/profile_screen.dart';
import '../features/people/qr_screen.dart';
import '../features/settings/appearance_screen.dart';
import '../features/settings/edit_profile_screen.dart';
import '../features/settings/privacy_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/starred_screen.dart';

part 'router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Arguments that let the chat screen render (and run hero animations)
/// before anything is loaded.
class ChatRouteArgs {
  const ChatRouteArgs({this.peer, this.heroTag});
  final AppUser? peer;
  final Object? heroTag;
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final session = ValueNotifier<Session>(const SessionLoading());
  ref.listen(sessionProvider, (_, next) => session.value = next.value ?? const SessionLoading(), fireImmediately: true);
  ref.onDispose(session.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/boot',
    refreshListenable: session,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      return switch (session.value) {
        SessionLoading() => null,
        SessionSignedOut() => loc == '/signin' ? null : '/signin',
        SessionNeedsProfile() => loc == '/onboarding' ? null : '/onboarding',
        SessionReady() => (loc == '/boot' || loc == '/signin' || loc == '/onboarding') ? '/chats' : null,
      };
    },
    routes: [
      GoRoute(path: '/boot', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(
        path: '/signin',
        pageBuilder: (_, _) => const NoTransitionPage(child: SignInScreen()),
      ),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, shell) => NoTransitionPage(child: HomeShell(shell: shell)),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/chats', builder: (_, _) => const ChatListScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/people', builder: (_, _) => const PeopleScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (_, s) => ChatScreen(chatId: s.pathParameters['id']!, args: s.extra as ChatRouteArgs?),
      ),
      GoRoute(
        path: '/user/:uid',
        builder: (_, s) => ProfileScreen(uid: s.pathParameters['uid']!),
      ),
      GoRoute(path: '/find', builder: (_, _) => const FindPeopleScreen()),
      GoRoute(path: '/qr', builder: (_, _) => const QrScreen()),
      GoRoute(path: '/settings/profile', builder: (_, _) => const EditProfileScreen()),
      GoRoute(path: '/settings/privacy', builder: (_, _) => const PrivacyScreen()),
      GoRoute(path: '/settings/appearance', builder: (_, _) => const AppearanceScreen()),
      GoRoute(path: '/settings/starred', builder: (_, _) => const StarredScreen()),
    ],
  );
}
