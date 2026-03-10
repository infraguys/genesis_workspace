class PushDataEntity {
  final String userId;
  final String kind;
  final String senderFullName;
  final String messageId;
  final String realmUrl;
  final DateTime time;
  final String senderId;
  final String content;

  const PushDataEntity({
    required this.userId,
    required this.kind,
    required this.senderFullName,
    required this.messageId,
    required this.realmUrl,
    required this.time,
    required this.senderId,
    required this.content,
  });
}
