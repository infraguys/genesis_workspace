part of 'users_remote_data_source.dart';

@Injectable(as: UsersRemoteDataSource)
class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final UsersApiClient apiClient = UsersApiClient(getIt<Dio>());

  @override
  Future<SubscriptionsResponseDto> getSubscribedChannels() async {
    try {
      return apiClient.getSubscribedChannels();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UsersResponseDto> getUsers() async {
    try {
      return apiClient.getUsers();
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
      return apiClient.setTyping(body.type, body.op, jsonEncode(body.to));
    } catch (e) {
      rethrow;
    }
  }
}
