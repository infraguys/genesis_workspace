import 'package:genesis_workspace/features/authentication/data/dto/api_key_request_dto.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';

abstract class AuthRepository {
  Future<ApiKeyEntity> fetchApiKey(ApiKeyRequestDto body);
  Future<void> saveToken({required String token, required String email});
  Future<void> deleteToken();
}
