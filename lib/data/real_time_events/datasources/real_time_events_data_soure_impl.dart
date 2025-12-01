part of 'real_time_events_data_soure.dart';

class RealTimeEventsDataSourceImpl implements RealTimeEventsDataSource {
  final RealTimeEventsApiClient _apiClient;

  RealTimeEventsDataSourceImpl(this._apiClient);

  @override
  Future<EventByQueueIdResponseDto> getEventsByQueueId(GetEventsByQueueIdBodyDto body) async {
    try {
      final response = await _apiClient.getEventsByQueueId(
        body.queueId,
        body.lastEventId,
        body.dontBlock,
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
      final bool simplifiedPresenceEvents = true;
      return await _apiClient.registerQueue(requestDto, applyMarkdown, simplifiedPresenceEvents);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteQueue(String queueId) async {
    try {
      await _apiClient.deleteQueue(queueId);
    } catch (e) {
      rethrow;
    }
  }
}
