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
  @JsonKey(
    name: "display_recipient",
    fromJson: _displayRecipientFromJson,
    toJson: _displayRecipientToJson,
  )
  final List<RecipientDto> displayRecipient;
  final List<String>? flags;

  MessageDto({
    required this.id,
    required this.isMeMessage,
    this.avatarUrl,
    required this.content,
    required this.senderId,
    required this.senderFullName,
    required this.displayRecipient,
    this.flags,
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
    flags: flags,
  );

  static List<RecipientDto> _displayRecipientFromJson(dynamic json) {
    if (json is String) {
      return [];
    } else if (json is List) {
      return json.map((e) => RecipientDto.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static dynamic _displayRecipientToJson(List<RecipientDto>? recipients) {
    return recipients?.map((e) => e.toJson()).toList();
  }
}
