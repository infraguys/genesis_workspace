import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:genesis_workspace/app.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

import 'core/dependency_injection/di.dart';

class Main {
  static Future<void> startApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    configureDependencies();
    usePathUrlStrategy();
    // LocaleSettings.useDeviceLocale();
    runApp(TranslationProvider(child: const WorkspaceApp()));
  }
}
