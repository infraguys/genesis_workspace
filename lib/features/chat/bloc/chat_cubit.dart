import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/send_message_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/send_message_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit()
    : super(
        ChatState(
          messages: [],
          chatId: null,
          typingId: null,
          myUserId: null,
          isMessagePending: false,
        ),
      ) {
    _typingEventsSubscription = _realTimeService.typingEventsStream.listen(_onTypingEvents);
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
  }

  final RealTimeService _realTimeService = getIt<RealTimeService>();

  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();
  final SendMessageUseCase _sendMessageUseCase = getIt<SendMessageUseCase>();

  late final StreamSubscription<TypingEventEntity> _typingEventsSubscription;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;

  Future<void> getMessages({required int chatId, required int myUserId}) async {
    state.chatId = chatId;
    state.myUserId = myUserId;
    try {
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.oldest,
        narrow: [
          MessageNarrowEntity(operator: NarrowOperator.dm, operand: [chatId]),
        ],
        numBefore: 100,
        numAfter: 100,
      );
      final response = await _getMessagesUseCase.call(body);
      state.messages = response.messages;
      emit(state.copyWith(messages: state.messages));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> sendMessage({required int chatId, required String content}) async {
    state.isMessagePending = true;
    emit(state.copyWith(isMessagePending: state.isMessagePending));
    final SendMessageType type = SendMessageType.direct;
    final body = SendMessageRequestEntity(type: type, to: [chatId], content: content);
    try {
      await _sendMessageUseCase.call(body);
    } catch (e) {
      inspect(e);
    }
    state.isMessagePending = false;
    emit(state.copyWith(isMessagePending: state.isMessagePending));
  }

  void _onTypingEvents(TypingEventEntity event) {
    final senderId = event.sender.userId;
    final isWriting = event.op == 'start' && senderId == state.chatId;

    if (isWriting) {
      state.typingId = senderId;
    } else {
      state.typingId = null;
    }
    emit(state.copyWith(typingId: state.typingId));
  }

  void _onMessageEvents(MessageEventEntity event) {
    inspect(event);
    bool isThisChatMessage =
        event.message.displayRecipient.any((recipient) => recipient.userId == state.myUserId) &&
        event.message.displayRecipient.any((recipient) => recipient.userId == state.chatId);
    if (isThisChatMessage) {
      state.messages = [...state.messages, event.message];
      emit(state.copyWith(messages: state.messages));
    }
  }
}
