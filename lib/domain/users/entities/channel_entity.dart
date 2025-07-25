import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';

class ChannelEntity extends SubscriptionEntity {
  List<TopicEntity> topics;
  Set<int> unreadMessages = {};
  ChannelEntity({
    required super.name,
    required super.subscribers,
    required super.streamId,
    required super.description,
    required super.color,
    required this.topics,
    required this.unreadMessages,
  });
}
