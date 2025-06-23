import 'package:genesis_workspace/features/authentication/data/api/auth_api_client.dart';
import 'package:genesis_workspace/features/authentication/data/dto/fetch_api_key_response_dto.dart';

part 'auth_remote_data_source_impl.dart';

abstract class AuthRemoteDataSource {
  Future<FetchApiKeyResponseDto> fetchApiKey(ApiKeyRequestDto body);
}
