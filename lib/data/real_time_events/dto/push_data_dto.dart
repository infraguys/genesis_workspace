import 'package:genesis_workspace/core/enums/push_message_kind.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/push_data_entity.dart';

class PushDataDto {
  final int? userId;
  final PushMessageKind kind;
  final String senderFullName;
  final int messageId;
  final String? realmUrl;
  final int time;
  final int senderId;
  final String content;
  final int? streamId;
  final String? topicName;
  final String? streamName;

  const PushDataDto({
    this.userId,
    required this.kind,
    required this.senderFullName,
    required this.messageId,
    required this.realmUrl,
    required this.time,
    required this.senderId,
    required this.content,
    required this.streamId,
    required this.topicName,
    this.streamName,
  });

  factory PushDataDto.fromJson(Map<String, dynamic> json) {
    final PushMessageKind kind = PushMessageKind.fromJson(json['kind']);
    final String? rawStreamId = json['stream_id'] ?? json['steram_id'];

    return PushDataDto(
      userId: int.parse(json['user_id'] ?? '-1'),
      kind: kind,
      senderFullName: json['sender_full_name'],
      messageId: int.parse(json['workspace_message_id']),
      realmUrl: json['realm_url'],
      time: int.parse(json['time']),
      senderId: int.parse(json['sender_id']),
      content: json['content']?.toString() ?? '',
      streamId: int.parse(rawStreamId ?? '-1'),
      topicName: json['topic'] as String?,
      streamName: json['stream'] as String?,
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
      streamId: streamId,
      topicName: topicName,
      streamName: streamName,
    );
  }
}
