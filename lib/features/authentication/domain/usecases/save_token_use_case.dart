import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveTokenUseCase {
  final AuthRepository repository;

  SaveTokenUseCase(this.repository);

  Future<void> call({required String email, required String token}) async {
    await repository.saveToken(token: token, email: email);
  }
}
