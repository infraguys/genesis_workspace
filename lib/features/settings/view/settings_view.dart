import 'package:audioplayers/audioplayers.dart';
// import 'package:desktop_updater/desktop_updater.dart';
// import 'package:desktop_updater/updater_controller.dart';
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

  @override
  void initState() {
    super.initState();
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
    // _desktopUpdaterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationService = getIt<LocalizationService>();

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: InkWell(
                      onTap: () => context.pushNamed(Routes.forceUpdate),
                      borderRadius: BorderRadius.circular(18),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.system_update_alt_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.t.updateView.openSelectorCta,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.t.updateView.openSelectorSubtitle,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 16, color: theme.colorScheme.onSecondaryContainer),
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
