// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsersResponseDto _$UsersResponseDtoFromJson(Map<String, dynamic> json) =>
    UsersResponseDto(
      result: json['result'] as String,
      msg: json['msg'] as String,
      members: (json['members'] as List<dynamic>)
          .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UsersResponseDtoToJson(UsersResponseDto instance) =>
    <String, dynamic>{
      'result': instance.result,
      'msg': instance.msg,
      'members': instance.members,
    };
