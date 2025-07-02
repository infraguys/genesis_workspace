import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/widgets/scaffold_with_nested_nav.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/chat/chat.dart';
import 'package:genesis_workspace/features/profile/profile.dart';
import 'package:genesis_workspace/features/settings/settings.dart';
import 'package:genesis_workspace/features/splash/splash.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/auth.dart';
import '../features/home/home.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

class Routes {
  static const String splashScreen = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String chat = '/chat';
}

final router = GoRouter(
  initialLocation: Routes.splashScreen,
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // the UI shell
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: Routes.home,
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const Home(),
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
          navigatorKey: _shellNavigatorProfileKey,
          routes: [GoRoute(path: Routes.profile, builder: (context, state) => const Profile())],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [GoRoute(path: Routes.settings, builder: (context, state) => const Settings())],
        ),
      ],
    ),
    GoRoute(
      path: Routes.chat,
      name: Routes.chat,
      builder: (context, state) => Chat(user: state.extra as UserEntity),
    ),
    GoRoute(
      path: Routes.splashScreen,
      name: Routes.splashScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const Splash(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Change the opacity of the screen using a Curve based on the the animation's
            // value
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
          return Routes.home;
        }
      },
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
  ],
);
