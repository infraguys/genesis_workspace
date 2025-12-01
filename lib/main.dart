import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:genesis_workspace/app.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/firebase_options.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';

import 'core/dependency_injection/di.dart';

class Main {
  static Future<void> startApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      name: "genesis_workspace",
      options: Platform.isLinux ?  DefaultFirebaseOptions.web : DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await AppConstants.init();
    await configureDependencies();
    usePathUrlStrategy();
    final LocalizationService localizationService = getIt<LocalizationService>();
    await localizationService.init();

    runApp(TranslationProvider(child: const WorkspaceApp()));
  }
}
