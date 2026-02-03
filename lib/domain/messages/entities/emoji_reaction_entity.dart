import 'package:genesis_workspace/data/messages/dto/emoji_reaction_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class EmojiReactionResponseEntity extends ResponseEntity {
  EmojiReactionResponseEntity({required super.msg, required super.result});
}

class EmojiReactionRequestEntity {
  final int messageId;
  final String emojiName;

  EmojiReactionRequestEntity({required this.messageId, required this.emojiName});

  EmojiReactionRequestDto toDto() => EmojiReactionRequestDto(messageId: messageId, emojiName: emojiName);
}
