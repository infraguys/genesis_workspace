import 'package:dio/dio.dart';
import 'package:genesis_workspace/domain/messages/entities/delete_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/emoji_reaction_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/mark_as_read_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_response_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/send_message_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/single_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';

abstract class MessagesRepository {
  Future<MessagesResponseEntity> getMessages(MessagesRequestEntity body);
  Future<SingleMessageResponseEntity> getMessageById(SingleMessageRequestEntity body);
  Future<void> sendMessage(SendMessageRequestEntity body);
  Future<void> updateMessagesFlags(UpdateMessagesFlagsRequestEntity body);
  Future<EmojiReactionResponseEntity> addEmojiReaction(EmojiReactionRequestEntity body);
  Future<EmojiReactionResponseEntity> removeEmojiReaction(EmojiReactionRequestEntity body);
  Future<DeleteMessageResponseEntity> deleteMessage(DeleteMessageRequestEntity body);
  Future<UpdateMessageResponseEntity> updateMessage(UpdateMessageRequestEntity body);
  Future<UploadFileResponseEntity> uploadFile(
    UploadFileRequestEntity body, {
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  });
  Future<List<UserEntity>> getMessageReaders(int messageId);
  Future<void> markStreamAsRead(MarkStreamAsReadRequestEntity body);
  Future<void> markTopicAsRead(MarkTopicAsReadRequestEntity body);
}
