import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit()
    : super(
        FeedState(
          messages: [],
          isLoadingMore: false,
          isAllMessagesLoaded: false,
          lastMessageId: null,
        ),
      );

  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();

  Future<void> getMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        numBefore: 150,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      state.messages = response.messages;
      state.isAllMessagesLoaded = response.foundOldest;
      state.lastMessageId = response.messages.first.id;

      emit(
        state.copyWith(
          messages: state.messages,
          isAllMessagesLoaded: state.isAllMessagesLoaded,
          lastMessageId: state.lastMessageId,
        ),
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
          numBefore: 150,
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
}
