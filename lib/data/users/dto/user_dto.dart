import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final String email;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'avatar_version')
  final int avatarVersion;
  @JsonKey(name: 'is_admin')
  final bool isAdmin;
  @JsonKey(name: 'is_owner')
  final bool isOwner;
  @JsonKey(name: 'is_guest')
  final bool isGuest;
  final int role;
  @JsonKey(name: 'is_bot')
  final bool isBot;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String timezone;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'date_joined')
  final String dateJoined;
  @JsonKey(name: 'delivery_email')
  final String deliveryEmail;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  UserDto({
    required this.email,
    required this.userId,
    required this.avatarVersion,
    required this.isAdmin,
    required this.isOwner,
    required this.isGuest,
    required this.role,
    required this.isBot,
    required this.fullName,
    required this.timezone,
    required this.isActive,
    required this.dateJoined,
    required this.deliveryEmail,
    this.avatarUrl,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  UserEntity toEntity() => UserEntity(
    email: email,
    userId: userId,
    role: role,
    isBot: isBot,
    fullName: fullName,
    timezone: timezone,
    isActive: isActive,
    avatarUrl: avatarUrl,
  );
}
