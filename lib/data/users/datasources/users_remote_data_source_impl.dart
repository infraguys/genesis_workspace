part of 'users_remote_data_source.dart';

@Injectable(as: UsersRemoteDataSource)
class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final UsersApiClient apiClient = UsersApiClient(getIt<Dio>());

  @override
  Future<SubscriptionsResponseDto> getSubscribedChannels(bool includeSubscribers) async {
    try {
      return apiClient.getSubscribedChannels(includeSubscribers);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UsersResponseDto> getUsers() async {
    try {
      final bool clientGravatar = false;
      final bool includeCustomProfileFields = true;
      return apiClient.getUsers(clientGravatar, includeCustomProfileFields);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OwnUserResponseDto> getOwnUser() async {
    try {
      return apiClient.getOwnUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> setTyping(TypingRequestDto body) async {
    try {
      return apiClient.setTyping(
        body.type,
        body.op,
        jsonEncode(body.to),
        body.streamId,
        body.topic,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TopicsResponseDto> getChannelTopics(int streamId) async {
    try {
      return await apiClient.getChannelTopics(streamId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PresencesResponseDto> getAllPresences() async {
    try {
      return await apiClient.getAllPresences();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserByIdResponseDto> getUserById(int userId) async {
    try {
      return await apiClient.getUserById(userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UpdatePresenceResponseDto> updatePresence(UpdatePresenceRequestDto body) async {
    try {
      return await apiClient.updatePresence(
        body.lastUpdateId,
        body.newUserInput,
        body.status,
        body.pingOnly,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChannelByIdResponseDto> getChannelById(int streamId) async {
    try {
      return await apiClient.getChannelById(streamId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserPresenceResponseDto> getUserPresence(UserPresenceRequestDto body) async {
    try {
      return await apiClient.getUserPresence(body.userId);
    } catch (e) {
      rethrow;
    }
  }
}
