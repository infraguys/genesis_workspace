import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum SendMessageType {
  @JsonValue("direct")
  direct,
  @JsonValue("stream")
  stream,
  @JsonValue("channel")
  channel,
}
