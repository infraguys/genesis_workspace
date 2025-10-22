import 'package:audioplayers/audioplayers.dart';
import 'package:desktop_updater/desktop_updater.dart';
import 'package:desktop_updater/updater_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/features/update/bloc/update_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _selectedSound = AssetsConstants.audioPop;
  SharedPreferences? _prefs;
  late final AudioPlayer _player;
  late final DesktopUpdaterController _desktopUpdaterController;

  @override
  void initState() {
    super.initState();
    final appArchiveUrl = context.read<UpdateCubit>().state.appArchiveUrl;
    _desktopUpdaterController = DesktopUpdaterController(appArchiveUrl: Uri.parse(appArchiveUrl));
    _player = AudioPlayer();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(SharedPrefsKeys.notificationSound);
    setState(() {
      _prefs = prefs;
      _selectedSound = saved ?? AssetsConstants.audioPop;
    });
  }

  Future<void> _playSelected() async {
    try {
      await _player.stop();
      await _player.play(AssetSource(_selectedSound));
    } catch (_) {}
  }

  @override
  void dispose() {
    _player.dispose();
    _desktopUpdaterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationService = getIt<LocalizationService>();
    final updateWidgetTexts = context.t.updateWidget;

    _desktopUpdaterController.localization = DesktopUpdateLocalization(
      updateAvailableText: updateWidgetTexts.updateAvailable,
      newVersionAvailableText: updateWidgetTexts.newVersionAvailable(
        version: _desktopUpdaterController.appVersion.toString(),
      ),
      newVersionLongText: updateWidgetTexts.newVersionLong(
        size: _desktopUpdaterController.downloadSize.toString(),
      ),
      restartText: updateWidgetTexts.restart,
      warningTitleText: updateWidgetTexts.warningTitle,
      restartWarningText: updateWidgetTexts.restartWarning,
      warningCancelText: updateWidgetTexts.warningCancel,
      warningConfirmText: updateWidgetTexts.warningConfirm,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(context.t.navBar.settings),
      ),
      body: ListView(
        children: [
          BlocBuilder<UpdateCubit, UpdateState>(
            builder: (context, state) {
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(context.t.settings.appVersion),
                    subtitle: Text(state.currentVersion),
                  ),
                  DesktopUpdateDirectCard(
                    controller: _desktopUpdaterController,
                    child: SizedBox.shrink(),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          if (_prefs != null)
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(context.t.settings.notificationSound),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: _selectedSound,
                    onChanged: (value) async {
                      if (value == null) return;
                      await _prefs!.setString(SharedPrefsKeys.notificationSound, value);
                      setState(() {
                        _selectedSound = value;
                      });
                      _playSelected();
                    },
                    items: const [
                      DropdownMenuItem(value: AssetsConstants.audioPop, child: Text('Pop')),
                      DropdownMenuItem(value: AssetsConstants.audioWhoop, child: Text('Whoop')),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Play',
                    icon: const Icon(Icons.play_arrow),
                    onPressed: _playSelected,
                  ),
                ],
              ),
            ),
          if (_prefs == null) const SizedBox.shrink(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.t.settings.language),
            trailing: DropdownButton<Locale>(
              value: localizationService.locale.flutterLocale,
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
          const Divider(),
          ElevatedButton(
            onPressed: () {
              context.goNamed(Routes.forceUpdate);
            },
            child: Text("go to update"),
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
                await context.read<AuthCubit>().logout();
                context.go(Routes.auth);
              },
              icon: const Icon(Icons.logout),
              label: Text(
                context.t.settings.logout,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (kDebugMode)
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
                  context.go(Routes.auth);
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
      ),
    );
  }
}
