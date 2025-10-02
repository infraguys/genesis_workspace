// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionEventDto _$SubscriptionEventDtoFromJson(
  Map<String, dynamic> json,
) => SubscriptionEventDto(
  id: (json['id'] as num).toInt(),
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  op: $enumDecode(_$SubscriptionOpEnumMap, json['op']),
  streamId: (json['stream_id'] as num).toInt(),
  property: $enumDecode(_$SubscriptionPropertyEnumMap, json['property']),
  value: SubscriptionValue.fromJson(json['value']),
);

Map<String, dynamic> _$SubscriptionEventDtoToJson(
  SubscriptionEventDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$EventTypeEnumMap[instance.type]!,
  'op': _$SubscriptionOpEnumMap[instance.op]!,
  'stream_id': instance.streamId,
  'property': _$SubscriptionPropertyEnumMap[instance.property]!,
  'value': SubscriptionValue.toJson(instance.value),
};

const _$EventTypeEnumMap = {
  EventType.typing: 'typing',
  EventType.message: 'message',
  EventType.heartbeat: 'heartbeat',
  EventType.presence: 'presence',
  EventType.updateMessageFlags: 'update_message_flags',
  EventType.reaction: 'reaction',
  EventType.deleteMessage: 'delete_message',
  EventType.updateMessage: 'update_message',
  EventType.subscription: 'subscription',
  EventType.unsupported: 'unsupported',
};

const _$SubscriptionOpEnumMap = {
  SubscriptionOp.add: 'add',
  SubscriptionOp.peerAdd: 'peer_add',
  SubscriptionOp.remove: 'remove',
  SubscriptionOp.peerRemove: 'peer_remove',
  SubscriptionOp.update: 'update',
};

const _$SubscriptionPropertyEnumMap = {
  SubscriptionProperty.color: 'color',
  SubscriptionProperty.isMuted: 'is_muted',
  SubscriptionProperty.inHomeView: 'in_home_view',
  SubscriptionProperty.pinToTop: 'pin_to_top',
  SubscriptionProperty.desktopNotifications: 'desktop_notifications',
  SubscriptionProperty.audibleNotifications: 'audible_notifications',
  SubscriptionProperty.pushNotifications: 'push_notifications',
  SubscriptionProperty.emailNotifications: 'email_notifications',
  SubscriptionProperty.wildcardMentionsNotify: 'wildcard_mentions_notify',
};
