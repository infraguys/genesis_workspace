class PushDataEntity {
  final int userId;
  final String kind;
  final String senderFullName;
  final int messageId;
  final String realmUrl;
  final int? organizationId;
  final DateTime time;
  final String senderId;
  final String content;

  const PushDataEntity({
    required this.userId,
    required this.kind,
    required this.senderFullName,
    required this.messageId,
    required this.realmUrl,
    required this.organizationId,
    required this.time,
    required this.senderId,
    required this.content,
  });
}
