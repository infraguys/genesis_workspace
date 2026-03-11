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
import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:genesis_workspace/domain/organizations/usecases/get_organization_id_by_comparable_url_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/notification_payload_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:genesis_workspace/services/firebase/firebase_service.dart';
import 'package:genesis_workspace/services/localization/localization_service.dart';
import 'package:genesis_workspace/services/notifications/local_notifications_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:window_manager/window_manager.dart';

bool _firebaseMessageListenersAttached = false;

Future<void> _ensureDependenciesInitialized() async {
  await AppConstants.init();
  if (!getIt.isRegistered<LocalNotificationsService>()) {
    await configureDependencies();
  }
}

Future<int> _resolveOrganizationIdByRealUrl(String realUrl, {int fallback = -1}) async {
  final String normalizedRealUrl = realUrl.trim();
  if (normalizedRealUrl.isEmpty) {
    return AppConstants.selectedOrganizationId ?? fallback;
  }
  try {
    final useCase = GetOrganizationIdByComparableUrlUseCase(getIt<OrganizationsRepository>());
    final int? organizationId = await useCase.call(normalizedRealUrl);
    return organizationId ?? AppConstants.selectedOrganizationId ?? fallback;
  } catch (_) {
    return AppConstants.selectedOrganizationId ?? fallback;
  }
}

Future<PushNotificationTapPayloadEntity?> _buildPushTapPayload(RemoteMessage message) async {
  if (message.data.isEmpty) return null;
  final PushDataDto data = PushDataDto.fromJson(message.data);
  final int organizationId = data.organizationId ?? await _resolveOrganizationIdByRealUrl(data.realmUrl, fallback: -1);
  return PushNotificationTapPayloadEntity(
    organizationId: organizationId,
    kind: data.kind,
    messageId: data.messageId,
    recipientId: data.recipientId,
    streamId: data.streamId,
    topic: data.topicName,
    userId: data.userId,
    content: data.content,
    senderId: data.senderId,
    senderFullName: data.senderFullName,
  );
}

Future<void> _handleForegroundMessage(RemoteMessage message) async {
  if (message.data.isEmpty || !getIt.isRegistered<LocalNotificationsService>()) return;
  try {
    final PushDataDto data = PushDataDto.fromJson(message.data);
    final int organizationId =
        data.organizationId ?? await _resolveOrganizationIdByRealUrl(data.realmUrl, fallback: -1);
    await LocalNotificationsService.showBackgroundPushNotification(
      kind: data.kind,
      messageId: data.messageId,
      displayTitle: data.senderFullName,
      content: data.content,
      organizationId: organizationId,
      userId: data.userId,
      recipientId: data.recipientId,
      streamId: data.streamId,
      topic: data.topicName,
      senderId: data.senderId,
    );
  } catch (error, stackTrace) {
    log('Failed to handle foreground FCM message', error: error, stackTrace: stackTrace);
  }
}

Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
  if (!getIt.isRegistered<LocalNotificationsService>()) return;
  try {
    final PushNotificationTapPayloadEntity? payload = await _buildPushTapPayload(message);
    if (payload == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(getIt<LocalNotificationsService>().openChatFromPushPayload(payload));
    });
  } catch (error, stackTrace) {
    log('Failed to handle notification tap from FCM', error: error, stackTrace: stackTrace);
  }
}

Future<void> _attachFirebaseMessageListeners() async {
  if (_firebaseMessageListenersAttached) return;
  _firebaseMessageListenersAttached = true;

  FirebaseMessaging.onMessage.listen((message) {
    unawaited(_handleForegroundMessage(message));
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    unawaited(_handleMessageOpenedApp(message));
  });

  final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    unawaited(_handleMessageOpenedApp(initialMessage));
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
    if (FirebaseService.isMessagingAvailable) {
      await _attachFirebaseMessageListeners();
    }

    // TalkerFlutter.init(settings: TalkerSettings(useConsoleLogs: false));
    getIt<Talker>();
    runApp(TranslationProvider(child: const WorkspaceApp()));
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await FirebaseService.initialize();
    await _ensureDependenciesInitialized();
    if (message.data.isEmpty) return;

    final PushDataDto data = PushDataDto.fromJson(message.data);
    final int organizationId =
        data.organizationId ?? await _resolveOrganizationIdByRealUrl(data.realmUrl, fallback: -1);
    await LocalNotificationsService.showBackgroundPushNotification(
      kind: data.kind,
      messageId: data.messageId,
      displayTitle: data.senderFullName,
      content: data.content,
      organizationId: organizationId,
      userId: data.userId,
      recipientId: data.recipientId,
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
