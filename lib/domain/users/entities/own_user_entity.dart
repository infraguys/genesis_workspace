class OwnUserEntity {
  final String result;
  final String msg;
  final int userId;
  final bool isBot;
  final String fullName;
  final String timezone;
  final String? avatarUrl;

  OwnUserEntity({
    required this.result,
    required this.msg,
    required this.userId,
    required this.isBot,
    required this.fullName,
    required this.timezone,
    this.avatarUrl,
  });
}
