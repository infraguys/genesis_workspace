import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger_cubit.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:injectable/injectable.dart';

class NotificationPayload {
  final MessageEntity message;
  final int organizationId;

  const NotificationPayload({
    required this.message,
    required this.organizationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
      'organizationId': organizationId,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      message: MessageEntity.fromJson(
        json['message'] as Map<String, dynamic>,
      ),
      organizationId: json['organizationId'] as int,
    );
  }

  factory NotificationPayload.fromJsonString(String source) {
    final Map<String, dynamic> decoded = jsonDecode(source) as Map<String, dynamic>;

    return NotificationPayload.fromJson(decoded);
  }
}

@injectable
class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final MessengerCubit _messengerCubit;
  final OrganizationsCubit _organizationsCubit;

  LocalNotificationsService(this._flutterLocalNotificationsPlugin, this._messengerCubit, this._organizationsCubit);

  void notificationTap(NotificationResponse notificationResponse) async {
    final NotificationPayload payload = NotificationPayload.fromJsonString(notificationResponse.payload!);
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
      _messengerCubit.selectChat(chat);
    } else {
      _messengerCubit.openChatFromMessage(payload.message);
    }
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse notificationResponse) async {
    final NotificationPayload payload = NotificationPayload.fromJsonString(notificationResponse.payload!);
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
      _messengerCubit.selectChat(chat);
    } else {
      _messengerCubit.openChatFromMessage(payload.message);
    }
  }

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
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
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
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
    final payload = NotificationPayload(message: message, organizationId: organizationId);
    await _flutterLocalNotificationsPlugin.show(
      message.id,
      message.displayTitle,
      message.content,
      notificationDetails,
      payload: payload.toJsonString(),
    );
  }
}
