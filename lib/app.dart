import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/download_files/bloc/download_files_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_cubit.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';

import 'core/config/theme.dart';

class WorkspaceApp extends StatelessWidget {
  const WorkspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<UpdateCubit>()),
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkToken()),
        BlocProvider(create: (_) => getIt<RealTimeCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<MessagesCubit>()),
        BlocProvider(create: (_) => getIt<EmojiKeyboardCubit>()),
        BlocProvider(create: (_) => getIt<AllChatsCubit>()),
        BlocProvider(create: (_) => getIt<OrganizationsCubit>()),
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
        BlocProvider(create: (_) => getIt<DownloadFilesCubit>()),
        BlocProvider(create: (_) => getIt<CallCubit>()),
        BlocProvider(
          create: (context) => getIt<ChannelChatCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<ChatCubit>(),
        ),
      ],
      child: MaterialApp.router(
        locale: TranslationProvider.of(context).flutterLocale,
        title: 'Workspace',
        routerConfig: router,
        theme: darkTheme,
      ),
    );
  }
}
