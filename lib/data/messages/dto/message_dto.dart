import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/data/messages/dto/reaction_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/recipient_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/display_recipient.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  final int id;

  @JsonKey(name: 'is_me_message')
  final bool isMeMessage;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  final String content;

  @JsonKey(name: 'sender_id')
  final int senderId;

  @JsonKey(name: 'sender_full_name')
  final String senderFullName;

  @JsonKey(
    name: 'display_recipient',
    fromJson: _displayRecipientFromJson,
    toJson: _displayRecipientToJson,
  )
  final DisplayRecipient displayRecipient;

  final List<String>? flags;

  final MessageType type;

  @JsonKey(name: 'stream_id')
  final int? streamId;

  final String subject;

  final int timestamp;

  final List<ReactionDto> reactions;

  @JsonKey(name: 'recipient_id')
  final int recipientId;

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
    required this.recipientId,
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
    displayRecipient: displayRecipient,
    flags: flags,
    type: type,
    streamId: streamId,
    subject: subject,
    timestamp: timestamp,
    reactions: reactions.map((reaction) => reaction.toEntity()).toList(),
    recipientId: recipientId,
  );

  // ====== Конвертеры display_recipient ======

  static DisplayRecipient _displayRecipientFromJson(dynamic json) {
    if (json is String) {
      return StreamDisplayRecipient(json);
    }
    if (json is List) {
      final recipients = json
          .cast<Map<String, dynamic>>()
          .map((map) => RecipientDto.fromJson(map).toEntity())
          .toList();
      return DirectMessageRecipients(recipients);
    }
    throw FormatException('Unsupported display_recipient format: ${json.runtimeType}');
  }

  static dynamic _displayRecipientToJson(DisplayRecipient value) {
    if (value is StreamDisplayRecipient) {
      return value.streamName;
    }
    if (value is DirectMessageRecipients) {
      return value.recipients.map((recipient) {
        return RecipientDto(
          email: recipient.email,
          userId: recipient.userId,
          fullName: recipient.fullName,
        ).toJson();
      }).toList();
    }
    throw ArgumentError('Unknown DisplayRecipient implementation: $value');
  }
}
