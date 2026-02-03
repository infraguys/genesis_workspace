import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_message_flags_event_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateMessageFlagsEventDto extends EventDto {
  final UpdateMessageFlagsOp op;
  final MessageFlag flag;
  final List<int> messages;
  final bool all;

  UpdateMessageFlagsEventDto({
    required super.id,
    required super.type,
    required this.op,
    required this.flag,
    required this.messages,
    required this.all,
  });

  factory UpdateMessageFlagsEventDto.fromJson(Map<String, dynamic> json) => _$UpdateMessageFlagsEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMessageFlagsEventDtoToJson(this);

  @override
  UpdateMessageFlagsEventEntity toEntity() => UpdateMessageFlagsEventEntity(
    id: id,
    type: type,
    op: op,
    flag: flag,
    messages: messages,
    all: all,
  );
}
