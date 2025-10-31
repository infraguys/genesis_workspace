// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagesRequestDto _$MessagesRequestDtoFromJson(Map<String, dynamic> json) =>
    MessagesRequestDto(
      anchor: json['anchor'] as String,
      narrow: (json['narrow'] as List<dynamic>?)
          ?.map((e) => MessageNarrowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      numBefore: (json['numBefore'] as num?)?.toInt(),
      numAfter: (json['numAfter'] as num?)?.toInt(),
      applyMarkdown: json['applyMarkdown'] as bool? ?? true,
      clientGravatar: json['clientGravatar'] as bool? ?? false,
    );

Map<String, dynamic> _$MessagesRequestDtoToJson(MessagesRequestDto instance) =>
    <String, dynamic>{
      'anchor': instance.anchor,
      'narrow': instance.narrow,
      'numBefore': instance.numBefore,
      'numAfter': instance.numAfter,
      'applyMarkdown': instance.applyMarkdown,
      'clientGravatar': instance.clientGravatar,
    };
