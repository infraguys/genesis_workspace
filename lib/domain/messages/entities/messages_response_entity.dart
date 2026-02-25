import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';

class MessagesResponseEntity {
  final String msg;
  final String result;
  final List<MessageEntity> messages;
  final int? anchor;
  final bool foundOldest;
  final bool foundNewest;
  final int? organizationId;

  MessagesResponseEntity({
    required this.msg,
    required this.result,
    required this.messages,
    this.anchor,
    required this.foundOldest,
    required this.foundNewest,
    this.organizationId,
  });
}
