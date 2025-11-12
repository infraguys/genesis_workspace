import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterQueueUseCase {
  final RealTimeEventsRepository _repository;

  RegisterQueueUseCase(this._repository);

  Future<RegisterQueueEntity> call(RegisterQueueRequestBodyEntity body) async {
    try {
      return await _repository.registerQueue(body);
    } catch (e) {
      rethrow;
    }
  }
}
