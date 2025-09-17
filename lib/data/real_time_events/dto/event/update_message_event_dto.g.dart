// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_message_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMessageEventDto _$UpdateMessageEventDtoFromJson(
  Map<String, dynamic> json,
) => UpdateMessageEventDto(
  id: (json['id'] as num).toInt(),
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  content: json['content'] as String,
  renderedContent: json['rendered_content'] as String,
  messageId: (json['message_id'] as num).toInt(),
);

Map<String, dynamic> _$UpdateMessageEventDtoToJson(
  UpdateMessageEventDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$EventTypeEnumMap[instance.type]!,
  'content': instance.content,
  'rendered_content': instance.renderedContent,
  'message_id': instance.messageId,
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
