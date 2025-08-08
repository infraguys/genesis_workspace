// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_reaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmojiReactionResponseDto _$EmojiReactionResponseDtoFromJson(
  Map<String, dynamic> json,
) => EmojiReactionResponseDto(
  msg: json['msg'] as String,
  result: json['result'] as String,
);

Map<String, dynamic> _$EmojiReactionResponseDtoToJson(
  EmojiReactionResponseDto instance,
) => <String, dynamic>{'msg': instance.msg, 'result': instance.result};

EmojiReactionRequestDto _$EmojiReactionRequestDtoFromJson(
  Map<String, dynamic> json,
) => EmojiReactionRequestDto(
  messageId: (json['message_id'] as num).toInt(),
  emojiName: json['emoji_name'] as String,
);

Map<String, dynamic> _$EmojiReactionRequestDtoToJson(
  EmojiReactionRequestDto instance,
) => <String, dynamic>{
  'message_id': instance.messageId,
  'emoji_name': instance.emojiName,
};
