import 'package:genesis_workspace/data/channels/dto/channel_dto.dart';

class CreateChannelResponseEntity {
  final int streamId;
  CreateChannelResponseEntity({
    required this.streamId,
  });
}

class CreateChannelRequestEntity {
  final String name;
  final String? description;
  final List<int> subscribers;
  final bool announce;
  final bool inviteOnly;

  CreateChannelRequestEntity({
    required this.name,
    this.description,
    required this.subscribers,
    this.announce = false,
    this.inviteOnly = false,
  });

  CreateChannelRequestDto toDto() => CreateChannelRequestDto(
    name: name,
    subscribers: subscribers,
    description: description,
    announce: announce,
    inviteOnly: inviteOnly,
  );
}
