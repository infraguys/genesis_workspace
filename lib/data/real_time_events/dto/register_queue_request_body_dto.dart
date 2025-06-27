import 'package:genesis_workspace/core/enums/event_types.dart';

class RegisterQueueRequestBodyDto {
  final List<EventTypes> eventTypes;

  RegisterQueueRequestBodyDto({required this.eventTypes});

  Map<String, dynamic> toJson() => {'event_types': eventTypes.map((event) => event.name).toList()};
}
