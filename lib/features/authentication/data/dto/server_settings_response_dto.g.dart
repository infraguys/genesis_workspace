// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_settings_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerSettingsResponseDto _$ServerSettingsResponseDtoFromJson(
  Map<String, dynamic> json,
) => ServerSettingsResponseDto(
  msg: json['msg'] as String,
  result: json['result'] as String,
  realmName: json['realm_name'] as String,
  realmUri: json['realm_uri'] as String,
  externalAuthenticationMethods:
      (json['external_authentication_methods'] as List<dynamic>)
          .map(
            (e) => ExternalAuthenticationMethodDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
);

Map<String, dynamic> _$ServerSettingsResponseDtoToJson(
  ServerSettingsResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'realm_name': instance.realmName,
  'realm_uri': instance.realmUri,
  'external_authentication_methods': instance.externalAuthenticationMethods,
};

ExternalAuthenticationMethodDto _$ExternalAuthenticationMethodDtoFromJson(
  Map<String, dynamic> json,
) => ExternalAuthenticationMethodDto(
  name: json['name'] as String,
  loginUrl: json['login_url'] as String,
  signupUrl: json['signup_url'] as String,
  displayName: json['display_name'] as String,
);

Map<String, dynamic> _$ExternalAuthenticationMethodDtoToJson(
  ExternalAuthenticationMethodDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'login_url': instance.loginUrl,
  'signup_url': instance.signupUrl,
  'display_name': instance.displayName,
};
