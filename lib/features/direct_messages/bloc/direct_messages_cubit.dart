import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_entity.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';

part 'direct_messages_state.dart';

class DirectMessagesCubit extends Cubit<DirectMessagesState> {
  final _realTimeService = getIt<RealTimeService>();

  DirectMessagesCubit()
    : super(
        DirectMessagesState(
          users: [],
          isUsersPending: false,
          typingUsers: [],
          selfUser: null,
          unreadMessages: [],
        ),
      ) {
    _typingEventsSubscription = _realTimeService.typingEventsStream.listen(_onTypingEvents);
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
  }

  final _getMessagesUseCase = getIt<GetMessagesUseCase>();
  final GetUsersUseCase _getUsersUseCase = getIt<GetUsersUseCase>();

  late final StreamSubscription<TypingEventEntity> _typingEventsSubscription;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEntity> _messageFlagsSubscription;

  setSelfUser(UserEntity? user) {
    if (state.selfUser == null) {
      state.selfUser = user;
      emit(state.copyWith(selfUser: state.selfUser));
    }
  }

  Future<void> getUsers() async {
    try {
      final response = await _getUsersUseCase.call();
      await getUnreadMessages();

      final List<UserEntity> users = response;
      state.users = users.map((user) => user.toDmUser()).toList();
      emit(state.copyWith(users: state.users));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getUnreadMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'unread')],
        numBefore: 5000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      state.unreadMessages = response.messages;
      for (var user in state.users) {
        user.unreadMessages = state.unreadMessages
            .where(
              (message) =>
                  (message.senderId == user.userId) &&
                  (message.type == MessageType.private) &&
                  message.senderId != state.selfUser?.userId,
            )
            .map((message) => message.id)
            .toSet();
      }
      emit(state.copyWith(unreadMessages: state.unreadMessages));
    } catch (e) {
      inspect(e);
    }
  }

  void _onTypingEvents(TypingEventEntity event) {
    final isWriting = event.op == TypingEventOp.start;
    final senderId = event.sender.userId;

    if (senderId == state.selfUser?.userId) {
      return;
    }

    if (isWriting) {
      state.typingUsers.add(senderId);
    } else {
      state.typingUsers.remove(senderId);
    }
    emit(state.copyWith(typingUsers: state.typingUsers));
  }

  void _onMessageEvents(MessageEventEntity event) {
    final message = event.message;

    if (message.senderId != state.selfUser!.userId) {
      final sender = state.users.firstWhere((user) => user.userId == message.senderId);
      final indexOfSender = state.users.indexOf(sender);
      if (message.hasUnreadMessages && message.type == MessageType.private) {
        sender.unreadMessages.add(message.id);
      }
      state.users[indexOfSender] = sender;
      emit(state.copyWith(users: state.users));
    }
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEntity event) {
    if (event.op == UpdateMessageFlagsOp.add && event.flag == MessageFlag.read) {
      final users = state.users.map((user) {
        user.unreadMessages.removeAll(event.messages);
        return user;
      }).toList();
      emit(state.copyWith(users: users));
    }
  }

  @override
  Future<void> close() {
    _typingEventsSubscription.cancel();
    _messagesEventsSubscription.cancel();
    _messageFlagsSubscription.cancel();
    return super.close();
  }
}
