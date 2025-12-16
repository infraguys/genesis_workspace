import 'package:audioplayers/audioplayers.dart';
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
import 'package:genesis_workspace/features/messenger/bloc/info_panel_cubit.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/features/profile/view/profile_personal_info_page.dart';
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/features/update/update.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  static const String _personalInfoRoute = '/personal-info';
  static const String _versionChooseRoute = '/version-choose';
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String _selectedSound = AssetsConstants.audioPop;
  SharedPreferences? _prefs;
  late final AudioPlayer _player;
  bool _prioritizePersonalUnread = false;
  bool _prioritizeUnmutedUnreadChannels = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadPrefs();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(SharedPrefsKeys.notificationSound);
    final settings = context.read<SettingsCubit>().state;
    setState(() {
      _prefs = prefs;
      _selectedSound = saved ?? AssetsConstants.audioPop;
      _prioritizePersonalUnread = settings.prioritizePersonalUnread;
      _prioritizeUnmutedUnreadChannels = settings.prioritizeUnmutedUnreadChannels;
    });
  }

  Future<void> _playSelected() async {
    try {
      await _player.stop();
      await _player.play(AssetSource(_selectedSound));
    } catch (_) {}
  }

  Future<void> _openChatSortingDialog() async {
    bool prioritizePersonalUnread = _prioritizePersonalUnread;
    bool prioritizeUnmutedUnreadChannels = _prioritizeUnmutedUnreadChannels;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(context.t.settings.chatSortingTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    value: prioritizePersonalUnread,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(context.t.settings.chatSortingPrioritizeDirects),
                    onChanged: (value) {
                      setState(() => prioritizePersonalUnread = value ?? false);
                    },
                  ),
                  CheckboxListTile(
                    value: prioritizeUnmutedUnreadChannels,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(context.t.settings.chatSortingPrioritizeUnmuted),
                    onChanged: (value) {
                      setState(() => prioritizeUnmutedUnreadChannels = value ?? false);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(context.t.folders.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await dialogContext.read<SettingsCubit>().saveChatSortingSettings(
                      prioritizePersonalUnread: prioritizePersonalUnread,
                      prioritizeUnmutedUnreadChannels: prioritizeUnmutedUnreadChannels,
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop(true);
                    }
                  },
                  child: Text(context.t.folders.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (mounted && (saved ?? false)) {
      final state = context.read<SettingsCubit>().state;
      setState(() {
        _prioritizePersonalUnread = state.prioritizePersonalUnread;
        _prioritizeUnmutedUnreadChannels = state.prioritizeUnmutedUnreadChannels;
      });
    }
  }

  void _openPersonalInfo() {
    _navigatorKey.currentState?.pushNamed(_personalInfoRoute);
  }

  void _openVersionChoose() {
    _navigatorKey.currentState?.pushNamed(_versionChooseRoute);
  }

  void _handleSoundChanged(String value) async {
    if (_prefs == null) return;
    await _prefs!.setString(SharedPrefsKeys.notificationSound, value);
    setState(() {
      _selectedSound = value;
    });
    _playSelected();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(12),
      child: Navigator(
        key: _navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (pageContext) => _ProfileSettingsView(
                  onClosePanel: () => pageContext.read<InfoPanelCubit>().setInfoPanelState(.closed),
                  onOpenPersonalInfo: _openPersonalInfo,
                  onOpenVersionChoose: _openVersionChoose,
                  showSoundSettings: _prefs != null,
                  selectedSound: _selectedSound,
                  onSoundChanged: _handleSoundChanged,
                  onPlaySound: _playSelected,
                  onOpenChatSorting: _openChatSortingDialog,
                ),
                settings: settings,
              );
            case _personalInfoRoute:
              return MaterialPageRoute(
                builder: (pageContext) => ProfilePersonalInfoPage(
                  onBack: () => _navigatorKey.currentState?.maybePop(),
                  onClose: () {
                    pageContext.read<InfoPanelCubit>().setInfoPanelState(.closed);
                  },
                ),
                settings: settings,
              );
            case _versionChooseRoute:
              return MaterialPageRoute(
                builder: (pageContext) => UpdateForce(),
                settings: settings,
              );
            default:
              return MaterialPageRoute(
                builder: (pageContext) => _ProfileSettingsView(
                  onClosePanel: () => pageContext.read<InfoPanelCubit>().setInfoPanelState(.closed),
                  onOpenVersionChoose: _openVersionChoose,
                  onOpenPersonalInfo: _openPersonalInfo,
                  showSoundSettings: _prefs != null,
                  selectedSound: _selectedSound,
                  onSoundChanged: _handleSoundChanged,
                  onPlaySound: _playSelected,
                  onOpenChatSorting: _openChatSortingDialog,
                ),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}

class _ProfileSettingsView extends StatelessWidget {
  const _ProfileSettingsView({
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
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
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
                leading: Assets.icons.accountCircle.svg(),
                title: Text(
                  context.t.profilePersonalInfo.title,
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: isMobile ? Assets.icons.arrowRight.svg() : null,
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
                        leading: Assets.icons.info.svg(),
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
                          Assets.icons.arrowRight.svg(),
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
                child: Assets.icons.volumeUp.svg(),
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
                      color: textColors.text30,
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
            leading: Assets.icons.language.svg(),
            title: Text(
              context.t.settings.language,
              style: theme.textTheme.bodyMedium,
            ),
            trailing: DropdownButton<Locale>(
              value: localizationService.locale.flutterLocale,
              underline: const SizedBox.shrink(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: textColors.text30,
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
              Icons.sort,
              color: textColors.text30,
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
