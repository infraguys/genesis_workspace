// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
  id: (json['id'] as num).toInt(),
  senderId: (json['sender_id'] as num).toInt(),
  content: json['content'] as String,
  recipientId: (json['recipient_id'] as num).toInt(),
  timestamp: (json['timestamp'] as num).toInt(),
  client: json['client'] as String,
  subject: json['subject'] as String,
  senderFullName: json['sender_full_name'] as String,
  senderEmail: json['sender_email'] as String,
  displayRecipient: (json['display_recipient'] as List<dynamic>)
      .map((e) => MessageRecipientDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  type: json['type'] as String,
  avatarUrl: json['avatar_url'] as String?,
  contentType: json['content_type'] as String,
);

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'avatar_url': instance.avatarUrl,
      'content': instance.content,
      'content_type': instance.contentType,
      'display_recipient': instance.displayRecipient
          .map((e) => e.toJson())
          .toList(),
      'sender_id': instance.senderId,
      'recipient_id': instance.recipientId,
      'timestamp': instance.timestamp,
      'client': instance.client,
      'subject': instance.subject,
      'sender_full_name': instance.senderFullName,
      'sender_email': instance.senderEmail,
      'type': instance.type,
    };
