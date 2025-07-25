import 'package:json_annotation/json_annotation.dart';

part 'message_narrow_dto.g.dart';

@JsonSerializable()
class MessageNarrowDto {
  final String operator;

  @JsonKey(fromJson: _operandFromJson, toJson: _operandToJson)
  final Object operand;

  MessageNarrowDto({required this.operator, required this.operand});

  factory MessageNarrowDto.fromJson(Map<String, dynamic> json) => _$MessageNarrowDtoFromJson(json);

  // Map<String, dynamic> toJson() => {
  //   "operator": operator,
  //   "operand": operand.map((x) => x).toList(),
  // };

  Map<String, dynamic> toJson() => _$MessageNarrowDtoToJson(this);

  static Object _operandFromJson(dynamic json) {
    if (json is String) return json;
    if (json is List<dynamic>) {
      // Можно уточнить, например: int или String
      if (json.every((e) => e is int)) return List<int>.from(json);
      if (json.every((e) => e is String)) return List<String>.from(json);
      return json;
    }
    return json;
  }

  static dynamic _operandToJson(Object operand) {
    return operand;
  }
}
