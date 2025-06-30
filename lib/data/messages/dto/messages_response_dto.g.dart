// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagesResponseDto _$MessagesResponseDtoFromJson(Map<String, dynamic> json) =>
    MessagesResponseDto(
      result: json['result'] as String,
      msg: json['msg'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      anchor: (json['anchor'] as num).toInt(),
    );

Map<String, dynamic> _$MessagesResponseDtoToJson(
  MessagesResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'messages': instance.messages,
  'anchor': instance.anchor,
};
