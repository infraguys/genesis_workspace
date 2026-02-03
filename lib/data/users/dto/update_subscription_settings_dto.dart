import 'dart:convert';

import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/users/entities/update_subscription_settings_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_subscription_settings_dto.g.dart';

@JsonSerializable()
class UpdateSubscriptionSettingsResponseDto extends ResponseDto {
  UpdateSubscriptionSettingsResponseDto({required super.msg, required super.result});

  factory UpdateSubscriptionSettingsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateSubscriptionSettingsResponseDtoFromJson(json);

  UpdateSubscriptionResponseEntity toEntity() => UpdateSubscriptionResponseEntity(msg: msg, result: result);
}

@JsonSerializable()
class UpdateSubscriptionSettingsRequestDto {
  @JsonKey(name: 'subscription_data')
  final List<SubscriptionPropertyUpdateDto> subscriptionData;

  UpdateSubscriptionSettingsRequestDto({required this.subscriptionData});

  factory UpdateSubscriptionSettingsRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateSubscriptionSettingsRequestDtoFromJson(json);

  Map<String, dynamic> toJson() {
    return {'subscription_data': subscriptionData.map((item) => item.toJson()).toList()};
  }

  String toForm() => jsonEncode(subscriptionData.map((e) => e.toJson()).toList());
}

@JsonSerializable()
class SubscriptionPropertyUpdateDto {
  @JsonKey(name: 'stream_id')
  final int streamId;

  final SubscriptionProperty property;

  @SubscriptionValueJsonConverter()
  final SubscriptionValue value;

  SubscriptionPropertyUpdateDto({
    required this.streamId,
    required this.property,
    required this.value,
  });

  factory SubscriptionPropertyUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPropertyUpdateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPropertyUpdateDtoToJson(this);

  factory SubscriptionPropertyUpdateDto.bool({
    required int streamId,
    required SubscriptionProperty property,
    required bool value,
  }) => SubscriptionPropertyUpdateDto(
    streamId: streamId,
    property: property,
    value: BoolSubscriptionValue(value),
  );

  factory SubscriptionPropertyUpdateDto.string({
    required int streamId,
    required SubscriptionProperty property,
    required String value,
  }) => SubscriptionPropertyUpdateDto(
    streamId: streamId,
    property: property,
    value: StringSubscriptionValue(value),
  );
}

@JsonEnum(alwaysCreate: true)
enum SubscriptionProperty {
  @JsonValue('color')
  color,

  @JsonValue('is_muted')
  isMuted,

  @JsonValue('in_home_view')
  inHomeView,

  @JsonValue('pin_to_top')
  pinToTop,

  @JsonValue('desktop_notifications')
  desktopNotifications,

  @JsonValue('audible_notifications')
  audibleNotifications,

  @JsonValue('push_notifications')
  pushNotifications,

  @JsonValue('email_notifications')
  emailNotifications,

  @JsonValue('wildcard_mentions_notify')
  wildcardMentionsNotify,
}

/// Разрешён только bool или String.
sealed class SubscriptionValue {
  const SubscriptionValue();
  Object get raw;

  /// Парсит значение из JSON-поля `value`.
  /// Допустимы только bool или String.
  static SubscriptionValue fromJson(Object? json) {
    if (json is bool) return BoolSubscriptionValue(json);
    if (json is String) return StringSubscriptionValue(json);
    throw ArgumentError(
      'Unsupported value type for SubscriptionValue. Expected bool or String, got: $json',
    );
  }

  /// Преобразует в JSON-значение для поля `value`.
  /// Возвращает либо bool, либо String.
  static Object toJson(SubscriptionValue value) => value.raw;
}

class BoolSubscriptionValue extends SubscriptionValue {
  final bool value;
  const BoolSubscriptionValue(this.value);
  @override
  Object get raw => value;
}

class StringSubscriptionValue extends SubscriptionValue {
  final String value;
  const StringSubscriptionValue(this.value);
  @override
  Object get raw => value;
}

class SubscriptionValueJsonConverter implements JsonConverter<SubscriptionValue, Object> {
  const SubscriptionValueJsonConverter();

  @override
  SubscriptionValue fromJson(Object json) {
    if (json is bool) return BoolSubscriptionValue(json);
    if (json is String) return StringSubscriptionValue(json);
    throw ArgumentError('Value must be String or bool, got: $json');
  }

  @override
  Object toJson(SubscriptionValue object) => object.raw;
}
