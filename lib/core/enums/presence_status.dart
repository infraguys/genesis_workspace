import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum PresenceStatus {
  @JsonValue("idle")
  idle,
  @JsonValue("active")
  active,
  @JsonValue('offline')
  offline,
}
