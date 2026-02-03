import 'package:genesis_workspace/core/enums/topic_visibility_policy.dart';

class UserTopicEntity {
  final int streamId;
  final String topicName;
  final TopicVisibilityPolicy visibilityPolicy;

  UserTopicEntity({required this.streamId, required this.topicName, required this.visibilityPolicy});
}
