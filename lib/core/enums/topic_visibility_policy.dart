import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum TopicVisibilityPolicy {
  none(0),
  muted(1),
  unmuted(2),
  followed(3)
  ;

  final int value;

  const TopicVisibilityPolicy(this.value);
}
