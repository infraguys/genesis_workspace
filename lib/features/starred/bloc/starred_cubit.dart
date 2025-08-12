import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:injectable/injectable.dart';

part 'starred_state.dart';

@injectable
class StarredCubit extends Cubit<StarredState> {
  StarredCubit(this._getMessagesUseCase)
    : super(
        StarredState(messages: [], isLoadingMore: false, isAllLoaded: false, lastMessageId: null),
      );

  final GetMessagesUseCase _getMessagesUseCase;

  final List<MessageNarrowEntity> narrow = [
    MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'starred'),
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
}
