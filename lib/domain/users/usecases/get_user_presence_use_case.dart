import 'package:genesis_workspace/domain/users/entities/user_presence_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUserPresenceUseCase {
  final UsersRepository _repository;
  GetUserPresenceUseCase(this._repository);

  Future<UserPresenceResponseEntity> call(int userId) async {
    try {
      return await _repository.getUserPresence(UserPresenceRequestEntity(userId: userId));
    } catch (e) {
      rethrow;
    }
  }
}
