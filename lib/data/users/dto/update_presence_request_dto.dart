import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_presence_request_dto.g.dart';

@JsonSerializable()
class UpdatePresenceRequestDto {
  UpdatePresenceRequestDto({
    this.lastUpdateId,
    this.newUserInput,
    this.pingOnly,
    required this.status,
  });

  @JsonKey(name: 'last_update_id')
  final int? lastUpdateId;
  @JsonKey(name: 'new_user_input')
  final bool? newUserInput;
  @JsonKey(name: 'ping_only')
  final bool? pingOnly;
  @JsonKey(name: 'status')
  final PresenceStatus status;


  Map<String, dynamic> toJson() => _$UpdatePresenceRequestDtoToJson(this);
}
