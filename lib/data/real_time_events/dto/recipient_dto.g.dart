// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipientDto _$RecipientDtoFromJson(Map<String, dynamic> json) => RecipientDto(
  email: json['email'] as String,
  userId: (json['user_id'] as num).toInt(),
);

Map<String, dynamic> _$RecipientDtoToJson(RecipientDto instance) =>
    <String, dynamic>{'email': instance.email, 'user_id': instance.userId};
