import 'package:genesis_workspace/core/enums/subscription_op.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_dto.dart';
import 'package:genesis_workspace/data/real_time_events/dto/event/event_type.dart';
import 'package:genesis_workspace/data/users/dto/update_subscription_settings_dto.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/subscription_event_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_event_dto.g.dart';

@JsonSerializable()
class SubscriptionEventDto extends EventDto {
  SubscriptionEventDto({
    required super.id,
    required super.type,
    required this.op,
    this.streamId = -1,
    required this.property,
    required this.value,
  });
  final SubscriptionOp op;
  @JsonKey(name: 'stream_id')
  final int streamId;
  final SubscriptionProperty property;
  @JsonKey(fromJson: SubscriptionValue.fromJson, toJson: SubscriptionValue.toJson)
  final SubscriptionValue value;

  factory SubscriptionEventDto.fromJson(Map<String, dynamic> json) => _$SubscriptionEventDtoFromJson(json);

  @override
  SubscriptionEventEntity toEntity() => SubscriptionEventEntity(
    id: id,
    type: type,
    op: op,
    streamId: streamId,
    property: property,
    value: value,
  );
}
