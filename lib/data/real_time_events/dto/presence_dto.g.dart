// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresenceDto _$PresenceDtoFromJson(Map<String, dynamic> json) => PresenceDto(
  presence: (json['presence'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, ClientPresenceDto.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$PresenceDtoToJson(PresenceDto instance) =>
    <String, dynamic>{'presence': instance.presence};
