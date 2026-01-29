part of 'notifications_cubit.dart';

class NotificationsState {
  final UserEntity? user;
  final Set<int> mutedChatsIds;
  final List<UserTopicEntity> userTopics;
  NotificationsState({
    this.user,
    required this.mutedChatsIds,
    required this.userTopics,
  });

  NotificationsState copyWith({
    UserEntity? user,
    Set<int>? mutedChatsIds,
    List<UserTopicEntity>? userTopics,
  }) {
    return NotificationsState(
      user: user ?? this.user,
      mutedChatsIds: mutedChatsIds ?? this.mutedChatsIds,
      userTopics: userTopics ?? this.userTopics,
    );
  }
}
