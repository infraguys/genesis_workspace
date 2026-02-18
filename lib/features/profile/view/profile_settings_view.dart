import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/config/screen_size.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/widgets/tap_effect_icon.dart';
import 'package:genesis_workspace/core/widgets/user_avatar.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingsView extends StatelessWidget {
  const ProfileSettingsView({
    required this.onClosePanel,
    required this.onOpenPersonalInfo,
    required this.onOpenVersionChoose,
    required this.showSoundSettings,
    required this.selectedSound,
    required this.onSoundChanged,
    required this.onPlaySound,
    required this.onOpenChatSorting,
  });

  final VoidCallback onClosePanel;
  final VoidCallback onOpenPersonalInfo;
  final VoidCallback onOpenVersionChoose;
  final bool showSoundSettings;
  final String selectedSound;
  final ValueChanged<String> onSoundChanged;
  final VoidCallback onPlaySound;
  final Future<void> Function() onOpenChatSorting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationService = getIt<LocalizationService>();
    final textColors = theme.extension<TextColors>()!;
    final iconColors = theme.extension<IconColors>()!;
    final cardColors = theme.extension<CardColors>()!;
    final isMobile = currentSize(context) <= .tablet;

    return Scaffold(
      backgroundColor: isMobile ? theme.scaffoldBackgroundColor : theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: isMobile,
        backgroundColor: isMobile ? theme.scaffoldBackgroundColor : theme.colorScheme.surface,
        title: Text(
          context.t.profile,
          style: theme.textTheme.labelLarge,
        ),
        actions: [
          if (!isMobile)
            IconButton(
              onPressed: onClosePanel,
              icon: Assets.icons.close.svg(),
            ),
        ],
      ),
      body: ListView(
        padding: .zero,
        children: [
          Column(
            children: [
              if (isMobile) ...[
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    return Padding(
                      padding: .symmetric(horizontal: 20),
                      child: Row(
                        spacing: 16,
                        children: [
                          UserAvatar(
                            avatarUrl: state.user?.avatarUrl ?? '',
                            size: 64,
                          ),
                          Text(
                            state.user?.fullName ?? '',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: .w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 12,
                ),
              ],
              ListTile(
                leading: Assets.icons.accountCircle.svg(
                  colorFilter: ColorFilter.mode(
                    iconColors.base,
                    BlendMode.srcIn,
                  ),
                ),
                title: Text(
                  context.t.profilePersonalInfo.title,
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: isMobile
                    ? Assets.icons.arrowRight.svg(
                        colorFilter: ColorFilter.mode(
                          iconColors.base,
                          BlendMode.srcIn,
                        ),
                      )
                    : null,
                onTap: () {
                  if (isMobile) {
                    context.pushNamed(Routes.profileInfo);
                  } else {
                    onOpenPersonalInfo();
                  }
                },
              ),
              BlocBuilder<UpdateCubit, UpdateState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      ListTile(
                        leading: Assets.icons.info.svg(
                          colorFilter: ColorFilter.mode(
                            iconColors.base,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: Text(
                          context.t.settings.appVersion,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          state.currentVersion,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColors.text30,
                          ),
                        ),
                      ),
                      if (state.isNewUpdateAvailable) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadiusGeometry.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                Text(
                                  context.t.updateView.newVersionAvailable,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  context.t.updateView.downloadNewVersionRn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: textColors.text30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: InkWell(
                  onTap: () {
                    if (isMobile) {
                      context.pushNamed(Routes.forceUpdate);
                    } else {
                      onOpenVersionChoose();
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cardColors.base,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.t.updateView.browseBuilds,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.t.updateView.browseBuildsSubtitle,
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: textColors.text30,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Assets.icons.arrowRight.svg(
                            colorFilter: ColorFilter.mode(
                              iconColors.base,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showSoundSettings)
            ListTile(
              leading: TapEffectIcon(
                onTap: onPlaySound,
                padding: .zero,
                child: Assets.icons.volumeUp.svg(
                  colorFilter: ColorFilter.mode(
                    iconColors.base,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              title: Text(
                context.t.settings.notificationSound,
                style: theme.textTheme.bodyMedium,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedSound,
                    underline: const SizedBox.shrink(),
                    onChanged: (value) {
                      if (value != null) {
                        onSoundChanged(value);
                      }
                    },
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: iconColors.base,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColors.text30,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: AssetsConstants.audioPop,
                        child: Text(context.t.profileView.notificationSoundPop),
                      ),
                      DropdownMenuItem(
                        value: AssetsConstants.audioWhoop,
                        child: Text(context.t.profileView.notificationSoundWhoop),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ListTile(
            leading: Assets.icons.language.svg(
              colorFilter: ColorFilter.mode(
                iconColors.base,
                BlendMode.srcIn,
              ),
            ),
            title: Text(
              context.t.settings.language,
              style: theme.textTheme.bodyMedium,
            ),
            trailing: DropdownButton<Locale>(
              value: localizationService.locale.flutterLocale,
              underline: const SizedBox.shrink(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: iconColors.base,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColors.text30,
              ),
              onChanged: (locale) {
                if (locale != null) {
                  localizationService.setLocale(
                    AppLocale.values.firstWhere((l) => l.languageCode == locale.languageCode),
                  );
                }
              },
              items: [
                DropdownMenuItem(value: const Locale('en'), child: Text(context.t.profileView.languageEnglish)),
                DropdownMenuItem(value: const Locale('ru'), child: Text(context.t.profileView.languageRussian)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.palette_outlined,
              color: iconColors.base,
            ),
            title: Text(
              context.t.settings.themeSettings,
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () => context.pushNamed(Routes.themeSettings),
          ),
          ListTile(
            leading: Icon(
              Icons.sort,
              color: iconColors.base,
            ),
            title: Text(
              context.t.settings.chatSortingAction,
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Text(
              context.t.settings.chatSortingDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColors.text30,
                fontSize: 12,
              ),
            ),
            onTap: onOpenChatSorting,
          ),
          ListTile(
            leading: Icon(Icons.featured_play_list),
            title: Text(
              "Logs",
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () => context.pushNamed(Routes.talkerScreen),
          ),
          ListTile(
            leading: Assets.icons.logout.svg(
              colorFilter: ColorFilter.mode(
                AppColors.noticeBase,
                BlendMode.srcIn,
              ),
            ),
            title: Text(
              context.t.settings.logout,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.noticeBase,
              ),
            ),
            onTap: () async {
              await context.read<AuthCubit>().logout();
            },
          ),
          if (kDebugMode) ...[
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text(context.t.profileView.clearDb),
              onTap: () {
                context.read<SettingsCubit>().clearLocalDatabase();
              },
            ),
            ListTile(
              leading: Assets.icons.logout.svg(),
              title: Text(context.t.profileView.devLogout),
              onTap: () async {
                await context.read<AuthCubit>().devLogout();
                // context.go(Routes.auth);
              },
            ),
          ],
        ],
      ),
    );
  }
}
