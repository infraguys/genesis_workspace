part of 'direct_messages_cubit.dart';

class DirectMessagesState {
  bool isUsersPending;
  List<DmUserEntity> users;
  List<MessageEntity> unreadMessages;
  List<int> typingUsers;
  UserEntity? selfUser;

  DirectMessagesState({
    required this.users,
    required this.isUsersPending,
    required this.typingUsers,
    this.selfUser,
    required this.unreadMessages,
  });

  DirectMessagesState copyWith({
    List<DmUserEntity>? users,
    bool? isUsersPending,
    List<int>? typingUsers,
    UserEntity? selfUser,
    List<MessageEntity>? unreadMessages,
  }) {
    return DirectMessagesState(
      users: users ?? this.users,
      isUsersPending: isUsersPending ?? this.isUsersPending,
      typingUsers: typingUsers ?? this.typingUsers,
      selfUser: selfUser ?? this.selfUser,
      unreadMessages: unreadMessages ?? this.unreadMessages,
    );
  }
}
