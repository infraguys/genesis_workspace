import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/presence_entity.dart';

class PresenceEventEntity extends EventEntity {
  final int userId;
  final String email;
  final double serverTimestamp;
  final PresenceEntity presence;

  PresenceEventEntity({
    required int id,
    required EventType type,
    required this.userId,
    required this.email,
    required this.serverTimestamp,
    required this.presence,
  }) : super(id: id, type: type);
}
