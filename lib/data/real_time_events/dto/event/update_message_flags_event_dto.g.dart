// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_message_flags_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMessageFlagsEventDto _$UpdateMessageFlagsEventDtoFromJson(
  Map<String, dynamic> json,
) => UpdateMessageFlagsEventDto(
  id: (json['id'] as num).toInt(),
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  op: $enumDecode(_$UpdateMessageFlagsOpEnumMap, json['op']),
  flag: $enumDecode(_$MessageFlagEnumMap, json['flag']),
  messages: (json['messages'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  all: json['all'] as bool,
);

Map<String, dynamic> _$UpdateMessageFlagsEventDtoToJson(
  UpdateMessageFlagsEventDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$EventTypeEnumMap[instance.type]!,
  'op': _$UpdateMessageFlagsOpEnumMap[instance.op]!,
  'flag': _$MessageFlagEnumMap[instance.flag]!,
  'messages': instance.messages,
  'all': instance.all,
};

const _$EventTypeEnumMap = {
  EventType.typing: 'typing',
  EventType.message: 'message',
  EventType.heartbeat: 'heartbeat',
  EventType.presence: 'presence',
  EventType.updateMessageFlags: 'update_message_flags',
  EventType.reaction: 'reaction',
  EventType.unsupported: 'unsupported',
};

const _$UpdateMessageFlagsOpEnumMap = {
  UpdateMessageFlagsOp.add: 'add',
  UpdateMessageFlagsOp.remove: 'remove',
};

const _$MessageFlagEnumMap = {
  MessageFlag.read: 'read',
  MessageFlag.starred: 'starred',
};
