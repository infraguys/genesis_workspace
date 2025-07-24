import 'dart:developer';

import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MessagesService {
  final _getMessagesUseCase = getIt<GetMessagesUseCase>();
  List<MessageEntity> _allMessages = [];

  List<MessageEntity> get messages => _allMessages;
  List<MessageEntity> get unreadMessages => _allMessages.where((message) {
    if (message.flags != null) {
      return !message.flags!.contains('read');
    } else {
      return true;
    }
  }).toList();

  set messages(List<MessageEntity> messages) {
    _allMessages = messages;
  }

  Future<void> getLastMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        numBefore: 5000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      _allMessages = response.messages;
    } catch (e) {
      inspect(e);
    }
  }
}
