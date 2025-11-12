import 'package:genesis_workspace/domain/users/entities/stream_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stream_dto.g.dart';

@JsonSerializable()
class StreamDto {
  @JsonKey(name: 'stream_id')
  final int streamId;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'subscriber_count')
  final int subscriberCount;

  StreamDto({required this.streamId, required this.name, required this.subscriberCount});

  factory StreamDto.fromJson(Map<String, dynamic> json) => _$StreamDtoFromJson(json);

  StreamEntity toEntity() =>
      StreamEntity(streamId: streamId, name: name, subscriberCount: subscriberCount);
}
