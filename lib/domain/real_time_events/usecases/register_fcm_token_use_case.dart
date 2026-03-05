import 'package:genesis_workspace/domain/real_time_events/entities/fcm_token_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/repositories/real_time_events_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterFcmTokenUseCase {
  final RealTimeEventsRepository _repository;
  RegisterFcmTokenUseCase(this._repository);

  Future<void> call(RegisterFcmTokenEntity body) async {
    try {
      await _repository.registerFcmToken(body);
    } catch (e) {
      rethrow;
    }
  }
}
