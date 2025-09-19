import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';

class UpdateMessageEventEntity extends EventEntity {
  final String content;
  final String renderedContent;
  final int messageId;

  UpdateMessageEventEntity({
    required super.id,
    required super.type,
    required this.content,
    required this.renderedContent,
    required this.messageId,
  });
}
