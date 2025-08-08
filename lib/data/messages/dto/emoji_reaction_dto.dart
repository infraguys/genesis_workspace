import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/emoji_reaction_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'emoji_reaction_dto.g.dart';

@JsonSerializable()
class EmojiReactionResponseDto extends ResponseDto {
  EmojiReactionResponseDto({required super.msg, required super.result});

  factory EmojiReactionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$EmojiReactionResponseDtoFromJson(json);

  EmojiReactionResponseEntity toEntity() => EmojiReactionResponseEntity(msg: msg, result: result);
}

@JsonSerializable()
class EmojiReactionRequestDto {
  @JsonKey(name: 'message_id')
  final int messageId;
  @JsonKey(name: 'emoji_name')
  final String emojiName;

  EmojiReactionRequestDto({required this.messageId, required this.emojiName});

  Map<String, dynamic> toJson() => _$EmojiReactionRequestDtoToJson(this);
}
