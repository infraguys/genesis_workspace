import 'dart:developer';

import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MessagesService {
  List<MessageEntity> messages = [];
  List<MessageEntity> unreadMessages = [];

  final _getMessagesUseCase = getIt<GetMessagesUseCase>();

  Future<void> getLastMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        numBefore: 5000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      messages = response.messages;
      unreadMessages = response.messages.where((message) => message.hasUnreadMessages).toList();
    } catch (e) {
      inspect(e);
    }
  }
}
