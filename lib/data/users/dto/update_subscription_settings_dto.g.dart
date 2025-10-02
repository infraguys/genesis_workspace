// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_subscription_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateSubscriptionSettingsResponseDto
_$UpdateSubscriptionSettingsResponseDtoFromJson(Map<String, dynamic> json) =>
    UpdateSubscriptionSettingsResponseDto(
      msg: json['msg'] as String,
      result: json['result'] as String,
    );

Map<String, dynamic> _$UpdateSubscriptionSettingsResponseDtoToJson(
  UpdateSubscriptionSettingsResponseDto instance,
) => <String, dynamic>{'msg': instance.msg, 'result': instance.result};

UpdateSubscriptionSettingsRequestDto
_$UpdateSubscriptionSettingsRequestDtoFromJson(Map<String, dynamic> json) =>
    UpdateSubscriptionSettingsRequestDto(
      subscriptionData: (json['subscription_data'] as List<dynamic>)
          .map(
            (e) => SubscriptionPropertyUpdateDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

Map<String, dynamic> _$UpdateSubscriptionSettingsRequestDtoToJson(
  UpdateSubscriptionSettingsRequestDto instance,
) => <String, dynamic>{'subscription_data': instance.subscriptionData};

SubscriptionPropertyUpdateDto _$SubscriptionPropertyUpdateDtoFromJson(
  Map<String, dynamic> json,
) => SubscriptionPropertyUpdateDto(
  streamId: (json['stream_id'] as num).toInt(),
  property: $enumDecode(_$SubscriptionPropertyEnumMap, json['property']),
  value: const SubscriptionValueJsonConverter().fromJson(
    json['value'] as Object,
  ),
);

Map<String, dynamic> _$SubscriptionPropertyUpdateDtoToJson(
  SubscriptionPropertyUpdateDto instance,
) => <String, dynamic>{
  'stream_id': instance.streamId,
  'property': _$SubscriptionPropertyEnumMap[instance.property]!,
  'value': const SubscriptionValueJsonConverter().toJson(instance.value),
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
