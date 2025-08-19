import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteSessionIdUseCase {
  final AuthRepository _repository;

  DeleteSessionIdUseCase(this._repository);

  Future<void> call() async {
    await _repository.deleteSessionId();
  }
}
