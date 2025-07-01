// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_narrow_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageNarrowDto _$MessageNarrowDtoFromJson(Map<String, dynamic> json) =>
    MessageNarrowDto(
      operator: json['operator'] as String,
      operand: (json['operand'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$MessageNarrowDtoToJson(MessageNarrowDto instance) =>
    <String, dynamic>{
      'operator': instance.operator,
      'operand': instance.operand,
    };
