import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum TypingEventOp {
  @JsonValue('start')
  start,
  @JsonValue('stop')
  stop,
}
