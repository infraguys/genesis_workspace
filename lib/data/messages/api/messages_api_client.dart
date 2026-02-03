import 'package:dio/dio.dart' hide Headers;
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/delete_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/emoji_reaction_dto.dart';
import 'package:genesis_workspace/data/messages/dto/message_readers_response.dart';
import 'package:genesis_workspace/data/messages/dto/messages_response_dto.dart';
import 'package:genesis_workspace/data/messages/dto/single_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/update_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/update_messages_flags_narrow_dto.dart';
import 'package:genesis_workspace/data/messages/dto/upload_file_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'messages_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class MessagesApiClient {
  factory MessagesApiClient(Dio dio, {String? baseUrl}) = _MessagesApiClient;

  @GET('/messages')
  Future<MessagesResponseDto> getMessages(
    @Query("anchor") String? anchor,
    @Query("narrow") String? narrow,
    @Query("num_before") int? numBefore,
    @Query("num_after") int? numAfter,
    @Query("apply_markdown") bool? applyMarkdown,
    @Query("client_gravatar") bool? clientGravatar,
    @Query("include_anchor") bool? includeAnchor,
    @Query("message_ids") String? messageIds,
  );

  @GET('/messages/{message_id}')
  Future<SingleMessageResponseDto> getMessageById(
    @Path('message_id') int messageId,
    @Query("apply_markdown") bool applyMarkdown,
  );

  @FormUrlEncoded()
  @POST('/messages')
  Future<void> sendMessage({
    @Field("type") required String type,
    @Field("to") required String to,
    @Field("content") required String content,
    @Field("stream_id") int? streamId,
    @Field("topic") String? topic,
    @Field("read_by_sender") bool? readBySender,
  });

  @FormUrlEncoded()
  @PATCH('/messages/{message_id}')
  Future<UpdateMessageResponseDto> updateMessage({
    @Path('message_id') required int messageId,
    @Field("content") required String content,
  });

  @POST('/messages/flags')
  Future<void> updateMessagesFlags(
    @Query("messages") String messages,
    @Query("op") UpdateMessageFlagsOp op,
    @Query("flag") MessageFlag flag,
  );

  @POST('/messages/flags/narrow')
  Future<UpdateMessagesFlagsNarrowResponseDto> updateMessagesFlagsNarrow(
    @Query("anchor") String anchor,
    @Query("include_anchor") bool includeAnchor,
    @Query("num_before") int? numBefore,
    @Query("num_after") int? numAfter,
    @Query("narrow") String narrow,
    @Query("op") UpdateMessageFlagsOp op,
    @Query("flag") MessageFlag flag,
  );

  @POST('/messages/{message_id}/reactions')
  Future<EmojiReactionResponseDto> addEmojiReaction(
    @Path('message_id') int messageId,
    @Query('emoji_name') String emojiName,
  );

  @DELETE('/messages/{message_id}/reactions')
  Future<EmojiReactionResponseDto> removeEmojiReaction(
    @Path('message_id') int messageId,
    @Query('emoji_name') String emojiName,
  );

  @DELETE('/messages/{message_id}')
  Future<DeleteMessageResponseDto> deleteMessage(@Path('message_id') int messageId);

  @POST('/user_uploads')
  @MultiPart()
  Future<UploadFileResponseDto> uploadFile(
    @Body() FormData formData,
    @SendProgress() ProgressCallback? onSendProgress,
    @CancelRequest() CancelToken? cancelToken,
  );

  @POST('/tus')
  @Headers({'Tus-Resumable': AppConstants.tusVersion})
  Future<HttpResponse<void>> createUpload(
    @Header('Upload-Length') String uploadLength,
    @Header('Upload-Metadata') String uploadMetadata,
  );

  @GET('/messages/{message_id}/read_receipts')
  Future<MessageReadersResponse> getMessageReaders(
    @Path('message_id') int messageId,
  );
}
