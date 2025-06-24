import 'package:flutter/material.dart';
import 'package:genesis_workspace/features/splash/view/splash_view.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashView(
      onInitializationComplete: () {
        context.go(Routes.auth);
      },
    );
  }
}
