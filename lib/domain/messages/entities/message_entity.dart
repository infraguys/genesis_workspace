class MessageEntity {
  final int id;
  final bool isMeMessage;
  final String avatarUrl;
  final String content;

  MessageEntity({
    required this.id,
    required this.isMeMessage,
    required this.avatarUrl,
    required this.content,
  });
}
