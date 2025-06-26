import 'package:genesis_workspace/data/users/datasources/users_remote_data_source.dart';
import 'package:genesis_workspace/data/users/dto/subscriptions_response_dto.dart';
import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:genesis_workspace/domain/users/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: UsersRepository)
class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource usersRemoteDataSource;

  UsersRepositoryImpl(this.usersRemoteDataSource);

  @override
  Future<List<SubscriptionEntity>> getSubscribedChannels() async {
    final SubscriptionsResponseDto dto = await usersRemoteDataSource.getSubscribedChannels();
    List<SubscriptionEntity> result = dto.subscriptions.map((e) => e.toEntity()).toList();
    return result;
  }
}
