// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsupported_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnsupportedEventDto _$UnsupportedEventDtoFromJson(Map<String, dynamic> json) =>
    UnsupportedEventDto(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$UnsupportedEventDtoToJson(
  UnsupportedEventDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$EventTypeEnumMap[instance.type]!,
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
