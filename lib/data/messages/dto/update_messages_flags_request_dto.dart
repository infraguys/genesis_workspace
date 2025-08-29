import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_messages_flags_request_dto.g.dart';

@JsonSerializable()
class UpdateMessagesFlagsRequestDto {
  @ToListAsJsonStringConverter()
  final List<int> messages;
  final UpdateMessageFlagsOp op;
  final MessageFlag flag;

  UpdateMessagesFlagsRequestDto({required this.messages, required this.op, required this.flag});

  Map<String, dynamic> toJson() => _$UpdateMessagesFlagsRequestDtoToJson(this);
}
