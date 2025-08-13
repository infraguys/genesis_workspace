part of 'real_time_events_data_soure.dart';

@Injectable(as: RealTimeEventsDataSource)
class RealTimeEventsDataSourceImpl implements RealTimeEventsDataSource {
  final RealTimeEventsApiClient apiClient = RealTimeEventsApiClient(getIt<Dio>());

  @override
  Future<EventByQueueIdResponseDto> getEventsByQueueId(GetEventsByQueueIdBodyDto body) async {
    try {
      final bool dontBlock = false;
      final response = await apiClient.getEventsByQueueId(
        body.queueId,
        body.lastEventId,
        dontBlock,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RegisterQueueResponseDto> registerQueue(RegisterQueueRequestBodyDto requestDto) async {
    try {
      final bool applyMarkdown = true;
      return await apiClient.registerQueue(requestDto, applyMarkdown);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteQueue(String queueId) async {
    try {
      await apiClient.deleteQueue(queueId);
    } catch (e) {
      rethrow;
    }
  }
}
