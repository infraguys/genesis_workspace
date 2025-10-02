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
    required super.isMuted,
    required this.topics,
    required this.unreadMessages,
  });

  factory ChannelEntity.fake({
    String? name,
    int? streamId,
    String? description,
    String? color,
    List<TopicEntity>? topics,
    Set<int>? unreadMessages,
    bool? isMuted,
  }) {
    return ChannelEntity(
      name: name ?? 'General',
      subscribers: <int>[],
      streamId: streamId ?? -1,
      description: description ?? 'This is a fake channel for testing',
      color: color ?? '#53B175',
      topics: topics ?? List.generate(3, (index) => TopicEntity.fake(index: index)),
      unreadMessages: unreadMessages ?? {1, 2, 3},
      isMuted: isMuted ?? false,
    );
  }

  ChannelEntity copyWith({
    String? name,
    List<int>? subscribers,
    int? streamId,
    String? description,
    String? color,
    bool? isMuted,
    List<TopicEntity>? topics,
    Set<int>? unreadMessages,
  }) {
    return ChannelEntity(
      name: name ?? this.name,
      subscribers: subscribers ?? this.subscribers,
      streamId: streamId ?? this.streamId,
      description: description ?? this.description,
      color: color ?? this.color,
      isMuted: isMuted ?? this.isMuted,
      topics: topics ?? this.topics,
      unreadMessages: unreadMessages ?? this.unreadMessages,
    );
  }
}
