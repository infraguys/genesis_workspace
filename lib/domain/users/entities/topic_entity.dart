class TopicEntity {
  final int maxId;
  final String name;
  Set<int> unreadMessages;

  TopicEntity({required this.maxId, required this.name, required this.unreadMessages});
}
