import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum EventType {
  @JsonValue('typing')
  typing,

  @JsonValue('message')
  message,

  @JsonValue('heartbeat')
  heartbeat,

  @JsonValue('presence')
  presence,

  @JsonValue('update_message_flags')
  updateMessageFlags,

  @JsonValue('reaction')
  reaction,

  @JsonValue('delete_message')
  deleteMessage,

  @JsonValue('update_message')
  updateMessage,

  unsupported,
}

extension EventTypeX on EventType {
  String toJson() {
    switch (this) {
      case EventType.typing:
        return 'typing';
      case EventType.message:
        return 'message';
      case EventType.heartbeat:
        return 'heartbeat';
      case EventType.updateMessageFlags:
        return 'update_message_flags';
      case EventType.reaction:
        return 'reaction';
      case EventType.presence:
        return 'presence';
      case EventType.deleteMessage:
        return 'delete_message';
      case EventType.updateMessage:
        return 'update_message';
      default:
        return 'unsupported';
    }
  }

  static EventType fromJson(String value) {
    switch (value) {
      case 'typing':
        return EventType.typing;
      case 'message':
        return EventType.message;
      case 'heartbeat':
        return EventType.heartbeat;
      case 'presence':
        return EventType.presence;
      case 'update_message_flags':
        return EventType.updateMessageFlags;
      case 'reaction':
        return EventType.reaction;
      case 'delete_message':
        return EventType.deleteMessage;
      case 'update_message':
        return EventType.updateMessage;
      default:
        return EventType.unsupported;
    }
  }
}
