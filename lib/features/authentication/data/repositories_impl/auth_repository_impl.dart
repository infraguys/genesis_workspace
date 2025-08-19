import 'dart:developer';

import 'package:genesis_workspace/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:genesis_workspace/features/authentication/data/dto/fetch_api_key_response_dto.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_request_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart';
import 'package:genesis_workspace/services/token_storage/token_storage.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage = TokenStorageFactory.create();

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiKeyEntity> fetchApiKey(ApiKeyRequestEntity body) async {
    final FetchApiKeyResponseDto dto = await remoteDataSource.fetchApiKey(body.toDto());
    return dto.toEntity();
  }

  @override
  Future<void> saveToken({required String token, required String email}) async {
    try {
      await tokenStorage.saveToken(token: token, email: email);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await tokenStorage.deleteToken();
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteSessionId() async {
    try {
      await tokenStorage.deleteSessionId();
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCsrfToken() async {
    try {
      await tokenStorage.deleteCsrfToken();
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<ServerSettingsEntity> getServerSettings() async {
    try {
      final dto = await remoteDataSource.getServerSettings();
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveSessionId({required String sessionId}) async {
    try {
      await tokenStorage.saveSessionIdCookie(sessionId: sessionId);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> saveCsrfToken({required String csrftoken}) async {
    try {
      await tokenStorage.saveCsrfTokenCookie(csrftoken: csrftoken);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }
}
