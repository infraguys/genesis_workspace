import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/features/messenger/bloc/info_panel_cubit.dart';
import 'package:genesis_workspace/features/profile/view/profile_personal_info_page.dart';
import 'package:genesis_workspace/features/profile/view/profile_settings_view.dart';
import 'package:genesis_workspace/features/settings/bloc/settings_cubit.dart';
import 'package:genesis_workspace/features/update/update.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
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
                builder: (pageContext) => ProfileSettingsView(
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
                builder: (pageContext) => ProfileSettingsView(
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
