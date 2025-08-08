import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ReactionOp {
  @JsonValue('add')
  add,
  @JsonValue('remove')
  remove,
}
