import 'package:genesis_workspace/domain/channels/entities/channel_entity.dart';

abstract class ChannelsRepository {
  Future<CreateChannelResponseEntity> createChannel(CreateChannelRequestEntity body);
}
