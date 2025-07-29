import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteQueueUseCase {
  final RealTimeEventsRepository _repository;
  DeleteQueueUseCase(this._repository);

  Future<void> call(String queueId) async {
    try {
      await _repository.deleteQueue(queueId);
    } catch (e) {
      rethrow;
    }
  }
}
