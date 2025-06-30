import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';

class MessageEntity {
  final int id;
  final int senderId;
  final String content;
  final int recipientId;
  final int timestamp;
  final String client;
  final String subject;
  final String senderFullName;
  final String senderEmail;
  final List<RecipientEntity> displayRecipient;
  final String type;
  final String avatarUrl;
  final String contentType;

  MessageEntity({
    required this.id,
    required this.senderId,
    required this.content,
    required this.recipientId,
    required this.timestamp,
    required this.client,
    required this.subject,
    required this.senderFullName,
    required this.senderEmail,
    required this.displayRecipient,
    required this.type,
    required this.avatarUrl,
    required this.contentType,
  });
}
