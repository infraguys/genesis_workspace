// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicDto _$TopicDtoFromJson(Map<String, dynamic> json) => TopicDto(
  maxId: (json['max_id'] as num).toInt(),
  name: json['name'] as String,
);

Map<String, dynamic> _$TopicDtoToJson(TopicDto instance) => <String, dynamic>{
  'max_id': instance.maxId,
  'name': instance.name,
};
