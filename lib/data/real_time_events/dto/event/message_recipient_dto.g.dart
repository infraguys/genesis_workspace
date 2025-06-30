// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_recipient_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageRecipientDto _$MessageRecipientDtoFromJson(Map<String, dynamic> json) =>
    MessageRecipientDto(
      email: json['email'] as String,
      id: (json['id'] as num).toInt(),
      fullName: json['full_name'] as String,
    );

Map<String, dynamic> _$MessageRecipientDtoToJson(
  MessageRecipientDto instance,
) => <String, dynamic>{
  'email': instance.email,
  'full_name': instance.fullName,
  'id': instance.id,
};
