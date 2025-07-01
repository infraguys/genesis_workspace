// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typing_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypingEventDto _$TypingEventDtoFromJson(Map<String, dynamic> json) =>
    TypingEventDto(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      messageType: json['message_type'] as String,
      op: json['op'] as String,
      sender: SenderDto.fromJson(json['sender'] as Map<String, dynamic>),
      recipients: (json['recipients'] as List<dynamic>)
          .map((e) => RecipientDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TypingEventDtoToJson(TypingEventDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$EventTypeEnumMap[instance.type]!,
      'message_type': instance.messageType,
      'op': instance.op,
      'sender': instance.sender.toJson(),
      'recipients': instance.recipients.map((e) => e.toJson()).toList(),
    };

const _$EventTypeEnumMap = {
  EventType.typing: 'typing',
  EventType.message: 'message',
  EventType.heartbeat: 'heartbeat',
  EventType.presence: 'presence',
  EventType.unsupported: 'unsupported',
};
