import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveCsrftokenUseCase {
  final AuthRepository _repository;

  SaveCsrftokenUseCase(this._repository);

  Future<void> call({required String baseUrl, required String csrftoken}) async {
    await _repository.saveCsrfToken(baseUrl: baseUrl, csrftoken: csrftoken);
  }
}
