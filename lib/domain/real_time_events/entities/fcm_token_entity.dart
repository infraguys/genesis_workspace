import 'package:genesis_workspace/data/real_time_events/dto/fcm_token_dto.dart';

class RegisterFcmTokenEntity {
  final String token;
  RegisterFcmTokenEntity({required this.token});

  RegisterFcmTokenDto toDto() => RegisterFcmTokenDto(token: token);
}

class RegisterApnsTokenEntity {
  final String token;
  final String appId;

  RegisterApnsTokenEntity({required this.token, required this.appId});

  RegisterApnsTokenDto toDto() => RegisterApnsTokenDto(token: token, appId: appId);
}
