import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/users/entities/user_status_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_status_dto.g.dart';

@JsonSerializable()
class UserStatusResponseDto extends ResponseDto {
  final UserStatusDto status;

  UserStatusResponseDto({
    required this.status,
    required super.msg,
    required super.result,
  });

  factory UserStatusResponseDto.fromJson(Map<String, dynamic> json) => _$UserStatusResponseDtoFromJson(json);
}

@JsonSerializable()
class UserStatusDto {
  @JsonKey(name: "emoji_code")
  final String? emojiCode;
  @JsonKey(name: "emoji_name")
  final String? emojiName;
  @JsonKey(name: "status_text")
  final String? statusText;

  UserStatusDto({this.emojiCode, this.emojiName, this.statusText});

  factory UserStatusDto.fromJson(Map<String, dynamic> json) => _$UserStatusDtoFromJson(json);

  UserStatusEntity toEntity() => UserStatusEntity(
    emojiCode: emojiCode,
    emojiName: emojiName,
    statusText: statusText,
  );
}

class UserStatusRequestDto {
  final int userId;
  UserStatusRequestDto({required this.userId});
}
