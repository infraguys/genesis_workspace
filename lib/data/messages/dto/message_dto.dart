import 'package:genesis_workspace/data/real_time_events/dto/recipient_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  final int id;
  @JsonKey(name: "is_me_message")
  final bool isMeMessage;
  @JsonKey(name: "avatar_url")
  final String? avatarUrl;
  final String content;
  @JsonKey(name: "sender_id")
  final int senderId;
  @JsonKey(name: "sender_full_name")
  final String senderFullName;
  @JsonKey(name: "display_recipient")
  final List<RecipientDto> displayRecipient;

  MessageDto({
    required this.id,
    required this.isMeMessage,
    this.avatarUrl,
    required this.content,
    required this.senderId,
    required this.senderFullName,
    required this.displayRecipient,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) => _$MessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);

  MessageEntity toEntity() => MessageEntity(
    id: id,
    isMeMessage: isMeMessage,
    avatarUrl: avatarUrl,
    content: content,
    senderId: senderId,
    senderFullName: senderFullName,
    displayRecipient: displayRecipient.map((e) => e.toEntity()).toList(),
  );
}
