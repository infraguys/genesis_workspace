import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/register_queue_request_body_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterQueueUseCase {
  final RealTimeEventsRepository repository = getIt<RealTimeEventsRepository>();

  Future<RegisterQueueEntity> call(RegisterQueueRequestBodyEntity body) async {
    try {
      return await repository.registerQueue(body);
    } catch (e) {
      rethrow;
    }
  }
}
