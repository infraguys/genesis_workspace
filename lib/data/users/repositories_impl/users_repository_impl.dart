import 'package:genesis_workspace/data/users/datasources/users_remote_data_source.dart';
import 'package:genesis_workspace/data/users/dto/subscriptions_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/users_response_dto.dart';
import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/domain/users/entities/typing_request_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: UsersRepository)
class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource usersRemoteDataSource;

  UsersRepositoryImpl(this.usersRemoteDataSource);

  @override
  Future<List<SubscriptionEntity>> getSubscribedChannels(bool includeSubscribers) async {
    try {
      final SubscriptionsResponseDto dto = await usersRemoteDataSource.getSubscribedChannels(
        includeSubscribers,
      );
      List<SubscriptionEntity> result = dto.subscriptions.map((e) => e.toEntity()).toList();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> getUsers() async {
    try {
      final UsersResponseDto dto = await usersRemoteDataSource.getUsers();
      List<UserEntity> result = dto.members.map((user) => user.toEntity()).toList();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> getOwnUser() async {
    try {
      final dto = await usersRemoteDataSource.getOwnUser();
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> setTyping(TypingRequestEntity body) async {
    try {
      return await usersRemoteDataSource.setTyping(body.toDto());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TopicEntity>> getChannelTopics(int streamId) async {
    try {
      final response = await usersRemoteDataSource.getChannelTopics(streamId);
      return response.topics.map((topic) => topic.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
