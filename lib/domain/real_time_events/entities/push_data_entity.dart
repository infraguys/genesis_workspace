import 'package:genesis_workspace/domain/real_time_events/entities/push_message_kind.dart';

class PushDataEntity {
  final int userId;
  final PushMessageKind kind;
  final String senderFullName;
  final int messageId;
  final String realmUrl;
  final int? organizationId;
  final DateTime time;
  final int? senderId;
  final String content;
  final int? streamId;
  final int? recipientId;
  final String? topicName;
  final String? streamName;

  const PushDataEntity({
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
}
