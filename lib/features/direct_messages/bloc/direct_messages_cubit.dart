import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/core/enums/presence_status.dart';
import 'package:genesis_workspace/core/enums/typing_event_op.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/core/utils/group_chat_utils.dart';
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
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_event_entity.dart';
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
          createGroupChatOpened: false,
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
    _updateMessageEventsSubscription = _realTimeService.updateMessageEventsStream.listen(
      _onUpdateMessageEvents,
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
  late final StreamSubscription<UpdateMessageEventEntity> _updateMessageEventsSubscription;

  List<GroupChatEntity> _buildGroupChatsFromMessages(Iterable<MessageEntity> messages) {
    final Map<String, GroupChatEntity> aggregated = {};
    for (final message in messages) {
      if (!message.isGroupChatMessage) continue;
      final recipients = (message.displayRecipient as DirectMessageRecipients).recipients;
      final key = GroupChatUtils.buildMembershipKeyFromRecipients(recipients);
      final current = aggregated[key];

      final unreadIncrement = message.isUnread ? 1 : 0;
      if (current == null) {
        final members = recipients.toList()..sort((a, b) => a.fullName.compareTo(b.fullName));
        aggregated[key] = GroupChatEntity(
          id: GroupChatUtils.computeGroupIdFromRecipients(recipients),
          members: members,
          unreadMessagesCount: unreadIncrement,
        );
      } else {
        aggregated[key] = current.copyWith(
          unreadMessagesCount: current.unreadMessagesCount + unreadIncrement,
        );
      }
    }

    final groups = aggregated.values.toList()
      ..sort((a, b) {
        final unreadDiff = b.unreadMessagesCount.compareTo(a.unreadMessagesCount);
        if (unreadDiff != 0) return unreadDiff;

        final nameA = a.members.map((member) => member.fullName).join(', ');
        final nameB = b.members.map((member) => member.fullName).join(', ');
        return nameA.compareTo(nameB);
      });

    return groups;
  }

  List<DmUserEntity> _mapUnreadToUsers({
    required List<DmUserEntity> users,
    required Iterable<MessageEntity> allMessages,
  }) {
    final Map<int, Set<int>> unreadByUserId = {};
    final int? selfUserId = state.selfUser?.userId;

    for (final message in allMessages) {
      if (!message.isUnread) continue;
      if (message.type != MessageType.private) continue;

      final recipients = message.displayRecipient.recipients;
      if (recipients.length != 2) continue;
      if (message.senderId == selfUserId) continue;

      unreadByUserId.putIfAbsent(message.senderId, () => <int>{}).add(message.id);
    }

    return users.map((user) {
      final unread = unreadByUserId[user.userId] ?? const <int>{};
      user.unreadMessages = Set<int>.from(unread);
      return user;
    }).toList();
  }

  void setCreateGroupChatOpened(bool opened) {
    if (opened == false) {
      searchUsers('');
    }
    emit(state.copyWith(createGroupChatOpened: opened));
  }

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
      final unreadMessages = messages.where((message) => message.isUnread).toList();
      final groupChats = _buildGroupChatsFromMessages(messages);
      final users = _mapUnreadToUsers(users: [...state.users], allMessages: messages);
      emit(
        state.copyWith(
          unreadMessages: unreadMessages,
          users: users,
          allMessages: messages,
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
    final message = event.message.copyWith(flags: event.flags);
    final bool isSelfMessage = message.senderId == state.selfUser?.userId;
    final updatedAllMessages = [...state.allMessages, message];
    final updatedUnreadMessages = [...state.unreadMessages];

    if (!isSelfMessage && message.isUnread) {
      updatedUnreadMessages.add(message);
    }

    if (message.displayRecipient.recipients.length == 2) {
      final users = [...state.users];
      if (!isSelfMessage && message.type == MessageType.private) {
        final senderIndex = users.indexWhere((user) => user.userId == message.senderId);
        if (senderIndex != -1) {
          users[senderIndex].unreadMessages.add(message.id);
        }
      }

      emit(
        state.copyWith(
          users: users,
          allMessages: updatedAllMessages,
          unreadMessages: updatedUnreadMessages,
        ),
      );
      _sortUsers();
      unawaited(getRecentDms());
    } else {
      final updatedGroupChats = _buildGroupChatsFromMessages(updatedAllMessages);
      emit(
        state.copyWith(
          allMessages: updatedAllMessages,
          unreadMessages: updatedUnreadMessages,
          groupChats: updatedGroupChats,
        ),
      );
    }
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    if (event.flag != MessageFlag.read) return;

    final Set<int> affectedIds = event.all
        ? state.allMessages.map((message) => message.id).toSet()
        : event.messages.toSet();

    if (affectedIds.isEmpty) return;

    final updatedAllMessages = state.allMessages.map((message) {
      if (!affectedIds.contains(message.id)) return message;
      final List<String> updatedFlags = List<String>.from(message.flags ?? const <String>[]);
      final flagName = event.flag.name;

      if (event.op == UpdateMessageFlagsOp.add) {
        if (!updatedFlags.contains(flagName)) {
          updatedFlags.add(flagName);
        }
      } else {
        updatedFlags.remove(flagName);
      }

      return message.copyWith(flags: updatedFlags);
    }).toList();

    final updatedUnreadMessages = updatedAllMessages.where((message) => message.isUnread).toList();
    final updatedUsers = _mapUnreadToUsers(
      users: [...state.users],
      allMessages: updatedAllMessages,
    );
    final updatedGroupChats = _buildGroupChatsFromMessages(updatedAllMessages);

    emit(
      state.copyWith(
        users: updatedUsers,
        unreadMessages: updatedUnreadMessages,
        allMessages: updatedAllMessages,
        groupChats: updatedGroupChats,
      ),
    );
    _sortUsers();
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
    final updatedMessages = state.allMessages
        .where((message) => message.id != event.messageId)
        .toList();
    final updatedUnreadMessages = updatedMessages.where((message) => message.isUnread).toList();
    final updatedUsers = _mapUnreadToUsers(users: [...state.users], allMessages: updatedMessages);
    final updatedGroupChats = _buildGroupChatsFromMessages(updatedMessages);

    emit(
      state.copyWith(
        allMessages: updatedMessages,
        unreadMessages: updatedUnreadMessages,
        users: updatedUsers,
        groupChats: updatedGroupChats,
      ),
    );
    _sortUsers();
  }

  void _onUpdateMessageEvents(UpdateMessageEventEntity event) {
    bool hasChanges = false;
    final updatedAllMessages = state.allMessages.map((message) {
      if (message.id != event.messageId) return message;
      hasChanges = true;
      return message.copyWith(content: event.content);
    }).toList();
    if (!hasChanges) return;
    final updatedUnreadMessages = updatedAllMessages.where((message) => message.isUnread).toList();
    final updatedGroupChats = _buildGroupChatsFromMessages(updatedAllMessages);

    emit(
      state.copyWith(
        allMessages: updatedAllMessages,
        unreadMessages: updatedUnreadMessages,
        groupChats: updatedGroupChats,
      ),
    );
  }

  @override
  Future<void> close() {
    _typingEventsSubscription.cancel();
    _messagesEventsSubscription.cancel();
    _messageFlagsSubscription.cancel();
    _presenceSubscription.cancel();
    _deleteMessageEventsSubscription.cancel();
    _updateMessageEventsSubscription.cancel();
    return super.close();
  }
}
