import 'package:json_annotation/json_annotation.dart';

part 'message_narrow_dto.g.dart';

@JsonSerializable()
class MessageNarrowDto {
  final String operator;

  final List<int> operand;

  MessageNarrowDto({required this.operator, required this.operand});

  factory MessageNarrowDto.fromJson(Map<String, dynamic> json) => _$MessageNarrowDtoFromJson(json);

  Map<String, dynamic> toJson() => {
    "operator": operator,
    "operand": operand.map((x) => x).toList(),
  };
}
