import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/enums/typing_message_type.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/data/real_time_events/dto/recipient_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/sender_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'typing_event_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class TypingEventDto extends EventDto {
  @JsonKey(name: 'message_type')
  final TypingMessageType messageType;
  final TypingEventOp op;
  final SenderDto sender;
  final List<RecipientDto>? recipients;
  @JsonKey(name: 'stream_id')
  final int? streamId;
  final String? topic;

  TypingEventDto({
    required int id,
    required EventType type,
    required this.messageType,
    required this.op,
    required this.sender,
    this.recipients,
    this.streamId,
    this.topic,
  }) : super(id: id, type: type);

  factory TypingEventDto.fromJson(Map<String, dynamic> json) => _$TypingEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TypingEventDtoToJson(this);

  @override
  TypingEventEntity toEntity() => TypingEventEntity(
    id: id,
    type: type,
    messageType: messageType,
    op: op,
    sender: sender.toEntity(),
    recipients: recipients?.map((e) => e.toEntity()).toList(),
    streamId: streamId,
    topic: topic,
  );
}
