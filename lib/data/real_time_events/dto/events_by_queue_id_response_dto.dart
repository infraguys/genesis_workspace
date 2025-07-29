import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_response_entity.dart';

class EventByQueueIdResponseDto {
  final String result;
  final String msg;
  final List<EventDto> events;
  // final String queueId;

  EventByQueueIdResponseDto({
    required this.result,
    required this.msg,
    required this.events,
    // required this.queueId,
  });

  factory EventByQueueIdResponseDto.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'] as List<dynamic>? ?? [];

    return EventByQueueIdResponseDto(
      result: json['result'] as String,
      msg: json['msg'] as String,
      events: rawEvents.map((e) => parseEventDto(e as Map<String, dynamic>)).toList(),
    );
  }

  EventsByQueueIdResponseEntity toEntity() => EventsByQueueIdResponseEntity(
    result: result,
    msg: msg,
    events: events.map((e) => e.toEntity()).toList(),
    // queueId: queueId,
  );
}
