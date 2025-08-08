import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/messages/datasources/messages_data_source.dart';
import 'package:genesis_workspace/domain/messages/entities/emoji_reaction_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_response_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/send_message_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_request_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: MessagesRepository)
class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesDataSource dataSource = getIt<MessagesDataSource>();

  @override
  Future<MessagesResponseEntity> getMessages(MessagesRequestEntity body) async {
    try {
      final dto = await dataSource.getMessages(body.toDto());
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(SendMessageRequestEntity body) async {
    try {
      await dataSource.sendMessage(body.toDto());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateMessagesFlags(UpdateMessagesFlagsRequestEntity body) async {
    try {
      await dataSource.updateMessagesFlags(body.toDto());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EmojiReactionResponseEntity> addEmojiReaction(EmojiReactionRequestEntity body) async {
    try {
      final response = await dataSource.addEmojiReaction(body.toDto());
      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EmojiReactionResponseEntity> removeEmojiReaction(EmojiReactionRequestEntity body) async {
    try {
      final response = await dataSource.removeEmojiReaction(body.toDto());
      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
