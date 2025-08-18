import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_request_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';

abstract class AuthRepository {
  Future<ApiKeyEntity> fetchApiKey(ApiKeyRequestEntity body);
  Future<void> saveToken({required String token, required String email});
  Future<void> deleteToken();
  Future<ServerSettingsEntity> getServerSettings();
}
