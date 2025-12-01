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
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage);

  @override
  Future<ApiKeyEntity> fetchApiKey(ApiKeyRequestEntity body) async {
    final FetchApiKeyResponseDto dto = await remoteDataSource.fetchApiKey(body.toDto());
    return dto.toEntity();
  }

  @override
  Future<void> saveToken({
    required String baseUrl,
    required String token,
    required String email,
  }) async {
    try {
      await tokenStorage.saveToken(baseUrl: baseUrl, token: token, email: email);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteToken({required String baseUrl}) async {
    try {
      await tokenStorage.deleteToken(baseUrl);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteSessionId({required String baseUrl}) async {
    try {
      await tokenStorage.deleteSessionId(baseUrl);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCsrfToken({required String baseUrl}) async {
    try {
      await tokenStorage.deleteCsrfToken(baseUrl);
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
  Future<void> saveSessionId({
    required String baseUrl,
    required String sessionId,
  }) async {
    try {
      await tokenStorage.saveSessionIdCookie(baseUrl: baseUrl, sessionId: sessionId);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  @override
  Future<void> saveCsrfToken({
    required String baseUrl,
    required String csrftoken,
  }) async {
    try {
      await tokenStorage.saveCsrfTokenCookie(baseUrl: baseUrl, csrftoken: csrftoken);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }
}
