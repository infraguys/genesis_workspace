import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_event_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_message_event_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateMessageEventDto extends EventDto {
  final String content;
  @JsonKey(name: 'rendered_content')
  final String renderedContent;
  @JsonKey(name: 'message_id')
  final int messageId;

  UpdateMessageEventDto({
    required super.id,
    required super.type,
    required this.content,
    required this.renderedContent,
    required this.messageId,
  });

  factory UpdateMessageEventDto.fromJson(Map<String, dynamic> json) => _$UpdateMessageEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMessageEventDtoToJson(this);

  @override
  UpdateMessageEventEntity toEntity() => UpdateMessageEventEntity(
    id: id,
    type: type,
    content: content,
    renderedContent: renderedContent,
    messageId: messageId,
  );
}
