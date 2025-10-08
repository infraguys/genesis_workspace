import 'package:genesis_workspace/data/users/dto/update_subscription_settings_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class UpdateSubscriptionResponseEntity extends ResponseEntity {
  UpdateSubscriptionResponseEntity({required super.msg, required super.result});
}

/// Entity для запроса: содержит список апдейтов конкретных свойств
class UpdateSubscriptionRequestEntity {
  final List<SubscriptionUpdateEntity> updates;

  UpdateSubscriptionRequestEntity({required this.updates});

  UpdateSubscriptionSettingsRequestDto toDto() => UpdateSubscriptionSettingsRequestDto(
    subscriptionData: updates.expand((e) => e.toDtoList()).toList(),
  );
}

/// Описывает все возможные апдейты для одного streamId
class SubscriptionUpdateEntity {
  final int streamId;
  final String? color;
  final bool? isMuted;
  final bool? inHomeView;
  final bool? pinToTop;
  final bool? desktopNotifications;
  final bool? audibleNotifications;
  final bool? pushNotifications;
  final bool? emailNotifications;
  final bool? wildcardMentionsNotify;

  SubscriptionUpdateEntity({
    required this.streamId,
    this.color,
    this.isMuted,
    this.inHomeView,
    this.pinToTop,
    this.desktopNotifications,
    this.audibleNotifications,
    this.pushNotifications,
    this.emailNotifications,
    this.wildcardMentionsNotify,
  });

  /// Конвертация в список DTO: для каждого ненулевого поля создаётся отдельный SubscriptionPropertyUpdateDto
  List<SubscriptionPropertyUpdateDto> toDtoList() {
    final List<SubscriptionPropertyUpdateDto> list = [];

    if (color != null) {
      list.add(
        SubscriptionPropertyUpdateDto.string(
          streamId: streamId,
          property: SubscriptionProperty.color,
          value: color!,
        ),
      );
    }
    if (isMuted != null) {
      list.add(
        SubscriptionPropertyUpdateDto.bool(
          streamId: streamId,
          property: SubscriptionProperty.isMuted,
          value: isMuted!,
        ),
      );
    }
    if (inHomeView != null) {
      list.add(
        SubscriptionPropertyUpdateDto.bool(
          streamId: streamId,
          property: SubscriptionProperty.inHomeView,
          value: inHomeView!,
        ),
      );
    }
    if (pinToTop != null) {
      list.add(
        SubscriptionPropertyUpdateDto.bool(
          streamId: streamId,
          property: SubscriptionProperty.pinToTop,
          value: pinToTop!,
        ),
      );
    }
    if (desktopNotifications != null) {
      list.add(
        SubscriptionPropertyUpdateDto.bool(
          streamId: streamId,
          property: SubscriptionProperty.desktopNotifications,
          value: desktopNotifications!,
        ),
      );
    }
    if (audibleNotifications != null) {
      list.add(
        SubscriptionPropertyUpdateDto.bool(
          streamId: streamId,
          property: SubscriptionProperty.audibleNotifications,
          value: audibleNotifications!,
        ),
      );
    }
    if (pushNotifications != null) {
      list.add(
        SubscriptionPropertyUpdateDto.bool(
          streamId: streamId,
          property: SubscriptionProperty.pushNotifications,
          value: pushNotifications!,
        ),
      );
    }
    if (emailNotifications != null) {
      list.add(
        SubscriptionPropertyUpdateDto.bool(
          streamId: streamId,
          property: SubscriptionProperty.emailNotifications,
          value: emailNotifications!,
        ),
      );
    }
    if (wildcardMentionsNotify != null) {
      list.add(
        SubscriptionPropertyUpdateDto.bool(
          streamId: streamId,
          property: SubscriptionProperty.wildcardMentionsNotify,
          value: wildcardMentionsNotify!,
        ),
      );
    }

    return list;
  }
}
