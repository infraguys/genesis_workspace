import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';

class MessagesResponseEntity {
  final String msg;
  final String result;
  final List<MessageEntity> messages;
  final int anchor;
  final bool foundOldest;

  MessagesResponseEntity({
    required this.msg,
    required this.result,
    required this.messages,
    required this.anchor,
    required this.foundOldest,
  });
}
