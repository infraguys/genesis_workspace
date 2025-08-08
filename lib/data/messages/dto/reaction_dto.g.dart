// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReactionDto _$ReactionDtoFromJson(Map<String, dynamic> json) => ReactionDto(
  emojiName: json['emoji_name'] as String,
  emojiCode: json['emoji_code'] as String,
  reactionType: $enumDecode(_$ReactionTypeEnumMap, json['reaction_type']),
  userId: (json['user_id'] as num).toInt(),
);

Map<String, dynamic> _$ReactionDtoToJson(ReactionDto instance) =>
    <String, dynamic>{
      'emoji_name': instance.emojiName,
      'emoji_code': instance.emojiCode,
      'reaction_type': _$ReactionTypeEnumMap[instance.reactionType]!,
      'user_id': instance.userId,
    };

const _$ReactionTypeEnumMap = {
  ReactionType.unicode: 'unicode_emoji',
  ReactionType.realm: 'realm_emoji',
  ReactionType.zulip: 'zulip_extra_emoji',
};
