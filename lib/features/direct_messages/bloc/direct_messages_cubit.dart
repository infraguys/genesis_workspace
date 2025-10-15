import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/core/utils/helpers.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/display_recipient.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/presence_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/typing_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/recipient_entity.dart';
import 'package:genesis_workspace/domain/users/entities/dm_user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/group_chat_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/entities/users_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_all_presences_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_users_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'direct_messages_state.dart';

@injectable
class DirectMessagesCubit extends Cubit<DirectMessagesState> {
  final RealTimeService _realTimeService;

  DirectMessagesCubit(
    this._realTimeService,
    this._getAllPresencesUseCase,
    this._getUsersUseCase,
    this._getMessagesUseCase,
  ) : super(
        DirectMessagesState(
          users: [],
          recentDmsUsers: [],
          filteredUsers: [],
          filteredRecentDmsUsers: [],
          isUsersPending: false,
          typingUsers: [],
          selfUser: null,
          unreadMessages: [],
          allMessages: [],
          selectedUserId: null,
          showAllUsers: false,
          groupChats: [],
        ),
      ) {
    _typingEventsSubscription = _realTimeService.typingEventsStream.listen(_onTypingEvents);
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
    _presenceSubscription = _realTimeService.presenceEventsStream.listen(_onPresenceEvents);
    _deleteMessageEventsSubscription = _realTimeService.deleteMessageEventsStream.listen(
      _onDeleteMessageEvents,
    );
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final GetUsersUseCase _getUsersUseCase;
  final GetAllPresencesUseCase _getAllPresencesUseCase;

  late final StreamSubscription<TypingEventEntity> _typingEventsSubscription;
  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsSubscription;
  late final StreamSubscription<PresenceEventEntity> _presenceSubscription;
  late final StreamSubscription<DeleteMessageEventEntity> _deleteMessageEventsSubscription;

  void setSelfUser(UserEntity? user) {
    if (state.selfUser == null) {
      state.selfUser = user;
      emit(state.copyWith(selfUser: state.selfUser));
    }
  }

  void selectUserChat({int? userId, int? unreadMessagesCount}) {
    emit(state.copyWith(selectedUserId: userId, selectedUnreadMessagesCount: unreadMessagesCount));
  }

  Future<void> getUsers() async {
    try {
      final body = UsersRequestEntity();
      final response = await _getUsersUseCase.call(body);
      final List<UserEntity> users = response;
      final mappedUsers = users.map((user) => user.toDmUser()).toList();

      state.users = mappedUsers;
      state.filteredUsers = mappedUsers;

      await Future.wait([getInitialMessages(), getAllPresences()]);
      await getRecentDms();
      _sortUsers();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getAllPresences() async {
    try {
      final response = await _getAllPresencesUseCase.call();
      response.presences.forEach((user, presence) {
        final indexOfUser = state.users.indexWhere((u) => u.email == user);
        if (indexOfUser != -1) {
          state.users[indexOfUser].presenceStatus = presence.aggregated!.status;
          state.users[indexOfUser].presenceTimestamp = presence.aggregated!.timestamp;
        }
      });
    } catch (e) {
      inspect(e);
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      emit(
        state.copyWith(
          filteredUsers: [...state.users],
          filteredRecentDmsUsers: [...state.recentDmsUsers],
        ),
      );
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = state.users.where((user) {
      return user.fullName.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery);
    }).toList();

    final filteredDms = state.recentDmsUsers.where((user) {
      return user.fullName.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery);
    }).toList();

    emit(state.copyWith(filteredUsers: filtered, filteredRecentDmsUsers: filteredDms));
  }

  void _sortUsers() {
    final sortedUsers = [...state.users];
    sortedUsers.sort((user1, user2) {
      // 1️⃣ Сортируем по количеству непрочитанных сообщений (по убыванию)
      final unreadDiff = user2.unreadMessages.length.compareTo(user1.unreadMessages.length);
      if (unreadDiff != 0) return unreadDiff;

      // 2️⃣ Сортируем по статусу: active > idle > остальные
      final isActive1 = user1.presenceStatus == PresenceStatus.active;
      final isActive2 = user2.presenceStatus == PresenceStatus.active;
      if (isActive1 && !isActive2) return -1;
      if (!isActive1 && isActive2) return 1;

      final isIdle1 = user1.presenceStatus == PresenceStatus.idle;
      final isIdle2 = user2.presenceStatus == PresenceStatus.idle;
      if (isIdle1 && !isIdle2) return -1;
      if (!isIdle1 && isIdle2) return 1;

      // 3️⃣ Если все равны — сортируем по имени
      return user1.fullName.compareTo(user2.fullName);
    });

    emit(state.copyWith(users: sortedUsers, filteredUsers: sortedUsers));
  }

  void toggleShowAllUsers() {
    emit(state.copyWith(showAllUsers: !state.showAllUsers));
  }

  Future<void> getRecentDms() async {
    try {
      final List<DmUserEntity> users = state.users;
      final Map<int, DmUserEntity> usersById = {for (final user in users) user.userId: user};

      final List<MessageEntity> allMessages = state.allMessages;
      final int? selfUserId = state.selfUser?.userId;

      final candidateMessages = allMessages.where((message) => message.type == MessageType.private);

      final Map<int, int> lastTimestampBySenderId = {};

      for (final message in candidateMessages) {
        final recipients = message.displayRecipient.recipients;
        final senderId = message.senderId == selfUserId
            ? recipients
                  .firstWhere(
                    (recipient) => recipient.userId != selfUserId,
                    orElse: () => RecipientEntity(userId: -1, email: '', fullName: ''),
                  )
                  .userId
            : message.senderId;
        final int timestamp = message.timestamp;
        final int? current = lastTimestampBySenderId[senderId];
        if (current == null || timestamp > current) {
          lastTimestampBySenderId[senderId] = timestamp;
        }
      }

      final orderedSenderIds = lastTimestampBySenderId.keys.toList()
        ..sort((a, b) {
          final tb = lastTimestampBySenderId[b]!;
          final ta = lastTimestampBySenderId[a]!;
          return tb.compareTo(ta);
        });

      final recentDmsUsers = <DmUserEntity>[
        for (final id in orderedSenderIds)
          if (usersById[id] != null) usersById[id]!,
      ];
      emit(state.copyWith(recentDmsUsers: recentDmsUsers, filteredRecentDmsUsers: recentDmsUsers));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> getInitialMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'dm')],
        numBefore: 1500,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);

      final messages = response.messages;

      final List<GroupChatEntity> groupChats = [];

      for (var message in messages) {
        if (message.isGroupChatMessage) {
          final members = message.displayRecipient.recipients;
          GroupChatEntity groupChat = GroupChatEntity(members: members, unreadMessagesCount: 0);
          if (!groupChats.contains(groupChat)) {
            groupChats.add(groupChat);
          }
        }
      }

      final unreadMessages = response.messages
          .where((message) => message.hasUnreadMessages)
          .toList();
      final users = [...state.users];
      for (var user in users) {
        user.unreadMessages = unreadMessages
            .where(
              (message) =>
                  (message.senderId == user.userId) &&
                  (message.type == MessageType.private) &&
                  message.senderId != state.selfUser?.userId &&
                  message.displayRecipient.recipients.length == 2,
            )
            .map((message) => message.id)
            .toSet();
      }
      emit(
        state.copyWith(
          unreadMessages: unreadMessages,
          users: users,
          allMessages: response.messages,
          groupChats: groupChats,
        ),
      );
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

    final updatedTypingUsers = [...state.typingUsers];

    if (isWriting) {
      updatedTypingUsers.add(senderId);
    } else {
      updatedTypingUsers.remove(senderId);
    }
    emit(state.copyWith(typingUsers: updatedTypingUsers));
  }

  void _onMessageEvents(MessageEventEntity event) {
    final message = event.message;
    if (message.senderId == state.selfUser!.userId) return;
    state.allMessages.add(event.message);

    if (message.displayRecipient.recipients.length == 2) {
      final sender = state.users.firstWhere((user) => user.userId == message.senderId);
      final indexOfSender = state.users.indexOf(sender);
      if (message.hasUnreadMessages && message.type == MessageType.private) {
        sender.unreadMessages.add(message.id);
      }
      state.users[indexOfSender] = sender;
      _sortUsers();
      getRecentDms();
    } else {
      final groupChats = state.groupChats;
      GroupChatEntity? selectedChat;
      for (var chat in groupChats) {
        final List<int> members = chat.members.map((member) => member.userId).toList();
        final List<int> messageRecipients = message.displayRecipient.recipients
            .map((recipient) => recipient.userId)
            .toList();
        if (unorderedEquals<int>(members, messageRecipients)) {
          selectedChat = chat;
          break;
        }
      }
      if (selectedChat != null) {
        groupChats.remove(selectedChat);
        groupChats.add(
          selectedChat.copyWith(unreadMessagesCount: selectedChat.unreadMessagesCount + 1),
        );
        emit(state.copyWith(groupChats: groupChats));
      }
    }
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    if (event.op == UpdateMessageFlagsOp.add && event.flag == MessageFlag.read) {
      final users = state.users.map((user) {
        user.unreadMessages.removeAll(event.messages);
        return user;
      }).toList();
      state.users = users;
      _sortUsers();
    }
  }

  void _onPresenceEvents(PresenceEventEntity event) {
    final user = state.users.firstWhere((user) => user.userId == event.userId);
    final indexOf = state.users.indexOf(user);
    if (event.presenceEntity.website != null) {
      user.presenceStatus = event.presenceEntity.website!.status;
      user.presenceTimestamp = event.presenceEntity.website!.timestamp;
    } else if (event.presenceEntity.aggregated != null) {
      user.presenceStatus = event.presenceEntity.aggregated!.status;
      user.presenceTimestamp = event.presenceEntity.aggregated!.timestamp;
    }
    final updatedUsers = [...state.users];
    updatedUsers[indexOf] = user;
    emit(state.copyWith(users: updatedUsers));
    _sortUsers();
  }

  void _onDeleteMessageEvents(DeleteMessageEventEntity event) {
    final updatedMessages = [...state.allMessages];
    updatedMessages.removeWhere((message) => message.id == event.messageId);
    final updatedUnreadMessages = [...state.unreadMessages];
    updatedUnreadMessages.removeWhere((message) => message.id == event.messageId);
    emit(state.copyWith(allMessages: updatedMessages, unreadMessages: updatedUnreadMessages));
    final users = state.users.map((user) {
      user.unreadMessages.remove(event.messageId);
      return user;
    }).toList();
    state.users = users;
    _sortUsers();
  }

  @override
  Future<void> close() {
    _typingEventsSubscription.cancel();
    _messagesEventsSubscription.cancel();
    _messageFlagsSubscription.cancel();
    _presenceSubscription.cancel();
    _deleteMessageEventsSubscription.cancel();
    return super.close();
  }
}
