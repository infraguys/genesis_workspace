import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_dto.g.dart';

@JsonSerializable()
class SubscriptionDto {
  @JsonKey(name: 'stream_id')
  final int streamId;

  final String name;
  final String description;

  @JsonKey(name: 'rendered_description')
  final String renderedDescription;

  @JsonKey(name: 'date_created')
  final int dateCreated;

  @JsonKey(name: 'creator_id')
  final int? creatorId;

  @JsonKey(name: 'invite_only')
  final bool inviteOnly;

  // final List<int> subscribers;

  @JsonKey(name: 'desktop_notifications')
  final bool? desktopNotifications;

  @JsonKey(name: 'email_notifications')
  final bool? emailNotifications;

  @JsonKey(name: 'wildcard_mentions_notify')
  final bool? wildcardMentionsNotify;

  @JsonKey(name: 'push_notifications')
  final bool? pushNotifications;

  @JsonKey(name: 'audible_notifications')
  final bool? audibleNotifications;

  @JsonKey(name: 'pin_to_top')
  final bool pinToTop;

  @JsonKey(name: 'is_muted')
  final bool isMuted;

  @JsonKey(name: 'in_home_view')
  final bool? inHomeView; // deprecated

  @JsonKey(name: 'is_announcement_only')
  final bool? isAnnouncementOnly; // deprecated

  @JsonKey(name: 'is_web_public')
  final bool isWebPublic;

  final String color;

  @JsonKey(name: 'stream_post_policy')
  final int? streamPostPolicy; // deprecated

  @JsonKey(name: 'message_retention_days')
  final int? messageRetentionDays;

  @JsonKey(name: 'history_public_to_subscribers')
  final bool historyPublicToSubscribers;

  @JsonKey(name: 'first_message_id')
  final int? firstMessageId;

  @JsonKey(name: 'is_recently_active')
  final bool isRecentlyActive;

  @JsonKey(name: 'stream_weekly_traffic')
  final int? streamWeeklyTraffic;

  @JsonKey(name: 'can_add_subscribers_group')
  final int canAddSubscribersGroup;

  @JsonKey(name: 'can_remove_subscribers_group')
  final int canRemoveSubscribersGroup;

  @JsonKey(name: 'can_administer_channel_group')
  final int canAdministerChannelGroup;

  @JsonKey(name: 'can_send_message_group')
  final int canSendMessageGroup;

  @JsonKey(name: 'can_subscribe_group')
  final int canSubscribeGroup;

  @JsonKey(name: 'is_archived')
  final bool isArchived;

  SubscriptionDto({
    required this.streamId,
    required this.name,
    required this.description,
    required this.renderedDescription,
    required this.dateCreated,
    this.creatorId,
    required this.inviteOnly,
    // required this.subscribers,
    this.desktopNotifications,
    this.emailNotifications,
    this.wildcardMentionsNotify,
    this.pushNotifications,
    this.audibleNotifications,
    required this.pinToTop,
    required this.isMuted,
    this.inHomeView,
    this.isAnnouncementOnly,
    required this.isWebPublic,
    required this.color,
    this.streamPostPolicy,
    this.messageRetentionDays,
    required this.historyPublicToSubscribers,
    this.firstMessageId,
    required this.isRecentlyActive,
    this.streamWeeklyTraffic,
    required this.canAddSubscribersGroup,
    required this.canRemoveSubscribersGroup,
    required this.canAdministerChannelGroup,
    required this.canSendMessageGroup,
    required this.canSubscribeGroup,
    required this.isArchived,
  });

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) => _$SubscriptionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionDtoToJson(this);

  SubscriptionEntity toEntity() => SubscriptionEntity(
    streamId: streamId,
    name: name,
    description: description,
    renderedDescription: renderedDescription,
    dateCreated: dateCreated,
    creatorId: creatorId,
    inviteOnly: inviteOnly,
    // subscribers: subscribers,
    desktopNotifications: desktopNotifications,
    emailNotifications: emailNotifications,
    wildcardMentionsNotify: wildcardMentionsNotify,
    pushNotifications: pushNotifications,
    audibleNotifications: audibleNotifications,
    pinToTop: pinToTop,
    isMuted: isMuted,
    inHomeView: inHomeView,
    isAnnouncementOnly: isAnnouncementOnly,
    isWebPublic: isWebPublic,
    color: color,
    streamPostPolicy: streamPostPolicy,
    messageRetentionDays: messageRetentionDays,
    historyPublicToSubscribers: historyPublicToSubscribers,
    firstMessageId: firstMessageId,
    isRecentlyActive: isRecentlyActive,
    streamWeeklyTraffic: streamWeeklyTraffic,
    canAddSubscribersGroup: canAddSubscribersGroup,
    canRemoveSubscribersGroup: canRemoveSubscribersGroup,
    canAdministerChannelGroup: canAdministerChannelGroup,
    canSendMessageGroup: canSendMessageGroup,
    canSubscribeGroup: canSubscribeGroup,
    isArchived: isArchived,
  );
}
