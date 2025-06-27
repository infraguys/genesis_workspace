import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/real_time_events/datasources/real_time_events_data_soure.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/get_events_by_queue_id_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: RealTimeEventsRepository)
class RealTimeEventsRepositoryImpl implements RealTimeEventsRepository {
  final RealTimeEventsDataSource dataSource = getIt<RealTimeEventsDataSource>();

  @override
  Future<RegisterQueueEntity> registerQueue(RegisterQueueRequestBodyEntity request) async {
    final dto = await dataSource.registerQueue(request.toDto());
    return dto.toEntity();
  }

  @override
  Future<void> getEventsByQueueId(GetEventsByQueueIdRequestBodyEntity body) async {
    final dto = body.toDto();
    await dataSource.getEventsByQueueId(dto);
  }
}
