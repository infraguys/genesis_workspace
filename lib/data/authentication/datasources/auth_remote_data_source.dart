import 'package:genesis_workspace/data/authentication/api/auth_api_client.dart';
import 'package:genesis_workspace/data/authentication/dto/fetch_api_key_response_dto.dart';

part 'auth_remote_data_source_impl.dart';

abstract class AuthRemoteDataSource {
  Future<FetchApiKeyResponseDto> fetchApiKey(ApiKeyRequestDto body);
}
