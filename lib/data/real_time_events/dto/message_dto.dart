import 'package:genesis_workspace/data/real_time_events/dto/event/message_recipient_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/recipient_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/message_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class MessageDto {
  final int id;

  @JsonKey(name: 'avatar_url')
  final String avatarUrl;

  final String content;

  @JsonKey(name: "content_type")
  final String contentType;

  @JsonKey(name: 'display_recipient')
  final List<MessageRecipientDto> displayRecipient;

  @JsonKey(name: 'sender_id')
  final int senderId;

  @JsonKey(name: 'recipient_id')
  final int recipientId;

  final int timestamp;

  final String client;

  final String subject;

  @JsonKey(name: 'sender_full_name')
  final String senderFullName;

  @JsonKey(name: 'sender_email')
  final String senderEmail;

  final String type;

  MessageDto({
    required this.id,
    required this.senderId,
    required this.content,
    required this.recipientId,
    required this.timestamp,
    required this.client,
    required this.subject,
    required this.senderFullName,
    required this.senderEmail,
    required this.displayRecipient,
    required this.type,
    required this.avatarUrl,
    required this.contentType,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) => _$MessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);

  MessageEntity toEntity() => MessageEntity(
    id: id,
    senderId: senderId,
    content: content,
    recipientId: recipientId,
    timestamp: timestamp,
    client: client,
    subject: subject,
    senderFullName: senderFullName,
    senderEmail: senderEmail,
    displayRecipient: displayRecipient.map((e) => e.toEntity()).toList(),
    type: type,
    avatarUrl: avatarUrl,
    contentType: contentType,
  );
}
