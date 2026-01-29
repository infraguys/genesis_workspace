import 'package:genesis_workspace/domain/channels/entities/user_topic_entity.dart';

class RegisterQueueEntity {
  final String queueId;
  final String msg;
  final String result;
  final int lastEventId;
  final String? realmJitsiServerUrl;
  final int? maxStreamNameLength;
  final int? maxStreamDescriptionLength;
  final List<UserTopicEntity>? userTopics;

  RegisterQueueEntity({
    required this.queueId,
    required this.msg,
    required this.result,
    required this.lastEventId,
    required this.realmJitsiServerUrl,
    required this.maxStreamNameLength,
    required this.maxStreamDescriptionLength,
    required this.userTopics,
  });
}
