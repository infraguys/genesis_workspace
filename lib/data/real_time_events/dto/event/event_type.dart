import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum EventType {
  @JsonValue('typing')
  typing,

  @JsonValue('message')
  message,

  @JsonValue('presence')
  presence,

  @JsonValue('heartbeat')
  heartbeat,

  // static EventType fromJson(String value) {
  //   switch (value) {
  //     case 'typing':
  //       return EventType.typing;
  //     case 'message':
  //       return EventType.message;
  //     case 'presence':
  //       return EventType.presence;
  //     default:
  //       throw UnsupportedError('Unknown event type: $value');
  //   }
  // }
  //
  // String toJson() {
  //   switch (this) {
  //     case EventType.typing:
  //       return 'typing';
  //     case EventType.message:
  //       return 'message';
  //     case EventType.presence:
  //       return 'presence';
  //   }
  // }
}

extension EventTypeX on EventType {
  String toJson() {
    switch (this) {
      case EventType.typing:
        return 'typing';
      case EventType.message:
        return 'message';
      case EventType.presence:
        return 'presence';
      case EventType.heartbeat:
        return 'heartbeat';
    }
  }
}
