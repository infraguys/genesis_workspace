import 'package:genesis_workspace/core/enums/presence_status.dart';
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
    avatarUrl: avatarUrl,
    unreadMessages: {},
    presenceStatus: PresenceStatus.idle,
    presenceTimestamp: 0,
  );

  factory UserEntity.fake({int? id, String? email, String? fullName, bool? isActive}) {
    return UserEntity(
      email: email ?? "fake_user_${id ?? 1}@example.com",
      userId: id ?? 1,
      role: 100,
      isBot: false,
      fullName: fullName ?? "Fake User ${(id ?? 1)}",
      timezone: "UTC",
      isActive: isActive ?? true,
      avatarUrl: "https://placehold.co/128x128",
    );
  }
}
