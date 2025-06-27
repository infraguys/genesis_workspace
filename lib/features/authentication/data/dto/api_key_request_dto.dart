import 'package:genesis_workspace/features/authentication/domain/entities/api_key_request_entity.dart';

class ApiKeyRequestDto {
  final String username;
  final String password;

  ApiKeyRequestDto({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
  ApiKeyRequestEntity toEntity() => ApiKeyRequestEntity(username: username, password: password);
}
