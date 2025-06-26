import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetSubscribedChannelsUseCase {
  final UsersRepository repository;

  GetSubscribedChannelsUseCase(this.repository);

  Future<List<SubscriptionEntity>> call() async {
    return await repository.getSubscribedChannels();
  }
}
