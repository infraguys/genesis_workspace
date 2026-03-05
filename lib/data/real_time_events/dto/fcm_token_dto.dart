class RegisterFcmTokenDto {
  final String token;
  RegisterFcmTokenDto({required this.token});

  String get bouncerToken => 'workspace:$token';
}
