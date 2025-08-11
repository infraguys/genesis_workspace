import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/emoji_reaction_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/add_emoji_reaction_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/remove_emoji_reaction_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_entity.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'messages_state.dart';

@LazySingleton(dispose: disposeMessagesCubit)
class MessagesCubit extends Cubit<MessagesState> {
  final RealTimeService _realTimeService;
  final GetMessagesUseCase _getMessagesUseCase;
  final AddEmojiReactionUseCase _addEmojiReactionUseCase;
  final RemoveEmojiReactionUseCase _removeEmojiReactionUseCase;

  StreamSubscription<MessageEventEntity>? _messagesEventsSubscription;
  StreamSubscription<UpdateMessageFlagsEntity>? _messageFlagsSubscription;

  MessagesCubit(
    this._realTimeService,
    this._getMessagesUseCase,
    this._addEmojiReactionUseCase,
    this._removeEmojiReactionUseCase,
  ) : super(const MessagesState(messages: [])) {
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(
      _onMessageEvent,
      onError: addError,
    );
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onFlagsEvent,
      onError: addError,
    );
  }

  @override
  Future<void> close() async {
    await _messagesEventsSubscription?.cancel();
    await _messageFlagsSubscription?.cancel();
    return super.close();
  }

  void _onMessageEvent(MessageEventEntity event) {
    final updatedMessages = List<MessageEntity>.of(state.messages);
    if (!updatedMessages.any((message) => message.id == event.message.id)) {
      updatedMessages.add(event.message);
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  void _onFlagsEvent(UpdateMessageFlagsEntity event) {
    if (event.flag != MessageFlag.read) return;

    final indexByMessageId = {
      for (var i = 0; i < state.messages.length; i++) state.messages[i].id: i,
    };
    final updatedMessages = List<MessageEntity>.of(state.messages);

    for (final messageId in event.messages) {
      final index = indexByMessageId[messageId];
      if (index == null) continue;

      final message = updatedMessages[index];
      final newFlags = {...?message.flags};

      if (event.op == UpdateMessageFlagsOp.add) {
        newFlags.add('read');
      } else if (event.op == UpdateMessageFlagsOp.remove) {
        newFlags.remove('read');
      }

      updatedMessages[index] = message.copyWith(flags: newFlags.toList(growable: false));
    }

    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> getLastMessages() async {
    try {
      final request = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'unread')],
        numBefore: 200,
        numAfter: 0,
      );

      final response = await _getMessagesUseCase(request);

      final mergedMessages = {
        for (final message in state.messages) message.id: message,
        for (final message in response.messages) message.id: message,
      }.values.toList(growable: false);

      emit(state.copyWith(messages: mergedMessages));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  Future<void> addEmojiReaction(int messageId, {required String emojiName}) async {
    try {
      await _addEmojiReactionUseCase(
        EmojiReactionRequestEntity(messageId: messageId, emojiName: emojiName),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> removeEmojiReaction(int messageId, {required String emojiName}) async {
    try {
      await _removeEmojiReactionUseCase(
        EmojiReactionRequestEntity(messageId: messageId, emojiName: emojiName),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }
}

void disposeMessagesCubit(MessagesCubit cubit) => cubit.close();
