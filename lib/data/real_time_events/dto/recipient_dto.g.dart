// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipientDto _$RecipientDtoFromJson(Map<String, dynamic> json) => RecipientDto(
  email: json['email'] as String,
  userId: (json['userId'] as num).toInt(),
  fullName: json['full_name'] as String?,
);

Map<String, dynamic> _$RecipientDtoToJson(RecipientDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'userId': instance.userId,
      'full_name': instance.fullName,
    };
