import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';

abstract class EventEntity {
  final int id;
  final EventType type;

  EventEntity({required this.id, required this.type});
}
