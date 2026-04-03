import 'package:genesis_workspace/data/users/dto/update_my_status_dto.dart';

class UpdateMyStatusRequestEntity {
  final String? statusText;
  final String? emojiCode;
  final String? emojiName;

  UpdateMyStatusRequestEntity({
    this.statusText,
    this.emojiCode,
    this.emojiName,
  });

  UpdateMyStatusRequestDto toDto() => UpdateMyStatusRequestDto(
    statusText: statusText,
    emojiCode: emojiCode,
    emojiName: emojiName,
  );
}
