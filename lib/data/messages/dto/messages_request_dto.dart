import 'package:json_annotation/json_annotation.dart';

part 'messages_request_dto.g.dart';

@JsonSerializable()
class MessagesRequestDto {
  final int anchor;

  MessagesRequestDto({required this.anchor});

  Map<String, dynamic> toJson() => _$MessagesRequestDtoToJson(this);
}
