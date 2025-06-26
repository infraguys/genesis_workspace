// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionDto _$SubscriptionDtoFromJson(Map<String, dynamic> json) =>
    SubscriptionDto(
      streamId: (json['stream_id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      renderedDescription: json['rendered_description'] as String,
      dateCreated: (json['date_created'] as num).toInt(),
      creatorId: (json['creator_id'] as num?)?.toInt(),
      inviteOnly: json['invite_only'] as bool,
      desktopNotifications: json['desktop_notifications'] as bool?,
      emailNotifications: json['email_notifications'] as bool?,
      wildcardMentionsNotify: json['wildcard_mentions_notify'] as bool?,
      pushNotifications: json['push_notifications'] as bool?,
      audibleNotifications: json['audible_notifications'] as bool?,
      pinToTop: json['pin_to_top'] as bool,
      isMuted: json['is_muted'] as bool,
      inHomeView: json['in_home_view'] as bool?,
      isAnnouncementOnly: json['is_announcement_only'] as bool?,
      isWebPublic: json['is_web_public'] as bool,
      color: json['color'] as String,
      streamPostPolicy: (json['stream_post_policy'] as num?)?.toInt(),
      messageRetentionDays: (json['message_retention_days'] as num?)?.toInt(),
      historyPublicToSubscribers: json['history_public_to_subscribers'] as bool,
      firstMessageId: (json['first_message_id'] as num?)?.toInt(),
      isRecentlyActive: json['is_recently_active'] as bool,
      streamWeeklyTraffic: (json['stream_weekly_traffic'] as num?)?.toInt(),
      canAddSubscribersGroup: (json['can_add_subscribers_group'] as num)
          .toInt(),
      canRemoveSubscribersGroup: (json['can_remove_subscribers_group'] as num)
          .toInt(),
      canAdministerChannelGroup: (json['can_administer_channel_group'] as num)
          .toInt(),
      canSendMessageGroup: (json['can_send_message_group'] as num).toInt(),
      canSubscribeGroup: (json['can_subscribe_group'] as num).toInt(),
      isArchived: json['is_archived'] as bool,
    );

Map<String, dynamic> _$SubscriptionDtoToJson(SubscriptionDto instance) =>
    <String, dynamic>{
      'stream_id': instance.streamId,
      'name': instance.name,
      'description': instance.description,
      'rendered_description': instance.renderedDescription,
      'date_created': instance.dateCreated,
      'creator_id': instance.creatorId,
      'invite_only': instance.inviteOnly,
      'desktop_notifications': instance.desktopNotifications,
      'email_notifications': instance.emailNotifications,
      'wildcard_mentions_notify': instance.wildcardMentionsNotify,
      'push_notifications': instance.pushNotifications,
      'audible_notifications': instance.audibleNotifications,
      'pin_to_top': instance.pinToTop,
      'is_muted': instance.isMuted,
      'in_home_view': instance.inHomeView,
      'is_announcement_only': instance.isAnnouncementOnly,
      'is_web_public': instance.isWebPublic,
      'color': instance.color,
      'stream_post_policy': instance.streamPostPolicy,
      'message_retention_days': instance.messageRetentionDays,
      'history_public_to_subscribers': instance.historyPublicToSubscribers,
      'first_message_id': instance.firstMessageId,
      'is_recently_active': instance.isRecentlyActive,
      'stream_weekly_traffic': instance.streamWeeklyTraffic,
      'can_add_subscribers_group': instance.canAddSubscribersGroup,
      'can_remove_subscribers_group': instance.canRemoveSubscribersGroup,
      'can_administer_channel_group': instance.canAdministerChannelGroup,
      'can_send_message_group': instance.canSendMessageGroup,
      'can_subscribe_group': instance.canSubscribeGroup,
      'is_archived': instance.isArchived,
    };
