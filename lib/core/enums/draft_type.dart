import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum DraftType {
  @JsonValue("stream")
  stream,
  @JsonValue("private")
  private,
}
