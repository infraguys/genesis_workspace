import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/data/users/dto/typing_request_dto.dart';

class TypingRequestEntity {
  final SendMessageType type;
  final TypingEventOp op;
  final List<int>? to;
  final int? streamId;
  final String? topic;

  TypingRequestEntity({required this.type, required this.op, this.to, this.streamId, this.topic});

  TypingRequestDto toDto() =>
      TypingRequestDto(type: type, op: op, to: to, streamId: streamId, topic: topic);
}
