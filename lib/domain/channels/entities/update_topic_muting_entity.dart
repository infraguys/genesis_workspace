import 'package:genesis_workspace/core/enums/topic_visibility_policy.dart';
import 'package:genesis_workspace/data/channels/dto/topic_muting_dto.dart';

class UpdateTopicMutingRequestEntity {
  final int streamId;
  final String topic;
  final TopicVisibilityPolicy policy;

  UpdateTopicMutingRequestEntity({
    required this.streamId,
    required this.topic,
    required this.policy,
  });

  UpdateTopicMutingRequestDto toDto() => UpdateTopicMutingRequestDto(
    streamId: streamId,
    topic: topic,
    policy: policy,
  );
}
