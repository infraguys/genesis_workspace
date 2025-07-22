import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum UpdateMessageFlagsOp {
  @JsonValue('add')
  add,
  @JsonValue('remove')
  remove,
}
