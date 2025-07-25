import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_entity.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'messages_state.dart';

@LazySingleton()
class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit() : super(MessagesState(messages: [], unreadMessages: [])) {
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _messageFlagsSubscription.cancel();
    return super.close();
  }

  final _getMessagesUseCase = getIt<GetMessagesUseCase>();
  final _realTimeService = getIt<RealTimeService>();

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEntity> _messageFlagsSubscription;

  _onMessageEvents(MessageEventEntity event) {
    final messages = [...state.messages];
    messages.add(event.message);
    state.unreadMessages = messages.where((message) => message.hasUnreadMessages).toList();
    emit(state.copyWith(messages: messages, unreadMessages: state.unreadMessages));
  }

  _onMessageFlagsEvents(UpdateMessageFlagsEntity event) {}

  Future<void> getLastMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        numBefore: 5000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      state.messages = response.messages;
      state.unreadMessages = response.messages
          .where((message) => message.hasUnreadMessages)
          .toList();
      emit(state.copyWith(messages: state.messages, unreadMessages: state.unreadMessages));
    } catch (e) {
      inspect(e);
    }
  }
}
