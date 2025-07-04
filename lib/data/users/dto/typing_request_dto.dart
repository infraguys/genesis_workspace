import 'package:genesis_workspace/core/config/helpers.dart';
import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:json_annotation/json_annotation.dart';

part 'typing_request_dto.g.dart';

@JsonSerializable()
class TypingRequestDto {
  final SendMessageType type;
  final TypingEventOp op;
  @ToListAsJsonStringConverter()
  final List<int> to;

  TypingRequestDto({required this.type, required this.op, required this.to});

  Map<String, dynamic> toJson() => _$TypingRequestDtoToJson(this);
}
