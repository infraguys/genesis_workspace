import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_response_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_request_body_entity.dart';

abstract class RealTimeEventsRepository {
  Future<RegisterQueueEntity> registerQueue(RegisterQueueRequestBodyEntity request);
  Future<EventsByQueueIdResponseEntity> getEventsByQueueId(EventsByQueueIdRequestBodyEntity body);
  Future<void> deleteQueue(String queueId);
}
