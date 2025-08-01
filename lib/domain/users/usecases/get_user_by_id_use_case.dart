import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUserByIdUseCase {
  final UsersRepository _repository;
  GetUserByIdUseCase(this._repository);

  Future<UserEntity> call(int userId) async {
    try {
      return await _repository.getUserById(userId);
    } catch (e) {
      rethrow;
    }
  }
}
