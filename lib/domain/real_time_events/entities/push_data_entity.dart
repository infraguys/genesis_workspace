import 'package:genesis_workspace/core/enums/push_message_kind.dart';

class PushDataEntity {
  final int? userId;
  final PushMessageKind kind;
  final String senderFullName;
  final int messageId;
  final String? realmUrl;
  final DateTime time;
  final int? senderId;
  final String content;
  final int? streamId;
  final String? topicName;
  final String? streamName;

  const PushDataEntity({
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
    required this.streamName,
  });
}
