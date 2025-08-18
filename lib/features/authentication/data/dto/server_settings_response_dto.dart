import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_settings_response_dto.g.dart';

@JsonSerializable()
class ServerSettingsResponseDto extends ResponseDto {
  @JsonKey(name: 'realm_name')
  final String realmName;
  @JsonKey(name: 'realm_uri')
  final String realmUri;
  @JsonKey(name: 'external_authentication_methods')
  final List<ExternalAuthenticationMethodDto> externalAuthenticationMethods;

  ServerSettingsResponseDto({
    required super.msg,
    required super.result,
    required this.realmName,
    required this.realmUri,
    required this.externalAuthenticationMethods,
  });

  factory ServerSettingsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ServerSettingsResponseDtoFromJson(json);

  ServerSettingsEntity toEntity() => ServerSettingsEntity(
    realmName: realmName,
    realmUri: realmUri,
    externalAuthenticationMethods: externalAuthenticationMethods.map((e) => e.toEntity()).toList(),
  );
}

@JsonSerializable()
class ExternalAuthenticationMethodDto {
  final String name;
  @JsonKey(name: 'login_url')
  final String loginUrl;
  @JsonKey(name: 'signup_url')
  final String signupUrl;
  @JsonKey(name: 'display_name')
  final String displayName;
  ExternalAuthenticationMethodDto({
    required this.name,
    required this.loginUrl,
    required this.signupUrl,
    required this.displayName,
  });

  factory ExternalAuthenticationMethodDto.fromJson(Map<String, dynamic> json) =>
      _$ExternalAuthenticationMethodDtoFromJson(json);

  ExternalAuthenticationMethodEntity toEntity() => ExternalAuthenticationMethodEntity(
    name: name,
    loginUrl: loginUrl,
    signupUrl: signupUrl,
    displayName: displayName,
  );
}
