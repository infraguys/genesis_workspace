import 'package:dio/dio.dart' hide Headers;
import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/data/users/dto/own_user_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/subscriptions_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/users_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'users_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class UsersApiClient {
  factory UsersApiClient(Dio dio, {String? baseUrl}) = _UsersApiClient;

  @GET('/users/me/subscriptions')
  Future<SubscriptionsResponseDto> getSubscribedChannels();

  @GET('/users')
  Future<UsersResponseDto> getUsers();

  @GET('/users/me')
  Future<OwnUserResponseDto> getOwnUser();

  @POST('/typing')
  Future<void> setTyping(
    @Query('type') SendMessageType type,
    @Query('op') TypingEventOp op,
    @Query('to') String to,
  );
}
