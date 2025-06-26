import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';

abstract class UsersRepository {
  Future<List<SubscriptionEntity>> getSubscribedChannels();
}
