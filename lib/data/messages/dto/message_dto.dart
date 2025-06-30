import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  final int id;
  @JsonKey(name: "is_me_message")
  final bool isMeMessage;
  @JsonKey(name: "avatar_url")
  final String avatarUrl;
  final String content;

  MessageDto({
    required this.id,
    required this.isMeMessage,
    required this.avatarUrl,
    required this.content,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) => _$MessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);

  MessageEntity toEntity() =>
      MessageEntity(id: id, isMeMessage: isMeMessage, avatarUrl: avatarUrl, content: content);
}
