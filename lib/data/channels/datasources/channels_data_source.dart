import 'package:genesis_workspace/data/channels/dto/channel_dto.dart';
import 'package:genesis_workspace/data/channels/dto/topic_muting_dto.dart';

abstract class ChannelsDataSource {
  Future<CreateChannelResponseDto> createChannel(CreateChannelRequestDto body);
  Future<void> updateTopicMuting(UpdateTopicMutingRequestDto body);
}
