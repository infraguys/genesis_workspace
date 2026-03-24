import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'topic_dto.g.dart';

@JsonSerializable()
class TopicDto {
  TopicDto({
    required this.maxId,
    required this.name,
  });

  @JsonKey(name: 'max_id')
  final int maxId;
  @JsonKey(name: 'name')
  final String name;

  factory TopicDto.fromJson(Map<String, dynamic> json) => _$TopicDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TopicDtoToJson(this);

  TopicEntity toEntity() => TopicEntity(
    maxId: maxId,
    name: name,
    unreadMessages: {},
  );
}
