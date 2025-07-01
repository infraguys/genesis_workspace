import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum NarrowOperator {
  @JsonValue('dm')
  dm,
}

extension NarrowOperatorToJson on NarrowOperator {
  String toJson() {
    switch (this) {
      case NarrowOperator.dm:
        return 'dm';
    }
  }
}
