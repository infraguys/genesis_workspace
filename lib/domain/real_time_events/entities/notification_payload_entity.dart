import 'dart:convert';

import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';

class NotificationPayloadEntity {
  final MessageEntity message;
  final int organizationId;

  const NotificationPayloadEntity({
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

  factory NotificationPayloadEntity.fromJson(Map<String, dynamic> json) {
    return NotificationPayloadEntity(
      message: MessageEntity.fromJson(
        json['message'] as Map<String, dynamic>,
      ),
      organizationId: json['organizationId'] as int,
    );
  }

  factory NotificationPayloadEntity.fromJsonString(String source) {
    final Map<String, dynamic> decoded = jsonDecode(source) as Map<String, dynamic>;

    return NotificationPayloadEntity.fromJson(decoded);
  }
}

class PushNotificationTapPayloadEntity {
  final int organizationId;
  final int? messageId;
  final String? content;
  final int? senderId;
  final String? senderFullName;
  final int? recipientId;
  final String? topic;

  const PushNotificationTapPayloadEntity({
    required this.organizationId,
    required this.messageId,
    required this.recipientId,
    required this.topic,
    this.content,
    this.senderId,
    this.senderFullName,
  });

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'messageId': messageId,
      'recipientId': recipientId,
      'topic': topic,
    };
  }

  factory PushNotificationTapPayloadEntity.fromJson(Map<String, dynamic> json) {
    return PushNotificationTapPayloadEntity(
      organizationId: _toInt(json['organizationId']) ?? -1,
      messageId: _toInt(json['messageId']),
      recipientId: _toInt(json['recipientId']),
      topic: _toNonEmptyString(json['topic']),
      content: _toNonEmptyString(json['content']),
      senderId: _toInt(json['senderId']),
      senderFullName: _toNonEmptyString(json['senderFullName']),
    );
  }

  static int? _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _toNonEmptyString(Object? value) {
    final String normalized = value?.toString().trim() ?? '';
    if (normalized.isEmpty) return null;
    return normalized;
  }
}
