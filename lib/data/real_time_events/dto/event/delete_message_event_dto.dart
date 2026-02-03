import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delete_message_event_dto.g.dart';

@JsonSerializable()
class DeleteMessageEventDto extends EventDto {
  DeleteMessageEventDto({
    required super.id,
    required super.type,
    required this.messageId,
    required this.messageType,
    this.streamId,
    this.topic,
  });
  @JsonKey(name: 'message_type')
  final MessageType messageType;
  @JsonKey(name: 'message_id')
  final int messageId;
  @JsonKey(name: 'stream_id')
  final int? streamId;
  final String? topic;

  factory DeleteMessageEventDto.fromJson(Map<String, dynamic> json) => _$DeleteMessageEventDtoFromJson(json);

  @override
  DeleteMessageEventEntity toEntity() => DeleteMessageEventEntity(
    id: id,
    type: type,
    messageId: messageId,
    messageType: messageType,
    streamId: streamId,
    topic: topic,
  );
}
