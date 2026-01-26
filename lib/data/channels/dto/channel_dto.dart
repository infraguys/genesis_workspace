import 'package:genesis_workspace/domain/channels/entities/channel_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'channel_dto.g.dart';

class CreateChannelRequestDto {
  final String name;
  final String? description;
  final List<int> subscribers;
  final bool announce;
  final bool inviteOnly;

  CreateChannelRequestDto({
    required this.name,
    this.description,
    required this.subscribers,
    this.announce = false,
    this.inviteOnly = false,
  });
}

@JsonSerializable()
class CreateChannelResponseDto {
  @JsonKey(name: 'id')
  final int streamId;

  CreateChannelResponseDto({required this.streamId});

  factory CreateChannelResponseDto.fromJson(Map<String, dynamic> json) => _$CreateChannelResponseDtoFromJson(json);

  CreateChannelResponseEntity toEntity() => CreateChannelResponseEntity(streamId: streamId);
}
