import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum MessageType {
  @JsonValue("private")
  private,
  @JsonValue("stream")
  stream,
}

MessageType messageTypeFromJson(String value) {
  return MessageType.values.firstWhere(
    (element) => element.name == value,
    orElse: () => MessageType.stream,
  );
}

String messageTypeToJson(MessageType value) => value.name;
