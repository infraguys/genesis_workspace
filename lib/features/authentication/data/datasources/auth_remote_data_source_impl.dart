part of 'auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiClient apiClient = AuthApiClient(getIt<Dio>());

  AuthRemoteDataSourceImpl();

  @override
  Future<FetchApiKeyResponseDto> fetchApiKey(ApiKeyRequestDto body) async {
    return await apiClient.fetchApiKey(body);
  }

  @override
  Future<ServerSettingsResponseDto> getServerSettings() async {
    try {
      final response = await apiClient.getServerSettings();
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
