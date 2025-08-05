import 'package:dio/dio.dart' hide Headers;
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/data/users/dto/channel_by_id_dto.dart';
import 'package:genesis_workspace/data/users/dto/own_user_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/presences_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/subscriptions_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/topics_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/update_presence_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/user_by_id_response_dto.dart';
import 'package:genesis_workspace/data/users/dto/users_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'users_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class UsersApiClient {
  factory UsersApiClient(Dio dio, {String? baseUrl}) = _UsersApiClient;

  @GET('/users')
  Future<UsersResponseDto> getUsers(
    @Query('client_gravatar') bool clientGravatar,
    @Query('include_custom_profile_fields') bool includeCustomProfileFields,
  );

  @GET('/users/{user_id}')
  Future<UserByIdResponseDto> getUserById(@Path('user_id') int userId);

  @GET('/realm/presence')
  Future<PresencesResponseDto> getAllPresences();

  @GET('/users/me')
  Future<OwnUserResponseDto> getOwnUser();

  @POST('/typing')
  Future<void> setTyping(
    @Query('type') SendMessageType type,
    @Query('op') TypingEventOp op,
    @Query('to') String? to,
    @Query('stream_id') int? streamId,
    @Query('topic') String? topic,
  );

  @GET('/users/me/subscriptions')
  Future<SubscriptionsResponseDto> getSubscribedChannels(
    @Query('include_subscribers') bool includeSubscribers,
  );

  @GET('/users/me/{stream_id}/topics')
  Future<TopicsResponseDto> getChannelTopics(@Path('stream_id') int streamId);

  @GET('/streams/{stream_id}')
  Future<ChannelByIdResponseDto> getChannelById(@Path('stream_id') int streamId);

  @POST('/users/me/presence')
  Future<UpdatePresenceResponseDto> updatePresence(
    @Query('last_update_id') int? lastUpdateId,
    @Query('new_user_input') bool? newUserInput,
    @Query('status') PresenceStatus status,
    @Query('ping_only') bool? pingOnly,
  );
}
