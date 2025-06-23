import 'package:genesis_workspace/features/authentication/data/api/auth_api_client.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class FetchApiKeyUseCase {
  final AuthRepository repository;

  FetchApiKeyUseCase(this.repository);

  Future<ApiKeyEntity> call(String username, String password) async {
    final body = ApiKeyRequestDto(username: username, password: password);
    return await repository.fetchApiKey(body);
  }
}
