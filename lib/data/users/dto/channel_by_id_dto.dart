import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/data/users/dto/stream_dto.dart';
import 'package:genesis_workspace/domain/users/entities/channel_by_id_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'channel_by_id_dto.g.dart';

@JsonSerializable(createToJson: false)
class ChannelByIdResponseDto extends ResponseDto {
  ChannelByIdResponseDto({
    required super.msg,
    required super.result,
    required this.stream,
  });

  final StreamDto stream;

  factory ChannelByIdResponseDto.fromJson(Map<String, dynamic> json) => _$ChannelByIdResponseDtoFromJson(json);

  ChannelByIdResponseEntity toEntity() => ChannelByIdResponseEntity(
    stream: stream.toEntity(),
    msg: msg,
    result: result,
  );
}

@JsonSerializable()
class ChannelByIdRequestDto {
  ChannelByIdRequestDto({
    required this.streamId,
  });

  final int streamId;
}
