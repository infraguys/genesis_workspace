import 'package:genesis_workspace/domain/real_time_events/entities/client_precence_entity.dart';

class PresenceEntity {
  final Map<String, ClientPresenceEntity> presence;

  PresenceEntity({required this.presence});
}
