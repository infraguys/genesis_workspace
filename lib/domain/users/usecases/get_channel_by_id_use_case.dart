import 'package:genesis_workspace/domain/users/entities/channel_by_id_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetChannelByIdUseCase {
  final UsersRepository _repository;

  GetChannelByIdUseCase(this._repository);

  Future<ChannelByIdResponseEntity> call(ChannelByIdRequestEntity body) async {
    try {
      return await _repository.getChannelById(body);
    } catch (e) {
      rethrow;
    }
  }
}
