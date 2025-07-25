import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/users/api/users_api_client.dart';
import 'package:genesis_workspace/data/users/dto/own_user_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/subscriptions_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/topics_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/typing_request_dto.dart';
import 'package:genesis_workspace/data/users/dto/users_response_dto.dart';
import 'package:injectable/injectable.dart';

part 'users_remote_data_source_impl.dart';

abstract class UsersRemoteDataSource {
  Future<SubscriptionsResponseDto> getSubscribedChannels(bool includeSubscribers);
  Future<UsersResponseDto> getUsers();
  Future<OwnUserResponseDto> getOwnUser();
  Future<void> setTyping(TypingRequestDto body);
  Future<TopicsResponseDto> getChannelTopics(int streamId);
}
