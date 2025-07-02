// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMessageRequestDto _$SendMessageRequestDtoFromJson(
  Map<String, dynamic> json,
) => SendMessageRequestDto(
  type: $enumDecode(_$SendMessageTypeEnumMap, json['type']),
  to: (json['to'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  content: json['content'] as String,
);

Map<String, dynamic> _$SendMessageRequestDtoToJson(
  SendMessageRequestDto instance,
) => <String, dynamic>{
  'type': _$SendMessageTypeEnumMap[instance.type]!,
  'to': instance.to,
  'content': instance.content,
};

const _$SendMessageTypeEnumMap = {
  SendMessageType.direct: 'direct',
  SendMessageType.stream: 'stream',
  SendMessageType.channel: 'channel',
};
