class MessageEntity {
  final int id;
  final bool isMeMessage;
  final String? avatarUrl;
  final String content;
  final int senderId;
  final String senderFullName;

  MessageEntity({
    required this.id,
    required this.isMeMessage,
    this.avatarUrl,
    required this.content,
    required this.senderId,
    required this.senderFullName,
  });
}
