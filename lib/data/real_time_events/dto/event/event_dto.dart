import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/message_event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/typing_event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/unsupported_event_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';

abstract class EventDto {
  final int id;
  final EventType type;

  EventDto({required this.id, required this.type});

  EventEntity toEntity();
}

EventDto parseEventDto(Map<String, dynamic> json) {
  final typeRaw = json['type'] as String;

  final type = EventType.values.firstWhere(
    (e) => e.toJson() == typeRaw,
    orElse: () => EventType.unsupported,
  );

  switch (type) {
    case EventType.typing:
      return TypingEventDto.fromJson(json);
    case EventType.message:
      return MessageEventDto.fromJson(json);
    default:
      return UnsupportedEventDto.fromJson(json);
  }
}
