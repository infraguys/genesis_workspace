import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/messages/datasources/messages_data_source.dart';
import 'package:genesis_workspace/data/users/datasources/users_remote_data_source.dart';
import 'package:genesis_workspace/data/users/dto/users_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/delete_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/emoji_reaction_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_response_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/send_message_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/single_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:genesis_workspace/domain/messages/repositories/messages_repository.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: MessagesRepository)
class MessagesRepositoryImpl implements MessagesRepository {
  final dataSource = getIt<MessagesDataSource>();
  final usersDataSource = getIt<UsersRemoteDataSource>();

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
  Future<SingleMessageResponseEntity> getMessageById(SingleMessageRequestEntity body) async {
    try {
      final response = await dataSource.getMessageById(body.toDto());
      return response.toEntity();
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

  @override
  Future<DeleteMessageResponseEntity> deleteMessage(DeleteMessageRequestEntity body) async {
    try {
      final response = await dataSource.deleteMessage(body.toDto());
      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UploadFileResponseEntity> uploadFile(
    UploadFileRequestEntity body, {
    Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dataSource.uploadFile(
        body.toDto(),
        onProgress: onProgress,
        cancelToken: cancelToken,
      );
      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UpdateMessageResponseEntity> updateMessage(UpdateMessageRequestEntity body) async {
    try {
      final response = await dataSource.updateMessage(body.toDto());
      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> getMessageReaders(int messageId) async {
    try {
      final response = await dataSource.getMessageReaders(messageId);
      final users = await usersDataSource.getUsers(UsersRequestDto(userIds: response.userIds));
      return users.members.map((it) => it.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
