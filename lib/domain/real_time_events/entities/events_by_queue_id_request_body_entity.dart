import 'package:genesis_workspace/data/real_time_events/dto/get_events_by_queue_id_body_dto.dart';

class EventsByQueueIdRequestBodyEntity {
  final String queueId;
  final int lastEventId;

  EventsByQueueIdRequestBodyEntity({required this.queueId, required this.lastEventId});

  GetEventsByQueueIdBodyDto toDto() =>
      GetEventsByQueueIdBodyDto(queueId: queueId, lastEventId: lastEventId);
}
