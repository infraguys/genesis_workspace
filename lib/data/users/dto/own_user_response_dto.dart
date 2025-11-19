import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'own_user_response_dto.g.dart';

@JsonSerializable()
class OwnUserResponseDto extends ResponseDto {
  @JsonKey(name: "user_id")
  final int userId;
  @JsonKey(name: "is_owner")
  final bool isOwner;
  @JsonKey(name: "is_guest")
  final bool isGuest;
  @JsonKey(name: "is_admin")
  final bool isAdmin;
  @JsonKey(name: "is_bot")
  final bool isBot;
  @JsonKey(name: "full_name")
  final String fullName;
  final String timezone;
  @JsonKey(name: "avatar_url")
  final String? avatarUrl;
  final String email;
  @JsonKey(name: "role", fromJson: _fromJsonToUserRole)
  final UserRole role;
  @JsonKey(name: "is_active")
  final bool isActive;

  OwnUserResponseDto({
    required super.result,
    required super.msg,
    required this.userId,
    required this.isBot,
    required this.fullName,
    required this.timezone,
    this.avatarUrl,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isOwner,
    required this.isAdmin,
    required this.isGuest,
  });

  factory OwnUserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OwnUserResponseDtoFromJson(json);

  UserEntity toEntity() => UserEntity(
    userId: userId,
    isBot: isBot,
    fullName: fullName,
    timezone: timezone,
    avatarUrl: avatarUrl,
    email: email,
    isActive: isActive,
    role: role,
    isAdmin: isAdmin,
    isOwner: isOwner,
    isGuest: isGuest,
  );

  static UserRole _fromJsonToUserRole(int json) {
    return switch (json) {
      100 => UserRole.admin,
      200 => UserRole.owner,
      300 => UserRole.moderator,
      400 => UserRole.member,
      _ => UserRole.guest,
    };
  }
}
