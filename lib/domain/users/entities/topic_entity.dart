import 'package:equatable/equatable.dart';

class TopicEntity extends Equatable {
  final int maxId;
  final String name;
  Set<int> unreadMessages;

  TopicEntity({required this.maxId, required this.name, required this.unreadMessages});

  @override
  List<Object> get props => [name];

  factory TopicEntity.fake({int? index, int? maxId, String? name, Set<int>? unreadMessages}) {
    final int topicIndex = index ?? 0;

    return TopicEntity(
      maxId: maxId ?? (topicIndex + 1) * 100,
      name: name ?? "Topic $topicIndex",
      unreadMessages: unreadMessages ?? {1, 2},
    );
  }
}
