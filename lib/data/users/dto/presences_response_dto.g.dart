// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presences_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresencesResponseDto _$PresencesResponseDtoFromJson(
  Map<String, dynamic> json,
) => PresencesResponseDto(
  msg: json['msg'] as String,
  result: json['result'] as String,
  serverTimestamp: (json['server_timestamp'] as num).toDouble(),
  presences: (json['presences'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, PresenceDto.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$PresencesResponseDtoToJson(
  PresencesResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'server_timestamp': instance.serverTimestamp,
  'presences': instance.presences,
};
