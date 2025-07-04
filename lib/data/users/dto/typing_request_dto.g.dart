// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typing_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypingRequestDto _$TypingRequestDtoFromJson(Map<String, dynamic> json) =>
    TypingRequestDto(
      type: $enumDecode(_$SendMessageTypeEnumMap, json['type']),
      op: $enumDecode(_$TypingEventOpEnumMap, json['op']),
      to: (json['to'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );

Map<String, dynamic> _$TypingRequestDtoToJson(TypingRequestDto instance) =>
    <String, dynamic>{
      'type': _$SendMessageTypeEnumMap[instance.type]!,
      'op': _$TypingEventOpEnumMap[instance.op]!,
      'to': instance.to,
    };

const _$SendMessageTypeEnumMap = {
  SendMessageType.direct: 'direct',
  SendMessageType.stream: 'stream',
  SendMessageType.channel: 'channel',
};

const _$TypingEventOpEnumMap = {
  TypingEventOp.start: 'start',
  TypingEventOp.stop: 'stop',
};
