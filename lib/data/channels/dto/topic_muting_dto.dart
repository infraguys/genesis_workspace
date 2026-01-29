import 'package:genesis_workspace/core/enums/topic_visibility_policy.dart';

class UpdateTopicMutingRequestDto {
  final int streamId;
  final String topic;
  final TopicVisibilityPolicy policy;

  UpdateTopicMutingRequestDto({required this.streamId, required this.topic, required this.policy});
}
