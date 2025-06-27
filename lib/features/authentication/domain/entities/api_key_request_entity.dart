import 'package:genesis_workspace/features/authentication/data/dto/api_key_request_dto.dart';

class ApiKeyRequestEntity {
  final String username;
  final String password;

  ApiKeyRequestEntity({required this.username, required this.password});

  ApiKeyRequestDto toDto() => ApiKeyRequestDto(username: username, password: password);
}
