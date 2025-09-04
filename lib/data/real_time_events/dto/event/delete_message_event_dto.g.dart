// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_message_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteMessageEventDto _$DeleteMessageEventDtoFromJson(
  Map<String, dynamic> json,
) => DeleteMessageEventDto(
  id: (json['id'] as num).toInt(),
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  messageId: (json['message_id'] as num).toInt(),
  messageType: $enumDecode(_$MessageTypeEnumMap, json['message_type']),
  streamId: (json['stream_id'] as num?)?.toInt(),
  topic: json['topic'] as String?,
);

Map<String, dynamic> _$DeleteMessageEventDtoToJson(
  DeleteMessageEventDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$EventTypeEnumMap[instance.type]!,
  'message_type': _$MessageTypeEnumMap[instance.messageType]!,
  'message_id': instance.messageId,
  'stream_id': instance.streamId,
  'topic': instance.topic,
};

const _$EventTypeEnumMap = {
  EventType.typing: 'typing',
  EventType.message: 'message',
  EventType.heartbeat: 'heartbeat',
  EventType.presence: 'presence',
  EventType.updateMessageFlags: 'update_message_flags',
  EventType.reaction: 'reaction',
  EventType.deleteMessage: 'delete_message',
  EventType.unsupported: 'unsupported',
};

const _$MessageTypeEnumMap = {
  MessageType.private: 'private',
  MessageType.stream: 'stream',
};
