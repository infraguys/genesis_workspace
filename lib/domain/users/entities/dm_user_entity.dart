import 'package:genesis_workspace/domain/users/entities/user_entity.dart';

class DmUserEntity extends UserEntity {
  Set<int> unreadMessages;
  DmUserEntity({
    required super.email,
    required super.userId,
    required super.role,
    required super.isBot,
    required super.fullName,
    required super.timezone,
    required super.isActive,
    required this.unreadMessages,
  });
}
