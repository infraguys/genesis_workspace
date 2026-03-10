import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/single_message_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_message_by_id_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/notification_payload_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:injectable/injectable.dart';
import 'package:window_manager/window_manager.dart';

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse notificationResponse) {
  //navigate to mobile
}

@injectable
class LocalNotificationsService {
  static const String _pushChannelId = 'workspace_push_messages';
  static const String _pushChannelName = 'Workspace messages';
  static const String _pushChannelDescription = 'Push notifications for new messages';
  static const NotificationDetails _pushNotificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _pushChannelId,
      _pushChannelName,
      channelDescription: _pushChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
  static final FlutterLocalNotificationsPlugin _backgroundNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _isBackgroundNotificationsPluginInitialized = false;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final MessengerCubit _messengerCubit;
  final OrganizationsCubit _organizationsCubit;

  LocalNotificationsService(this._flutterLocalNotificationsPlugin, this._messengerCubit, this._organizationsCubit);

  void notificationTap(NotificationResponse notificationResponse) async {
    await _focusAppOnDesktop();
    final String? payloadString = notificationResponse.payload;
    if (payloadString == null || payloadString.isEmpty) return;
    await _handleNotificationPayloadEntityString(payloadString);
  }

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );
    final WindowsInitializationSettings initializationSettingsWindows = WindowsInitializationSettings(
      appName: 'Workspace',
      appUserModelId: 'Com.Genesis.Workspace',
      guid: '4c1dc691-5ece-47c8-ba3a-0b3a7684b1cc',
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackgroundHandler,
    );
    await _processTappedNotificationAfterLaunch();
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> showNotification({
    required MessageEntity message,
    required int organizationId,
  }) async {
    NotificationDetails notificationDetails = NotificationDetails(
      linux: LinuxNotificationDetails(
        timeout: LinuxNotificationTimeout.fromDuration(Duration(seconds: 5)),
        category: LinuxNotificationCategory.email,
      ),
      macOS: DarwinNotificationDetails(),
      windows: WindowsNotificationDetails(
        duration: WindowsNotificationDuration.short,
      ),
    );
    final payload = NotificationPayloadEntity(message: message, organizationId: organizationId);
    await _flutterLocalNotificationsPlugin.show(
      message.id,
      message.displayTitle,
      "New message",
      notificationDetails,
      payload: payload.toJsonString(),
    );
  }

  static Future<void> showBackgroundPushNotification({
    required int messageId,
    required String displayTitle,
    required int organizationId,
    required String content,
    required int userId,
    int? recipientId,
    String? topic,
    int? senderId,
  }) async {
    await _ensureBackgroundPluginInitialized();
    final payload = jsonEncode(
      PushNotificationTapPayloadEntity(
        organizationId: organizationId,
        messageId: messageId,
        recipientId: recipientId,
        topic: topic,
        content: content,
        senderId: senderId,
        senderFullName: displayTitle,
        userId: userId,
      ).toJson(),
    );
    await _backgroundNotificationsPlugin.show(
      messageId,
      displayTitle,
      content,
      _pushNotificationDetails,
      payload: payload,
    );
  }

  static Future<void> _ensureBackgroundPluginInitialized() async {
    if (_isBackgroundNotificationsPluginInitialized) return;

    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );
    await _backgroundNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationTapBackgroundHandler,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackgroundHandler,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = _backgroundNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        _pushChannelId,
        _pushChannelName,
        description: _pushChannelDescription,
        importance: Importance.max,
      ),
    );

    _isBackgroundNotificationsPluginInitialized = true;
  }

  void cancelNotification(int id) {
    _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> _handleNotificationPayloadEntityString(String payloadString) async {
    final Map<String, dynamic>? payloadMap = _tryDecodePayloadMap(payloadString);
    if (payloadMap == null) return;
    if (payloadMap.containsKey('message')) {
      final NotificationPayloadEntity payload = NotificationPayloadEntity.fromJson(payloadMap);
      await _selectChatFromPayload(payload);
      return;
    }

    final PushNotificationTapPayloadEntity payload = PushNotificationTapPayloadEntity.fromJson(payloadMap);
    await _openChatFromPushPayloadWithRetry(payload);
  }

  Future<void> _selectChatFromPayload(NotificationPayloadEntity payload) async {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != payload.organizationId) {
      final organization = _organizationsCubit.state.organizations.firstWhereOrNull(
        (element) => element.id == payload.organizationId,
      );
      if (organization != null) {
        await _organizationsCubit.selectOrganization(organization);
      }
    }
    final chatId = payload.message.recipientId;
    final chat = _messengerCubit.state.chats.firstWhereOrNull((chat) => chat.id == chatId);
    if (chat != null) {
      _messengerCubit.selectChat(
        chat,
        selectedTopic: payload.message.subject,
        focusedMessageId: payload.message.id,
      );
    } else {
      _messengerCubit.openChatFromMessage(payload.message);
    }
  }

  Future<void> _focusAppOnDesktop() async {
    if (!platformInfo.isDesktop) return;
    try {
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      }
      await windowManager.show();
      await windowManager.focus();
    } catch (_) {}
  }

  Future<void> _openChatFromPushPayloadWithRetry(
    PushNotificationTapPayloadEntity payload, {
    int attempt = 0,
  }) async {
    final bool isHandled = await _tryOpenChatFromPushPayload(payload);
    if (isHandled || attempt >= 5) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _openChatFromPushPayloadWithRetry(payload, attempt: attempt + 1);
  }

  Future<bool> _tryOpenChatFromPushPayload(PushNotificationTapPayloadEntity payload) async {
    inspect(payload);
    final int organizationId = payload.organizationId;
    final int? selectedOrganizationId = AppConstants.selectedOrganizationId;
    if (organizationId > 0 && organizationId != selectedOrganizationId) {
      final organization = _organizationsCubit.state.organizations.firstWhereOrNull(
        (element) => element.id == organizationId,
      );
      if (organization == null) {
        return false;
      }
      await _organizationsCubit.selectOrganization(organization);
      AppConstants.setSelectedOrganizationId(organization.id);
    }

    final int? recipientId = payload.recipientId;
    if (recipientId != null) {
      final chat = _messengerCubit.state.chats.firstWhereOrNull((chat) => chat.id == recipientId);
      if (chat != null) {
        if (platformInfo.isMobile) {
          //navigate to Routes.chat
          inspect(chat);
        } else {
          _messengerCubit.selectChat(
            chat,
            selectedTopic: payload.topic,
            focusedMessageId: payload.messageId,
          );
          return true;
        }
      }
    }

    final int? messageId = payload.messageId;
    if (messageId == null) return false;
    return _openChatByMessageId(
      messageId,
      topic: payload.topic,
    );
  }

  Future<bool> _openChatByMessageId(int messageId, {String? topic}) async {
    try {
      final response = await getIt<GetMessageByIdUseCase>().call(
        SingleMessageRequestEntity(messageId: messageId, applyMarkdown: false),
      );
      final message = response.message;
      _messengerCubit.openChatFromMessage(message);
      final chat = _messengerCubit.state.chats.firstWhereOrNull((chat) => chat.id == message.recipientId);
      if (chat != null) {
        _messengerCubit.selectChat(
          chat,
          selectedTopic: topic ?? message.subject,
          focusedMessageId: messageId,
        );
      }
      return true;
    } catch (error, stackTrace) {
      log(
        'Notification tap handling failed for messageId=$messageId',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> _processTappedNotificationAfterLaunch() async {
    // String? launchPayload;
    // final NotificationAppLaunchDetails? launchDetails = await _flutterLocalNotificationsPlugin
    //     .getNotificationAppLaunchDetails();
    // final NotificationResponse? launchResponse = launchDetails?.notificationResponse;
    // if (launchResponse?.payload case final String payload when payload.isNotEmpty) {
    //   launchPayload = payload;
    //   await _handleNotificationPayloadEntityString(payload);
    // }
    //
    // final String? pendingPayload = await _takePendingBackgroundTapPayload();
    // if (pendingPayload == null || pendingPayload == launchPayload) return;
    // await _handleNotificationPayloadEntityString(pendingPayload);
    // router.pushNamed(
    //   Routes.chat,
    //   pathParameters: {'userId': "16"},
    // );
  }

  Map<String, dynamic>? _tryDecodePayloadMap(String payloadString) {
    try {
      final decoded = jsonDecode(payloadString);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
