import 'package:genesis_workspace/domain/users/entities/stream_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stream_dto.g.dart';

@JsonSerializable()
class StreamDto {
  @JsonKey(name: 'stream_id')
  final int streamId;
  final String name;

  StreamDto({required this.streamId, required this.name});

  factory StreamDto.fromJson(Map<String, dynamic> json) => _$StreamDtoFromJson(json);

  StreamEntity toEntity() => StreamEntity(streamId: streamId, name: name);
}
