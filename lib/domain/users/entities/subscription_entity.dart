class SubscriptionEntity {
  final int streamId;
  final String name;
  final String description;
  final String renderedDescription;
  final int dateCreated;
  final int? creatorId;
  final bool inviteOnly;
  // final List<int> subscribers;
  final bool? desktopNotifications;
  final bool? emailNotifications;
  final bool? wildcardMentionsNotify;
  final bool? pushNotifications;
  final bool? audibleNotifications;
  final bool pinToTop;
  final bool isMuted;
  final bool? inHomeView;
  final bool? isAnnouncementOnly;
  final bool isWebPublic;
  final String color;
  final int? streamPostPolicy;
  final int? messageRetentionDays;
  final bool historyPublicToSubscribers;
  final int? firstMessageId;
  final bool isRecentlyActive;
  final int? streamWeeklyTraffic;
  final int canAddSubscribersGroup;
  final int canRemoveSubscribersGroup;
  final int canAdministerChannelGroup;
  final int canSendMessageGroup;
  final int canSubscribeGroup;
  final bool isArchived;

  SubscriptionEntity({
    required this.streamId,
    required this.name,
    required this.description,
    required this.renderedDescription,
    required this.dateCreated,
    required this.creatorId,
    required this.inviteOnly,
    // required this.subscribers,
    required this.desktopNotifications,
    required this.emailNotifications,
    required this.wildcardMentionsNotify,
    required this.pushNotifications,
    required this.audibleNotifications,
    required this.pinToTop,
    required this.isMuted,
    required this.inHomeView,
    required this.isAnnouncementOnly,
    required this.isWebPublic,
    required this.color,
    required this.streamPostPolicy,
    required this.messageRetentionDays,
    required this.historyPublicToSubscribers,
    required this.firstMessageId,
    required this.isRecentlyActive,
    required this.streamWeeklyTraffic,
    required this.canAddSubscribersGroup,
    required this.canRemoveSubscribersGroup,
    required this.canAdministerChannelGroup,
    required this.canSendMessageGroup,
    required this.canSubscribeGroup,
    required this.isArchived,
  });
}
