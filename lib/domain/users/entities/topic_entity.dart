import 'package:equatable/equatable.dart';
import 'package:genesis_workspace/core/enums/topic_visibility_policy.dart';

class TopicEntity extends Equatable {
  const TopicEntity({
    required this.maxId,
    required this.name,
    required this.unreadMessages,
    this.lastMessageSenderName = '',
    this.lastMessagePreview = '',
    this.visibilityPolicy = .none,
  });

  final int maxId;
  final String name;
  final String lastMessageSenderName;
  final String lastMessagePreview;
  final TopicVisibilityPolicy visibilityPolicy;
  final Set<int> unreadMessages;

  bool get isMuted => visibilityPolicy == .muted;

  int? get firstUnreadMessageId => unreadMessages.firstOrNull;

  TopicEntity copyWith({
    int? maxId,
    String? name,
    Set<int>? unreadMessages,
    String? lastMessageSenderName,
    String? lastMessagePreview,
    TopicVisibilityPolicy? visibilityPolicy,
  }) {
    return TopicEntity(
      maxId: maxId ?? this.maxId,
      name: name ?? this.name,
      unreadMessages: unreadMessages ?? Set<int>.of(this.unreadMessages),
      lastMessageSenderName: lastMessageSenderName ?? this.lastMessageSenderName,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      visibilityPolicy: visibilityPolicy ?? this.visibilityPolicy,
    );
  }

  @override
  List<Object> get props => [name];

  factory TopicEntity.fake({
    int index = 0,
    int? maxId,
    String? name,
    Set<int>? unreadMessages,
  }) {
    return TopicEntity(
      maxId: maxId ?? (index + 1) * 100,
      name: name ?? "Topic $index",
      unreadMessages: unreadMessages ?? {1, 2},
    );
  }

  factory TopicEntity.newTopic(String name) {
    return TopicEntity(
      maxId: -1,
      name: name,
      unreadMessages: {},
    );
  }
}
