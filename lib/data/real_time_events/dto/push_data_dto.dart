import 'package:genesis_workspace/domain/real_time_events/entities/push_data_entity.dart';

class PushDataDto {
  final String userId;
  final String kind;
  final String senderFullName;
  final int messageId;
  final String realmUrl;
  final int time;
  final String senderId;
  final String content;

  const PushDataDto({
    required this.userId,
    required this.kind,
    required this.senderFullName,
    required this.messageId,
    required this.realmUrl,
    required this.time,
    required this.senderId,
    required this.content,
  });

  factory PushDataDto.fromJson(Map<String, dynamic> json) {
    return PushDataDto(
      userId: json['user_id'] as String,
      kind: json['kind'] as String,
      senderFullName: json['sender_full_name'] as String,
      messageId: int.parse(json['workspace_message_id'] as String),
      realmUrl: json['realm_url'] as String,
      time: int.parse(json['time'].toString()),
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
    );
  }

  PushDataEntity toEntity() {
    return PushDataEntity(
      messageId: messageId,
      userId: userId,
      kind: kind,
      senderFullName: senderFullName,
      realmUrl: realmUrl,
      time: DateTime.fromMillisecondsSinceEpoch(time * 1000),
      senderId: senderId,
      content: content,
    );
  }
}
