import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/domain/users/entities/typing_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';

abstract class UsersRepository {
  Future<List<SubscriptionEntity>> getSubscribedChannels(bool includeSubscribers);
  Future<List<UserEntity>> getUsers();
  Future<UserEntity> getOwnUser();
  Future<void> setTyping(TypingRequestEntity body);
  Future<List<TopicEntity>> getChannelTopics(int streamId);
}
