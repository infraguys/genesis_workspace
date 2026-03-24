import 'package:genesis_workspace/domain/users/entities/user_status_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUserStatusUseCase {
  final UsersRepository _usersRepository;

  GetUserStatusUseCase(this._usersRepository);

  Future<UserStatusEntity> call(UserStatusRequestEntity body) async {
    try {
      return await _usersRepository.getUserStatus(body);
    } catch (e) {
      rethrow;
    }
  }
}
