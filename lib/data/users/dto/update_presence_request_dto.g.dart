// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_presence_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePresenceRequestDto _$UpdatePresenceRequestDtoFromJson(
  Map<String, dynamic> json,
) => UpdatePresenceRequestDto(
  lastUpdateId: (json['last_update_id'] as num?)?.toInt(),
  newUserInput: json['new_user_input'] as bool?,
  pingOnly: json['ping_only'] as bool?,
  status: $enumDecode(_$PresenceStatusEnumMap, json['status']),
);

Map<String, dynamic> _$UpdatePresenceRequestDtoToJson(
  UpdatePresenceRequestDto instance,
) => <String, dynamic>{
  'last_update_id': instance.lastUpdateId,
  'new_user_input': instance.newUserInput,
  'ping_only': instance.pingOnly,
  'status': _$PresenceStatusEnumMap[instance.status]!,
};

const _$PresenceStatusEnumMap = {
  PresenceStatus.idle: 'idle',
  PresenceStatus.active: 'active',
};
