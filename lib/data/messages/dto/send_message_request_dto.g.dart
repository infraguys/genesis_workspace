// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMessageRequestDto _$SendMessageRequestDtoFromJson(
  Map<String, dynamic> json,
) => SendMessageRequestDto(
  type: $enumDecode(_$SendMessageTypeEnumMap, json['type']),
  to: SendMessageRequestDto._toFromJson(json['to']),
  content: json['content'] as String,
  topic: json['topic'] as String?,
  streamId: (json['stream_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$SendMessageRequestDtoToJson(
  SendMessageRequestDto instance,
) => <String, dynamic>{
  'type': _$SendMessageTypeEnumMap[instance.type]!,
  'to': SendMessageRequestDto._toToJson(instance.to),
  'content': instance.content,
  'topic': instance.topic,
  'stream_id': instance.streamId,
};

const _$SendMessageTypeEnumMap = {
  SendMessageType.direct: 'direct',
  SendMessageType.stream: 'stream',
  SendMessageType.channel: 'channel',
};
