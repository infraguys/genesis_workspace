import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/users/entities/presences_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'presence_dto.g.dart';

@JsonSerializable()
class PresenceDto {
  final PresenceDetailDto? aggregated;
  final PresenceDetailDto? website;

  PresenceDto({required this.aggregated, this.website});

  factory PresenceDto.fromJson(Map<String, dynamic> json) => _$PresenceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PresenceDtoToJson(this);

  PresenceEntity toEntity() =>
      PresenceEntity(aggregated: aggregated?.toEntity(), website: website?.toEntity());
}

@JsonSerializable()
class PresenceDetailDto {
  final PresenceStatus status;
  final int timestamp;
  final bool? pushable;

  PresenceDetailDto({required this.status, required this.timestamp, this.pushable});

  factory PresenceDetailDto.fromJson(Map<String, dynamic> json) =>
      _$PresenceDetailDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PresenceDetailDtoToJson(this);

  PresenceDetailEntity toEntity() =>
      PresenceDetailEntity(status: status, timestamp: timestamp, pushable: pushable);
}
