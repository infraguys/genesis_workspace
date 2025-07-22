import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/update_messages_flags_request_dto.dart';

class UpdateMessagesFlagsRequestEntity {
  final List<int> messages;
  final UpdateMessageFlagsOp op;
  final MessageFlag flag;

  UpdateMessagesFlagsRequestEntity({required this.messages, required this.op, required this.flag});

  UpdateMessagesFlagsRequestDto toDto() =>
      UpdateMessagesFlagsRequestDto(messages: messages, op: op, flag: flag);
}
