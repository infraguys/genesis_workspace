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
);

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_me_message': instance.isMeMessage,
      'avatar_url': instance.avatarUrl,
      'content': instance.content,
      'sender_id': instance.senderId,
      'sender_full_name': instance.senderFullName,
    };
