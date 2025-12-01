import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:genesis_workspace/app.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/services/firebase/firebase_service.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';

class Main {
  static Future<void> startApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FirebaseService.initialize();
    await AppConstants.init();
    await configureDependencies();
    usePathUrlStrategy();
    final LocalizationService localizationService = getIt<LocalizationService>();
    await localizationService.init();

    runApp(TranslationProvider(child: const WorkspaceApp()));
  }
}
