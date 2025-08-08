// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
  id: (json['id'] as num).toInt(),
  isMeMessage: json['is_me_message'] as bool,
  avatarUrl: json['avatar_url'] as String?,
  content: json['content'] as String,
  senderId: (json['sender_id'] as num).toInt(),
  senderFullName: json['sender_full_name'] as String,
  displayRecipient: MessageDto._displayRecipientFromJson(
    json['display_recipient'],
  ),
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  flags: (json['flags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  streamId: (json['stream_id'] as num?)?.toInt(),
  subject: json['subject'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  reactions: (json['reactions'] as List<dynamic>)
      .map((e) => ReactionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_me_message': instance.isMeMessage,
      'avatar_url': instance.avatarUrl,
      'content': instance.content,
      'sender_id': instance.senderId,
      'sender_full_name': instance.senderFullName,
      'display_recipient': MessageDto._displayRecipientToJson(
        instance.displayRecipient,
      ),
      'flags': instance.flags,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'stream_id': instance.streamId,
      'subject': instance.subject,
      'timestamp': instance.timestamp,
      'reactions': instance.reactions,
    };

const _$MessageTypeEnumMap = {
  MessageType.private: 'private',
  MessageType.stream: 'stream',
};
