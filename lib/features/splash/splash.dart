import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/features/splash/view/splash_view.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:go_router/go_router.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizationsCubit, OrganizationsState>(
      builder: (context, state) {
        return SplashView(
          onInitializationComplete: () {
            if (state.organizations.isEmpty) {
              context.go(Routes.pasteBaseUrl);
            } else {
              context.go(Routes.messenger);
            }
          },
        );
      },
    );
  }
}
