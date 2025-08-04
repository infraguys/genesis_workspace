import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_response_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdatePresenceUseCase {
  final UsersRepository _repository;
  UpdatePresenceUseCase(this._repository);

  Future<UpdatePresenceResponseEntity> call(UpdatePresenceRequestEntity body) async {
    try {
      return await _repository.updatePresence(body);
    } catch (e) {
      rethrow;
    }
  }
}
