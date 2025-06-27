import 'package:genesis_workspace/core/enums/event_types.dart';
import 'package:genesis_workspace/data/real_time_events/dto/register_queue_request_body_dto.dart';

class RegisterQueueRequestBodyEntity {
  final List<EventTypes> eventTypes;

  RegisterQueueRequestBodyEntity({required this.eventTypes});

  RegisterQueueRequestBodyDto toDto() => RegisterQueueRequestBodyDto(eventTypes: eventTypes);
}
