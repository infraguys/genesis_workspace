import 'package:genesis_workspace/core/models/emoji.dart';
import 'package:genesis_workspace/data/users/dto/user_status_dto.dart';

class UserStatusEntity {
  final String? emojiName;
  final String? emojiCode;
  final String? statusText;

  UserStatusEntity({this.emojiName, this.emojiCode, this.statusText});

  UnicodeEmojiDisplay get emojiDisplay =>
      UnicodeEmojiDisplay(emojiName: emojiName ?? '', emojiUnicode: emojiCode ?? '');
}

class UserStatusRequestEntity {
  final int userId;
  UserStatusRequestEntity({required this.userId});

  UserStatusRequestDto toDto() => UserStatusRequestDto(userId: userId);
}
