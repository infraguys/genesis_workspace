import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:injectable/injectable.dart';

part 'starred_state.dart';

@injectable
class StarredCubit extends Cubit<StarredState> {
  StarredCubit(this._realTimeService, this._getMessagesUseCase)
    : super(
        StarredState(messages: [], isLoadingMore: false, isAllLoaded: false, lastMessageId: null),
      ) {
    _messageFlagsSubscription = _realTimeService.messageFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
  }

  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsSubscription;

  final MultiPollingService _realTimeService;
  final GetMessagesUseCase _getMessagesUseCase;

  final List<MessageNarrowEntity> _narrow = [
    MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'starred'),
  ];

  Future<void> getMessages() async {
    try {
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: _narrow,
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
          narrow: _narrow,
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

  void _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    final updatedMessages = [...state.messages];
    for (var messageId in event.messages) {
      if (event.flag == MessageFlag.starred) {
        MessageEntity message = updatedMessages.firstWhere((message) => message.id == messageId);
        final int index = updatedMessages.indexOf(message);
        if (event.op == UpdateMessageFlagsOp.add) {
          MessageEntity changedMessage = message.copyWith(
            flags: [...message.flags ?? [], MessageFlag.starred.name],
          );
          updatedMessages[index] = changedMessage;
        } else if (event.op == UpdateMessageFlagsOp.remove) {
          MessageEntity changedMessage = message;
          changedMessage.flags?.remove(MessageFlag.starred.name);
          updatedMessages[index] = changedMessage;
        }
      }
    }
    emit(state.copyWith(messages: updatedMessages));
  }

  @override
  Future<void> close() {
    _messageFlagsSubscription.cancel();
    return super.close();
  }
}
