import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/data/users/dto/user_dto.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.email,
    required this.userId,
    required this.role,
    required this.isOwner,
    required this.isAdmin,
    required this.isGuest,
    required this.isBot,
    required this.fullName,
    required this.timezone,
    required this.isActive,
    this.avatarUrl,
  });

  final String email;
  final int userId;
  final UserRole role;
  final bool isOwner;
  final bool isAdmin;
  final bool isGuest;
  final bool isBot;
  final String fullName;
  final String timezone;
  final bool isActive;
  final String? avatarUrl;

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
    isGuest: isGuest,
    isOwner: isOwner,
    isAdmin: isAdmin,
  );

  factory UserEntity.fake({int? id, String? email, String? fullName, bool? isActive}) {
    return UserEntity(
      email: email ?? "fake_user_${id ?? 1}@example.com",
      userId: id ?? 1,
      role: UserRole.guest,
      isBot: false,
      fullName: fullName ?? "Fake User ${(id ?? 1)}",
      timezone: "UTC",
      isActive: isActive ?? true,
      avatarUrl: "https://placehold.co/128x128",
      isAdmin: false,
      isOwner: false,
      isGuest: true,
    );
  }

  @override
  List<Object?> get props => [userId, role, fullName, isActive, avatarUrl];
}

enum UserRole {
  owner,
  admin,
  moderator,
  member,
  guest
  ;

  String humanReadable(BuildContext context) {
    return switch (this) {
      owner => context.t.roles.owner,
      admin => context.t.roles.admin,
      moderator => context.t.roles.moderator,
      member => context.t.roles.member,
      _ => context.t.roles.guest,
    };
  }
}
