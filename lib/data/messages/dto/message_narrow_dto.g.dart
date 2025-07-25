// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_narrow_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageNarrowDto _$MessageNarrowDtoFromJson(Map<String, dynamic> json) =>
    MessageNarrowDto(
      operator: json['operator'] as String,
      operand: MessageNarrowDto._operandFromJson(json['operand']),
    );

Map<String, dynamic> _$MessageNarrowDtoToJson(MessageNarrowDto instance) =>
    <String, dynamic>{
      'operator': instance.operator,
      'operand': MessageNarrowDto._operandToJson(instance.operand),
    };
