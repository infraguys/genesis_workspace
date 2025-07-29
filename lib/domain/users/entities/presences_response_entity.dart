import 'package:genesis_workspace/core/enums/presence_status.dart';

class PresencesResponseEntity {
  final String msg;
  final String result;
  final double serverTimestamp;
  final Map<String, PresenceEntity> presences;

  PresencesResponseEntity({
    required this.msg,
    required this.result,
    required this.serverTimestamp,
    required this.presences,
  });
}

class PresenceEntity {
  final PresenceDetailEntity aggregated;
  final PresenceDetailEntity? website;

  PresenceEntity({required this.aggregated, this.website});
}

class PresenceDetailEntity {
  final String client;
  final PresenceStatus status;
  final int timestamp;
  final bool? pushable;

  PresenceDetailEntity({
    required this.client,
    required this.status,
    required this.timestamp,
    this.pushable,
  });
}
