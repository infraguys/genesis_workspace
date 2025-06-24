// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionDto _$SubscriptionDtoFromJson(Map<String, dynamic> json) =>
    SubscriptionDto(
      audibleNotifications: json['audible_notifications'] as bool,
      color: json['color'] as String,
      creatorId: (json['creator_id'] as num?)?.toInt(),
      description: json['description'] as String,
      desktopNotifications: json['desktop_notifications'] as bool,
      isArchived: json['is_archived'] as bool,
      isMuted: json['is_muted'] as bool,
      inviteOnly: json['invite_only'] as bool,
      name: json['name'] as String,
      pinToTop: json['pin_to_top'] as bool,
      pushNotifications: json['push_notifications'] as bool,
      streamId: (json['stream_id'] as num).toInt(),
      subscribers: (json['subscribers'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$SubscriptionDtoToJson(SubscriptionDto instance) =>
    <String, dynamic>{
      'audible_notifications': instance.audibleNotifications,
      'color': instance.color,
      'creator_id': instance.creatorId,
      'description': instance.description,
      'desktop_notifications': instance.desktopNotifications,
      'is_archived': instance.isArchived,
      'is_muted': instance.isMuted,
      'invite_only': instance.inviteOnly,
      'name': instance.name,
      'pin_to_top': instance.pinToTop,
      'push_notifications': instance.pushNotifications,
      'stream_id': instance.streamId,
      'subscribers': instance.subscribers,
    };
