import 'package:genesis_workspace/data/users/dto/user_presence_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';
import 'package:genesis_workspace/domain/users/entities/presences_response_entity.dart';

class UserPresenceResponseEntity extends ResponseEntity {
  final PresenceEntity userPresence;

  UserPresenceResponseEntity({
    required this.userPresence,
    required super.msg,
    required super.result,
  });
}

class UserPresenceRequestEntity {
  final int userId;
  UserPresenceRequestEntity({required this.userId});

  UserPresenceRequestDto toDto() => UserPresenceRequestDto(userId: userId);
}
