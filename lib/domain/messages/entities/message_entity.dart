import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';

class MessageEntity {
  final int id;
  final bool isMeMessage;
  final String? avatarUrl;
  final String content;
  final int senderId;
  final List<RecipientEntity> displayRecipient;
  final String senderFullName;
  final List<String>? flags;

  MessageEntity({
    required this.id,
    required this.isMeMessage,
    this.avatarUrl,
    required this.content,
    required this.senderId,
    required this.senderFullName,
    required this.displayRecipient,
    this.flags,
  });

  MessageEntity copyWith({
    int? id,
    bool? isMeMessage,
    String? avatarUrl,
    String? content,
    int? senderId,
    String? senderFullName,
    List<RecipientEntity>? displayRecipient,
    List<String>? flags,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      isMeMessage: isMeMessage ?? this.isMeMessage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderFullName: senderFullName ?? this.senderFullName,
      displayRecipient: displayRecipient ?? this.displayRecipient,
      flags: flags ?? this.flags,
    );
  }
}
