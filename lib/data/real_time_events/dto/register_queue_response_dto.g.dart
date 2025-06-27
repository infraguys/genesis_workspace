// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_queue_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterQueueResponseDto _$RegisterQueueResponseDtoFromJson(
  Map<String, dynamic> json,
) => RegisterQueueResponseDto(
  queueId: json['queue_id'] as String,
  msg: json['msg'] as String,
  result: json['result'] as String,
  lastEventId: (json['last_event_id'] as num).toInt(),
);

Map<String, dynamic> _$RegisterQueueResponseDtoToJson(
  RegisterQueueResponseDto instance,
) => <String, dynamic>{
  'queue_id': instance.queueId,
  'msg': instance.msg,
  'result': instance.result,
  'last_event_id': instance.lastEventId,
};
