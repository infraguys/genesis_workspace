import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_response_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/get_events_by_queue_id_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/usecases/register_queue_use_case.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';

part 'direct_messages_state.dart';

class DirectMessagesCubit extends Cubit<DirectMessagesState> {
  final _realTimeService = getIt<RealTimeService>();

  DirectMessagesCubit()
    : super(DirectMessagesState(users: [], isUsersPending: false, typingUsers: [])) {
    _typingEventsSubscription = _realTimeService.typingEventsStream.listen(_onTypingEvents);
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
  }

  final RegisterQueueUseCase _registerQueue = getIt<RegisterQueueUseCase>();
  final GetEventsByQueueIdUseCase _getEvents = getIt<GetEventsByQueueIdUseCase>();
  final _getMessagesUseCase = getIt<GetMessagesUseCase>();

  final GetUsersUseCase _getUsersUseCase = getIt<GetUsersUseCase>();

  late final StreamSubscription<TypingEventEntity> _typingEventsSubscription;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEntity> _messageFlagsSubscription;

  void _onTypingEvents(TypingEventEntity event) {
    final isWriting = event.op == TypingEventOp.start;
    final senderId = event.sender.userId;

    if (isWriting) {
      state.typingUsers.add(senderId);
    } else {
      state.typingUsers.remove(senderId);
    }
    emit(state.copyWith(typingUsers: state.typingUsers));
  }

  Future<void> getUsers() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        numBefore: 1000,
        numAfter: 0,
      );
      final responses = await Future.wait([
        _getUsersUseCase.call(),
        _getMessagesUseCase.call(messagesBody),
      ]);

      final List<UserEntity> users = responses[0] as List<UserEntity>;
      final MessagesResponseEntity messages = responses[1] as MessagesResponseEntity;

      List<MessageEntity> unreadMessages = messages.messages.where((message) {
        if (message.flags != null) {
          return !message.flags!.contains('read');
        } else {
          return true;
        }
      }).toList();

      state.users = users.map((user) => user.toDmUser()).toList();
      for (var user in state.users) {
        user.unreadMessages = unreadMessages
            .where(
              (message) =>
                  (message.senderId == user.userId) && (message.type == MessageType.private),
            )
            .map((message) => message.id)
            .toSet();
      }
      emit(state.copyWith(users: state.users));
    } catch (e) {
      inspect(e);
    }
  }

  void _onMessageEvents(MessageEventEntity event) {
    final message = event.message;
    final sender = state.users.firstWhere((user) => user.userId == message.senderId);
    final indexOfSender = state.users.indexOf(sender);
    if (message.flags == null || !message.flags!.contains('read')) {
      sender.unreadMessages.add(message.id);
    }
    state.users[indexOfSender] = sender;
    emit(state.copyWith(users: state.users));
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
}
