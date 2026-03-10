import 'package:genesis_workspace/domain/real_time_events/entities/fcm_token_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterApnsTokenUseCase {
  final RealTimeEventsRepository _repository;
  RegisterApnsTokenUseCase(this._repository);

  Future<void> call(RegisterApnsTokenEntity body) async {
    try {
      await _repository.registerApnsToken(body);
    } catch (e) {
      rethrow;
    }
  }
}
