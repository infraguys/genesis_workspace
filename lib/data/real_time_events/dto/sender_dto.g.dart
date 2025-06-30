// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sender_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SenderDto _$SenderDtoFromJson(Map<String, dynamic> json) => SenderDto(
  userId: (json['user_id'] as num).toInt(),
  email: json['email'] as String,
);

Map<String, dynamic> _$SenderDtoToJson(SenderDto instance) => <String, dynamic>{
  'user_id': instance.userId,
  'email': instance.email,
};
