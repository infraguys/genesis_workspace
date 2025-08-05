import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_user_by_id_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';

part 'inbox_state.dart';

class InboxCubit extends Cubit<InboxState> {
  final _realTimeService = getIt<RealTimeService>();

  InboxCubit() : super(InboxState(dmMessages: {}, channelMessages: {})) {
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
  }

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEntity> _messageFlagsSubscription;

  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = getIt<GetUserByIdUseCase>();

  Future<void> getLastMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'unread')],
        numBefore: 5000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);

      final dmMessages = <MessageEntity>[];
      final channelMessages = <MessageEntity>[];

      for (var message in response.messages) {
        if (message.type == MessageType.private) {
          dmMessages.add(message);
        } else if (message.type == MessageType.stream) {
          channelMessages.add(message);
        }
      }

      for (var message in dmMessages) {
        final senderFullName = message.senderFullName;
        state.dmMessages.putIfAbsent(senderFullName, () => []).add(message);
      }

      for (var msg in channelMessages) {
        final channel = msg.displayRecipient ?? 'Unknown';
        final topic = msg.subject.isEmpty ? '' : msg.subject;
        state.channelMessages.putIfAbsent(channel, () => {});
        state.channelMessages[channel]!.putIfAbsent(topic, () => []).add(msg);
      }

      emit(state.copyWith(dmMessages: state.dmMessages, channelMessages: state.channelMessages));
    } catch (e) {
      inspect(e);
    }
  }

  Future<UserEntity> getUserById(int userId) async {
    try {
      return await _getUserByIdUseCase.call(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getChannelById() async {
    try {} catch (e) {
      rethrow;
    }
  }

  void _onMessageEvents(MessageEventEntity event) {
    final message = event.message;
    if (message.type == MessageType.private) {
      final senderFullName = message.senderFullName;
      state.dmMessages.putIfAbsent(senderFullName, () => []).add(message);
    } else {
      state.channelMessages.putIfAbsent(message.displayRecipient ?? 'Unknown', () => {});
      state.channelMessages[message.displayRecipient]!
          .putIfAbsent(message.subject, () => [])
          .add(message);
    }
    emit(state.copyWith(dmMessages: state.dmMessages, channelMessages: state.channelMessages));
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEntity event) {
    if (event.op == UpdateMessageFlagsOp.add && event.flag == MessageFlag.read) {
      for (var eventMessage in event.messages) {
        for (var user in state.dmMessages.keys) {
          state.dmMessages[user]?.removeWhere((msg) => msg.id == eventMessage);
        }
        for (var channelName in state.channelMessages.keys) {
          state.channelMessages[channelName]?.keys.forEach((topic) {
            state.channelMessages[channelName]![topic]?.removeWhere(
              (msg) => msg.id == eventMessage,
            );
          });
        }
      }
    }
    Map<String, List<MessageEntity>> updatedDmMessages = state.dmMessages;
    updatedDmMessages.removeWhere((key, value) => value.isEmpty);
    Map<String, Map<String, List<MessageEntity>>> updatedChannelMessages = state.channelMessages;
    updatedChannelMessages.forEach((key, value) {
      value.removeWhere((key, value) => value.isEmpty);
    });
    updatedChannelMessages.removeWhere((key, value) => value.isEmpty);
    emit(state.copyWith(dmMessages: updatedDmMessages, channelMessages: updatedChannelMessages));
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _messageFlagsSubscription.cancel();
    return super.close();
  }
}
