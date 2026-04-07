import 'package:genesis_workspace/core/enums/subscription_op.dart';
import 'package:genesis_workspace/data/users/dto/update_subscription_settings_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';

sealed class SubscriptionEventEntity extends EventEntity {
  SubscriptionEventEntity({
    required super.id,
    required super.type,
    super.organizationId,
    required this.op,
  });
  final SubscriptionOp op;
}

final class SubscriptionUpdateEventEntity extends SubscriptionEventEntity {
  SubscriptionUpdateEventEntity({
    required super.id,
    required super.type,
    super.organizationId,
    required this.streamId,
    required this.property,
    required this.value,
  }) : super(op: SubscriptionOp.update);

  final int streamId;
  final SubscriptionProperty property;
  final SubscriptionValue value;
}

final class SubscriptionAddEventEntity extends SubscriptionEventEntity {
  SubscriptionAddEventEntity({
    required super.id,
    required super.type,
    super.organizationId,
    required this.subscriptions,
  }) : super(op: SubscriptionOp.add);

  final List<SubscriptionEntity> subscriptions;
}

final class SubscriptionUnsupportedEventEntity extends SubscriptionEventEntity {
  SubscriptionUnsupportedEventEntity({
    required super.id,
    required super.type,
    super.organizationId,
    required super.op,
  });
}
