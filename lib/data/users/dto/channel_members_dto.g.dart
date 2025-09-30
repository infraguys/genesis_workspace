// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_members_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelMembersResponseDto _$ChannelMembersResponseDtoFromJson(
  Map<String, dynamic> json,
) => ChannelMembersResponseDto(
  msg: json['msg'] as String,
  result: json['result'] as String,
  subscribers: (json['subscribers'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$ChannelMembersResponseDtoToJson(
  ChannelMembersResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'subscribers': instance.subscribers,
};
