import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';

class UpdateMessageFlagsEventEntity extends EventEntity {
  final UpdateMessageFlagsOp op;
  final MessageFlag flag;
  final List<int> messages;
  final bool all;
  UpdateMessageFlagsEventEntity({
    required super.id,
    required super.type,
    required this.op,
    required this.flag,
    required this.messages,
    required this.all,
  });
}
