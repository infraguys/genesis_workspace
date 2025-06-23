import 'package:genesis_workspace/features/authentication/data/api/auth_api_client.dart';
import 'package:genesis_workspace/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/api_key_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiKeyEntity> fetchApiKey(ApiKeyRequestDto body) async {
    final dto = await remoteDataSource.fetchApiKey(body);
    return ApiKeyEntity(apiKey: dto.apiKey, email: dto.email, userId: dto.userId);
  }
}
