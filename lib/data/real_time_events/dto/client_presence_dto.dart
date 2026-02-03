import 'package:genesis_workspace/domain/real_time_events/entities/client_precence_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client_presence_dto.g.dart';

@JsonSerializable()
class ClientPresenceDto {
  final String client;
  final String status;
  final int timestamp;
  final bool pushable;

  ClientPresenceDto({
    required this.client,
    required this.status,
    required this.timestamp,
    required this.pushable,
  });

  factory ClientPresenceDto.fromJson(Map<String, dynamic> json) => _$ClientPresenceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClientPresenceDtoToJson(this);

  ClientPresenceEntity toEntity() => ClientPresenceEntity(
    client: client,
    status: status,
    timestamp: timestamp,
    pushable: pushable,
  );
}
