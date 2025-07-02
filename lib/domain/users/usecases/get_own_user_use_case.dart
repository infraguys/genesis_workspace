import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOwnUserUseCase {
  final UsersRepository repository;

  GetOwnUserUseCase(this.repository);

  Future<UserEntity> call() async {
    try {
      return await repository.getOwnUser();
    } catch (e) {
      rethrow;
    }
  }
}
