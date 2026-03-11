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
import 'package:genesis_workspace/domain/organizations/usecases/get_organization_id_by_url_use_case.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/services/firebase/firebase_service.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';
import 'package:genesis_workspace/services/notifications/local_notifications_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:window_manager/window_manager.dart';

Future<void> _ensureDependenciesInitialized() async {
  await AppConstants.init();
  if (!getIt.isRegistered<LocalNotificationsService>()) {
    await configureDependencies();
  }
}

Future<int> _resolveOrganizationIdByRealmUrl(String realUrl, {int fallback = -1}) async {
  final String normalizedRealUrl = realUrl.trim();
  try {
    final useCase = getIt<GetOrganizationIdByUrlUseCase>();
    final int? organizationId = await useCase.call(normalizedRealUrl);
    return organizationId ?? AppConstants.selectedOrganizationId ?? fallback;
  } catch (_) {
    return AppConstants.selectedOrganizationId ?? fallback;
  }
}

class Main {
  static Future<void> startApp() async {
    MediaKit.ensureInitialized();
    if (platformInfo.isDesktop && !platformInfo.isWeb) {
      await windowManager.ensureInitialized();
    }
    await FirebaseService.initialize();
    await _ensureDependenciesInitialized();
    usePathUrlStrategy();
    final LocalizationService localizationService = getIt<LocalizationService>();
    await localizationService.init();
    if (!platformInfo.isWeb) {
      await getIt<LocalNotificationsService>().init();
    }

    getIt<Talker>();
    runApp(TranslationProvider(child: const WorkspaceApp()));
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  inspect(message);
  try {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await FirebaseService.initialize();
    await _ensureDependenciesInitialized();
    if (message.data.isEmpty) return;

    if (message.data['kind'] == 'remove_notification_message') {
      (message.data['message_ids'] as String).split(',').forEach((id) {
        final pushId = int.parse(id);
        LocalNotificationsService.cancelBackgroundPushNotification(pushId);
      });
      return;
    }

    final PushDataDto data = PushDataDto.fromJson(message.data);
    final int organizationId = await _resolveOrganizationIdByRealmUrl(data.realmUrl ?? '', fallback: -1);
    await LocalNotificationsService.showBackgroundPushNotification(
      kind: data.kind,
      messageId: data.messageId,
      displayTitle: data.senderFullName,
      content: data.content,
      organizationId: organizationId,
      userId: data.userId,
      streamId: data.streamId,
      topic: data.topicName,
      senderId: data.senderId,
    );
  } catch (error, stackTrace) {
    log('Failed to handle background FCM message', error: error, stackTrace: stackTrace);
  }
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
