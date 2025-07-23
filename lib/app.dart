import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';

import 'core/config/theme.dart';

class WorkspaceApp extends StatelessWidget {
  const WorkspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkToken()),
        BlocProvider(create: (_) => getIt<RealTimeCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
      ],
      child: MaterialApp.router(
        locale: TranslationProvider.of(context).flutterLocale,
        title: 'Workspace',
        routerConfig: router,
        theme: theme,
      ),
    );
  }
}
