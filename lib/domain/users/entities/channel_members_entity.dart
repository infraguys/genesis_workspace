import 'package:genesis_workspace/data/users/dto/channel_members_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class ChannelMembersResponseEntity extends ResponseEntity {
  final List<int> subscribers;
  ChannelMembersResponseEntity({
    required super.msg,
    required super.result,
    required this.subscribers,
  });
}

class ChannelMembersRequestEntity {
  final int streamId;
  ChannelMembersRequestEntity({required this.streamId});

  ChannelMembersRequestDto toDto() => ChannelMembersRequestDto(streamId: streamId);
}
