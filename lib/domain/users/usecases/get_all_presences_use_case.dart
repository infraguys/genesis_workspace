import 'package:genesis_workspace/domain/users/entities/presences_response_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAllPresencesUseCase {
  final UsersRepository _repository;
  GetAllPresencesUseCase(this._repository);

  Future<PresencesResponseEntity> call() async {
    try {
      return await _repository.getAllPresences();
    } catch (e) {
      rethrow;
    }
  }
}
