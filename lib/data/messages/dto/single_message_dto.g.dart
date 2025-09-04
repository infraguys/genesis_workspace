// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleMessageResponseDto _$SingleMessageResponseDtoFromJson(
  Map<String, dynamic> json,
) => SingleMessageResponseDto(
  msg: json['msg'] as String,
  result: json['result'] as String,
  message: MessageDto.fromJson(json['message'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SingleMessageResponseDtoToJson(
  SingleMessageResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'message': instance.message,
};
