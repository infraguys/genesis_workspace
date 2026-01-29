import 'package:genesis_workspace/core/enums/topic_visibility_policy.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';

class UserTopicEventEntity extends EventEntity {
  UserTopicEventEntity({
    required super.id,
    required super.type,
    required this.streamId,
    required this.topicName,
    required this.visibilityPolicy,
  });
  final int streamId;
  final String topicName;
  final TopicVisibilityPolicy visibilityPolicy;
}
