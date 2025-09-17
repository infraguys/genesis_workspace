// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReactionEventDto _$ReactionEventDtoFromJson(Map<String, dynamic> json) =>
    ReactionEventDto(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      op: $enumDecode(_$ReactionOpEnumMap, json['op']),
      userId: (json['user_id'] as num).toInt(),
      messageId: (json['message_id'] as num).toInt(),
      emojiName: json['emoji_name'] as String,
      emojiCode: json['emoji_code'] as String,
      reactionType: $enumDecode(_$ReactionTypeEnumMap, json['reaction_type']),
    );

Map<String, dynamic> _$ReactionEventDtoToJson(ReactionEventDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$EventTypeEnumMap[instance.type]!,
      'op': _$ReactionOpEnumMap[instance.op]!,
      'user_id': instance.userId,
      'message_id': instance.messageId,
      'emoji_name': instance.emojiName,
      'emoji_code': instance.emojiCode,
      'reaction_type': _$ReactionTypeEnumMap[instance.reactionType]!,
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

const _$ReactionOpEnumMap = {
  ReactionOp.add: 'add',
  ReactionOp.remove: 'remove',
};

const _$ReactionTypeEnumMap = {
  ReactionType.unicode: 'unicode_emoji',
  ReactionType.realm: 'realm_emoji',
  ReactionType.zulip: 'zulip_extra_emoji',
};
