import 'package:genesis_workspace/domain/real_time_events/entities/push_data_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/push_message_kind.dart';

class PushDataDto {
  final int userId;
  final PushMessageKind kind;
  final String senderFullName;
  final int messageId;
  final String realmUrl;
  final int? organizationId;
  final int time;
  final int? senderId;
  final String content;
  final int? streamId;
  final int? recipientId;
  final String? topicName;
  final String? streamName;

  const PushDataDto({
    required this.userId,
    required this.kind,
    required this.senderFullName,
    required this.messageId,
    required this.realmUrl,
    required this.organizationId,
    required this.time,
    required this.senderId,
    required this.content,
    required this.streamId,
    required this.recipientId,
    required this.topicName,
    required this.streamName,
  });

  factory PushDataDto.fromJson(Map<String, dynamic> json) {
    final PushMessageKind kind = PushMessageKind.fromJson(json['kind']);
    final Object? rawRealmUrl = json['real_url'] ?? json['realm_url'];
    final Object? rawMessageId = json['workspace_message_id'] ?? json['message_id'];
    final Object? rawStreamId = json['stream_id'] ?? json['steram_id'];
    final String? parsedTopicName = _parseNonEmptyString(json['topic'] ?? json['topic_name'] ?? json['subject']);
    final int? parsedRecipientId = _parseOptionalInt(json['recipient_id']);

    return PushDataDto(
      userId: _parseOptionalInt(json['user_id']) ?? -1,
      kind: kind,
      senderFullName: json['sender_full_name']?.toString() ?? '',
      messageId: _parseRequiredInt(rawMessageId),
      realmUrl: rawRealmUrl?.toString() ?? '',
      organizationId: _parseOptionalInt(json['organization_id']),
      time: _parseRequiredInt(json['time']),
      senderId: _parseOptionalInt(json['sender_id']),
      content: json['content']?.toString() ?? '',
      streamId: _parseOptionalInt(rawStreamId),
      recipientId: parsedRecipientId,
      topicName: parsedTopicName,
      streamName: _parseNonEmptyString(json['stream']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'kind': kind.rawValue,
      'sender_full_name': senderFullName,
      'workspace_message_id': messageId,
      'real_url': realmUrl,
      'organization_id': organizationId,
      'time': time,
      'sender_id': senderId,
      'content': content,
      if (kind.isStreamChatMessage || streamId != null) 'stream_id': streamId,
      if (kind.isStreamChatMessage || topicName != null) 'topic': topicName,
      if (kind.isStreamChatMessage || streamName != null) 'stream': streamName,
      if (!kind.isStreamChatMessage && recipientId != null) 'recipient_id': recipientId,
    };
  }

  PushDataEntity toEntity() {
    return PushDataEntity(
      messageId: messageId,
      userId: userId,
      kind: kind,
      senderFullName: senderFullName,
      realmUrl: realmUrl,
      organizationId: organizationId,
      time: DateTime.fromMillisecondsSinceEpoch(time * 1000),
      senderId: senderId,
      content: content,
      streamId: streamId,
      recipientId: recipientId,
      topicName: topicName,
      streamName: streamName,
    );
  }

  static int _parseRequiredInt(Object? value) {
    final int? parsed = _parseOptionalInt(value);
    if (parsed == null) {
      throw FormatException('Cannot parse int from value: $value');
    }
    return parsed;
  }

  static int? _parseOptionalInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _parseNonEmptyString(Object? value) {
    final String normalized = value?.toString().trim() ?? '';
    if (normalized.isEmpty) return null;
    return normalized;
  }
}
