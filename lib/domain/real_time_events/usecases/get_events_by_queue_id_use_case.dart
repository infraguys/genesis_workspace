import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/events_by_queue_id_response_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetEventsByQueueIdUseCase {
  final RealTimeEventsRepository repository = getIt<RealTimeEventsRepository>();

  Future<EventsByQueueIdResponseEntity> call(EventsByQueueIdRequestBodyEntity body) async {
    try {
      return await repository.getEventsByQueueId(body);
    } catch (e) {
      rethrow;
    }
  }
}
