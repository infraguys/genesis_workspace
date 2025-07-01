import 'package:json_annotation/json_annotation.dart';

import 'message_narrow_dto.dart';

part 'messages_request_dto.g.dart';

@JsonSerializable()
class MessagesRequestDto {
  final String anchor;

  final List<MessageNarrowDto>? narrow;

  MessagesRequestDto({required this.anchor, this.narrow});

  factory MessagesRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MessagesRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => {
    "anchor": anchor,
    narrow != null ? "narrow" : '': narrow?.map((e) => e.toJson()).toList(),
  };
}
