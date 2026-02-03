import 'package:genesis_workspace/core/enums/topic_visibility_policy.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/user_topic_event_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_topic_event_dto.g.dart';

@JsonSerializable()
class UserTopicEventDto extends EventDto {
  UserTopicEventDto({
    required super.id,
    required super.type,
    required this.streamId,
    required this.topicName,
    required this.visibilityPolicy,
  });

  @JsonKey(name: 'stream_id')
  final int streamId;
  @JsonKey(name: 'topic_name')
  final String topicName;
  @JsonKey(name: 'visibility_policy')
  final TopicVisibilityPolicy visibilityPolicy;

  factory UserTopicEventDto.fromJson(Map<String, dynamic> json) => _$UserTopicEventDtoFromJson(json);

  @override
  UserTopicEventEntity toEntity() => UserTopicEventEntity(
    id: id,
    type: type,
    streamId: streamId,
    topicName: topicName,
    visibilityPolicy: visibilityPolicy,
  );
}
