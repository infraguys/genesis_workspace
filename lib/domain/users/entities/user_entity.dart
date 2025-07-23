import 'package:genesis_workspace/data/users/dto/user_dto.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';

class UserEntity {
  final String email;
  final int userId;
  final int role;
  final bool isBot;
  final String fullName;
  final String timezone;
  final bool isActive;
  final String? avatarUrl;

  UserEntity({
    required this.email,
    required this.userId,
    required this.role,
    required this.isBot,
    required this.fullName,
    required this.timezone,
    required this.isActive,
    this.avatarUrl,
  });

  UserDto toDto() {
    return UserDto(
      email: email,
      userId: userId,
      avatarVersion: 0,
      isAdmin: false,
      isOwner: false,
      isGuest: false,
      role: role,
      isBot: isBot,
      fullName: fullName,
      timezone: timezone,
      isActive: isActive,
      dateJoined: "",
      avatarUrl: avatarUrl,
    );
  }

  DmUserEntity toDmUser() => DmUserEntity(
    email: email,
    userId: userId,
    role: role,
    isBot: isBot,
    fullName: fullName,
    timezone: timezone,
    isActive: isActive,
    unreadMessagesCount: 0,
  );
}
