import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';

class MessageEventEntity extends EventEntity {
  final MessageEntity message;
  final List<String> flags;

  MessageEventEntity({
    required super.id,
    required super.type,
    super.organizationId,
    required this.message,
    required this.flags,
  });
}
