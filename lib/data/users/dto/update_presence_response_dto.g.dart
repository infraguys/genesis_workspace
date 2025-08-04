// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_presence_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePresenceResponseDto _$UpdatePresenceResponseDtoFromJson(
  Map<String, dynamic> json,
) => UpdatePresenceResponseDto(
  msg: json['msg'] as String,
  result: json['result'] as String,
  presenceLastUpdateId: (json['presence_last_update_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdatePresenceResponseDtoToJson(
  UpdatePresenceResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'presence_last_update_id': instance.presenceLastUpdateId,
};
