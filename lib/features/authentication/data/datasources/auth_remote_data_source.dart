import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/features/authentication/data/api/auth_api_client.dart';
import 'package:genesis_workspace/features/authentication/data/dto/api_key_request_dto.dart';
import 'package:genesis_workspace/features/authentication/data/dto/fetch_api_key_response_dto.dart';
import 'package:injectable/injectable.dart';

part 'auth_remote_data_source_impl.dart';

abstract class AuthRemoteDataSource {
  Future<FetchApiKeyResponseDto> fetchApiKey(ApiKeyRequestDto body);
}
