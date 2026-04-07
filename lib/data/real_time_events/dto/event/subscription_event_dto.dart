import 'package:genesis_workspace/core/enums/subscription_op.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/data/users/dto/subscription_dto.dart';
import 'package:genesis_workspace/data/users/dto/update_subscription_settings_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/subscription_event_entity.dart';

sealed class SubscriptionEventDto extends EventDto {
  SubscriptionEventDto({
    required super.id,
    required super.type,
    required this.op,
  });

  final SubscriptionOp op;

  static SubscriptionEventDto fromJson(Map<String, dynamic> json) {
    final SubscriptionOp op = _subscriptionOpFromJson(json['op']);
    return switch (op) {
      SubscriptionOp.add => SubscriptionAddEventDto.fromJson(json),
      SubscriptionOp.update => SubscriptionUpdateEventDto.fromJson(json),
      _ => SubscriptionUnsupportedEventDto.fromJson(json: json, op: op),
    };
  }

  static int idFromJson(Map<String, dynamic> json) {
    final Object? id = json['id'];
    if (id is num) return id.toInt();
    throw FormatException('Subscription event has invalid id: $id');
  }

  static EventType typeFromJson(Map<String, dynamic> json) {
    final Object? type = json['type'];
    if (type is String) return EventTypeX.fromJson(type);
    return EventType.unsupported;
  }

  static SubscriptionOp _subscriptionOpFromJson(Object? raw) {
    switch (raw) {
      case 'add':
        return SubscriptionOp.add;
      case 'peer_add':
        return SubscriptionOp.peerAdd;
      case 'remove':
        return SubscriptionOp.remove;
      case 'peer_remove':
        return SubscriptionOp.peerRemove;
      case 'update':
        return SubscriptionOp.update;
      default:
        throw FormatException('Unsupported subscription op: $raw');
    }
  }
}

final class SubscriptionUpdateEventDto extends SubscriptionEventDto {
  SubscriptionUpdateEventDto({
    required super.id,
    required super.type,
    required this.streamId,
    required this.property,
    required this.value,
  }) : super(op: SubscriptionOp.update);

  final int streamId;
  final SubscriptionProperty property;
  final SubscriptionValue value;

  factory SubscriptionUpdateEventDto.fromJson(Map<String, dynamic> json) {
    final Object? streamId = json['stream_id'];
    if (streamId is! num) {
      throw FormatException('Subscription update event has invalid stream_id: $streamId');
    }

    final SubscriptionProperty property = _subscriptionPropertyFromJson(json['property']);
    final SubscriptionValue? value = SubscriptionValue.fromJson(json['value']);
    if (value == null) {
      throw FormatException('Subscription update event has invalid value: ${json['value']}');
    }

    return SubscriptionUpdateEventDto(
      id: SubscriptionEventDto.idFromJson(json),
      type: SubscriptionEventDto.typeFromJson(json),
      streamId: streamId.toInt(),
      property: property,
      value: value,
    );
  }

  @override
  SubscriptionUpdateEventEntity toEntity() => SubscriptionUpdateEventEntity(
    id: id,
    type: type,
    streamId: streamId,
    property: property,
    value: value,
  );
}

final class SubscriptionAddEventDto extends SubscriptionEventDto {
  SubscriptionAddEventDto({
    required super.id,
    required super.type,
    required this.subscriptions,
  }) : super(op: SubscriptionOp.add);

  final List<SubscriptionDto> subscriptions;

  factory SubscriptionAddEventDto.fromJson(Map<String, dynamic> json) {
    final Object? rawSubscriptions = json['subscriptions'];
    if (rawSubscriptions is! List) {
      throw FormatException('Subscription add event has invalid subscriptions: $rawSubscriptions');
    }

    final List<SubscriptionDto> subscriptions = rawSubscriptions.map((item) {
      if (item is! Map<String, dynamic>) {
        throw FormatException('Subscription add event has invalid subscription item: $item');
      }
      return SubscriptionDto.fromJson(item);
    }).toList();

    return SubscriptionAddEventDto(
      id: SubscriptionEventDto.idFromJson(json),
      type: SubscriptionEventDto.typeFromJson(json),
      subscriptions: subscriptions,
    );
  }

  @override
  SubscriptionAddEventEntity toEntity() => SubscriptionAddEventEntity(
    id: id,
    type: type,
    subscriptions: subscriptions.map((subscription) => subscription.toEntity()).toList(),
  );
}

final class SubscriptionUnsupportedEventDto extends SubscriptionEventDto {
  SubscriptionUnsupportedEventDto({
    required super.id,
    required super.type,
    required super.op,
  });

  factory SubscriptionUnsupportedEventDto.fromJson({
    required Map<String, dynamic> json,
    required SubscriptionOp op,
  }) => SubscriptionUnsupportedEventDto(
    id: SubscriptionEventDto.idFromJson(json),
    type: SubscriptionEventDto.typeFromJson(json),
    op: op,
  );

  @override
  SubscriptionUnsupportedEventEntity toEntity() => SubscriptionUnsupportedEventEntity(
    id: id,
    type: type,
    op: op,
  );
}

SubscriptionProperty _subscriptionPropertyFromJson(Object? raw) {
  switch (raw) {
    case 'color':
      return SubscriptionProperty.color;
    case 'is_muted':
      return SubscriptionProperty.isMuted;
    case 'in_home_view':
      return SubscriptionProperty.inHomeView;
    case 'pin_to_top':
      return SubscriptionProperty.pinToTop;
    case 'desktop_notifications':
      return SubscriptionProperty.desktopNotifications;
    case 'audible_notifications':
      return SubscriptionProperty.audibleNotifications;
    case 'push_notifications':
      return SubscriptionProperty.pushNotifications;
    case 'email_notifications':
      return SubscriptionProperty.emailNotifications;
    case 'wildcard_mentions_notify':
      return SubscriptionProperty.wildcardMentionsNotify;
    default:
      throw FormatException('Unsupported subscription property: $raw');
  }
}
