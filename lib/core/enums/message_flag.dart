import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum MessageFlag {
  @JsonValue('read')
  read,
}
