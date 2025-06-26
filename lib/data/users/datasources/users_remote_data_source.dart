import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/users/api/users_api_client.dart';
import 'package:genesis_workspace/data/users/dto/subscriptions_response_dto.dart';
import 'package:injectable/injectable.dart';

part 'users_remote_data_source_impl.dart';

abstract class UsersRemoteDataSource {
  Future<SubscriptionsResponseDto> getSubscribedChannels();
}
