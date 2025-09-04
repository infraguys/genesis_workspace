import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/messages/api/messages_api_client.dart';
import 'package:genesis_workspace/data/messages/datasources/messages_data_source.dart';
import 'package:genesis_workspace/data/messages/dto/delete_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/emoji_reaction_dto.dart';
import 'package:genesis_workspace/data/messages/dto/messages_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/messages_response_dto.dart';
import 'package:genesis_workspace/data/messages/dto/send_message_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/single_message_dto.dart';
import 'package:genesis_workspace/data/messages/dto/update_messages_flags_request_dto.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: MessagesDataSource)
class MessagesDataSourceImpl implements MessagesDataSource {
  final MessagesApiClient apiClient = MessagesApiClient(getIt<Dio>());

  @override
  Future<MessagesResponseDto> getMessages(MessagesRequestDto body) async {
    try {
      final anchor = body.anchor;
      final narrowString = jsonEncode(body.narrow?.map((e) => e.toJson()).toList());
      final bool applyMarkdown = true;
      final bool clientGravatar = false;

      return await apiClient.getMessages(
        anchor,
        narrowString,
        body.numBefore,
        body.numAfter,
        applyMarkdown,
        clientGravatar,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SingleMessageResponseDto> getMessageById(SingleMessageRequestDto body) async {
    try {
      final messageId = body.messageId;
      final applyMarkdown = body.applyMarkdown;
      return await apiClient.getMessageById(messageId, applyMarkdown);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(SendMessageRequestDto body) async {
    try {
      await apiClient.sendMessage(
        body.type,
        jsonEncode(body.to),
        body.content,
        body.streamId,
        body.topic,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateMessagesFlags(UpdateMessagesFlagsRequestDto body) async {
    try {
      await apiClient.updateMessagesFlags(jsonEncode(body.messages), body.op, body.flag);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EmojiReactionResponseDto> addEmojiReaction(EmojiReactionRequestDto body) async {
    try {
      return await apiClient.addEmojiReaction(body.messageId, body.emojiName);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EmojiReactionResponseDto> removeEmojiReaction(EmojiReactionRequestDto body) async {
    try {
      return await apiClient.removeEmojiReaction(body.messageId, body.emojiName);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DeleteMessageResponseDto> deleteMessage(DeleteMessageRequestDto body) async {
    try {
      return await apiClient.deleteMessage(body.messageId);
    } catch (e) {
      rethrow;
    }
  }
}
