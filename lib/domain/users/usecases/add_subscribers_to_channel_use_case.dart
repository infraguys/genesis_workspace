import 'package:genesis_workspace/domain/users/entities/add_subscribers_to_channel_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddSubscribersToChannelUseCase {
  final UsersRepository _repository;
  AddSubscribersToChannelUseCase(this._repository);

  Future<void> call(AddSubscribersToChannelEntity body) async {
    return await _repository.addSubscribersToChannel(body);
  }
}
