import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/users/entities/channel_members_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'channel_members_dto.g.dart';

@JsonSerializable()
class ChannelMembersResponseDto extends ResponseDto {
  final List<int> subscribers;
  ChannelMembersResponseDto({required super.msg, required super.result, required this.subscribers});

  factory ChannelMembersResponseDto.fromJson(Map<String, dynamic> json) => _$ChannelMembersResponseDtoFromJson(json);

  ChannelMembersResponseEntity toEntity() =>
      ChannelMembersResponseEntity(msg: msg, result: result, subscribers: subscribers);
}

class ChannelMembersRequestDto {
  final int streamId;
  ChannelMembersRequestDto({required this.streamId});
}
