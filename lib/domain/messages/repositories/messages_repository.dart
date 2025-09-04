import 'package:genesis_workspace/domain/messages/entities/delete_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/emoji_reaction_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_response_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/send_message_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_request_entity.dart';

abstract class MessagesRepository {
  Future<MessagesResponseEntity> getMessages(MessagesRequestEntity body);
  Future<void> sendMessage(SendMessageRequestEntity body);
  Future<void> updateMessagesFlags(UpdateMessagesFlagsRequestEntity body);
  Future<EmojiReactionResponseEntity> addEmojiReaction(EmojiReactionRequestEntity body);
  Future<EmojiReactionResponseEntity> removeEmojiReaction(EmojiReactionRequestEntity body);
  Future<DeleteMessageResponseEntity> deleteMessage(DeleteMessageRequestEntity body);
}
