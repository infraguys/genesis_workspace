part of 'direct_messages_cubit.dart';

class DirectMessagesState {
  bool isUsersPending;
  List<DmUserEntity> users;
  List<int> typingUsers;

  DirectMessagesState({
    required this.users,
    required this.isUsersPending,
    required this.typingUsers,
  });

  DirectMessagesState copyWith({
    List<DmUserEntity>? users,
    bool? isUsersPending,
    List<int>? typingUsers,
  }) {
    return DirectMessagesState(
      users: users ?? this.users,
      isUsersPending: isUsersPending ?? this.isUsersPending,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }
}
