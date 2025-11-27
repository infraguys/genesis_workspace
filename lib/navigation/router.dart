import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/widgets/image_full_screen.dart';
import 'package:genesis_workspace/core/widgets/in_development_widget.dart';
import 'package:genesis_workspace/core/widgets/scaffold_with_nested_nav.dart';
import 'package:genesis_workspace/features/authentication/presentation/auth.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/authentication/presentation/view/paste_code_view.dart';
import 'package:genesis_workspace/features/call/view/call_web_view_page.dart';
import 'package:genesis_workspace/features/channel_chat/channel_chat.dart';
import 'package:genesis_workspace/features/channels/channels.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/feed/feed.dart';
import 'package:genesis_workspace/features/inbox/inbox.dart';
import 'package:genesis_workspace/features/mentions/mentions.dart';
import 'package:genesis_workspace/features/messenger/messenger.dart';
import 'package:genesis_workspace/features/paste_base_url/paste_base_url.dart';
import 'package:genesis_workspace/features/reactions/reactions.dart';
import 'package:genesis_workspace/features/settings/settings.dart';
import 'package:genesis_workspace/features/splash/splash.dart';
import 'package:genesis_workspace/features/starred/starred.dart';
import 'package:genesis_workspace/features/update/update.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorChannelsKey = GlobalKey<NavigatorState>(debugLabel: 'shellChannels');
final _shellNavigationInDevelopment = GlobalKey<NavigatorState>(debugLabel: 'shellInDevelopment');
final _shellNavigatorMessengerKey = GlobalKey<NavigatorState>(debugLabel: 'shellMessenger');
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');
final _shellNavigatorMenuKey = GlobalKey<NavigatorState>(debugLabel: 'shellMenu');

class Routes {
  static const String splashScreen = '/';
  static const String auth = '/auth';
  static const String pasteToken = '/paste-token';
  static const String allChats = '/all-chats';
  static const String directMessages = '/direct-messages';
  static const String groupChat = '/group-chat';
  static const String channels = '/channels';
  static const String settings = '/settings';
  static const String feed = '/feed';
  static const String chat = '/chat';
  static const String channelChat = '/channel-chat';
  static const String channelChatTopic = '/channel-chat/topic';
  static const String inbox = '/inbox';
  static const String mentions = '/mentions';
  static const String reactions = '/reactions';
  static const String starred = '/starred';
  static const String imageFullScreen = '/image-full-screen';
  static const String pasteBaseUrl = '/paste-base-url';
  static const String forceUpdate = '/force-update';
  static const String messenger = '/messenger';
  static const String notifications = '/notifications';
  static const String call = '/call';
}

final router = GoRouter(
  initialLocation: Routes.splashScreen,
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigationInDevelopment,
          routes: [
            GoRoute(
              path: Routes.notifications,
              name: Routes.notifications,
              builder: (context, state) {
                return InDevelopmentWidget();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMessengerKey,
          routes: [
            GoRoute(
              path: Routes.messenger,
              name: Routes.messenger,
              redirect: (BuildContext context, GoRouterState state) {
                // if (!context.read<AuthCubit>().state.isAuthorized) {
                //   return Routes.auth;
                // }
                return null;
              },
              builder: (context, state) {
                return Messenger();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: shellNavigatorChannelsKey,
          routes: [
            GoRoute(
              path: Routes.channels,
              name: Routes.channels,
              // pageBuilder: (context, state) => const NoTransitionPage(child: Channels()),
              pageBuilder: (context, state) => const NoTransitionPage(child: InDevelopmentWidget()),
            ),
            if (kIsWeb) ...[
              GoRoute(
                path: '${Routes.channels}/:channelId',
                name: 'allChatsChannelChat',
                pageBuilder: (context, state) {
                  final channelIdString = state.pathParameters['channelId'];
                  final channelId = int.tryParse(channelIdString ?? '');
                  assert(channelId != null, 'channelId must be int');

                  final extra = state.extra as Map<String, dynamic>?;
                  final unreadMessagesCount = extra?['unreadMessagesCount'] ?? 0;

                  if (currentSize(context) > ScreenSize.lTablet) {
                    return NoTransitionPage(
                      child: Channels(initialChannelId: channelId, initialTopicName: null),
                    );
                  } else {
                    return NoTransitionPage(
                      child: ChannelChat(
                        channelId: channelId!,
                        unreadMessagesCount: unreadMessagesCount,
                      ),
                    );
                  }
                },
              ),
              GoRoute(
                path: '${Routes.channels}/:channelId/:topicName',
                name: 'allChatsChannelChatTopic',
                pageBuilder: (context, state) {
                  final channelIdString = state.pathParameters['channelId'];
                  final topicName = state.pathParameters['topicName'];
                  final channelId = int.tryParse(channelIdString ?? '');
                  assert(channelId != null, 'channelId must be int');

                  final extra = state.extra as Map<String, dynamic>?;
                  final unreadMessagesCount = extra?['unreadMessagesCount'] ?? 0;

                  if (currentSize(context) > ScreenSize.lTablet) {
                    return NoTransitionPage(
                      child: Channels(initialChannelId: channelId, initialTopicName: topicName),
                    );
                  } else {
                    return NoTransitionPage(
                      child: ChannelChat(
                        channelId: channelId!,
                        topicName: topicName,
                        unreadMessagesCount: unreadMessagesCount,
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMenuKey,
          routes: [
            GoRoute(
              path: Routes.feed,
              builder: (context, state) => const InDevelopmentWidget(),
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
    if (!kIsWeb) ...[
      GoRoute(
        path: '${Routes.directMessages}/:userId',
        name: Routes.chat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final userId = int.parse(state.pathParameters['userId']!);
          final extra = state.extra as Map<String, dynamic>?;
          final unread = extra?['unreadMessagesCount'] ?? 0;

          if (currentSize(context) > ScreenSize.lTablet) {
            // На десктопе в идеале сюда не приходим, но на всякий случай
            return SizedBox.shrink();
          } else {
            return Chat(userIds: [userId], unreadMessagesCount: unread);
          }
        },
      ),
      GoRoute(
        path: '${Routes.groupChat}/:userIds',
        name: Routes.groupChat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final List<int> userIds = state.pathParameters['userIds']?.split(',').map(int.parse).toList() ?? [];
          final extra = state.extra as Map<String, dynamic>?;
          final unread = extra?['unreadMessagesCount'] ?? 0;

          if (currentSize(context) > ScreenSize.lTablet) {
            return SizedBox.shrink();
          } else {
            return Chat(userIds: userIds, unreadMessagesCount: unread);
          }
        },
      ),
      GoRoute(
        path: '${Routes.channels}/:channelId',
        name: Routes.channelChat,
        pageBuilder: (context, state) {
          final channelIdString = state.pathParameters['channelId'];
          final channelId = int.tryParse(channelIdString ?? '');
          assert(channelId != null, 'channelId must be int');

          final extra = state.extra as Map<String, dynamic>?;
          final unreadMessagesCount = extra?['unreadMessagesCount'] ?? 0;

          if (currentSize(context) > ScreenSize.lTablet) {
            return NoTransitionPage(
              child: Channels(initialChannelId: channelId, initialTopicName: null),
            );
          } else {
            return NoTransitionPage(
              child: ChannelChat(channelId: channelId!, unreadMessagesCount: unreadMessagesCount),
            );
          }
        },
      ),
      GoRoute(
        path: '${Routes.channels}/:channelId/:topicName',
        name: Routes.channelChatTopic,
        builder: (context, state) {
          final channelIdString = state.pathParameters['channelId'];
          final topicName = state.pathParameters['topicName'];
          final channelId = int.tryParse(channelIdString ?? '');
          assert(channelId != null, 'channelId must be int');

          final extra = state.extra as Map<String, dynamic>?;
          final unreadMessagesCount = extra?['unreadMessagesCount'] ?? 0;

          if (currentSize(context) > ScreenSize.lTablet) {
            return Channels(initialChannelId: channelId, initialTopicName: topicName);
          } else {
            return ChannelChat(
              channelId: channelId!,
              topicName: topicName,
              unreadMessagesCount: unreadMessagesCount,
            );
          }
        },
      ),
    ],
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
      path: Routes.pasteBaseUrl,
      name: Routes.pasteBaseUrl,
      builder: (context, state) {
        return PasteBaseUrl();
      },
    ),
    GoRoute(
      path: Routes.auth,
      name: Routes.auth,
      redirect: (BuildContext context, GoRouterState state) {
        if (context.read<AuthCubit>().state.isAuthorized) {
          return Routes.messenger;
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
    GoRoute(
      path: Routes.call,
      name: Routes.call,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final meetingLink = state.extra as String?;
        assert(meetingLink != null && meetingLink!.isNotEmpty, 'meeting link required');

        return CallWebViewPage(meetingLink: meetingLink!);
      },
    ),
    GoRoute(
      path: Routes.forceUpdate,
      name: Routes.forceUpdate,
      builder: (context, state) => const UpdateForce(),
    ),
  ],
);
