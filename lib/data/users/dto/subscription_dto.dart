import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_dto.g.dart';

@JsonSerializable()
class SubscriptionDto {
  final String name;
  final List<int>? subscribers;
  @JsonKey(name: 'stream_id')
  final int streamId;
  final String description;
  final String color;

  SubscriptionDto({
    required this.name,
    this.subscribers,
    required this.streamId,
    required this.description,
    required this.color,
  });

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) => _$SubscriptionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionDtoToJson(this);

  SubscriptionEntity toEntity() => SubscriptionEntity(
    name: name,
    subscribers: subscribers,
    streamId: streamId,
    description: description,
    color: color,
  );
}
