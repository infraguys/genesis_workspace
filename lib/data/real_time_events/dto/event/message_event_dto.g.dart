// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageEventDto _$MessageEventDtoFromJson(Map<String, dynamic> json) =>
    MessageEventDto(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      message: MessageDto.fromJson(json['message'] as Map<String, dynamic>),
      flags: (json['flags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MessageEventDtoToJson(MessageEventDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$EventTypeEnumMap[instance.type]!,
      'message': instance.message.toJson(),
      'flags': instance.flags,
    };

const _$EventTypeEnumMap = {
  EventType.typing: 'typing',
  EventType.message: 'message',
  EventType.heartbeat: 'heartbeat',
  EventType.presence: 'presence',
  EventType.updateMessageFlags: 'update_message_flags',
  EventType.reaction: 'reaction',
  EventType.deleteMessage: 'delete_message',
  EventType.updateMessage: 'update_message',
  EventType.subscription: 'subscription',
  EventType.unsupported: 'unsupported',
};
