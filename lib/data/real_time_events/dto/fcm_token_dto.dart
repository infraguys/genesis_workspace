import 'package:genesis_workspace/core/utils/platform_info/platform_info.dart';

class RegisterFcmTokenDto {
  final String token;
  RegisterFcmTokenDto({required this.token});

  String get bouncerToken => platformInfo.isIos ? 'workspace:apple:$token' : 'workspace:android:$token';
}

class RegisterApnsTokenDto {
  final String token;
  final String appId;

  String get bouncerToken => '$token';

  RegisterApnsTokenDto({required this.token, required this.appId});
}
