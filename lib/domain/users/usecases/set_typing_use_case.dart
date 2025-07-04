import 'package:genesis_workspace/domain/users/entities/typing_request_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SetTypingUseCase {
  final UsersRepository _repository;
  SetTypingUseCase(this._repository);

  Future<void> call(TypingRequestEntity body) async {
    try {
      return await _repository.setTyping(body);
    } catch (e) {
      rethrow;
    }
  }
}
