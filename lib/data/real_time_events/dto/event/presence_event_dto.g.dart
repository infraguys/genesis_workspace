// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresenceEventDto _$PresenceEventDtoFromJson(Map<String, dynamic> json) =>
    PresenceEventDto(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      userId: (json['user_id'] as num).toInt(),
      email: json['email'] as String,
      serverTimestamp: (json['server_timestamp'] as num).toDouble(),
      presence: PresenceDto.fromJson(json['presence'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PresenceEventDtoToJson(PresenceEventDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$EventTypeEnumMap[instance.type]!,
      'user_id': instance.userId,
      'email': instance.email,
      'server_timestamp': instance.serverTimestamp,
      'presence': instance.presence.toJson(),
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
  EventType.unsupported: 'unsupported',
};
