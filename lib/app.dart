import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/all_chats/bloc/all_chats_cubit.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/call/bloc/call_cubit.dart';
import 'package:genesis_workspace/features/channel_chat/bloc/channel_chat_cubit.dart';
import 'package:genesis_workspace/features/chat/bloc/chat_cubit.dart';
import 'package:genesis_workspace/features/download_files/bloc/download_files_cubit.dart';
import 'package:genesis_workspace/features/drafts/bloc/drafts_cubit.dart';
import 'package:genesis_workspace/features/emoji_keyboard/bloc/emoji_keyboard_cubit.dart';
import 'package:genesis_workspace/features/logs/bloc/logs_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages/messages_cubit.dart';
import 'package:genesis_workspace/features/messages/bloc/messages_select/messages_select_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel/info_panel_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/mute/mute_cubit.dart';
import 'package:genesis_workspace/features/notifications/bloc/notifications_cubit.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/real_time/bloc/real_time_cubit.dart';
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart';
import 'package:genesis_workspace/features/theme/bloc/theme_cubit.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:genesis_workspace/core/config/theme.dart';

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
        BlocProvider(create: (_) => ThemeCubit(getIt<SharedPreferences>())),
        BlocProvider(create: (_) => getIt<DownloadFilesCubit>()),
        BlocProvider(create: (_) => getIt<CallCubit>()),
        BlocProvider(create: (context) => getIt<ChannelChatCubit>()),
        BlocProvider(create: (context) => getIt<ChatCubit>()),
        BlocProvider(create: (context) => getIt<NotificationsCubit>()),
        BlocProvider(create: (context) => getIt<InfoPanelCubit>()),
        BlocProvider(create: (context) => getIt<LogsCubit>()),
        BlocProvider(create: (context) => getIt<MessengerCubit>()),
        BlocProvider(create: (context) => getIt<DraftsCubit>()),
        BlocProvider(create: (_) => getIt<MuteCubit>()),
        BlocProvider(create: (_) => getIt<MessagesSelectCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            locale: TranslationProvider.of(context).flutterLocale,
            title: 'Workspace',
            routerConfig: router,
            theme: buildThemeForPalette(
              palette: state.selectedPalette,
              brightness: Brightness.light,
            ),
            darkTheme: buildThemeForPalette(
              palette: state.selectedPalette,
              brightness: Brightness.dark,
            ),
            themeMode: state.themeMode,
          );
        },
      ),
    );
  }
}
