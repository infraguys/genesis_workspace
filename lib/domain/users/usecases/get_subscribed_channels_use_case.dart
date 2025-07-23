import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetSubscribedChannelsUseCase {
  final UsersRepository _repository;

  GetSubscribedChannelsUseCase(this._repository);

  Future<List<SubscriptionEntity>> call(bool includeSubscribers) async {
    return await _repository.getSubscribedChannels(includeSubscribers);
  }
}
