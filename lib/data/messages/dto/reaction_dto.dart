import 'package:genesis_workspace/domain/messages/entities/reaction_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reaction_dto.g.dart';

@JsonSerializable()
class ReactionDto {
  @JsonKey(name: 'emoji_name')
  final String emojiName;
  @JsonKey(name: 'emoji_code')
  final String emojiCode;
  @JsonKey(name: 'reaction_type')
  final ReactionType reactionType;
  @JsonKey(name: 'user_id')
  final int userId;

  ReactionDto({
    required this.emojiName,
    required this.emojiCode,
    required this.reactionType,
    required this.userId,
  });

  factory ReactionDto.fromJson(Map<String, dynamic> json) => _$ReactionDtoFromJson(json);

  ReactionEntity toEntity() => ReactionEntity(
    emojiName: emojiName,
    emojiCode: emojiCode,
    reactionType: reactionType,
    userId: userId,
  );
}

@JsonEnum()
enum ReactionType {
  @JsonValue('unicode_emoji')
  unicode,
  @JsonValue('realm_emoji')
  realm,
  @JsonValue('zulip_extra_emoji')
  zulip,
}
