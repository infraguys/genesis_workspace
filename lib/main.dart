import 'package:flutter/material.dart';
import 'package:genesis_workspace/app.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

import 'core/dependency_injection/di.dart';

class Main {
  static Future<void> startApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    configureDependencies();
    // LocaleSettings.useDeviceLocale();
    runApp(TranslationProvider(child: const WorkspaceApp()));
  }
}
