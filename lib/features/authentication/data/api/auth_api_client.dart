import 'package:dio/dio.dart' hide Headers;
import 'package:genesis_workspace/features/authentication/data/dto/fetch_api_key_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  @POST('/fetch_api_key')
  @Headers(<String, dynamic>{'Content-Type': 'application/x-www-form-urlencoded'})
  Future<FetchApiKeyResponseDto> fetchApiKey(@Body() ApiKeyRequestDto requestDto);
}

class ApiKeyRequestDto {
  final String username;
  final String password;

  ApiKeyRequestDto({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}
