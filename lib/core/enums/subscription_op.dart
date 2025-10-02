import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum SubscriptionOp {
  @JsonValue('add')
  add,
  @JsonValue('peer_add')
  peerAdd,
  @JsonValue('remove')
  remove,
  @JsonValue('peer_remove')
  peerRemove,
  @JsonValue('update')
  update,
}
