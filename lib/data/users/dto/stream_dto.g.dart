// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamDto _$StreamDtoFromJson(Map<String, dynamic> json) => StreamDto(
  streamId: (json['stream_id'] as num).toInt(),
  name: json['name'] as String,
);

Map<String, dynamic> _$StreamDtoToJson(StreamDto instance) => <String, dynamic>{
  'stream_id': instance.streamId,
  'name': instance.name,
};
