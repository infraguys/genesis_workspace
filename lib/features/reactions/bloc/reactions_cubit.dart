import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/enums/reaction_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/reaction_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/reaction_event_entity.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'reactions_state.dart';

@injectable
class ReactionsCubit extends Cubit<ReactionsState> {
  ReactionsCubit(this._realTimeService, this._getMessagesUseCase)
    : super(
        ReactionsState(messages: [], isLoadingMore: false, isAllLoaded: false, lastMessageId: null),
      ) {
    _reactionsSubscription = _realTimeService.reactionsEventsStream.listen(_onReactionEvents);
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final RealTimeService _realTimeService;

  late final StreamSubscription<ReactionEventEntity> _reactionsSubscription;

  final List<MessageNarrowEntity> narrow = [
    MessageNarrowEntity(operator: NarrowOperator.has, operand: 'reaction'),
    MessageNarrowEntity(operator: NarrowOperator.sender, operand: 'me'),
  ];

  Future<void> getMessages() async {
    try {
      final body = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: narrow,
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
          narrow: narrow,
          numBefore: 100,
          numAfter: 0,
        );
        final response = await _getMessagesUseCase.call(body);
        emit(
          state.copyWith(
            messages: [...response.messages, ...state.messages],
            isLoadingMore: false,
            lastMessageId: response.messages.first.id,
            isAllLoaded: response.foundOldest,
          ),
        );
      } catch (e) {
        inspect(e);
      }
    }
  }

  void _onReactionEvents(ReactionEventEntity event) {
    MessageEntity message = state.messages.firstWhere((message) => message.id == event.messageId);
    final int index = state.messages.indexOf(message);
    List<ReactionEntity> reactions = message.reactions;
    if (event.op == ReactionOp.add) {
      reactions.add(
        ReactionEntity(
          emojiName: event.emojiName,
          emojiCode: event.emojiCode,
          reactionType: event.reactionType,
          userId: event.userId,
        ),
      );
    } else if (event.op == ReactionOp.remove) {
      reactions.removeWhere(
        (reaction) => (reaction.userId == event.userId) && (reaction.emojiName == event.emojiName),
      );
    }
    MessageEntity changedMessage = message.copyWith(reactions: reactions);
    state.messages[index] = changedMessage;
    emit(state.copyWith(messages: state.messages));
  }

  @override
  Future<void> close() {
    _reactionsSubscription.cancel();
    return super.close();
  }
}
