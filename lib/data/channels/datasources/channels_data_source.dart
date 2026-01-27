import 'package:genesis_workspace/data/channels/dto/channel_dto.dart';

abstract class ChannelsDataSource {
  Future<CreateChannelResponseDto> createChannel(CreateChannelRequestDto body);
}
