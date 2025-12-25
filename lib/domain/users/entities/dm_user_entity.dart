import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';

class DmUserEntity extends UserEntity {
  DmUserEntity({
    required super.email,
    required super.userId,
    required super.role,
    required super.isBot,
    required super.fullName,
    required super.timezone,
    required super.isActive,
    super.avatarUrl,
    required this.unreadMessages,
    required this.presenceStatus,
    required this.presenceTimestamp,
    required super.isAdmin,
    required super.isOwner,
    required super.isGuest,
    required super.jobTitle,
    required super.bossName,
  });

  Set<int> unreadMessages;
  PresenceStatus presenceStatus;
  int presenceTimestamp;

  DmUserEntity copyWith({
    String? email,
    int? userId,
    UserRole? role,
    bool? isBot,
    String? fullName,
    String? timezone,
    bool? isActive,
    String? avatarUrl,
    Set<int>? unreadMessages,
    PresenceStatus? presenceStatus,
    int? presenceTimestamp,
    bool? isAdmin,
    bool? isOwner,
    bool? isGuest,
    String? jobTitle,
    String? bossName,
  }) {
    return DmUserEntity(
      email: email ?? this.email,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      isBot: isBot ?? this.isBot,
      fullName: fullName ?? this.fullName,
      timezone: timezone ?? this.timezone,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      presenceStatus: presenceStatus ?? this.presenceStatus,
      presenceTimestamp: presenceTimestamp ?? this.presenceTimestamp,
      isAdmin: isAdmin ?? this.isAdmin,
      isOwner: isOwner ?? this.isOwner,
      isGuest: isGuest ?? this.isGuest,
      jobTitle: jobTitle ?? this.jobTitle,
      bossName: bossName ?? this.bossName,
    );
  }
}
