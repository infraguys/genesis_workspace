part of 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<FetchApiKeyResponseDto> fetchApiKey(ApiKeyRequestDto body) async {
    return await apiClient.fetchApiKey(body);
  }
}
