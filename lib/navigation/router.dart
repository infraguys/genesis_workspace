import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/auth.dart';
import '../features/home/home.dart';

final router = GoRouter(
  initialLocation: Routes.auth,
  routes: [
    GoRoute(path: Routes.home, builder: (context, state) => const Home()),
    GoRoute(
      path: Routes.auth,
      redirect: (BuildContext context, GoRouterState state) {
        if (context.read<AuthCubit>().state.isAuthorized) {
          return Routes.home;
        }
      },
      builder: (context, state) => const Auth(),
    ),
  ],
);

class Routes {
  static const String auth = '/auth';
  static const String home = '/home';
}
