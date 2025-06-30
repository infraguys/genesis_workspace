import 'package:genesis_workspace/data/real_time_events/dto/client_presence_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/presence_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'presence_dto.g.dart';

@JsonSerializable()
class PresenceDto {
  final Map<String, ClientPresenceDto> presence;

  PresenceDto({required this.presence});

  factory PresenceDto.fromJson(Map<String, dynamic> json) {
    final presenceMap = (json['presence'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, ClientPresenceDto.fromJson(value as Map<String, dynamic>)),
    );

    return PresenceDto(presence: presenceMap);
  }

  Map<String, dynamic> toJson() => {'presence': presence.map((k, v) => MapEntry(k, v.toJson()))};

  PresenceEntity toEntity() =>
      PresenceEntity(presence: presence.map((k, v) => MapEntry(k, v.toEntity())));
}
