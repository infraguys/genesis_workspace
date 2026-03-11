import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/push_message_kind.dart';
import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/display_recipient.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/single_message_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_message_by_id_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/notification_payload_entity.dart';
import 'package:genesis_workspace/features/messenger/bloc/messenger/messenger_cubit.dart';
import 'package:genesis_workspace/features/organizations/bloc/organizations_cubit.dart';
import 'package:genesis_workspace/navigation/router.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

@pragma('vm:entry-point')
Future<void> notificationTapBackgroundHandler(NotificationResponse notificationResponse) async {
  final String payloadString = notificationResponse.payload ?? '';
  if (payloadString.isEmpty || tryDecodePayloadMap(payloadString) == null) {
    return;
  }

  try {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await _savePendingBackgroundTapPayload(payloadString);
    if (getIt.isRegistered<LocalNotificationsService>()) {
      unawaited(getIt<LocalNotificationsService>().processPendingBackgroundTapPayload());
    }
  } catch (error, stackTrace) {
    log(
      'Failed to persist notification tap payload from background callback',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Future<void> _savePendingBackgroundTapPayload(String payloadString) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(LocalNotificationsService._pendingBackgroundTapPayloadKey, payloadString);
}

Map<String, dynamic>? tryDecodePayloadMap(String payloadString) {
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

@injectable
class LocalNotificationsService {
  static const String _pushChannelId = 'workspace_push_messages';
  static const String _pushChannelName = 'Workspace messages';
  static const String _pushChannelDescription = 'Push notifications for new messages';
  static const String _pendingBackgroundTapPayloadKey = 'pending_background_notification_tap_payload';
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
    required PushMessageKind kind,
    required int messageId,
    required String displayTitle,
    required int organizationId,
    required String content,
    int? userId,
    int? recipientId,
    int? streamId,
    String? topic,
    int? senderId,
  }) async {
    await _ensureBackgroundPluginInitialized();
    final payload = jsonEncode(
      PushNotificationTapPayloadEntity(
        organizationId: organizationId,
        kind: kind,
        messageId: messageId,
        streamId: streamId,
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

  static void cancelBackgroundPushNotification(int id) {
    _backgroundNotificationsPlugin.cancel(id);
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
    final Map<String, dynamic>? payloadMap = tryDecodePayloadMap(payloadString);
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

    if (payload.kind.isStreamChatMessage || payload.streamId != null) {
      return _openChannelFromPushPayload(payload);
    }

    final List<int> dmMemberIds = _extractDmMemberIdsFromPayload(payload);
    final ChatEntity? chatByMembers = _findDmChatByMemberIds(dmMemberIds);
    if (chatByMembers != null) {
      return _openResolvedChat(chatByMembers, payload);
    }

    final int? messageId = payload.messageId;
    if (messageId == null) return false;
    return _openChatByMessageId(
      messageId,
      topic: payload.topic,
    );
  }

  Future<bool> _openChannelFromPushPayload(PushNotificationTapPayloadEntity payload) async {
    final int? streamId = payload.streamId;
    final String? topic = payload.topic;
    final int? messageId = payload.messageId;

    if (streamId == null || streamId <= 0) {
      if (messageId == null) return false;
      return _openChatByMessageId(messageId, topic: topic);
    }

    ChatEntity? chat = _messengerCubit.state.chats.firstWhereOrNull((chat) => chat.streamId == streamId);
    if (chat == null) {
      await _messengerCubit.addChannelById(streamId);
      chat = _messengerCubit.state.chats.firstWhereOrNull((chat) => chat.streamId == streamId);
    }

    if (chat == null) {
      if (messageId == null) return false;
      return _openChatByMessageId(messageId, topic: topic);
    }

    if (platformInfo.isMobile) {
      await _openMobileChannelChat(
        chatId: chat.id,
        channelId: streamId,
        topicName: topic,
        focusedMessageId: messageId,
      );
      return true;
    }
    _messengerCubit.selectChat(
      chat,
      selectedTopic: topic,
      focusedMessageId: messageId,
    );
    return true;
  }

  Future<bool> _openChatByMessageId(int messageId, {String? topic}) async {
    try {
      final response = await getIt<GetMessageByIdUseCase>().call(
        SingleMessageRequestEntity(messageId: messageId, applyMarkdown: false),
      );
      final message = response.message;
      if (!message.isDirectMessage && !message.isGroupChatMessage && !message.isChannelMessage) {
        return false;
      }
      _messengerCubit.openChatFromMessage(message);
      final chat = _messengerCubit.state.chats.firstWhereOrNull((chat) => chat.id == message.recipientId);
      if (chat != null) {
        if (platformInfo.isMobile) {
          if (message.isChannelMessage) {
            final int? channelId = chat.streamId ?? message.streamId;
            if (channelId == null || channelId <= 0) {
              return false;
            }
            await _openMobileChannelChat(
              chatId: chat.id,
              channelId: channelId,
              topicName: topic ?? message.subject,
              focusedMessageId: messageId,
            );
          } else {
            await _openMobileDmChat(
              chatId: chat.id,
              memberIds: _extractDmMemberIdsFromMessage(message),
              focusedMessageId: messageId,
            );
          }
        } else {
          _messengerCubit.selectChat(
            chat,
            selectedTopic: topic ?? message.subject,
            focusedMessageId: messageId,
          );
        }
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

  Future<bool> _openResolvedChat(ChatEntity chat, PushNotificationTapPayloadEntity payload) async {
    if (platformInfo.isMobile) {
      final List<int> memberIds = chat.dmIds ?? _extractDmMemberIdsFromPayload(payload);
      await _openMobileDmChat(
        chatId: chat.id,
        memberIds: memberIds,
        focusedMessageId: payload.messageId,
      );
      return true;
    }
    _messengerCubit.selectChat(
      chat,
      selectedTopic: payload.topic,
      focusedMessageId: payload.messageId,
    );
    return true;
  }

  Future<void> _openMobileDmChat({
    required int chatId,
    required List<int> memberIds,
    required int? focusedMessageId,
  }) async {
    if (chatId <= 0) return;
    final List<int> normalizedMemberIds = memberIds.where((id) => id > 0).toSet().toList()..sort();
    if (normalizedMemberIds.isEmpty) return;

    router.go(Routes.messenger);
    router.pushNamed(
      Routes.groupChat,
      pathParameters: {
        'chatId': chatId.toString(),
        'userIds': normalizedMemberIds.join(','),
      },
      extra: {
        'messageId': focusedMessageId,
        'focusedMessageId': focusedMessageId,
      },
    );
  }

  Future<void> _openMobileChannelChat({
    required int chatId,
    required int channelId,
    required String? topicName,
    required int? focusedMessageId,
  }) async {
    if (chatId <= 0 || channelId <= 0) return;
    router.go(Routes.messenger);

    final String? normalizedTopic = topicName?.trim();
    if (normalizedTopic != null && normalizedTopic.isNotEmpty) {
      router.pushNamed(
        Routes.channelChatTopic,
        pathParameters: {
          'chatId': chatId.toString(),
          'channelId': channelId.toString(),
          'topicName': normalizedTopic,
        },
        extra: {
          'messageId': focusedMessageId,
          'focusedMessageId': focusedMessageId,
        },
      );
      return;
    }

    router.pushNamed(
      Routes.channelChat,
      pathParameters: {
        'chatId': chatId.toString(),
        'channelId': channelId.toString(),
      },
      extra: {
        'messageId': focusedMessageId,
        'focusedMessageId': focusedMessageId,
      },
    );
  }

  ChatEntity? _findDmChatByMemberIds(List<int> memberIds) {
    if (memberIds.isEmpty) return null;
    final Set<int> targetMemberIds = memberIds.toSet();
    return _messengerCubit.state.chats.firstWhereOrNull((chat) {
      final List<int>? chatMemberIds = chat.dmIds;
      if (chatMemberIds == null || chatMemberIds.isEmpty) return false;
      final Set<int> chatMembersSet = chatMemberIds.toSet();
      return chatMembersSet.length == targetMemberIds.length && chatMembersSet.containsAll(targetMemberIds);
    });
  }

  List<int> _extractDmMemberIdsFromPayload(PushNotificationTapPayloadEntity payload) {
    final Set<int> memberIds = <int>{};
    if ((payload.userId ?? -1) > 0) {
      memberIds.add(payload.userId!);
    }
    final int? senderId = payload.senderId;
    if (senderId != null && senderId > 0) {
      memberIds.add(senderId);
    }
    return memberIds.toList();
  }

  List<int> _extractDmMemberIdsFromMessage(MessageEntity message) {
    final displayRecipient = message.displayRecipient;
    if (displayRecipient is! DirectMessageRecipients) {
      return const <int>[];
    }
    return displayRecipient.recipients.map((recipient) => recipient.userId).where((id) => id > 0).toSet().toList();
  }

  Future<void> processPendingBackgroundTapPayload() async {
    final String? pendingPayload = await _takePendingBackgroundTapPayload();
    if (pendingPayload == null || pendingPayload.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_handleNotificationPayloadEntityString(pendingPayload));
    });
  }

  Future<String?> _takePendingBackgroundTapPayload() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? pendingPayload = prefs.getString(_pendingBackgroundTapPayloadKey);
    if (pendingPayload == null || pendingPayload.isEmpty) {
      return null;
    }
    await prefs.remove(_pendingBackgroundTapPayloadKey);
    return pendingPayload;
  }

  Future<void> _processTappedNotificationAfterLaunch() async {
    final NotificationAppLaunchDetails? launchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    final NotificationResponse? launchResponse = launchDetails?.notificationResponse;
    final String? launchPayload = launchResponse?.payload;
    final String? pendingPayload = await _takePendingBackgroundTapPayload();
    final String? payloadToHandle = (launchPayload != null && launchPayload.isNotEmpty)
        ? launchPayload
        : pendingPayload;
    if (payloadToHandle == null || payloadToHandle.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_handleNotificationPayloadEntityString(payloadToHandle));
    });
  }
}
