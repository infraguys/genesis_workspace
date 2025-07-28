import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum TypingMessageType {
  @JsonValue("direct")
  direct,
  @JsonValue("stream")
  stream,
}
