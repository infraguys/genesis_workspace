part of 'direct_messages_cubit.dart';

class DirectMessagesState {
  bool isUsersPending;
  List<DmUserEntity> users;
  List<DmUserEntity> filteredUsers;
  List<MessageEntity> unreadMessages;
  List<int> typingUsers;
  UserEntity? selfUser;
  DmUserEntity? selectedUser;

  DirectMessagesState({
    required this.users,
    required this.filteredUsers,
    required this.isUsersPending,
    required this.typingUsers,
    this.selfUser,
    required this.unreadMessages,
    this.selectedUser,
  });

  DirectMessagesState copyWith({
    List<DmUserEntity>? users,
    List<DmUserEntity>? filteredUsers,
    bool? isUsersPending,
    List<int>? typingUsers,
    UserEntity? selfUser,
    List<MessageEntity>? unreadMessages,
    DmUserEntity? selectedUser,
  }) {
    return DirectMessagesState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      isUsersPending: isUsersPending ?? this.isUsersPending,
      typingUsers: typingUsers ?? this.typingUsers,
      selfUser: selfUser ?? this.selfUser,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      selectedUser: selectedUser ?? this.selectedUser,
    );
  }
}
