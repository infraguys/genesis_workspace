// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topics_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicsResponseDto _$TopicsResponseDtoFromJson(Map<String, dynamic> json) =>
    TopicsResponseDto(
      msg: json['msg'] as String,
      result: json['result'] as String,
      topics: (json['topics'] as List<dynamic>)
          .map((e) => TopicDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TopicsResponseDtoToJson(TopicsResponseDto instance) =>
    <String, dynamic>{
      'msg': instance.msg,
      'result': instance.result,
      'topics': instance.topics,
    };
