import 'package:dio/dio.dart' hide Headers;
import 'package:genesis_workspace/data/messages/dto/messages_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'messages_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class MessagesApiClient {
  factory MessagesApiClient(Dio dio, {String? baseUrl}) = _MessagesApiClient;

  @GET('/messages')
  Future<MessagesResponseDto> getMessages(
    @Query("anchor") String anchor,
    @Query("narrow") String? narrow,
    @Query("num_before") int? numBefore,
    @Query("num_after") int? numAfter,
    @Query("apply_markdown") bool? applyMarkdown,
  );
}
