import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';

class MessageEntity {
  final int id;
  final bool isMeMessage;
  final String? avatarUrl;
  final String content;
  final int senderId;
  final List<RecipientEntity> displayRecipient;
  final String senderFullName;

  MessageEntity({
    required this.id,
    required this.isMeMessage,
    this.avatarUrl,
    required this.content,
    required this.senderId,
    required this.senderFullName,
    required this.displayRecipient,
  });
}
