import 'package:dio/dio.dart' hide Headers;
import 'package:genesis_workspace/features/authentication/data/dto/api_key_request_dto.dart';
import 'package:genesis_workspace/features/authentication/data/dto/fetch_api_key_response_dto.dart';
import 'package:genesis_workspace/features/authentication/data/dto/server_settings_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  @POST('/fetch_api_key')
  @Headers(<String, dynamic>{'Content-Type': 'application/x-www-form-urlencoded'})
  Future<FetchApiKeyResponseDto> fetchApiKey(@Body() ApiKeyRequestDto requestDto);

  @GET('/server_settings')
  Future<ServerSettingsResponseDto> getServerSettings();
}
