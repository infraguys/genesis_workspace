// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_by_id_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelByIdResponseDto _$ChannelByIdResponseDtoFromJson(
  Map<String, dynamic> json,
) => ChannelByIdResponseDto(
  msg: json['msg'] as String,
  result: json['result'] as String,
  stream: StreamDto.fromJson(json['stream'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChannelByIdResponseDtoToJson(
  ChannelByIdResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'stream': instance.stream,
};
