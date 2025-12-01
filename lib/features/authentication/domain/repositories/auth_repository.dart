import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_request_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';

abstract class AuthRepository {
  Future<ApiKeyEntity> fetchApiKey(ApiKeyRequestEntity body);
  Future<void> saveToken({required String baseUrl, required String token, required String email});
  Future<void> saveSessionId({required String baseUrl, required String sessionId});
  Future<void> saveCsrfToken({required String baseUrl, required String csrftoken});
  Future<void> deleteToken({required String baseUrl});
  Future<void> deleteSessionId({required String baseUrl});
  Future<void> deleteCsrfToken({required String baseUrl});
  Future<ServerSettingsEntity> getServerSettings();
}
