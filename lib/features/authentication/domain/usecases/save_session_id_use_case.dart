import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveSessionIdUseCase {
  final AuthRepository _repository;

  SaveSessionIdUseCase(this._repository);

  Future<void> call({required String sessionId}) async {
    await _repository.saveSessionId(sessionId: sessionId);
  }
}
