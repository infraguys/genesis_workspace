part of 'direct_messages_cubit.dart';

class DirectMessagesState {
  bool isUsersPending;
  List<DmUserEntity> users;
  List<DmUserEntity> recentDmsUsers;
  List<DmUserEntity> filteredUsers;
  List<MessageEntity> unreadMessages;
  List<MessageEntity> allMessages;
  List<int> typingUsers;
  UserEntity? selfUser;
  int? selectedUserId;
  int? selectedUnreadMessagesCount;
  bool showAllUsers;

  DirectMessagesState({
    required this.users,
    required this.recentDmsUsers,
    required this.filteredUsers,
    required this.isUsersPending,
    required this.typingUsers,
    this.selfUser,
    required this.unreadMessages,
    required this.allMessages,
    this.selectedUserId,
    this.selectedUnreadMessagesCount,
    required this.showAllUsers,
  });

  DirectMessagesState copyWith({
    List<DmUserEntity>? users,
    List<DmUserEntity>? recentDmsUsers,
    List<DmUserEntity>? filteredUsers,
    bool? isUsersPending,
    List<int>? typingUsers,
    UserEntity? selfUser,
    List<MessageEntity>? unreadMessages,
    List<MessageEntity>? allMessages,
    int? selectedUserId,
    int? selectedUnreadMessagesCount,
    bool? showAllUsers,
  }) {
    return DirectMessagesState(
      users: users ?? this.users,
      recentDmsUsers: recentDmsUsers ?? this.recentDmsUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      isUsersPending: isUsersPending ?? this.isUsersPending,
      typingUsers: typingUsers ?? this.typingUsers,
      selfUser: selfUser ?? this.selfUser,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      allMessages: allMessages ?? this.allMessages,
      selectedUserId: selectedUserId ?? this.selectedUserId,
      selectedUnreadMessagesCount: selectedUnreadMessagesCount ?? this.selectedUnreadMessagesCount,
      showAllUsers: showAllUsers ?? this.showAllUsers,
    );
  }
}
