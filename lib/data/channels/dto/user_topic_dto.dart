import 'package:genesis_workspace/core/enums/topic_visibility_policy.dart';
import 'package:genesis_workspace/domain/channels/entities/user_topic_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_topic_dto.g.dart';

@JsonSerializable()
class UserTopicDto {
  @JsonKey(name: 'stream_id')
  final int streamId;
  @JsonKey(name: 'topic_name')
  final String topicName;
  @JsonKey(name: 'visibility_policy')
  final TopicVisibilityPolicy visibilityPolicy;

  UserTopicDto({required this.streamId, required this.topicName, required this.visibilityPolicy});

  factory UserTopicDto.fromJson(Map<String, dynamic> json) => _$UserTopicDtoFromJson(json);

  UserTopicEntity toEntity() => UserTopicEntity(
    streamId: streamId,
    topicName: topicName,
    visibilityPolicy: visibilityPolicy,
  );
}
