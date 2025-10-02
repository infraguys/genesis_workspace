// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionDto _$SubscriptionDtoFromJson(Map<String, dynamic> json) =>
    SubscriptionDto(
      name: json['name'] as String,
      subscribers: (json['subscribers'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      streamId: (json['stream_id'] as num).toInt(),
      description: json['description'] as String,
      color: json['color'] as String,
      isMuted: json['is_muted'] as bool,
    );

Map<String, dynamic> _$SubscriptionDtoToJson(SubscriptionDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'subscribers': instance.subscribers,
      'stream_id': instance.streamId,
      'description': instance.description,
      'color': instance.color,
      'is_muted': instance.isMuted,
    };
