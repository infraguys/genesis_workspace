import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/splash/view/splash_view.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return SplashView(
          onInitializationComplete: () {
            context.go(Routes.messenger);
            // if (state.isAuthorized) {
            //   context.go(Routes.messenger);
            // } else if (state.hasBaseUrl) {
            //   context.go(Routes.auth);
            // } else {
            //   context.go(Routes.pasteBaseUrl);
            // }
          },
        );
      },
    );
  }
}
