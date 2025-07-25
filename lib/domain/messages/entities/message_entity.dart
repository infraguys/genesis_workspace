import 'package:genesis_workspace/core/enums/message_type.dart';

class MessageEntity {
  final int id;
  final bool isMeMessage;
  final String? avatarUrl;
  final String content;
  final int senderId;
  final dynamic displayRecipient;
  final String senderFullName;
  final List<String>? flags;
  final MessageType type;
  final int? streamId;
  final String subject;

  MessageEntity({
    required this.id,
    required this.isMeMessage,
    this.avatarUrl,
    required this.content,
    required this.senderId,
    required this.senderFullName,
    required this.displayRecipient,
    required this.type,
    this.flags,
    this.streamId,
    required this.subject,
  });

  bool get hasUnreadMessages => flags == null || (flags != null && !flags!.contains('read'));

  MessageEntity copyWith({
    int? id,
    bool? isMeMessage,
    String? avatarUrl,
    String? content,
    int? senderId,
    String? senderFullName,
    dynamic displayRecipient,
    List<String>? flags,
    MessageType? type,
    int? streamId,
    String? subject,
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
      type: type ?? this.type,
      streamId: streamId ?? this.streamId,
      subject: subject ?? this.subject,
    );
  }
}
