import 'package:json_annotation/json_annotation.dart';

part 'stream_dto.g.dart';

@JsonSerializable()
class StreamDto {
  @JsonKey(name: 'stream_id')
  final int streamId;

  StreamDto({required this.streamId});

  factory StreamDto.fromJson(Map<String, dynamic> json) => _$StreamDtoFromJson(json);
}
