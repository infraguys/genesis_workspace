part of 'users_remote_data_source.dart';

@Injectable(as: UsersRemoteDataSource)
class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final UsersApiClient apiClient = UsersApiClient(getIt<Dio>());

  @override
  Future<SubscriptionsResponseDto> getSubscribedChannels() async {
    return apiClient.getSubscribedChannels();
  }
}
