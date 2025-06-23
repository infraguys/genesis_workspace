import 'package:genesis_workspace/features/authentication/data/api/auth_api_client.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';

abstract class AuthRepository {
  Future<ApiKeyEntity> fetchApiKey(ApiKeyRequestDto body);
}
