// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'own_user_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnUserResponseDto _$OwnUserResponseDtoFromJson(Map<String, dynamic> json) =>
    OwnUserResponseDto(
      result: json['result'] as String,
      msg: json['msg'] as String,
      userId: (json['user_id'] as num).toInt(),
      isBot: json['is_bot'] as bool,
      fullName: json['full_name'] as String,
      timezone: json['timezone'] as String,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String,
      role: (json['role'] as num).toInt(),
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$OwnUserResponseDtoToJson(OwnUserResponseDto instance) =>
    <String, dynamic>{
      'msg': instance.msg,
      'result': instance.result,
      'user_id': instance.userId,
      'is_bot': instance.isBot,
      'full_name': instance.fullName,
      'timezone': instance.timezone,
      'avatar_url': instance.avatarUrl,
      'email': instance.email,
      'role': instance.role,
      'is_active': instance.isActive,
    };
