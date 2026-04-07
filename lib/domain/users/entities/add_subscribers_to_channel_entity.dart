import 'package:genesis_workspace/data/users/dto/add_subscribers_to_channel_dto.dart';

class AddSubscribersToChannelEntity {
  final String streamName;
  final List<int> userIds;

  AddSubscribersToChannelEntity({
    required this.streamName,
    required this.userIds,
  });

  AddSubscribersToChannelDto toDto() => AddSubscribersToChannelDto(
    streamName: streamName,
    userIds: userIds,
  );
}
