import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/message_entity.dart';

class MessageEventEntity extends EventEntity {
  final MessageEntity message;
  final List<String> flags;

  MessageEventEntity({
    required int id,
    required EventType type,
    required this.message,
    required this.flags,
  }) : super(id: id, type: type);
}
