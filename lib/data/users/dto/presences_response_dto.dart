import 'package:genesis_workspace/data/users/dto/presence_dto.dart';
import 'package:genesis_workspace/domain/users/entities/presences_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'presences_response_dto.g.dart';

@JsonSerializable()
class PresencesResponseDto {
  final String msg;
  final String result;
  @JsonKey(name: 'server_timestamp')
  final double serverTimestamp;
  final Map<String, PresenceDto> presences;

  PresencesResponseDto({
    required this.msg,
    required this.result,
    required this.serverTimestamp,
    required this.presences,
  });

  factory PresencesResponseDto.fromJson(Map<String, dynamic> json) => _$PresencesResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PresencesResponseDtoToJson(this);

  PresencesResponseEntity toEntity() => PresencesResponseEntity(
    msg: msg,
    result: result,
    serverTimestamp: serverTimestamp,
    presences: presences.map((key, value) => MapEntry(key, value.toEntity())),
  );
}
