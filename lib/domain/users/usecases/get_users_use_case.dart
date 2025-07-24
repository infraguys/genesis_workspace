import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUsersUseCase {
  final UsersRepository _repository;

  GetUsersUseCase(this._repository);

  Future<List<UserEntity>> call() async {
    try {
      return await _repository.getUsers();
    } catch (e) {
      rethrow;
    }
  }
}
