import 'package:genesis_workspace/data/users/dto/topic_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'topics_response_dto.g.dart';

@JsonSerializable()
class TopicsResponseDto {
  final String msg;
  final String result;
  final List<TopicDto> topics;

  TopicsResponseDto({required this.msg, required this.result, required this.topics});

  factory TopicsResponseDto.fromJson(Map<String, dynamic> json) => _$TopicsResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TopicsResponseDtoToJson(this);
}
