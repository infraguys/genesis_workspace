import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/delete_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/emoji_reaction_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/single_message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/update_messages_flags_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/add_emoji_reaction_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/delete_message_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_message_by_id_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/remove_emoji_reaction_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/update_message_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/update_messages_flags_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'messages_state.dart';

@LazySingleton(dispose: disposeMessagesCubit)
class MessagesCubit extends Cubit<MessagesState> {
  final RealTimeService _realTimeService;

  MessagesCubit(
    this._realTimeService,
    this._getMessagesUseCase,
    this._addEmojiReactionUseCase,
    this._removeEmojiReactionUseCase,
    this._updateMessagesFlagsUseCase,
    this._deleteMessageUseCase,
    this._getMessageByIdUseCase,
    this._updateMessageUseCase,
  ) : super(MessagesState(messages: [])) {
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
    _deleteMessageEventsSubscription = _realTimeService.deleteMessageEventsStream.listen(
      _onDeleteMessageEvents,
    );
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final AddEmojiReactionUseCase _addEmojiReactionUseCase;
  final RemoveEmojiReactionUseCase _removeEmojiReactionUseCase;
  final UpdateMessagesFlagsUseCase _updateMessagesFlagsUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final GetMessageByIdUseCase _getMessageByIdUseCase;
  final UpdateMessageUseCase _updateMessageUseCase;

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsSubscription;
  late final StreamSubscription<DeleteMessageEventEntity> _deleteMessageEventsSubscription;

  Future<void> getLastMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'unread')],
        numBefore: 1000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      final messages = response.messages;
      emit(state.copyWith(messages: messages));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> addEmojiReaction(int messageId, {required String emojiName}) async {
    try {
      await _addEmojiReactionUseCase.call(
        EmojiReactionRequestEntity(messageId: messageId, emojiName: emojiName),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeEmojiReaction(int messageId, {required String emojiName}) async {
    try {
      await _removeEmojiReactionUseCase.call(
        EmojiReactionRequestEntity(messageId: messageId, emojiName: emojiName),
      );
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> addStarredFlag(int messageId) async {
    try {
      final body = UpdateMessagesFlagsRequestEntity(
        messages: [messageId],
        op: UpdateMessageFlagsOp.add,
        flag: MessageFlag.starred,
      );
      await _updateMessagesFlagsUseCase.call(body);
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> removeStarredFlag(int messageId) async {
    try {
      final body = UpdateMessagesFlagsRequestEntity(
        messages: [messageId],
        op: UpdateMessageFlagsOp.remove,
        flag: MessageFlag.starred,
      );
      await _updateMessagesFlagsUseCase.call(body);
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      final body = DeleteMessageRequestEntity(messageId: messageId);
      await _deleteMessageUseCase.call(body);
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  Future<MessageEntity> getMessageById({required int messageId, bool? applyMarkdown = true}) async {
    try {
      final body = SingleMessageRequestEntity(messageId: messageId, applyMarkdown: applyMarkdown!);
      final response = await _getMessageByIdUseCase.call(body);
      return response.message;
    } catch (e) {
      inspect(e);
      rethrow;
    }
  }

  _onMessageEvents(MessageEventEntity event) {
    final messages = [...state.messages];
    messages.add(event.message);
    emit(state.copyWith(messages: messages));
  }

  _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    final newMessages = [...state.messages];
    if (event.op == UpdateMessageFlagsOp.add && event.flag == MessageFlag.read) {
      for (var messageId in event.messages) {
        newMessages.removeWhere((message) => message.id == messageId);
      }
      newMessages.removeWhere((message) => message.hasUnreadMessages);
    }
    emit(state.copyWith(messages: newMessages));
  }

  _onDeleteMessageEvents(DeleteMessageEventEntity event) {
    final newMessages = [...state.messages];
    newMessages.removeWhere((message) => message.id == event.messageId);
    emit(state.copyWith(messages: newMessages));
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _messageFlagsSubscription.cancel();
    _deleteMessageEventsSubscription.cancel();
    return super.close();
  }
}

void disposeMessagesCubit(MessagesCubit c) => c.close();
