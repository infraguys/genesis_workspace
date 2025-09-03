import 'package:genesis_workspace/data/messages/dto/message_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_response_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'messages_response_dto.g.dart';

@JsonSerializable()
class MessagesResponseDto {
  final String msg;
  final String result;
  final List<MessageDto> messages;
  final int anchor;

  MessagesResponseDto({
    required this.result,
    required this.msg,
    required this.messages,
    required this.anchor,
  });

  factory MessagesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MessagesResponseDtoFromJson(json);

  MessagesResponseEntity toEntity() => MessagesResponseEntity(
    msg: msg,
    result: result,
    messages: messages.map((m) => m.toEntity()).toList(),
    anchor: anchor,
  );
}
