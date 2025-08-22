// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_presence_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPresenceResponseDto _$UserPresenceResponseDtoFromJson(
  Map<String, dynamic> json,
) => UserPresenceResponseDto(
  msg: json['msg'] as String,
  result: json['result'] as String,
  presence: PresenceDto.fromJson(json['presence'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserPresenceResponseDtoToJson(
  UserPresenceResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'presence': instance.presence,
};
