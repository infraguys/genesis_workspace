import 'package:genesis_workspace/domain/users/entities/channel_by_id_entity.dart';
import 'package:genesis_workspace/domain/users/entities/presences_response_entity.dart';
import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/domain/users/entities/typing_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/update_presence_response_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_presence_entity.dart';

abstract class UsersRepository {
  Future<List<SubscriptionEntity>> getSubscribedChannels(bool includeSubscribers);
  Future<List<UserEntity>> getUsers();
  Future<UserEntity> getOwnUser();
  Future<void> setTyping(TypingRequestEntity body);
  Future<List<TopicEntity>> getChannelTopics(int streamId);
  Future<PresencesResponseEntity> getAllPresences();
  Future<UserPresenceResponseEntity> getUserPresence(UserPresenceRequestEntity body);
  Future<UserEntity> getUserById(int userId);
  Future<UpdatePresenceResponseEntity> updatePresence(UpdatePresenceRequestEntity body);
  Future<ChannelByIdResponseEntity> getChannelById(ChannelByIdRequestEntity body);
}
