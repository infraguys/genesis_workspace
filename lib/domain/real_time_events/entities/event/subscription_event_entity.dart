import 'package:genesis_workspace/core/enums/subscription_op.dart';
import 'package:genesis_workspace/data/users/dto/update_subscription_settings_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/event_entity.dart';

class SubscriptionEventEntity extends EventEntity {
  SubscriptionEventEntity({
    required super.id,
    required super.type,
    super.organizationId,
    required this.op,
    required this.streamId,
    required this.property,
    required this.value,
  });
  final SubscriptionOp op;
  final int streamId;
  final SubscriptionProperty property;
  final SubscriptionValue value;
}
