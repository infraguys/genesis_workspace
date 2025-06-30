import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';

class EventsByQueueIdResponseEntity {
  final String result;
  final String msg;
  final List<EventEntity> events;
  // final String queueId;

  EventsByQueueIdResponseEntity({
    required this.result,
    required this.msg,
    required this.events,
    // required this.queueId,
  });
}
