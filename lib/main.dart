import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:genesis_workspace/app.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/data/real_time_events/dto/push_data_dto.dart';
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
    if (!platformInfo.isWeb) {
      await getIt<LocalNotificationsService>().init();
    }

    // TalkerFlutter.init(settings: TalkerSettings(useConsoleLogs: false));
    getIt<Talker>();
    runApp(TranslationProvider(child: const WorkspaceApp()));
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  inspect(message);
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await FirebaseService.initialize();
  final PushDataDto data = PushDataDto.fromJson(message.data);
  await LocalNotificationsService.showBackgroundPushNotification(
    messageId: data.messageId,
    displayTitle: data.senderFullName,
    content: data.content,
    organizationId: 1,
    userId: data.userId,
    recipientId: int.parse(data.senderId),
    senderId: int.parse(data.senderId),
  );
}

void main() async {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        print("main");
        inspect(message);
      });
      return Main.startApp();
    },
    (error, stackTrace) {
      inspect(error);
      inspect(stackTrace);
    },
  );
}
