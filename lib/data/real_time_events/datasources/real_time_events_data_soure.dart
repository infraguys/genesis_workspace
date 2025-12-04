import 'package:genesis_workspace/data/real_time_events/api/real_time_events_api_client.dart';
import 'package:genesis_workspace/data/real_time_events/dto/events_by_queue_id_response_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/get_events_by_queue_id_body_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/register_queue_request_body_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/register_queue_response_dto.dart';

part 'real_time_events_data_soure_impl.dart';

abstract class RealTimeEventsDataSource {
  Future<RegisterQueueResponseDto> registerQueue(RegisterQueueRequestBodyDto requestDto);
  Future<EventByQueueIdResponseDto> getEventsByQueueId(GetEventsByQueueIdBodyDto body);
  Future<void> deleteQueue(String queueId);
}
