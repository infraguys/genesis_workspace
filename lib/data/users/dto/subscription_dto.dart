import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_dto.g.dart';

@JsonSerializable()
class SubscriptionDto {
  @JsonKey(name: 'audible_notifications')
  final bool audibleNotifications;
  final String color;
  @JsonKey(name: 'creator_id')
  final int? creatorId;
  final String description;
  @JsonKey(name: 'desktop_notifications')
  final bool desktopNotifications;
  @JsonKey(name: "is_archived")
  final bool isArchived;
  @JsonKey(name: "is_muted")
  final bool isMuted;
  @JsonKey(name: "invite_only")
  final bool inviteOnly;
  final String name;
  @JsonKey(name: "pin_to_top")
  final bool pinToTop;
  @JsonKey(name: "push_notifications")
  final bool pushNotifications;
  @JsonKey(name: "stream_id")
  final int streamId;
  final List<int> subscribers;

  SubscriptionDto({
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

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) => _$SubscriptionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionDtoToJson(this);

  Subscription toEntity() => Subscription(
    audibleNotifications: audibleNotifications,
    color: color,
    creatorId: creatorId,
    description: description,
    desktopNotifications: desktopNotifications,
    isArchived: isArchived,
    isMuted: isMuted,
    inviteOnly: inviteOnly,
    name: name,
    pinToTop: pinToTop,
    pushNotifications: pushNotifications,
    streamId: streamId,
    subscribers: subscribers,
  );
}
