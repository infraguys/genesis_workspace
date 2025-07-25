import 'package:genesis_workspace/data/messages/dto/message_narrow_dto.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';

class MessageNarrowEntity {
  final NarrowOperator operator;
  final Object operand;

  MessageNarrowEntity({required this.operator, required this.operand});

  MessageNarrowDto toDto() => MessageNarrowDto(operand: operand, operator: operator.name);
}
