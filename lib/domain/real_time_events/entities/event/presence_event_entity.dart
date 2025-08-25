import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/presences_response_entity.dart';

class PresenceEventEntity extends EventEntity {
  PresenceEventEntity({
    required super.id,
    required super.type,
    required this.userId,
    required this.email,
    required this.serverTimestamp,
    required this.presenceEntity,
  });
  final int userId;
  final String email;
  final double serverTimestamp;
  final PresenceEntity presenceEntity;
}
