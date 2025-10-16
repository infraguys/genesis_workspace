import 'package:genesis_workspace/data/users/dto/users_dto.dart';

class UsersRequestEntity {
  final List<int>? userIds;
  UsersRequestEntity({this.userIds});

  UsersRequestDto toDto() => UsersRequestDto(userIds: userIds);
}
