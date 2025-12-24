import 'package:dio/dio.dart';
import 'package:genesis_workspace/data/messages/dto/delete_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/emoji_reaction_dto.dart';
import 'package:genesis_workspace/data/messages/dto/mark_as_read_dto.dart';
import 'package:genesis_workspace/data/messages/dto/message_readers_response.dart';
import 'package:genesis_workspace/data/messages/dto/messages_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/messages_response_dto.dart';
import 'package:genesis_workspace/data/messages/dto/send_message_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/single_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/update_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/update_messages_flags_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/upload_file_dto.dart';

abstract class MessagesDataSource {
  Future<MessagesResponseDto> getMessages(MessagesRequestDto body);
  Future<SingleMessageResponseDto> getMessageById(SingleMessageRequestDto body);
  Future<void> sendMessage(SendMessageRequestDto body);
  Future<void> updateMessagesFlags(UpdateMessagesFlagsRequestDto body);
  Future<EmojiReactionResponseDto> addEmojiReaction(EmojiReactionRequestDto body);
  Future<EmojiReactionResponseDto> removeEmojiReaction(EmojiReactionRequestDto body);
  Future<DeleteMessageResponseDto> deleteMessage(DeleteMessageRequestDto body);
  Future<UpdateMessageResponseDto> updateMessage(UpdateMessageRequestDto body);
  Future<UploadFileResponseDto> uploadFile(
    UploadFileRequestDto body, {
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  });
  Future<MessageReadersResponse> getMessageReaders(int messageId);
  Future<void> markStreamAsRead(MarkStreamAsReadRequestDto body);
  Future<void> markTopicAsRead(MarkTopicAsReadRequestDto body);
}
