import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:genesis_workspace/app.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/services/firebase/firebase_service.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';
import 'package:genesis_workspace/services/notifications/local_notifications_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:window_manager/window_manager.dart';

class Main {
  static Future<void> startApp() async {
    MediaKit.ensureInitialized();
    if (platformInfo.isDesktop && !platformInfo.isWeb) {
      await windowManager.ensureInitialized();
    }
    await FirebaseService.initialize();
    await AppConstants.init();
    await configureDependencies();
    usePathUrlStrategy();
    final LocalizationService localizationService = getIt<LocalizationService>();
    await localizationService.init();
    if (platformInfo.isDesktop) {
      await getIt<LocalNotificationsService>().init();
    }

    // TalkerFlutter.init(settings: TalkerSettings(useConsoleLogs: false));
    getIt<Talker>();
    runApp(TranslationProvider(child: const WorkspaceApp()));
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await AppConstants.init();
  await configureDependencies();
  inspect(message);
  print("Handling a background message: ${message.messageId}");
  final _localNotificationsService = getIt<LocalNotificationsService>();
  final organizationId = AppConstants.selectedOrganizationId;
  await _localNotificationsService.showNotificationFromPush(
    messageId: int.parse(message.data['message_id']),
    displayTitle: message.data['sender_full_name'],
    content: message.data['content'],
    organizationId: organizationId ?? -1,
  );
}

void main() async {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      return Main.startApp();
    },
    (error, stackTrace) {
      inspect(error);
      inspect(stackTrace);
    },
  );
}
