import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class PresencesResponseEntity extends ResponseEntity {
  final double serverTimestamp;
  final Map<String, PresenceEntity> presences;

  PresencesResponseEntity({
    required super.msg,
    required super.result,
    required this.serverTimestamp,
    required this.presences,
  });
}

class PresenceEntity {
  final PresenceDetailEntity? aggregated;
  final PresenceDetailEntity? website;

  PresenceEntity({required this.aggregated, this.website});
}

class PresenceDetailEntity {
  final PresenceStatus status;
  final int timestamp;
  final bool? pushable;

  PresenceDetailEntity({required this.status, required this.timestamp, this.pushable});
}
