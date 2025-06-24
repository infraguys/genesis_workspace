// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriptions_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionsResponseDto _$SubscriptionsResponseDtoFromJson(
  Map<String, dynamic> json,
) => SubscriptionsResponseDto(
  msg: json['msg'] as String,
  result: json['result'] as String,
  subscriptions: (json['subscriptions'] as List<dynamic>)
      .map((e) => SubscriptionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SubscriptionsResponseDtoToJson(
  SubscriptionsResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'subscriptions': instance.subscriptions.map((e) => e.toJson()).toList(),
};
