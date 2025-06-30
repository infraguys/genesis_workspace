import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/sender_entity.dart';

class TypingEventEntity extends EventEntity {
  final String messageType;
  final String op;
  final SenderEntity sender;
  final List<RecipientEntity> recipients;

  TypingEventEntity({
    required int id,
    required EventType type,
    required this.messageType,
    required this.op,
    required this.sender,
    required this.recipients,
  }) : super(id: id, type: type);
}
