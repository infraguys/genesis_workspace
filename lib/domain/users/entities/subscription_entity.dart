import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';

class SubscriptionEntity {
  final String name;
  final List<int> subscribers;
  final int streamId;
  final String description;
  final String color;

  SubscriptionEntity({
    required this.name,
    required this.subscribers,
    required this.streamId,
    required this.description,
    required this.color,
  });

  ChannelEntity toChannelEntity() => ChannelEntity(
    name: name,
    subscribers: subscribers,
    streamId: streamId,
    description: description,
    color: color,
    topics: [],
    unreadMessages: {},
  );
}
