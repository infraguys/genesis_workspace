import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/enums/typing_message_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/sender_entity.dart';

class TypingEventEntity extends EventEntity {
  final TypingMessageType messageType;
  final TypingEventOp op;
  final SenderEntity sender;
  final List<RecipientEntity>? recipients;
  final int? streamId;
  final String? topic;

  TypingEventEntity({
    required super.id,
    required super.type,
    required this.messageType,
    required this.op,
    required this.sender,
    this.recipients,
    this.streamId,
    this.topic,
  });
}
