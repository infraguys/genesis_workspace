// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_presence_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientPresenceDto _$ClientPresenceDtoFromJson(Map<String, dynamic> json) =>
    ClientPresenceDto(
      client: json['client'] as String,
      status: json['status'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      pushable: json['pushable'] as bool,
    );

Map<String, dynamic> _$ClientPresenceDtoToJson(ClientPresenceDto instance) =>
    <String, dynamic>{
      'client': instance.client,
      'status': instance.status,
      'timestamp': instance.timestamp,
      'pushable': instance.pushable,
    };
