import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';

class SubscriptionEntity {
  final int streamId;
  final String name;
  final List<int>? subscribers;
  final String description;
  final String color;
  final bool isMuted;

  SubscriptionEntity({
    required this.streamId,
    required this.name,
    required this.subscribers,
    required this.description,
    required this.color,
    required this.isMuted,
  });

  factory SubscriptionEntity.fake({
    String name = 'Fake channel',
    List<int>? subscribers,
    int streamId = -1,
    String description = 'Mock subscription',
    String color = '#CCCCCC',
    bool isMuted = false,
  }) => SubscriptionEntity(
    name: name,
    subscribers: subscribers ?? const <int>[1, 2, 3],
    streamId: streamId,
    description: description,
    color: color,
    isMuted: isMuted,
  );

  ChannelEntity toChannelEntity() => ChannelEntity(
    name: name,
    subscribers: subscribers,
    streamId: streamId,
    description: description,
    color: color,
    topics: [],
    unreadMessages: {},
    isMuted: isMuted,
  );
}
