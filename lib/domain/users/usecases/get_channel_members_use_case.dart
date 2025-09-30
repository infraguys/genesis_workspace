import 'package:genesis_workspace/domain/users/entities/channel_members_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetChannelMembersUseCase {
  final UsersRepository _repository;
  GetChannelMembersUseCase(this._repository);

  Future<ChannelMembersResponseEntity> call(ChannelMembersRequestEntity body) async {
    try {
      return await _repository.getChannelMembers(body);
    } catch (e) {
      rethrow;
    }
  }
}
