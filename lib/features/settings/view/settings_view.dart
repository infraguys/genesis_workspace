import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';
import 'package:go_router/go_router.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
                  context.read<AuthCubit>().devLogout();
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
