import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/data/messages/dto/reaction_dto.dart';
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
  final dynamic displayRecipient;
  final List<String>? flags;
  final MessageType type;
  @JsonKey(name: "stream_id")
  final int? streamId;
  final String subject;
  final int timestamp;
  final List<ReactionDto> reactions;

  MessageDto({
    required this.id,
    required this.isMeMessage,
    this.avatarUrl,
    required this.content,
    required this.senderId,
    required this.senderFullName,
    required this.displayRecipient,
    required this.type,
    this.flags,
    this.streamId,
    required this.subject,
    required this.timestamp,
    required this.reactions,
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
    displayRecipient: displayRecipient is List
        ? displayRecipient.map((e) => e.toEntity()).toList()
        : displayRecipient,
    flags: flags,
    type: type,
    streamId: streamId,
    subject: subject,
    timestamp: timestamp,
    reactions: reactions.map((e) => e.toEntity()).toList(),
  );

  static dynamic _displayRecipientFromJson(dynamic json) {
    if (json is String) {
      return json;
    } else if (json is List) {
      return json.map((e) => RecipientDto.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static dynamic _displayRecipientToJson(List<RecipientDto>? recipients) {
    return recipients?.map((e) => e.toJson()).toList();
  }
}
