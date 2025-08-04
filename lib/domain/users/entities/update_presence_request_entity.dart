import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/data/users/dto/update_presence_request_dto.dart';

class UpdatePresenceRequestEntity {
  int? lastUpdateId;
  final bool? newUserInput;
  final bool? pingOnly;
  final PresenceStatus status;

  UpdatePresenceRequestEntity({
    this.lastUpdateId,
    this.newUserInput,
    this.pingOnly,
    required this.status,
  });

  UpdatePresenceRequestDto toDto() => UpdatePresenceRequestDto(
    lastUpdateId: lastUpdateId,
    status: status,
    newUserInput: newUserInput,
    pingOnly: pingOnly,
  );
}
