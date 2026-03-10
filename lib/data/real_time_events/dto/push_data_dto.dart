import 'package:genesis_workspace/domain/real_time_events/entities/push_data_entity.dart';

class PushDataDto {
  final int userId;
  final String kind;
  final String senderFullName;
  final int messageId;
  final String realmUrl;
  final int? organizationId;
  final int time;
  final String senderId;
  final String content;

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
  });

  factory PushDataDto.fromJson(Map<String, dynamic> json) {
    final Object? rawRealmUrl = json['real_url'] ?? json['realm_url'];
    final Object? rawMessageId = json['workspace_message_id'] ?? json['message_id'];
    return PushDataDto(
      userId: _parseRequiredInt(json['user_id']),
      kind: json['kind']?.toString() ?? 'unknown',
      senderFullName: json['sender_full_name']?.toString() ?? '',
      messageId: _parseRequiredInt(rawMessageId),
      realmUrl: rawRealmUrl?.toString() ?? '',
      organizationId: _parseOptionalInt(json['organization_id']),
      time: _parseRequiredInt(json['time']),
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
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
}
