import 'package:dio/dio.dart';
import 'package:genesis_workspace/data/channels/dto/channel_dto.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'channels_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class ChannelsApiClient {
  factory ChannelsApiClient(Dio dio, {String? baseUrl}) = _ChannelsApiClient;

  @FormUrlEncoded()
  @POST('/channels/create')
  Future<CreateChannelResponseDto> createChannel(
    @Field('name') String name,
    @Field('subscribers') String subscribers,
  );
}
