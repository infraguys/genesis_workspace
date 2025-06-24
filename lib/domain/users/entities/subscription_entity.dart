class Subscription {
  final bool audibleNotifications;
  final String color;
  final int? creatorId;
  final String description;
  final bool desktopNotifications;
  final bool isArchived;
  final bool isMuted;
  final bool inviteOnly;
  final String name;
  final bool pinToTop;
  final bool pushNotifications;
  final int streamId;
  final List<int> subscribers;

  Subscription({
    required this.audibleNotifications,
    required this.color,
    required this.creatorId,
    required this.description,
    required this.desktopNotifications,
    required this.isArchived,
    required this.isMuted,
    required this.inviteOnly,
    required this.name,
    required this.pinToTop,
    required this.pushNotifications,
    required this.streamId,
    required this.subscribers,
  });
}
