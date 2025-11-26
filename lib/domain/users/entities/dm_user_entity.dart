import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';

class DmUserEntity extends UserEntity {
  Set<int> unreadMessages;
  PresenceStatus presenceStatus;
  int presenceTimestamp;

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
  });
}
