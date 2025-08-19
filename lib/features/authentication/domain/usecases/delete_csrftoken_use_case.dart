import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteCsrftokenUseCase {
  final AuthRepository _repository;

  DeleteCsrftokenUseCase(this._repository);

  Future<void> call() async {
    await _repository.deleteCsrfToken();
  }
}
