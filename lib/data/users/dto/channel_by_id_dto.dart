import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/data/users/dto/stream_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'channel_by_id_dto.g.dart';

@JsonSerializable()
class ChannelByIdResponseDto extends ResponseDto {
  final StreamDto stream;
  ChannelByIdResponseDto({required super.msg, required super.result, required this.stream});

  factory ChannelByIdResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChannelByIdResponseDtoFromJson(json);
}
