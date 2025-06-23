// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_api_key_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FetchApiKeyResponseDto _$FetchApiKeyResponseDtoFromJson(
  Map<String, dynamic> json,
) => FetchApiKeyResponseDto(
  apiKey: json['api_key'] as String,
  email: json['email'] as String,
  msg: json['msg'] as String,
  result: json['result'] as String,
  userId: (json['user_id'] as num).toInt(),
);

Map<String, dynamic> _$FetchApiKeyResponseDtoToJson(
  FetchApiKeyResponseDto instance,
) => <String, dynamic>{
  'api_key': instance.apiKey,
  'email': instance.email,
  'msg': instance.msg,
  'result': instance.result,
  'user_id': instance.userId,
};
