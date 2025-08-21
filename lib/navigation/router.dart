import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/image_full_screen.dart';
import 'package:genesis_workspace/core/widgets/scaffold_with_nested_nav.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/authentication/presentation/view/paste_code_view.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/channels/channels.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/direct_messages/direct_messages.dart';
import 'package:genesis_workspace/features/feed/feed.dart';
import 'package:genesis_workspace/features/inbox/inbox.dart';
import 'package:genesis_workspace/features/mentions/mentions.dart';
import 'package:genesis_workspace/features/menu/menu.dart';
import 'package:genesis_workspace/features/reactions/reactions.dart';
import 'package:genesis_workspace/features/settings/settings.dart';
import 'package:genesis_workspace/features/splash/splash.dart';
import 'package:genesis_workspace/features/starred/starred.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/auth.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorDMKey = GlobalKey<NavigatorState>(debugLabel: 'shellDM');
final _shellNavigatorChannelsKey = GlobalKey<NavigatorState>(debugLabel: 'shellChannels');
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');
final _shellNavigatorMenuKey = GlobalKey<NavigatorState>(debugLabel: 'shellMenu');

class Routes {
  static const String splashScreen = '/';
  static const String auth = '/auth';
  static const String pasteToken = '/paste-token';
  static const String directMessages = '/direct-messages';
  static const String channels = '/channels';
  static const String settings = '/settings';
  static const String feed = '/feed';
  static const String chat = '/chat';
  static const String channelChat = '/channel-chat';
  static const String inbox = '/inbox';
  static const String mentions = '/mentions';
  static const String reactions = '/reactions';
  static const String starred = '/starred';
  static const String imageFullScreen = '/image-full-screen';
}

final router = GoRouter(
  initialLocation: Routes.splashScreen,
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      redirect: (BuildContext context, GoRouterState state) {
        if (!context.read<AuthCubit>().state.isAuthorized) {
          return Routes.auth;
        }
        return null;
      },
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDMKey,
          routes: [
            GoRoute(
              path: Routes.directMessages,
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const DirectMessages(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
                      child: child,
                    );
                  },
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorChannelsKey,
          routes: [GoRoute(path: Routes.channels, builder: (context, state) => const Channels())],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMenuKey,
          routes: [
            GoRoute(
              path: Routes.feed,
              builder: (context, state) => const Menu(),
              routes: [
                GoRoute(path: Routes.feed, name: Routes.feed, builder: (context, state) => Feed()),
                GoRoute(
                  path: Routes.inbox,
                  name: Routes.inbox,
                  builder: (context, state) => Inbox(),
                ),
                GoRoute(
                  path: Routes.mentions,
                  name: Routes.mentions,
                  builder: (context, state) => Mentions(),
                ),
                GoRoute(
                  path: Routes.reactions,
                  name: Routes.reactions,
                  builder: (context, state) => Reactions(),
                ),
                GoRoute(
                  path: Routes.starred,
                  name: Routes.starred,
                  builder: (context, state) => Starred(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [GoRoute(path: Routes.settings, builder: (context, state) => const Settings())],
        ),
      ],
    ),
    GoRoute(
      path: Routes.directMessages,
      name: Routes.directMessages,
      builder: (context, state) {
        final userId = int.tryParse(state.uri.queryParameters['userId'] ?? '');
        return DirectMessages(initialUserId: userId);
      },
      routes: [
        GoRoute(
          path: ':userId',
          name: Routes.chat,
          builder: (context, state) {
            final idStr = state.pathParameters['userId'];
            final id = int.tryParse(idStr ?? '');
            assert(id != null, 'userId must be int');
            return Chat(userId: id!);
          },
        ),
      ],
    ),
    GoRoute(
      path: Routes.channelChat,
      name: Routes.channelChat,
      builder: (context, state) => ChannelChat(extra: state.extra as ChannelChatExtra),
    ),
    GoRoute(
      path: Routes.splashScreen,
      name: Routes.splashScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const Splash(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: Routes.auth,
      name: Routes.auth,
      redirect: (BuildContext context, GoRouterState state) {
        if (context.read<AuthCubit>().state.isAuthorized) {
          return Routes.directMessages;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: Routes.pasteToken,
          name: Routes.pasteToken,
          builder: (context, state) => const PasteCodeView(),
        ),
      ],
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const Auth(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      // важна точная сигнатура пути, которую вы указали в deep link
      path: '/auth/callback',
      name: 'auth_callback',
      builder: (context, state) {
        // Разбор query через state.uri
        final uri = state.uri;
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];
        final stateParam = uri.queryParameters['state']; // если используете PKCE/state

        return Scaffold(body: Center(child: Text('$code, $error, $stateParam')));
      },
    ),
    GoRoute(
      path: Routes.imageFullScreen,
      name: Routes.imageFullScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: ImageFullScreen(imageBytes: state.extra as Uint8List),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
