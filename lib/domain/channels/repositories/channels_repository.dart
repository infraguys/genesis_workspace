import 'package:genesis_workspace/domain/channels/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/channels/entities/update_topic_muting_entity.dart';

abstract class ChannelsRepository {
  Future<CreateChannelResponseEntity> createChannel(CreateChannelRequestEntity body);
  Future<void> updateTopicMuting(UpdateTopicMutingRequestEntity body);
}
