import 'package:dio/dio.dart' hide Headers;
import 'package:genesis_workspace/data/real_time_events/dto/register_queue_request_body_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/register_queue_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'real_time_events_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class RealTimeEventsApiClient {
  factory RealTimeEventsApiClient(Dio dio, {String? baseUrl}) = _RealTimeEventsApiClient;

  @POST('/register')
  Future<RegisterQueueResponseDto> registerQueue(@Body() RegisterQueueRequestBodyDto requestDto);

  @GET('/events')
  Future<void> getEventsByQueueId(
    @Query('queue_id') String queueId,
    @Query("last_event_id") int lastEventId,
  );
}
