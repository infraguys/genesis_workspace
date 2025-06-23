import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteTokenUseCase {
  final AuthRepository repository;

  DeleteTokenUseCase(this.repository);

  Future<void> call() async {
    await repository.deleteToken();
  }
}
