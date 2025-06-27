import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUsersUseCase {
  final UsersRepository repository;

  GetUsersUseCase(this.repository);

  Future<List<UserEntity>> call() async {
    try {
      return await repository.getUsers();
    } catch (e) {
      rethrow;
    }
  }
}
