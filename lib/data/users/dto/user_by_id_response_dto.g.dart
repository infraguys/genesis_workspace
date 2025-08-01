// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_by_id_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserByIdResponseDto _$UserByIdResponseDtoFromJson(Map<String, dynamic> json) =>
    UserByIdResponseDto(
      msg: json['msg'] as String,
      result: json['result'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserByIdResponseDtoToJson(
  UserByIdResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'user': instance.user,
};
