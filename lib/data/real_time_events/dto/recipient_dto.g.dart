// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipient_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipientDto _$RecipientDtoFromJson(Map<String, dynamic> json) => RecipientDto(
  email: json['email'] as String,
  userId: (json['userId'] as num).toInt(),
  fullName: json['fullName'] as String,
);

Map<String, dynamic> _$RecipientDtoToJson(RecipientDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'userId': instance.userId,
      'fullName': instance.fullName,
    };
