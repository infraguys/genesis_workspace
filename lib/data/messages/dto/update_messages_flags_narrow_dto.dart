import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/data/messages/dto/message_narrow_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_narrow_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_messages_flags_narrow_dto.g.dart';

@JsonSerializable()
class UpdateMessagesFlagsNarrowRequestDto {
  final String anchor;
  final bool includeAnchor;
  final int? numBefore;
  final int? numAfter;
  @NarrowToJsonConverter()
  final List<MessageNarrowDto>? narrow;
  final UpdateMessageFlagsOp op;
  final MessageFlag flag;

  UpdateMessagesFlagsNarrowRequestDto({
    required this.anchor,
    required this.includeAnchor,
    this.numBefore,
    this.numAfter,
    this.narrow,
    required this.op,
    required this.flag,
  });

  Map<String, dynamic> toJson() => _$UpdateMessagesFlagsNarrowRequestDtoToJson(this);
}

@JsonSerializable()
class UpdateMessagesFlagsNarrowResponseDto extends ResponseDto {
  @JsonKey(name: "first_processed_id")
  final int firstProcessedId;
  @JsonKey(name: "last_processed_id")
  final int lastProcessedId;
  @JsonKey(name: "found_newest")
  final bool foundNewest;
  @JsonKey(name: "found_oldest")
  final bool foundOldest;

  UpdateMessagesFlagsNarrowResponseDto({
    required super.msg,
    required super.result,
    required this.firstProcessedId,
    required this.lastProcessedId,
    required this.foundNewest,
    required this.foundOldest,
  });

  factory UpdateMessagesFlagsNarrowResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateMessagesFlagsNarrowResponseDtoFromJson(json);

  UpdateMessagesFlagsNarrowResponseEntity toEntity() => UpdateMessagesFlagsNarrowResponseEntity(
    msg: msg,
    result: result,
    firstProcessedId: firstProcessedId,
    lastProcessedId: lastProcessedId,
    foundNewest: foundNewest,
    foundOldest: foundOldest,
  );
}
