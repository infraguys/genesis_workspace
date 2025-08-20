import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:genesis_workspace/app.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';

import 'core/dependency_injection/di.dart';

class Main {
  static Future<void> startApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await configureDependencies();
    usePathUrlStrategy();
    final LocalizationService localizationService = getIt<LocalizationService>();
    await localizationService.init();
    // LocaleSettings.useDeviceLocale();
    runApp(TranslationProvider(child: const WorkspaceApp()));
  }
}
