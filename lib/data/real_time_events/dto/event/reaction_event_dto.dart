import 'package:genesis_workspace/core/enums/reaction_op.dart';
import 'package:genesis_workspace/data/messages/dto/reaction_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/reaction_event_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reaction_event_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ReactionEventDto extends EventDto {
  final ReactionOp op;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'message_id')
  final int messageId;
  @JsonKey(name: 'emoji_name')
  final String emojiName;
  @JsonKey(name: 'emoji_code')
  final String emojiCode;
  @JsonKey(name: 'reaction_type')
  final ReactionType reactionType;
  ReactionEventDto({
    required super.id,
    required super.type,
    required this.op,
    required this.userId,
    required this.messageId,
    required this.emojiName,
    required this.emojiCode,
    required this.reactionType,
  });

  factory ReactionEventDto.fromJson(Map<String, dynamic> json) => _$ReactionEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionEventDtoToJson(this);

  @override
  ReactionEventEntity toEntity() => ReactionEventEntity(
    id: id,
    type: type,
    op: op,
    userId: userId,
    messageId: messageId,
    emojiName: emojiName,
    emojiCode: emojiCode,
    reactionType: reactionType,
  );
}
