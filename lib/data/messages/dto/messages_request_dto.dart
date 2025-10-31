import 'package:json_annotation/json_annotation.dart';

import 'message_narrow_dto.dart';

part 'messages_request_dto.g.dart';

@JsonSerializable()
class MessagesRequestDto {
  final String anchor;

  final List<MessageNarrowDto>? narrow;

  final int? numBefore;
  final int? numAfter;

  final bool applyMarkdown;
  final bool clientGravatar;

  MessagesRequestDto({
    required this.anchor,
    this.narrow,
    this.numBefore,
    this.numAfter,
    this.applyMarkdown = true,
    this.clientGravatar = false,
  });

  factory MessagesRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MessagesRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => {
    "anchor": anchor,
    narrow != null ? "narrow" : '': narrow?.map((e) => e.toJson()).toList(),
    "num_before": numBefore,
    "num_after": numAfter,
    "apply_markdown": applyMarkdown,
    "client_gravatar": clientGravatar,
  };
}
