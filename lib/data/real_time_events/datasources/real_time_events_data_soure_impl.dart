part of 'real_time_events_data_soure.dart';

@Injectable(as: RealTimeEventsDataSource)
class RealTimeEventsDataSourceImpl implements RealTimeEventsDataSource {
  final RealTimeEventsApiClient apiClient = RealTimeEventsApiClient(getIt<Dio>());

  @override
  Future<void> getEventsByQueueId(GetEventsByQueueIdBodyDto body) async {
    return await apiClient.getEventsByQueueId(body.queueId, body.lastEventId);
  }

  @override
  Future<RegisterQueueResponseDto> registerQueue(RegisterQueueRequestBodyDto requestDto) async {
    return await apiClient.registerQueue(requestDto);
  }
}
