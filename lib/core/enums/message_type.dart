import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum MessageType {
  @JsonValue("private")
  private,
  @JsonValue("stream")
  stream,
}
