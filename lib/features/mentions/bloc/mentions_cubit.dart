import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:injectable/injectable.dart';

part 'mentions_state.dart';

@injectable
class MentionsCubit extends Cubit<MentionsState> {
  MentionsCubit(this._getMessagesUseCase, this._realTimeService)
    : super(
        MentionsState(messages: [], isLoadingMore: false, isAllLoaded: false, lastMessageId: null),
      ) {
    _messagesEventsSubscription = _realTimeService.messageEventsStream.listen(_onMessageEvents);
  }

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;

  final MultiPollingService _realTimeService;
  final GetMessagesUseCase _getMessagesUseCase;

  Future<void> getMessages() async {
    try {
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'mentioned')],
        numBefore: 100,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(body);
      emit(state.copyWith(messages: response.messages, lastMessageId: response.messages.first.id));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> loadMoreMessages() async {
    if (!state.isAllLoaded) {
      emit(state.copyWith(isLoadingMore: true));
      try {
        final body = MessagesRequestEntity(
          anchor: MessageAnchor.id(state.lastMessageId ?? 0),
          narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'mentioned')],
          numBefore: 100,
          numAfter: 0,
        );
        final response = await _getMessagesUseCase.call(body);
        emit(
          state.copyWith(
            messages: [...response.messages, ...state.messages],
            lastMessageId: response.messages.first.id,
            isAllLoaded: response.foundOldest,
          ),
        );
      } catch (e) {
        inspect(e);
      } finally {
        emit(
          state.copyWith(
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  void _onMessageEvents(MessageEventEntity event) {
    if (event.flags.contains('mentioned')) {
      final message = event.message;
      final updatedMessages = [...state.messages, message];
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    return super.close();
  }
}
