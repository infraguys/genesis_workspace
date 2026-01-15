import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/update_messages_flags_narrow_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';

class UpdateMessagesFlagsNarrowRequestEntity {
  final MessageAnchor anchor;
  final bool includeAnchor;
  final int? numBefore;
  final int? numAfter;
  final List<MessageNarrowEntity>? narrow;
  final UpdateMessageFlagsOp op;
  final MessageFlag flag;

  UpdateMessagesFlagsNarrowRequestEntity({
    required this.anchor,
    required this.includeAnchor,
    this.numBefore,
    this.numAfter,
    this.narrow,
    required this.op,
    required this.flag,
  });

  UpdateMessagesFlagsNarrowRequestDto toDto() => UpdateMessagesFlagsNarrowRequestDto(
    anchor: anchor.toJson(),
    includeAnchor: includeAnchor,
    numBefore: numBefore,
    numAfter: numAfter,
    narrow: narrow?.map((narrow) => narrow.toDto()).toList(),
    op: op,
    flag: flag,
  );
}

class UpdateMessagesFlagsNarrowResponseEntity extends ResponseEntity {
  final int firstProcessedId;
  final int lastProcessedId;
  final bool foundNewest;
  final bool foundOldest;

  UpdateMessagesFlagsNarrowResponseEntity({
    required super.result,
    required super.msg,
    required this.firstProcessedId,
    required this.lastProcessedId,
    required this.foundNewest,
    required this.foundOldest,
  });
}
