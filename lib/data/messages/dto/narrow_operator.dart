import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum NarrowOperator {
  @JsonValue('dm')
  dm,
  @JsonValue('channel')
  channel,
  @JsonValue('is')
  isFilter,
  @JsonValue('topic')
  topic,
  @JsonValue('has')
  has,
}

extension NarrowOperatorToJson on NarrowOperator {
  String toJson() {
    switch (this) {
      case NarrowOperator.dm:
        return 'dm';
      case NarrowOperator.channel:
        return 'channel';
      case NarrowOperator.isFilter:
        return 'is';
      case NarrowOperator.topic:
        return 'topic';
      case NarrowOperator.has:
        return 'has';
    }
  }
}
