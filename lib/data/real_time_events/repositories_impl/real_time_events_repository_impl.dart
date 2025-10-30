import 'package:genesis_workspace/data/real_time_events/datasources/real_time_events_data_soure.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_response_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart';

class RealTimeEventsRepositoryImpl implements RealTimeEventsRepository {
  final RealTimeEventsDataSource _dataSource;

  RealTimeEventsRepositoryImpl(this._dataSource);

  @override
  Future<RegisterQueueEntity> registerQueue(RegisterQueueRequestBodyEntity request) async {
    try {
      final dto = await _dataSource.registerQueue(request.toDto());
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EventsByQueueIdResponseEntity> getEventsByQueueId(
    EventsByQueueIdRequestBodyEntity body,
  ) async {
    try {
      final dto = body.toDto();
      final responseDto = await _dataSource.getEventsByQueueId(dto);
      return responseDto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteQueue(String queueId) async {
    try {
      await _dataSource.deleteQueue(queueId);
    } catch (e) {
      rethrow;
    }
  }
}
