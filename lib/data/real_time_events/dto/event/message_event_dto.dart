import 'package:genesis_workspace/data/messages/dto/message_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_event_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class MessageEventDto extends EventDto {
  final MessageDto message;
  final List<String> flags;

  MessageEventDto({
    required super.id,
    required super.type,
    required this.message,
    required this.flags,
  });

  factory MessageEventDto.fromJson(Map<String, dynamic> json) => _$MessageEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageEventDtoToJson(this);

  @override
  MessageEventEntity toEntity() =>
      MessageEventEntity(id: id, type: type, message: message.toEntity(), flags: flags);
}
