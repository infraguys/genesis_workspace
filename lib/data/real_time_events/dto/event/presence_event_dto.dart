import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/data/users/dto/presence_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/presence_event_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'presence_event_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PresenceEventDto extends EventDto {
  @JsonKey(name: 'user_id')
  final int userId;
  final String email;
  @JsonKey(name: 'server_timestamp')
  final double serverTimestamp;
  final PresenceDto presence;
  PresenceEventDto({
    required super.id,
    required super.type,
    required this.userId,
    required this.email,
    required this.serverTimestamp,
    required this.presence,
  });

  factory PresenceEventDto.fromJson(Map<String, dynamic> json) => _$PresenceEventDtoFromJson(json);

  @override
  PresenceEventEntity toEntity() => PresenceEventEntity(
    id: id,
    type: type,
    userId: userId,
    email: email,
    serverTimestamp: serverTimestamp,
    presenceEntity: presence.toEntity(),
  );
}
