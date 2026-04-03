import 'package:genesis_workspace/data/users/dto/subscription_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscriptions_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class SubscriptionsResponseDto {
  SubscriptionsResponseDto({
    required this.msg,
    required this.result,
    required this.subscriptions,
  });

  final String msg;
  final String result;
  final List<SubscriptionDto> subscriptions;

  factory SubscriptionsResponseDto.fromJson(Map<String, dynamic> json) => _$SubscriptionsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionsResponseDtoToJson(this);
}
