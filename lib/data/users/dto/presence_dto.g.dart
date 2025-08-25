// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresenceDto _$PresenceDtoFromJson(Map<String, dynamic> json) => PresenceDto(
  aggregated: json['aggregated'] == null
      ? null
      : PresenceDetailDto.fromJson(json['aggregated'] as Map<String, dynamic>),
  website: json['website'] == null
      ? null
      : PresenceDetailDto.fromJson(json['website'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PresenceDtoToJson(PresenceDto instance) =>
    <String, dynamic>{
      'aggregated': instance.aggregated,
      'website': instance.website,
    };

PresenceDetailDto _$PresenceDetailDtoFromJson(Map<String, dynamic> json) =>
    PresenceDetailDto(
      status: $enumDecode(_$PresenceStatusEnumMap, json['status']),
      timestamp: (json['timestamp'] as num).toInt(),
      pushable: json['pushable'] as bool?,
    );

Map<String, dynamic> _$PresenceDetailDtoToJson(PresenceDetailDto instance) =>
    <String, dynamic>{
      'status': _$PresenceStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp,
      'pushable': instance.pushable,
    };

const _$PresenceStatusEnumMap = {
  PresenceStatus.idle: 'idle',
  PresenceStatus.active: 'active',
  PresenceStatus.offline: 'offline',
};
