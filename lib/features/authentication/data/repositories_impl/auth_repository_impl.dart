import 'dart:developer';

import 'package:genesis_workspace/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:genesis_workspace/features/authentication/data/dto/fetch_api_key_response_dto.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_request_entity.dart';
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
}
