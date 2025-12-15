import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/widgets/tap_effect_icon.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel_cubit.dart';
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePanel extends StatefulWidget {
  const ProfilePanel({super.key});

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationService = getIt<LocalizationService>();
    final textColors = theme.extension<TextColors>()!;
    final cardColors = theme.extension<CardColors>()!;
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(12),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            "Профиль",
            style: theme.textTheme.labelLarge,
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.read<InfoPanelCubit>().setInfoPanelState(.closed);
              },
              icon: Assets.icons.close.svg(),
            ),
          ],
        ),
        body: ListView(
          children: [
            BlocBuilder<UpdateCubit, UpdateState>(
              builder: (context, state) {
                return Column(
                  children: [
                    ListTile(
                      leading: Assets.icons.accountCircle.svg(),
                      title: Text(
                        "Личная информация",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: InkWell(
                        onTap: () => context.pushNamed(Routes.forceUpdate),
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
                                        context.t.updateView.openSelectorCta,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        context.t.updateView.openSelectorSubtitle,
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
                );
              },
            ),
            if (_prefs != null)
              ListTile(
                leading: TapEffectIcon(
                  onTap: _playSelected,
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
                      value: _selectedSound,
                      underline: SizedBox.shrink(),
                      onChanged: (value) async {
                        if (value == null) return;
                        await _prefs!.setString(SharedPrefsKeys.notificationSound, value);
                        setState(() {
                          _selectedSound = value;
                        });
                        _playSelected();
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: textColors.text30,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColors.text30,
                      ),
                      items: const [
                        DropdownMenuItem(value: AssetsConstants.audioPop, child: Text('Pop')),
                        DropdownMenuItem(value: AssetsConstants.audioWhoop, child: Text('Whoop')),
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
                underline: SizedBox.shrink(),
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
                  DropdownMenuItem(value: const Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: const Locale('ru'), child: Text('Русский')),
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
              onTap: _openChatSortingDialog,
            ),
            ListTile(
              leading: Assets.icons.logout.svg(),
              title: Text(
                context.t.settings.logout,
                style: theme.textTheme.bodyMedium,
              ),
              onTap: () async {
                await context.read<AuthCubit>().logout();
              },
            ),
            if (kDebugMode) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SettingsCubit>().clearLocalDatabase();
                  },
                  child: Text("Clear db"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await context.read<AuthCubit>().devLogout();
                    // context.go(Routes.auth);
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(
                    "Dev logout",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
