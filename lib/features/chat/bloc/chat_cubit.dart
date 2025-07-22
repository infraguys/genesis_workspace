import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/send_message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/send_message_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/send_message_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/update_messages_flags_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_entity.dart';
import 'package:genesis_workspace/domain/users/entities/typing_request_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/set_typing_use_case.dart';
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
          isLoadingMore: false,
          isAllMessagesLoaded: false,
          selfTypingOp: TypingEventOp.stop,
          pendingToMarkAsRead: {},
        ),
      ) {
    _typingEventsSubscription = _realTimeService.typingEventsStream.listen(_onTypingEvents);
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
  }

  final RealTimeService _realTimeService = getIt<RealTimeService>();

  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();
  final SendMessageUseCase _sendMessageUseCase = getIt<SendMessageUseCase>();
  final SetTypingUseCase _setTypingUseCase = getIt<SetTypingUseCase>();
  final _updateMessagesFlagsUseCase = getIt<UpdateMessagesFlagsUseCase>();

  late final StreamSubscription<TypingEventEntity> _typingEventsSubscription;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEntity> _messageFlagsSubscription;

  Timer? _readMessageDebounceTimer;

  Future<void> getMessages({required int chatId, required int myUserId}) async {
    state.chatId = chatId;
    state.myUserId = myUserId;
    try {
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [
          MessageNarrowEntity(operator: NarrowOperator.dm, operand: [chatId]),
        ],
        numBefore: 25,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(body);
      state.isAllMessagesLoaded = response.foundOldest;
      state.lastMessageId = response.messages.first.id;
      state.messages = response.messages;
      emit(
        state.copyWith(messages: state.messages, isAllMessagesLoaded: state.isAllMessagesLoaded),
      );
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> loadMoreMessages() async {
    if (!state.isAllMessagesLoaded) {
      state.isLoadingMore = true;
      emit(state.copyWith(isLoadingMore: state.isLoadingMore));
      try {
        final body = MessagesRequestEntity(
          anchor: MessageAnchor.id(state.lastMessageId ?? 0),
          narrow: [
            MessageNarrowEntity(operator: NarrowOperator.dm, operand: [state.chatId ?? 0]),
          ],
          numBefore: 25,
          numAfter: 0,
        );
        final response = await _getMessagesUseCase.call(body);
        state.lastMessageId = response.messages.first.id;
        state.isAllMessagesLoaded = response.foundOldest;
        state.messages = [...response.messages, ...state.messages];
        state.isLoadingMore = false;
        emit(
          state.copyWith(
            messages: state.messages,
            isLoadingMore: state.isLoadingMore,
            isAllMessagesLoaded: state.isAllMessagesLoaded,
          ),
        );
      } catch (e) {
        inspect(e);
      }
    }
  }

  Future<void> changeTyping({required int chatId, required TypingEventOp op}) async {
    if (state.selfTypingOp != op) {
      state.selfTypingOp = op;
      try {
        await _setTypingUseCase.call(
          TypingRequestEntity(type: SendMessageType.direct, op: op, to: [chatId]),
        );
      } catch (e) {
        inspect(e);
      }
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
    final isWriting = event.op == TypingEventOp.start && senderId == state.chatId;

    if (isWriting) {
      state.typingId = senderId;
    } else {
      state.typingId = null;
    }
    emit(state.copyWith(typingId: state.typingId));
  }

  void _onMessageEvents(MessageEventEntity event) {
    bool isThisChatMessage =
        event.message.displayRecipient.any((recipient) => recipient.userId == state.myUserId) &&
        event.message.displayRecipient.any((recipient) => recipient.userId == state.chatId);
    if (isThisChatMessage) {
      state.messages = [...state.messages, event.message];
      emit(state.copyWith(messages: state.messages));
    }
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEntity event) {
    event.messages.forEach((messageId) {
      if (event.flag == MessageFlag.read) {
        MessageEntity message = state.messages.firstWhere((message) => message.id == messageId);
        final int index = state.messages.indexOf(message);
        MessageEntity changedMessage = message.copyWith(
          flags: [...message.flags ?? [], MessageFlag.read.name],
        );
        state.messages[index] = changedMessage;
      }
    });
    emit(state.copyWith(messages: state.messages));
  }

  void scheduleMarkAsRead(int messageId) {
    state.pendingToMarkAsRead.add(messageId);

    _readMessageDebounceTimer?.cancel();
    _readMessageDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _sendMarkAsRead();
    });
  }

  Future<void> _sendMarkAsRead() async {
    if (state.pendingToMarkAsRead.isEmpty) return;

    final idsToSend = state.pendingToMarkAsRead.toList();
    state.pendingToMarkAsRead.clear();

    try {
      await _updateMessagesFlagsUseCase.call(
        UpdateMessagesFlagsRequestEntity(
          messages: idsToSend,
          op: UpdateMessageFlagsOp.add,
          flag: MessageFlag.read,
        ),
      );
    } catch (e) {
      // Optional: retry or log error
    }
  }
}
