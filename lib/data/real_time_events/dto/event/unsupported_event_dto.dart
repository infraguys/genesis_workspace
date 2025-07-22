import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/unsupported_event_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unsupported_event_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UnsupportedEventDto extends EventDto {
  UnsupportedEventDto({required int id, required EventType type}) : super(id: id, type: type);

  // factory UnsupportedEventDto.fromJson(Map<String, dynamic> json) =>
  //     _$UnsupportedEventDtoFromJson(json);

  factory UnsupportedEventDto.fromJson(Map<String, dynamic> json) {
    return UnsupportedEventDto(
      id: json['id'],
      type: EventType.values.contains(json['type'])
          ? EventTypeX.fromJson(json['type'])
          : EventType.unsupported,
    );
  }

  Map<String, dynamic> toJson() => _$UnsupportedEventDtoToJson(this);

  @override
  UnsupportedEventEntity toEntity() => UnsupportedEventEntity(id: id, type: type);
}
