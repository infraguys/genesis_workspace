import 'package:genesis_workspace/core/enums/reaction_op.dart';
import 'package:genesis_workspace/data/messages/dto/reaction_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';

class ReactionEventEntity extends EventEntity {
  final ReactionOp op;
  final int userId;
  final int messageId;
  final String emojiName;
  final String emojiCode;
  final ReactionType reactionType;
  ReactionEventEntity({
    required super.id,
    required super.type,
    super.organizationId,
    required this.op,
    required this.userId,
    required this.messageId,
    required this.emojiName,
    required this.emojiCode,
    required this.reactionType,
  });
}
