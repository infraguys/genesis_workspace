import 'package:genesis_workspace/domain/users/entities/update_my_status_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateMyStatusUseCase {
  final UsersRepository _usersRepository;

  UpdateMyStatusUseCase(this._usersRepository);

  Future<void> call(UpdateMyStatusRequestEntity body) async {
    return await _usersRepository.updateMyStatus(body);
  }
}
