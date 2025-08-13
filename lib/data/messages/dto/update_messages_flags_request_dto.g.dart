// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_messages_flags_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMessagesFlagsRequestDto _$UpdateMessagesFlagsRequestDtoFromJson(
  Map<String, dynamic> json,
) => UpdateMessagesFlagsRequestDto(
  messages: (json['messages'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  op: $enumDecode(_$UpdateMessageFlagsOpEnumMap, json['op']),
  flag: $enumDecode(_$MessageFlagEnumMap, json['flag']),
);

Map<String, dynamic> _$UpdateMessagesFlagsRequestDtoToJson(
  UpdateMessagesFlagsRequestDto instance,
) => <String, dynamic>{
  'messages': instance.messages,
  'op': _$UpdateMessageFlagsOpEnumMap[instance.op]!,
  'flag': _$MessageFlagEnumMap[instance.flag]!,
};

const _$UpdateMessageFlagsOpEnumMap = {
  UpdateMessageFlagsOp.add: 'add',
  UpdateMessageFlagsOp.remove: 'remove',
};

const _$MessageFlagEnumMap = {
  MessageFlag.read: 'read',
  MessageFlag.starred: 'starred',
};
