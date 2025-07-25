import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'topic_dto.g.dart';

@JsonSerializable()
class TopicDto {
  @JsonKey(name: 'max_id')
  final int maxId;
  final String name;

  TopicDto({required this.maxId, required this.name});

  factory TopicDto.fromJson(Map<String, dynamic> json) => _$TopicDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TopicDtoToJson(this);

  TopicEntity toEntity() => TopicEntity(maxId: maxId, name: name, unreadMessages: {});
}
