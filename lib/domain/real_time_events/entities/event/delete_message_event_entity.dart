import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';

class DeleteMessageEventEntity extends EventEntity {
  DeleteMessageEventEntity({
    required super.id,
    required super.type,
    super.organizationId,
    required this.messageId,
    required this.messageType,
    this.streamId,
    this.topic,
  });
  final MessageType messageType;
  final int messageId;
  final int? streamId;
  final String? topic;
}
